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
    frame_fence: *d3d12.IFence,
    frame_fence_event: os.HANDLE,
    frame_counter: u64 = 0,
    frame_index: u32 = 0,
    back_buffer_index: u32 = 0,
    resource_pool: ResourcePool,

    pub fn init(window: os.HWND) DxContext {
        dxgi.init();
        d3d12.init();

        var rect: os.RECT = undefined;
        _ = os.GetClientRect(window, &rect);
        const window_width = @intCast(u32, rect.right);
        const window_height = @intCast(u32, rect.bottom);

        var factory: *dxgi.IFactory4 = undefined;
        vhr(dxgi.CreateFactory2(
            dxgi.CREATE_FACTORY_DEBUG,
            &dxgi.IID_IFactory4,
            @ptrCast(**c_void, &factory),
        ));

        var debug: *d3d12.IDebug = undefined;
        vhr(d3d12.GetDebugInterface(&d3d12.IID_IDebug, @ptrCast(**c_void, &debug)));
        debug.EnableDebugLayer();
        releaseCom(&debug);

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
                .Type = d3d12.COMMAND_LIST_TYPE.DIRECT,
                .Priority = @enumToInt(d3d12.COMMAND_QUEUE_PRIORITY.NORMAL),
                .Flags = d3d12.COMMAND_QUEUE_FLAGS.NONE,
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
                    .Width = window_width,
                    .Height = window_height,
                    .RefreshRate = dxgi.RATIONAL{
                        .Numerator = 0,
                        .Denominator = 0,
                    },
                    .Format = dxgi.FORMAT.R8G8B8A8_UNORM,
                    .ScanlineOrdering = dxgi.MODE_SCANLINE_ORDER.UNSPECIFIED,
                    .Scaling = dxgi.MODE_SCALING.UNSPECIFIED,
                },
                .SampleDesc = dxgi.SAMPLE_DESC{
                    .Count = 1,
                    .Quality = 0,
                },
                .BufferUsage = dxgi.USAGE_RENDER_TARGET_OUTPUT,
                .BufferCount = num_swapbuffers,
                .OutputWindow = window,
                .Windowed = os.TRUE,
                .SwapEffect = dxgi.SWAP_EFFECT.FLIP_DISCARD,
                .Flags = 0,
            },
            &temp_swapchain,
        ));
        var swapchain: *dxgi.ISwapChain3 = undefined;
        vhr(temp_swapchain.QueryInterface(&dxgi.IID_ISwapChain3, @ptrCast(**c_void, &swapchain)));
        releaseCom(&temp_swapchain);
        releaseCom(&factory);

        var frame_fence: *d3d12.IFence = undefined;
        vhr(device.CreateFence(
            0,
            d3d12.FENCE_FLAGS.NONE,
            &d3d12.IID_IFence,
            @ptrCast(**c_void, &frame_fence),
        ));
        const frame_fence_event = os.CreateEventEx(
            null,
            "frame_fence_event",
            0,
            os.EVENT_ALL_ACCESS,
        ) catch unreachable;

        var cmdallocs: [num_frames]*d3d12.ICommandAllocator = undefined;
        for (cmdallocs) |*cmdalloc| {
            vhr(device.CreateCommandAllocator(
                d3d12.COMMAND_LIST_TYPE.DIRECT,
                &d3d12.IID_ICommandAllocator,
                @ptrCast(**c_void, &cmdalloc.*),
            ));
        }

        var rtv_heap = DescriptorHeap.init(
            device,
            num_rtv_descriptors,
            d3d12.DESCRIPTOR_HEAP_TYPE.RTV,
            d3d12.DESCRIPTOR_HEAP_FLAGS.NONE,
        );
        var dsv_heap = DescriptorHeap.init(
            device,
            num_dsv_descriptors,
            d3d12.DESCRIPTOR_HEAP_TYPE.DSV,
            d3d12.DESCRIPTOR_HEAP_FLAGS.NONE,
        );
        var cbv_srv_uav_cpu_heap = DescriptorHeap.init(
            device,
            num_cbv_srv_uav_cpu_descriptors,
            d3d12.DESCRIPTOR_HEAP_TYPE.CBV_SRV_UAV,
            d3d12.DESCRIPTOR_HEAP_FLAGS.NONE,
        );
        var cbv_srv_uav_gpu_heaps: [num_frames]DescriptorHeap = undefined;
        for (cbv_srv_uav_gpu_heaps) |*heap| {
            heap.* = DescriptorHeap.init(
                device,
                num_cbv_srv_uav_gpu_descriptors,
                d3d12.DESCRIPTOR_HEAP_TYPE.CBV_SRV_UAV,
                d3d12.DESCRIPTOR_HEAP_FLAGS.SHADER_VISIBLE,
            );
        }

        var resource_pool = ResourcePool.init();

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
                swapbuffer.* = resource_pool.addResource(
                    buffer,
                    d3d12.RESOURCE_STATES.PRESENT,
                    dxgi.FORMAT.R8G8B8A8_UNORM,
                );
                device.CreateRenderTargetView(buffer, null, handle);
                handle.ptr += rtv_heap.descriptor_size;
            }
        }

        var cmdlist: *d3d12.IGraphicsCommandList = undefined;
        vhr(device.CreateCommandList(
            0,
            d3d12.COMMAND_LIST_TYPE.DIRECT,
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
            .frame_fence = frame_fence,
            .frame_fence_event = frame_fence_event,
            .resource_pool = resource_pool,
        };
    }

    pub fn deinit(dx: *DxContext) void {
        waitForGpu(dx.*);
        releaseCom(&dx.swapchain);
        releaseCom(&dx.cmdqueue);
        releaseCom(&dx.device);
        dx.resource_pool.deinit();
        dx.* = undefined;
    }

    pub fn beginFrame(dx: DxContext) void {
        const cmdalloc = dx.cmdallocs[dx.frame_index];
        vhr(cmdalloc.Reset());
        vhr(dx.cmdlist.Reset(cmdalloc, null));
        dx.cmdlist.SetDescriptorHeaps(1, &dx.cbv_srv_uav_gpu_heaps[dx.frame_index].heap);
    }

    pub fn endFrame(dx: *DxContext) void {
        vhr(dx.cmdlist.Close());
        dx.cmdqueue.ExecuteCommandLists(1, @ptrCast(*const *d3d12.ICommandList, &dx.cmdlist));

        dx.frame_counter += 1;
        vhr(dx.swapchain.Present(0, 0));
        vhr(dx.cmdqueue.Signal(dx.frame_fence, dx.frame_counter));

        const gpu_frame_counter = dx.frame_fence.GetCompletedValue();
        if ((dx.frame_counter - gpu_frame_counter) >= num_frames) {
            vhr(dx.frame_fence.SetEventOnCompletion(gpu_frame_counter + 1, dx.frame_fence_event));
            os.WaitForSingleObject(dx.frame_fence_event, os.INFINITE) catch unreachable;
        }

        dx.frame_index = (dx.frame_index + 1) % num_frames;
        dx.back_buffer_index = dx.swapchain.GetCurrentBackBufferIndex();
        dx.cbv_srv_uav_gpu_heaps[dx.frame_index].size = 0;
    }

    pub fn waitForGpu(dx: DxContext) void {
        const value = dx.frame_counter + 1;
        vhr(dx.cmdqueue.Signal(dx.frame_fence, value));
        vhr(dx.frame_fence.SetEventOnCompletion(value, dx.frame_fence_event));
        os.WaitForSingleObject(dx.frame_fence_event, os.INFINITE) catch unreachable;
    }

    pub fn allocateCpuDescriptors(
        dx: *DxContext,
        heap_type: d3d12.DESCRIPTOR_HEAP_TYPE,
        num_descriptors: u32,
    ) d3d12.CPU_DESCRIPTOR_HANDLE {
        return switch (heap_type) {
            d3d12.DESCRIPTOR_HEAP_TYPE.CBV_SRV_UAV => dx.cbv_srv_uav_cpu_heap.
                allocateDescriptors(num_descriptors).
                cpu_handle,
            d3d12.DESCRIPTOR_HEAP_TYPE.SAMPLER => unreachable,
            d3d12.DESCRIPTOR_HEAP_TYPE.RTV => dx.rtv_heap.allocateDescriptors(num_descriptors).cpu_handle,
            d3d12.DESCRIPTOR_HEAP_TYPE.DSV => dx.dsv_heap.allocateDescriptors(num_descriptors).cpu_handle,
        };
    }

    pub fn allocateGpuDescriptors(dx: *DxContext, num_descriptors: u32) Descriptor {
        return dx.cbv_srv_uav_gpu_heaps[dx.frame_index].allocateDescriptors(num_descriptors);
    }

    pub fn getDxResource(dx: DxContext, handle: ResourceHandle) *d3d12.IResource {
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

    pub fn encodeTransitionBarrier(
        dx: DxContext,
        handle: ResourceHandle,
        state_after: d3d12.RESOURCE_STATES,
    ) void {
        var resource = dx.resource_pool.getResource(handle);

        if (state_after != resource.state) {
            dx.cmdlist.ResourceBarrier(1, &d3d12.RESOURCE_BARRIER{
                .Type = d3d12.RESOURCE_BARRIER_TYPE.TRANSITION,
                .Flags = d3d12.RESOURCE_BARRIER_FLAGS.NONE,
                .u = .{
                    .Transition = d3d12.RESOURCE_TRANSITION_BARRIER{
                        .pResource = resource.raw.?,
                        .Subresource = d3d12.RESOURCE_BARRIER_ALL_SUBRESOURCES,
                        .StateBefore = resource.state,
                        .StateAfter = state_after,
                    },
                },
            });
            resource.state = state_after;
        }
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
                if (flags == d3d12.DESCRIPTOR_HEAP_FLAGS.SHADER_VISIBLE)
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

const Descriptor = packed struct {
    cpu_handle: d3d12.CPU_DESCRIPTOR_HANDLE,
    gpu_handle: d3d12.GPU_DESCRIPTOR_HANDLE,
};

pub const ResourceHandle = packed struct {
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
                    res.* = Resource{
                        .raw = null,
                        .state = d3d12.RESOURCE_STATES.COMMON,
                        .format = dxgi.FORMAT.UNKNOWN,
                    };
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

        self.resources[slot_idx] = Resource{
            .raw = raw,
            .state = state,
            .format = format,
        };

        return ResourceHandle{
            .index = @intCast(u16, slot_idx),
            .generation = blk: {
                self.generations[slot_idx] += 1;
                break :blk self.generations[slot_idx];
            },
        };
    }

    pub fn getResource(self: ResourcePool, handle: ResourceHandle) *Resource {
        assert(handle.index > 0 and handle.index <= max_num_resources);
        assert(handle.generation > 0);
        assert(handle.generation == self.generations[handle.index]);
        return &self.resources[handle.index];
    }
};
