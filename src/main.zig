const std = @import("std");
const assert = std.debug.assert;
const os = @import("windows.zig");
const dxgi = @import("dxgi.zig");
const d3d12 = @import("d3d12.zig");

const window_name = "zig d3d12 test";
const window_width = 1920;
const window_height = 1080;

pub inline fn vhr(hr: os.HRESULT) void {
    if (hr != 0) {
        std.debug.panic("D3D12 function failed.", .{});
    }
}

fn updateFrameStats(window: ?os.HWND, name: [*:0]const u8) struct { time: f64, delta_time: f32 } {
    const state = struct {
        var timer: std.time.Timer = undefined;
        var previous_time_ns: u64 = 0;
        var header_refresh_time_ns: u64 = 0;
        var frame_count: u64 = ~@as(u64, 0);
    };

    if (state.frame_count == ~@as(u64, 0)) {
        state.timer = std.time.Timer.start() catch unreachable;
        state.previous_time_ns = 0;
        state.header_refresh_time_ns = 0;
        state.frame_count = 0;
    }

    const now_ns = state.timer.read();
    const time = @intToFloat(f64, now_ns) / std.time.ns_per_s;
    const delta_time = @intToFloat(f32, now_ns - state.previous_time_ns) / std.time.ns_per_s;
    state.previous_time_ns = now_ns;

    if ((now_ns - state.header_refresh_time_ns) >= std.time.ns_per_s) {
        const t = @intToFloat(f64, now_ns - state.header_refresh_time_ns) / std.time.ns_per_s;
        const fps = @intToFloat(f64, state.frame_count) / t;
        const ms = (1.0 / fps) * 1000.0;

        var buffer = [_]u8{0} ** 128;
        const buffer_slice = buffer[0 .. buffer.len - 1];
        const header = std.fmt.bufPrint(
            buffer_slice,
            "[{d:.1} fps  {d:.3} ms] {}",
            .{ fps, ms, name },
        ) catch buffer_slice;

        _ = os.SetWindowTextA(window, @ptrCast(os.LPCSTR, header.ptr));

        state.header_refresh_time_ns = now_ns;
        state.frame_count = 0;
    }
    state.frame_count += 1;

    return .{ .time = time, .delta_time = delta_time };
}

fn processWindowMessage(
    window: os.HWND,
    message: os.UINT,
    wparam: os.WPARAM,
    lparam: os.LPARAM,
) callconv(.Stdcall) os.LRESULT {
    const processed = switch (message) {
        os.user32.WM_DESTROY => blk: {
            os.user32.PostQuitMessage(0);
            break :blk true;
        },
        os.user32.WM_KEYDOWN => blk: {
            if (wparam == os.VK_ESCAPE) {
                os.user32.PostQuitMessage(0);
                break :blk true;
            }
            break :blk false;
        },
        else => false,
    };
    return if (processed) null else os.user32.DefWindowProcA(window, message, wparam, lparam);
}

pub fn main() !void {
    _ = os.SetProcessDPIAware();

    const winclass = os.user32.WNDCLASSEXA{
        .style = 0,
        .lpfnWndProc = processWindowMessage,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hInstance = @ptrCast(os.HINSTANCE, os.kernel32.GetModuleHandleA(null)),
        .hIcon = null,
        .hCursor = os.LoadCursorA(null, @intToPtr(os.LPCSTR, 32512)),
        .hbrBackground = null,
        .lpszMenuName = null,
        .lpszClassName = window_name,
        .hIconSm = null,
    };
    _ = os.user32.RegisterClassExA(&winclass);

    const style = os.user32.WS_OVERLAPPED +
        os.user32.WS_SYSMENU +
        os.user32.WS_CAPTION +
        os.user32.WS_MINIMIZEBOX;

    var rect = os.RECT{ .left = 0, .top = 0, .right = window_width, .bottom = window_height };
    _ = os.AdjustWindowRect(&rect, style, false);

    const window = os.user32.CreateWindowExA(
        0,
        window_name,
        window_name,
        style + os.WS_VISIBLE,
        -1,
        -1,
        rect.right - rect.left,
        rect.bottom - rect.top,
        null,
        null,
        winclass.hInstance,
        null,
    );

    dxgi.init();
    d3d12.init();

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
    std.log.info("node count is {}", .{device.GetNodeCount()});

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
            .BufferCount = 4,
            .OutputWindow = window.?,
            .Windowed = 1,
            .SwapEffect = dxgi.SWAP_EFFECT.FLIP_DISCARD,
            .Flags = 0,
        },
        &temp_swapchain,
    ));
    var swapchain: *dxgi.ISwapChain3 = undefined;
    vhr(temp_swapchain.QueryInterface(&dxgi.IID_ISwapChain3, @ptrCast(**c_void, &swapchain)));
    _ = temp_swapchain.Release();
    _ = factory.Release();

    var frame_fence: *d3d12.IFence = undefined;
    vhr(device.CreateFence(
        0,
        d3d12.FENCE_FLAGS.NONE,
        &d3d12.IID_IFence,
        @ptrCast(**c_void, &frame_fence),
    ));
    const frame_fence_event = try os.CreateEventEx(null, "frame_fence_event", 0, os.EVENT_ALL_ACCESS);
    var num_frames: u64 = 0;

    while (true) {
        var message = std.mem.zeroes(os.user32.MSG);
        if (os.user32.PeekMessageA(&message, null, 0, 0, os.user32.PM_REMOVE)) {
            _ = os.user32.DispatchMessageA(&message);
            if (message.message == os.user32.WM_QUIT)
                break;
        } else {
            const stats = updateFrameStats(window, window_name);

            num_frames += 1;
            vhr(swapchain.Present(0, 0));

            vhr(cmdqueue.Signal(frame_fence, num_frames));
            vhr(frame_fence.SetEventOnCompletion(num_frames, frame_fence_event));
            try os.WaitForSingleObject(frame_fence_event, os.INFINITE);
        }
    }

    num_frames += 1;
    vhr(cmdqueue.Signal(frame_fence, num_frames));
    vhr(frame_fence.SetEventOnCompletion(num_frames, frame_fence_event));
    try os.WaitForSingleObject(frame_fence_event, os.INFINITE);

    _ = swapchain.Release();
    _ = cmdqueue.Release();
    _ = device.Release();
}
