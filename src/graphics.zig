const builtin = @import("builtin");
const std = @import("std");
const assert = std.debug.assert;
const os = @import("windows.zig");
const dxgi = @import("dxgi.zig");
const d3d12 = @import("d3d12.zig");

const num_frames = 2;
const num_swapbuffers = 4;
const num_rtv_descriptors = 128;
const num_dsv_descriptors = 128;
const num_cbv_srv_uav_cpu_descriptors = 16 * 1024;
const num_cbv_srv_uav_gpu_descriptors = 4 * 1024;

const max_num_resources = 256;
const max_num_pipelines = 128;

const upload_heaps_capacity = 8 * 1024 * 1024;

pub inline fn vhr(hr: os.HRESULT) void {
    if (hr != 0) {
        std.debug.panic("D3D12 function failed.", .{});
    }
}

pub inline fn releaseCom(obj: anytype) void {
    comptime assert(@hasDecl(@TypeOf(obj.*.*), "Release"));
    _ = obj.*.Release();
    obj.* = undefined;
}

pub const DxContext = struct {
    device: *d3d12.IDevice,
    cmdlist: *d3d12.IGraphicsCommandList,
    cmdqueue: *d3d12.ICommandQueue,
    cmdallocs: [num_frames]*d3d12.ICommandAllocator,
    swapchain: *dxgi.ISwapChain3,
    swapbuffers: [num_swapbuffers]ResourceHandle,
    rtv_heap: DescriptorHeap,
    dsv_heap: DescriptorHeap,
    cbv_srv_uav_cpu_heap: DescriptorHeap,
    cbv_srv_uav_gpu_heaps: [num_frames]DescriptorHeap,
    upload_memory_heaps: [num_frames]GpuMemoryHeap,
    frame_fence: *d3d12.IFence,
    frame_fence_event: os.HANDLE,
    frame_fence_counter: u64 = 0,
    frame_index: u32 = 0,
    back_buffer_index: u32 = 0,
    resource_pool: ResourcePool,
    pipeline: struct {
        pool: PipelinePool,
        map: std.AutoHashMap(u32, PipelineHandle),
        current: PipelineHandle,
    },
    num_resource_barriers: u32 = 0,
    buffered_resource_barriers: []d3d12.RESOURCE_BARRIER,
    viewport_width: u32,
    viewport_height: u32,
    window: os.HWND,

    pub fn init(window: os.HWND) DxContext {
        dxgi.init();
        d3d12.init();

        var rect: os.RECT = undefined;
        _ = os.GetClientRect(window, &rect);
        const viewport_width = @intCast(u32, rect.right);
        const viewport_height = @intCast(u32, rect.bottom);

        var factory: *dxgi.IFactory4 = undefined;
        vhr(dxgi.CreateFactory2(
            dxgi.CREATE_FACTORY_DEBUG,
            &dxgi.IID_IFactory4,
            @ptrCast(**c_void, &factory),
        ));

        if (comptime builtin.mode == .Debug) {
            var debug: *d3d12.IDebug1 = undefined;
            if (d3d12.GetDebugInterface(&d3d12.IID_IDebug1, @ptrCast(**c_void, &debug)) == 0) {
                debug.EnableDebugLayer();
                debug.SetEnableGPUBasedValidation(os.TRUE);
                releaseCom(&debug);
            }
        }

        var device: *d3d12.IDevice = undefined;
        vhr(d3d12.CreateDevice(
            null,
            d3d12.FEATURE_LEVEL._11_1,
            &d3d12.IID_IDevice,
            @ptrCast(**c_void, &device),
        ));

        var cmdqueue: *d3d12.ICommandQueue = undefined;
        vhr(device.CreateCommandQueue(
            &d3d12.COMMAND_QUEUE_DESC{
                .Type = .DIRECT,
                .Priority = @enumToInt(d3d12.COMMAND_QUEUE_PRIORITY.NORMAL),
                .Flags = .NONE,
                .NodeMask = 0,
            },
            &d3d12.IID_ICommandQueue,
            @ptrCast(**c_void, &cmdqueue),
        ));

        var temp_swapchain: *os.IUnknown = undefined;
        vhr(factory.CreateSwapChain(
            @ptrCast(*os.IUnknown, cmdqueue),
            &dxgi.SWAP_CHAIN_DESC{
                .BufferDesc = dxgi.MODE_DESC{
                    .Width = viewport_width,
                    .Height = viewport_height,
                    .RefreshRate = dxgi.RATIONAL{
                        .Numerator = 0,
                        .Denominator = 0,
                    },
                    .Format = .R8G8B8A8_UNORM,
                    .ScanlineOrdering = .UNSPECIFIED,
                    .Scaling = .UNSPECIFIED,
                },
                .SampleDesc = dxgi.SAMPLE_DESC{
                    .Count = 1,
                    .Quality = 0,
                },
                .BufferUsage = dxgi.USAGE_RENDER_TARGET_OUTPUT,
                .BufferCount = num_swapbuffers,
                .OutputWindow = window,
                .Windowed = os.TRUE,
                .SwapEffect = .FLIP_DISCARD,
                .Flags = 0,
            },
            &temp_swapchain,
        ));
        var swapchain: *dxgi.ISwapChain3 = undefined;
        vhr(temp_swapchain.QueryInterface(&dxgi.IID_ISwapChain3, @ptrCast(**c_void, &swapchain)));
        releaseCom(&temp_swapchain);
        releaseCom(&factory);

        var frame_fence: *d3d12.IFence = undefined;
        vhr(device.CreateFence(0, .NONE, &d3d12.IID_IFence, @ptrCast(**c_void, &frame_fence)));
        const frame_fence_event = os.CreateEventEx(
            null,
            "frame_fence_event",
            0,
            os.EVENT_ALL_ACCESS,
        ) catch unreachable;

        var cmdallocs: [num_frames]*d3d12.ICommandAllocator = undefined;
        for (cmdallocs) |*cmdalloc| {
            vhr(device.CreateCommandAllocator(
                .DIRECT,
                &d3d12.IID_ICommandAllocator,
                @ptrCast(**c_void, &cmdalloc.*),
            ));
        }

        var rtv_heap = DescriptorHeap.init(device, num_rtv_descriptors, .RTV, .NONE);
        var dsv_heap = DescriptorHeap.init(device, num_dsv_descriptors, .DSV, .NONE);
        var cbv_srv_uav_cpu_heap = DescriptorHeap.init(
            device,
            num_cbv_srv_uav_cpu_descriptors,
            .CBV_SRV_UAV,
            .NONE,
        );
        var cbv_srv_uav_gpu_heaps: [num_frames]DescriptorHeap = undefined;
        for (cbv_srv_uav_gpu_heaps) |*heap| {
            heap.* = DescriptorHeap.init(
                device,
                num_cbv_srv_uav_gpu_descriptors,
                .CBV_SRV_UAV,
                .SHADER_VISIBLE,
            );
        }
        var upload_memory_heaps: [num_frames]GpuMemoryHeap = undefined;
        for (upload_memory_heaps) |*heap| {
            heap.* = GpuMemoryHeap.init(device, upload_heaps_capacity, .UPLOAD);
        }

        var resource_pool = ResourcePool.init();
        var pipeline_pool = PipelinePool.init();

        // First 'num_swapbuffers' slots in 'rtv_heap' contain swapbuffer descriptors.
        var swapbuffers: [num_swapbuffers]ResourceHandle = undefined;
        {
            var handle = rtv_heap.allocateDescriptors(num_swapbuffers).cpu_handle;

            for (swapbuffers) |*swapbuffer, i| {
                var buffer: *d3d12.IResource = undefined;
                vhr(swapchain.GetBuffer(
                    @intCast(u32, i),
                    &d3d12.IID_IResource,
                    @ptrCast(**c_void, &buffer),
                ));
                swapbuffer.* = resource_pool.addResource(buffer, .{}, .R8G8B8A8_UNORM);
                device.CreateRenderTargetView(buffer, null, handle);
                handle.ptr += rtv_heap.descriptor_size;
            }
        }

        var cmdlist: *d3d12.IGraphicsCommandList = undefined;
        vhr(device.CreateCommandList(
            0,
            .DIRECT,
            cmdallocs[0],
            null,
            &d3d12.IID_IGraphicsCommandList,
            @ptrCast(**c_void, &cmdlist),
        ));
        vhr(cmdlist.Close());

        return DxContext{
            .device = device,
            .cmdlist = cmdlist,
            .cmdqueue = cmdqueue,
            .cmdallocs = cmdallocs,
            .swapchain = swapchain,
            .swapbuffers = swapbuffers,
            .rtv_heap = rtv_heap,
            .dsv_heap = dsv_heap,
            .cbv_srv_uav_cpu_heap = cbv_srv_uav_cpu_heap,
            .cbv_srv_uav_gpu_heaps = cbv_srv_uav_gpu_heaps,
            .upload_memory_heaps = upload_memory_heaps,
            .frame_fence = frame_fence,
            .frame_fence_event = frame_fence_event,
            .resource_pool = resource_pool,
            .pipeline = .{
                .pool = pipeline_pool,
                // TODO: Use gpa?
                .map = std.AutoHashMap(u32, PipelineHandle).init(std.heap.page_allocator),
                .current = PipelineHandle{ .index = 0, .generation = 0 },
            },
            .buffered_resource_barriers = std.heap.page_allocator.alloc( // TODO: Use gpa?
                d3d12.RESOURCE_BARRIER,
                32,
            ) catch unreachable,
            .viewport_width = viewport_width,
            .viewport_height = viewport_height,
            .window = window,
        };
    }

    pub fn deinit(dx: *DxContext) void {
        waitForGpu(dx);
        dx.resource_pool.deinit();
        dx.pipeline.pool.deinit();
        assert(dx.pipeline.map.count() == 0);
        dx.pipeline.map.deinit();
        releaseCom(&dx.rtv_heap.heap);
        releaseCom(&dx.dsv_heap.heap);
        releaseCom(&dx.cbv_srv_uav_cpu_heap.heap);
        for (dx.cbv_srv_uav_gpu_heaps) |*heap| {
            releaseCom(&heap.*.heap);
        }
        for (dx.upload_memory_heaps) |*heap| {
            releaseCom(&heap.*.heap);
        }
        for (dx.cmdallocs) |*cmdalloc| {
            releaseCom(&cmdalloc.*);
        }
        os.CloseHandle(dx.frame_fence_event);
        releaseCom(&dx.cmdqueue);
        releaseCom(&dx.cmdlist);
        releaseCom(&dx.frame_fence);
        releaseCom(&dx.swapchain);
        releaseCom(&dx.device);
        dx.* = undefined;
    }

    pub fn beginFrame(dx: *DxContext) void {
        const cmdalloc = dx.cmdallocs[dx.frame_index];
        vhr(cmdalloc.Reset());
        vhr(dx.cmdlist.Reset(cmdalloc, null));
        dx.cmdlist.SetDescriptorHeaps(1, &dx.cbv_srv_uav_gpu_heaps[dx.frame_index].heap);
        dx.cmdlist.RSSetViewports(1, &d3d12.VIEWPORT{
            .TopLeftX = 0.0,
            .TopLeftY = 0.0,
            .Width = @intToFloat(f32, dx.viewport_width),
            .Height = @intToFloat(f32, dx.viewport_height),
            .MinDepth = 0.0,
            .MaxDepth = 1.0,
        });
        dx.cmdlist.RSSetScissorRects(1, &d3d12.RECT{
            .left = 0,
            .top = 0,
            .right = @intCast(c_long, dx.viewport_width),
            .bottom = @intCast(c_long, dx.viewport_height),
        });
        dx.pipeline.current = .{ .index = 0, .generation = 0 };
    }

    pub fn endFrame(dx: *DxContext) void {
        dx.closeAndExecuteCommandList();

        dx.frame_fence_counter += 1;
        vhr(dx.swapchain.Present(0, 0));
        vhr(dx.cmdqueue.Signal(dx.frame_fence, dx.frame_fence_counter));

        const gpu_frame_counter = dx.frame_fence.GetCompletedValue();
        if ((dx.frame_fence_counter - gpu_frame_counter) >= num_frames) {
            vhr(dx.frame_fence.SetEventOnCompletion(gpu_frame_counter + 1, dx.frame_fence_event));
            os.WaitForSingleObject(dx.frame_fence_event, os.INFINITE) catch unreachable;
        }

        dx.frame_index = (dx.frame_index + 1) % num_frames;
        dx.back_buffer_index = dx.swapchain.GetCurrentBackBufferIndex();

        dx.cbv_srv_uav_gpu_heaps[dx.frame_index].size = 0;
        dx.upload_memory_heaps[dx.frame_index].size = 0;
    }

    pub fn waitForGpu(dx: *DxContext) void {
        dx.frame_fence_counter += 1;

        vhr(dx.cmdqueue.Signal(dx.frame_fence, dx.frame_fence_counter));
        vhr(dx.frame_fence.SetEventOnCompletion(dx.frame_fence_counter, dx.frame_fence_event));
        os.WaitForSingleObject(dx.frame_fence_event, os.INFINITE) catch unreachable;

        dx.cbv_srv_uav_gpu_heaps[dx.frame_index].size = 0;
        dx.upload_memory_heaps[dx.frame_index].size = 0;
    }

    pub fn allocateCpuDescriptors(
        dx: *DxContext,
        heap_type: d3d12.DESCRIPTOR_HEAP_TYPE,
        num_descriptors: u32,
    ) d3d12.CPU_DESCRIPTOR_HANDLE {
        return switch (heap_type) {
            .CBV_SRV_UAV => dx.cbv_srv_uav_cpu_heap.allocateDescriptors(num_descriptors).cpu_handle,
            .SAMPLER => unreachable,
            .RTV => dx.rtv_heap.allocateDescriptors(num_descriptors).cpu_handle,
            .DSV => dx.dsv_heap.allocateDescriptors(num_descriptors).cpu_handle,
        };
    }

    pub fn allocateGpuDescriptors(dx: *DxContext, num_descriptors: u32) Descriptor {
        return dx.cbv_srv_uav_gpu_heaps[dx.frame_index].allocateDescriptors(num_descriptors);
    }

    pub fn getResource(dx: DxContext, handle: ResourceHandle) *d3d12.IResource {
        return dx.resource_pool.getResource(handle).*.raw.?;
    }

    pub fn getBackBuffer(dx: DxContext) struct {
        resource_handle: ResourceHandle,
        cpu_handle: d3d12.CPU_DESCRIPTOR_HANDLE,
    } {
        return .{
            .resource_handle = dx.swapbuffers[dx.back_buffer_index],
            .cpu_handle = d3d12.CPU_DESCRIPTOR_HANDLE{
                .ptr = dx.rtv_heap.cpu_start.ptr + dx.back_buffer_index * dx.rtv_heap.descriptor_size,
            },
        };
    }

    pub fn addTransitionBarrier(
        dx: *DxContext,
        handle: ResourceHandle,
        state_after: d3d12.RESOURCE_STATES,
    ) void {
        var resource = dx.resource_pool.getResource(handle);

        if (@bitCast(u32, state_after) != @bitCast(u32, resource.state)) {
            if (dx.num_resource_barriers >= dx.buffered_resource_barriers.len) {
                flushResourceBarriers(dx);
            }
            dx.buffered_resource_barriers[dx.num_resource_barriers] = d3d12.RESOURCE_BARRIER{
                .Type = .TRANSITION,
                .Flags = .NONE,
                .u = .{
                    .Transition = d3d12.RESOURCE_TRANSITION_BARRIER{
                        .pResource = resource.raw.?,
                        .Subresource = d3d12.RESOURCE_BARRIER_ALL_SUBRESOURCES,
                        .StateBefore = resource.state,
                        .StateAfter = state_after,
                    },
                },
            };
            dx.num_resource_barriers += 1;
            resource.state = state_after;
        }
    }

    pub fn flushResourceBarriers(dx: *DxContext) void {
        if (dx.num_resource_barriers > 0) {
            dx.cmdlist.ResourceBarrier(dx.num_resource_barriers, dx.buffered_resource_barriers.ptr);
            dx.num_resource_barriers = 0;
        }
    }

    pub fn setPipelineState(dx: *DxContext, pipeline_handle: PipelineHandle) void {
        // TODO: Do we need to unset pipeline state (null, null)?
        const pipeline = dx.pipeline.pool.getPipeline(pipeline_handle);

        if (pipeline_handle.index == dx.pipeline.current.index and
            pipeline_handle.generation == dx.pipeline.current.generation)
        {
            return;
        }

        dx.cmdlist.SetPipelineState(pipeline.pso.?);
        switch (pipeline.ptype.?) {
            .Graphics => dx.cmdlist.SetGraphicsRootSignature(pipeline.root_signature.?),
            .Compute => dx.cmdlist.SetComputeRootSignature(pipeline.root_signature.?),
        }

        dx.pipeline.current = pipeline_handle;
    }

    pub fn createCommittedResource(
        dx: *DxContext,
        heap_type: d3d12.HEAP_TYPE,
        heap_flags: d3d12.HEAP_FLAGS,
        desc: *const d3d12.RESOURCE_DESC,
        initial_state: d3d12.RESOURCE_STATES,
        clear_value: ?*const d3d12.CLEAR_VALUE,
    ) ResourceHandle {
        var raw: *d3d12.IResource = undefined;
        vhr(dx.device.CreateCommittedResource(
            &d3d12.HEAP_PROPERTIES{ .Type = heap_type },
            heap_flags,
            desc,
            initial_state,
            clear_value,
            &d3d12.IID_IResource,
            @ptrCast(**c_void, &raw),
        ));
        return dx.resource_pool.addResource(raw, initial_state, desc.Format);
    }

    pub fn addResourceRef(dx: DxContext, handle: ResourceHandle) u32 {
        const resource = dx.resource_pool.getResource(handle);
        return resource.raw.?.AddRef();
    }

    pub fn releaseResource(dx: DxContext, handle: ResourceHandle) u32 {
        var resource = dx.resource_pool.getResource(handle);

        const refcount = resource.raw.?.Release();
        if (refcount == 0) {
            resource.* = Resource{ .raw = null, .state = .{}, .format = .UNKNOWN };
        }

        return refcount;
    }

    pub fn createGraphicsPipeline(
        dx: *DxContext,
        pso_desc: d3d12.GRAPHICS_PIPELINE_STATE_DESC,
    ) PipelineHandle {
        const hash = compute_hash: {
            var hasher = std.hash.Adler32.init();
            hasher.update(
                @ptrCast([*]const u8, pso_desc.VS.pShaderBytecode.?)[0..pso_desc.VS.BytecodeLength],
            );
            hasher.update(
                @ptrCast([*]const u8, pso_desc.PS.pShaderBytecode.?)[0..pso_desc.PS.BytecodeLength],
            );
            hasher.update(std.mem.asBytes(&pso_desc.BlendState));
            hasher.update(std.mem.asBytes(&pso_desc.SampleMask));
            hasher.update(std.mem.asBytes(&pso_desc.RasterizerState));
            hasher.update(std.mem.asBytes(&pso_desc.DepthStencilState));
            hasher.update(std.mem.asBytes(&pso_desc.IBStripCutValue));
            hasher.update(std.mem.asBytes(&pso_desc.PrimitiveTopologyType));
            hasher.update(std.mem.asBytes(&pso_desc.NumRenderTargets));
            hasher.update(std.mem.asBytes(&pso_desc.RTVFormats));
            hasher.update(std.mem.asBytes(&pso_desc.DSVFormat));
            hasher.update(std.mem.asBytes(&pso_desc.SampleDesc));
            // We don't support fixed vertex fetch.
            assert(pso_desc.InputLayout.pInputElementDescs == null);
            assert(pso_desc.InputLayout.NumElements == 0);
            break :compute_hash hasher.final();
        };

        if (dx.pipeline.map.contains(hash)) {
            std.log.info("[graphics] Graphics pipeline hit detected.", .{});
            const handle = dx.pipeline.map.getEntry(hash).?.value;
            _ = dx.addPipelineRef(handle);
            return handle;
        }

        var root_signature: *d3d12.IRootSignature = undefined;
        vhr(dx.device.CreateRootSignature(
            0,
            pso_desc.VS.pShaderBytecode.?,
            pso_desc.VS.BytecodeLength,
            &d3d12.IID_IRootSignature,
            @ptrCast(**c_void, &root_signature),
        ));

        var pso: *d3d12.IPipelineState = undefined;
        vhr(dx.device.CreateGraphicsPipelineState(
            &pso_desc,
            &d3d12.IID_IPipelineState,
            @ptrCast(**c_void, &pso),
        ));

        const handle = dx.pipeline.pool.addPipeline(pso, root_signature, .Graphics);
        dx.pipeline.map.put(hash, handle) catch unreachable;
        return handle;
    }

    pub fn createComputePipeline(
        dx: *DxContext,
        pso_desc: d3d12.COMPUTE_PIPELINE_STATE_DESC,
    ) PipelineHandle {
        const hash = compute_hash: {
            var hasher = std.hash.Adler32.init();
            hasher.update(
                @ptrCast([*]const u8, pso_desc.CS.pShaderBytecode.?)[0..pso_desc.CS.BytecodeLength],
            );
            break :compute_hash hasher.final();
        };

        if (dx.pipeline.map.contains(hash)) {
            std.log.info("[graphics] Compute pipeline hit detected.", .{});
            const handle = dx.pipeline.map.getEntry(hash).?.value;
            _ = addPipelineRef(handle);
            return handle;
        }

        var root_signature: *d3d12.IRootSignature = undefined;
        vhr(dx.device.CreateRootSignature(
            0,
            pso_desc.CS.pShaderBytecode.?,
            pso_desc.CS.BytecodeLength,
            &d3d12.IID_IRootSignature,
            @ptrCast(**c_void, &root_signature),
        ));

        var pso: *d3d12.IPipelineState = undefined;
        vhr(dx.device.CreateComputePipelineState(
            &pso_desc,
            &d3d12.IID_IPipelineState,
            @ptrCast(**c_void, &pso),
        ));

        const handle = dx.pipeline.pool.addPipeline(pso, root_signature, .Compute);
        dx.pipeline.map.put(hash, handle) catch unreachable;
        return handle;
    }

    pub fn addPipelineRef(dx: DxContext, handle: PipelineHandle) u32 {
        const pipeline = dx.pipeline.pool.getPipeline(handle);
        const refcount = pipeline.pso.?.AddRef();
        if (pipeline.root_signature.?.AddRef() != refcount) {
            assert(false);
        }
        return refcount;
    }

    pub fn releasePipeline(dx: *DxContext, handle: PipelineHandle) u32 {
        var pipeline = dx.pipeline.pool.getPipeline(handle);

        const refcount = pipeline.pso.?.Release();
        if (pipeline.root_signature.?.Release() != refcount) {
            assert(false);
        }

        if (refcount == 0) {
            const hash_to_delete = blk: {
                var it = dx.pipeline.map.iterator();
                while (it.next()) |kv| {
                    if (kv.value.index == handle.index and
                        kv.value.generation == handle.generation)
                    {
                        break :blk kv.key;
                    }
                }
                unreachable;
            };
            _ = dx.pipeline.map.remove(hash_to_delete);
            pipeline.* = Pipeline{ .pso = null, .root_signature = null, .ptype = null };
        }

        return refcount;
    }

    fn allocateUploadMemory(
        dx: *DxContext,
        size: u32,
    ) struct { cpu_slice: []u8, gpu_addr: d3d12.GPU_VIRTUAL_ADDRESS } {
        var memory = dx.upload_memory_heaps[dx.frame_index].allocate(size);

        if (memory.cpu_slice == null and memory.gpu_addr == null) {
            std.log.info("[graphics] Upload memory exhausted - waiting for a GPU...", .{});

            dx.closeAndExecuteCommandList();
            dx.waitForGpu();
            dx.beginFrame();

            memory = dx.upload_memory_heaps[dx.frame_index].allocate(size);
        }

        return .{ .cpu_slice = memory.cpu_slice.?, .gpu_addr = memory.gpu_addr.? };
    }

    pub fn allocateUploadBufferRegion(
        dx: *DxContext,
        comptime T: type,
        num_elements: u32,
    ) struct { cpu_slice: []T, buffer: *d3d12.IResource, buffer_offset: u64 } {
        const size = num_elements * @sizeOf(T);
        const memory = dx.allocateUploadMemory(size);
        const aligned_size = (size + 255) & 0xffff_ff00;
        return .{
            .cpu_slice = std.mem.bytesAsSlice(T, @alignCast(@alignOf(T), memory.cpu_slice)),
            .buffer = dx.upload_memory_heaps[dx.frame_index].heap,
            .buffer_offset = dx.upload_memory_heaps[dx.frame_index].size - aligned_size,
        };
    }

    pub fn closeAndExecuteCommandList(dx: DxContext) void {
        vhr(dx.cmdlist.Close());
        dx.cmdqueue.ExecuteCommandLists(1, @ptrCast(*const *d3d12.ICommandList, &dx.cmdlist));
    }

    pub fn copyDescriptorsToGpuHeap(
        dx: *DxContext,
        num: u32,
        src_base_handle: d3d12.CPU_DESCRIPTOR_HANDLE,
    ) d3d12.GPU_DESCRIPTOR_HANDLE {
        const base = dx.allocateGpuDescriptors(num);
        dx.device.CopyDescriptorsSimple(num, base.cpu_handle, src_base_handle, .CBV_SRV_UAV);
        return base.gpu_handle;
    }
};

