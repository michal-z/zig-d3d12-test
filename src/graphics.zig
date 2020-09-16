const builtin = @import("builtin");
const std = @import("std");
const assert = std.debug.assert;
const os = @import("windows.zig");
const dxgi = @import("dxgi.zig");
const d3d12 = @import("d3d12.zig");

const num_frames = 2;
const num_swapbuffers = 4;
const num_rtv_descriptors = 1024;
const num_dsv_descriptors = 1024;
const num_cbv_srv_uav_descriptors = 16 * 1024;

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
    cmdqueue: *d3d12.ICommandQueue,
    cmdallocs: [num_frames]*d3d12.ICommandAllocator,
    swapchain: *dxgi.ISwapChain3,
    swapbuffers: [num_swapbuffers]*d3d12.IResource,
    rtv_heap: DescriptorHeap,
    frame_fence: *d3d12.IFence,
    frame_fence_event: os.HANDLE,
    frame_counter: u64 = 0,

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

        var swapbuffers: [num_swapbuffers]*d3d12.IResource = undefined;
        {
            var handle = rtv_heap.allocateDescriptors(num_swapbuffers).cpu_handle;

            for (swapbuffers) |*swapbuffer, i| {
                vhr(swapchain.GetBuffer(
                    @intCast(u32, i),
                    &d3d12.IID_IResource,
                    @ptrCast(**c_void, &swapbuffer.*),
                ));
            }
        }

        return DxContext{
            .device = device,
            .cmdqueue = cmdqueue,
            .cmdallocs = cmdallocs,
            .swapchain = swapchain,
            .swapbuffers = swapbuffers,
            .rtv_heap = rtv_heap,
            .frame_fence = frame_fence,
            .frame_fence_event = frame_fence_event,
        };
    }

    pub fn deinit(dx: *DxContext) void {
        waitForGpu(dx.*);
        releaseCom(&dx.swapchain);
        releaseCom(&dx.cmdqueue);
        releaseCom(&dx.device);
        dx.* = undefined;
    }

    pub fn present(dx: *DxContext) void {
        dx.frame_counter += 1;
        vhr(dx.swapchain.Present(0, 0));
    }

    pub fn waitForGpu(dx: DxContext) void {
        const value = dx.frame_counter + 1;
        vhr(dx.cmdqueue.Signal(dx.frame_fence, value));
        vhr(dx.frame_fence.SetEventOnCompletion(value, dx.frame_fence_event));
        os.WaitForSingleObject(dx.frame_fence_event, os.INFINITE) catch unreachable;
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

    fn allocateDescriptors(
        self: *DescriptorHeap,
        num_descriptors: u32,
    ) struct { cpu_handle: d3d12.CPU_DESCRIPTOR_HANDLE, gpu_handle: d3d12.GPU_DESCRIPTOR_HANDLE } {
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
        return .{ .cpu_handle = cpu_handle, .gpu_handle = gpu_handle };
    }
};

pub const ResourceHandle = packed struct {
    index: u16,
    generation: u16,
};

const Resource = struct {
    raw: *d3d12.IResource,
    state: d3d12.RESOURCE_STATES,
    format: dxgi.FORMAT,
};
