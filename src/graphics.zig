const builtin = @import("builtin");
const std = @import("std");
const assert = std.debug.assert;
const os = @import("windows.zig");
const dxgi = @import("dxgi.zig");
const d3d12 = @import("d3d12.zig");

pub inline fn vhr(hr: os.HRESULT) void {
    if (hr != 0) {
        std.debug.panic("D3D12 function failed.", .{});
    }
}

pub inline fn safeRelease(obj: anytype) void {
    _ = obj.*.Release();
    obj.* = undefined;
}

const dx12_num_frames = 2;
const dx12_num_swapbuffers = 4;

pub const Dx12Context = struct {
    device: *d3d12.IDevice,
    cmdqueue: *d3d12.ICommandQueue,
    cmdallocs: [dx12_num_frames]*d3d12.ICommandAllocator,
    swapchain: *dxgi.ISwapChain3,
    swapbuffers: [dx12_num_swapbuffers]*d3d12.IResource,
    frame_fence: *d3d12.IFence,
    frame_fence_event: os.HANDLE,
    num_frames: u64 = 0,

    pub fn init(window: os.HWND) Dx12Context {
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
        _ = debug.Release();

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
                .BufferCount = dx12_num_swapbuffers,
                .OutputWindow = window,
                .Windowed = os.TRUE,
                .SwapEffect = dxgi.SWAP_EFFECT.FLIP_DISCARD,
                .Flags = 0,
            },
            &temp_swapchain,
        ));
        var swapchain: *dxgi.ISwapChain3 = undefined;
        vhr(temp_swapchain.QueryInterface(&dxgi.IID_ISwapChain3, @ptrCast(**c_void, &swapchain)));
        safeRelease(&temp_swapchain);
        safeRelease(&factory);

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

        var cmdallocs: [dx12_num_frames]*d3d12.ICommandAllocator = undefined;
        for (cmdallocs) |*cmdalloc| {
            vhr(device.CreateCommandAllocator(
                d3d12.COMMAND_LIST_TYPE.DIRECT,
                &d3d12.IID_ICommandAllocator,
                @ptrCast(**c_void, &cmdalloc.*),
            ));
        }

        var swapbuffers: [dx12_num_swapbuffers]*d3d12.IResource = undefined;
        for (swapbuffers) |*swapbuffer, i| {
            vhr(swapchain.GetBuffer(
                @intCast(u32, i),
                &d3d12.IID_IResource,
                @ptrCast(**c_void, &swapbuffer.*),
            ));
        }

        return Dx12Context{
            .device = device,
            .cmdqueue = cmdqueue,
            .cmdallocs = cmdallocs,
            .swapchain = swapchain,
            .swapbuffers = swapbuffers,
            .frame_fence = frame_fence,
            .frame_fence_event = frame_fence_event,
        };
    }

    pub fn deinit(self: *Dx12Context) void {
        self.waitForGpu();
        safeRelease(&self.swapchain);
        safeRelease(&self.cmdqueue);
        safeRelease(&self.device);
        self.* = undefined;
    }

    pub fn present(self: *Dx12Context) void {
        self.num_frames += 1;
        vhr(self.swapchain.Present(0, 0));
    }

    pub fn waitForGpu(self: Dx12Context) void {
        const value = self.num_frames + 1;
        vhr(self.cmdqueue.Signal(self.frame_fence, value));
        vhr(self.frame_fence.SetEventOnCompletion(value, self.frame_fence_event));
        os.WaitForSingleObject(self.frame_fence_event, os.INFINITE) catch unreachable;
    }
};