const DescriptorHeap = struct {
    heap: *d3d12.IDescriptorHeap,
    cpu_start: d3d12.CPU_DESCRIPTOR_HANDLE,
    gpu_start: d3d12.GPU_DESCRIPTOR_HANDLE,
    size: u32,
    capacity: u32,
    descriptor_size: u32,

    fn init(
        device: *d3d12.IDevice,
        capacity: u32,
        heap_type: d3d12.DESCRIPTOR_HEAP_TYPE,
        flags: d3d12.DESCRIPTOR_HEAP_FLAGS,
    ) DescriptorHeap {
        assert(capacity > 0);

        var heap: *d3d12.IDescriptorHeap = undefined;
        vhr(device.CreateDescriptorHeap(
            &d3d12.DESCRIPTOR_HEAP_DESC{
                .Type = heap_type,
                .NumDescriptors = capacity,
                .Flags = flags,
                .NodeMask = 0,
            },
            &d3d12.IID_IDescriptorHeap,
            @ptrCast(**c_void, &heap),
        ));

        return DescriptorHeap{
            .heap = heap,
            .cpu_start = heap.GetCPUDescriptorHandleForHeapStart(),
            .gpu_start = blk: {
                if (flags == .SHADER_VISIBLE)
                    break :blk heap.GetGPUDescriptorHandleForHeapStart();
                break :blk d3d12.GPU_DESCRIPTOR_HANDLE{ .ptr = 0 };
            },
            .size = 0,
            .capacity = capacity,
            .descriptor_size = device.GetDescriptorHandleIncrementSize(heap_type),
        };
    }

    fn allocateDescriptors(self: *DescriptorHeap, num_descriptors: u32) Descriptor {
        assert((self.size + num_descriptors) < self.capacity);

        const cpu_handle = d3d12.CPU_DESCRIPTOR_HANDLE{
            .ptr = self.cpu_start.ptr + self.size * self.descriptor_size,
        };
        const gpu_handle = d3d12.GPU_DESCRIPTOR_HANDLE{
            .ptr = blk: {
                if (self.gpu_start.ptr != 0)
                    break :blk self.gpu_start.ptr + self.size * self.descriptor_size;
                break :blk 0;
            },
        };

        self.size += num_descriptors;
        return Descriptor{ .cpu_handle = cpu_handle, .gpu_handle = gpu_handle };
    }
};

const Descriptor = struct {
    cpu_handle: d3d12.CPU_DESCRIPTOR_HANDLE,
    gpu_handle: d3d12.GPU_DESCRIPTOR_HANDLE,
};

pub const PipelineHandle = struct {
    index: u16,
    generation: u16,
};

const PipelineType = enum {
    Graphics,
    Compute,
};

const Pipeline = struct {
    pso: ?*d3d12.IPipelineState,
    root_signature: ?*d3d12.IRootSignature,
    ptype: ?PipelineType,
};

const PipelinePool = struct {
    pipelines: []Pipeline,
    generations: []u16,

    fn init() PipelinePool {
        return PipelinePool{
            .pipelines = blk: {
                var pipelines = std.heap.page_allocator.alloc(
                    Pipeline,
                    max_num_pipelines + 1,
                ) catch unreachable;
                for (pipelines) |*pipeline| {
                    pipeline.* = Pipeline{ .pso = null, .root_signature = null, .ptype = null };
                }
                break :blk pipelines;
            },
            .generations = blk: {
                var generations = std.heap.page_allocator.alloc(
                    u16,
                    max_num_pipelines + 1,
                ) catch unreachable;
                for (generations) |*generation| {
                    generation.* = 0;
                }
                break :blk generations;
            },
        };
    }

    fn deinit(self: *PipelinePool) void {
        for (self.pipelines) |pipeline| {
            // Verify that all pipelines has been released by a user.
            assert(pipeline.pso == null);
            assert(pipeline.root_signature == null);
        }
        std.heap.page_allocator.free(self.pipelines);
        std.heap.page_allocator.free(self.generations);
        self.* = undefined;
    }

    fn addPipeline(
        self: *PipelinePool,
        pso: *d3d12.IPipelineState,
        root_signature: *d3d12.IRootSignature,
        ptype: PipelineType,
    ) PipelineHandle {
        var slot_idx: u32 = 1;
        while (slot_idx <= max_num_pipelines) : (slot_idx += 1) {
            if (self.pipelines[slot_idx].pso == null)
                break;
        }
        assert(slot_idx <= max_num_pipelines);

        self.pipelines[slot_idx] = Pipeline{
            .pso = pso,
            .root_signature = root_signature,
            .ptype = ptype,
        };

        return PipelineHandle{
            .index = @intCast(u16, slot_idx),
            .generation = blk: {
                self.generations[slot_idx] += 1;
                break :blk self.generations[slot_idx];
            },
        };
    }

    fn getPipeline(self: PipelinePool, handle: PipelineHandle) *Pipeline {
        assert(handle.index > 0 and handle.index <= max_num_pipelines);
        assert(handle.generation > 0);
        assert(handle.generation == self.generations[handle.index]);
        return &self.pipelines[handle.index];
    }
};

pub const ResourceHandle = struct {
    index: u16,
    generation: u16,
};

const Resource = struct {
    raw: ?*d3d12.IResource,
    state: d3d12.RESOURCE_STATES,
    format: dxgi.FORMAT,
};

const ResourcePool = struct {
    resources: []Resource,
    generations: []u16,

    fn init() ResourcePool {
        return ResourcePool{
            .resources = blk: {
                var resources = std.heap.page_allocator.alloc(
                    Resource,
                    max_num_resources + 1,
                ) catch unreachable;
                for (resources) |*res| {
                    res.* = Resource{ .raw = null, .state = .{}, .format = .UNKNOWN };
                }
                break :blk resources;
            },
            .generations = blk: {
                var generations = std.heap.page_allocator.alloc(
                    u16,
                    max_num_resources + 1,
                ) catch unreachable;
                for (generations) |*gen| {
                    gen.* = 0;
                }
                break :blk generations;
            },
        };
    }

    fn deinit(self: *ResourcePool) void {
        for (self.resources) |resource, i| {
            if (i > 0 and i <= num_swapbuffers) {
                // Release internally created swapbuffers.
                _ = resource.raw.?.Release();
            } else if (i > num_swapbuffers) {
                // Verify that all resources has been released by a user.
                assert(resource.raw == null);
            }
        }
        std.heap.page_allocator.free(self.resources);
        std.heap.page_allocator.free(self.generations);
        self.* = undefined;
    }

    fn addResource(
        self: *ResourcePool,
        raw: *d3d12.IResource,
        state: d3d12.RESOURCE_STATES,
        format: dxgi.FORMAT,
    ) ResourceHandle {
        var slot_idx: u32 = 1;
        while (slot_idx <= max_num_resources) : (slot_idx += 1) {
            if (self.resources[slot_idx].raw == null)
                break;
        }
        assert(slot_idx <= max_num_resources);

        self.resources[slot_idx] = Resource{ .raw = raw, .state = state, .format = format };

        return ResourceHandle{
            .index = @intCast(u16, slot_idx),
            .generation = blk: {
                self.generations[slot_idx] += 1;
                break :blk self.generations[slot_idx];
            },
        };
    }

    fn getResource(self: ResourcePool, handle: ResourceHandle) *Resource {
        assert(handle.index > 0 and handle.index <= max_num_resources);
        assert(handle.generation > 0);
        assert(handle.generation == self.generations[handle.index]);
        return &self.resources[handle.index];
    }
};

const GpuMemoryHeap = struct {
    heap: *d3d12.IResource,
    cpu_slice: []u8,
    gpu_start: d3d12.GPU_VIRTUAL_ADDRESS,
    size: u32,
    capacity: u32,

    fn init(device: *d3d12.IDevice, capacity: u32, heap_type: d3d12.HEAP_TYPE) GpuMemoryHeap {
        var heap: *d3d12.IResource = undefined;
        vhr(device.CreateCommittedResource(
            &d3d12.HEAP_PROPERTIES{ .Type = heap_type },
            .{},
            &d3d12.RESOURCE_DESC.buffer(capacity),
            d3d12.RESOURCE_STATES.genericRead(),
            null,
            &d3d12.IID_IResource,
            @ptrCast(**c_void, &heap),
        ));

        var cpu_start: [*]u8 = undefined;
        vhr(heap.Map(0, &d3d12.RANGE{ .Begin = 0, .End = 0 }, @ptrCast(**c_void, &cpu_start)));

        return GpuMemoryHeap{
            .heap = heap,
            .cpu_slice = cpu_start[0..capacity],
            .gpu_start = heap.GetGPUVirtualAddress(),
            .size = 0,
            .capacity = capacity,
        };
    }

    fn deinit(self: *GpuMemoryHeap) void {
        releaseCom(&self.heap);
        self.* = undefined;
    }

    fn allocate(
        self: *GpuMemoryHeap,
        size: u32,
    ) struct { cpu_slice: ?[]u8, gpu_addr: ?d3d12.GPU_VIRTUAL_ADDRESS } {
        assert(size > 0);

        const aligned_size = (size + 255) & 0xffff_ff00;
        if ((self.size + aligned_size) >= self.capacity) {
            return .{ .cpu_slice = null, .gpu_addr = null };
        }
        const cpu_slice = (self.cpu_slice.ptr + self.size)[0..size];
        const gpu_addr = self.gpu_start + self.size;

        self.size += aligned_size;
        return .{ .cpu_slice = cpu_slice, .gpu_addr = gpu_addr };
    }
};
