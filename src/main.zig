const std = @import("std");
const assert = std.debug.assert;
const os = std.os.windows;
const d3d12 = @import("d3d12.zig");

const window_name = "zig d3d12 test";
const window_width = 1920;
const window_height = 1080;

pub inline fn vhr(hr: os.HRESULT) void {
    if (hr < 0) {
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

        _ = SetWindowTextA(window, @ptrCast(os.LPCSTR, header.ptr));

        state.header_refresh_time_ns = now_ns;
        state.frame_count = 0;
    }
    state.frame_count += 1;

    return .{ .time = time, .delta_time = delta_time };
}

const WS_VISIBLE = 0x10000000;
const VK_ESCAPE = 0x001B;

const RECT = extern struct {
    left: os.LONG,
    top: os.LONG,
    right: os.LONG,
    bottom: os.LONG,
};

extern "kernel32" fn AdjustWindowRect(
    lpRect: ?*RECT,
    dwStyle: os.DWORD,
    bMenu: bool,
) callconv(.Stdcall) bool;

extern "user32" fn SetProcessDPIAware() callconv(.Stdcall) bool;

extern "user32" fn SetWindowTextA(hWnd: ?os.HWND, lpString: os.LPCSTR) callconv(.Stdcall) bool;

extern "user32" fn LoadCursorA(
    hInstance: ?os.HINSTANCE,
    lpCursorName: os.LPCSTR,
) callconv(.Stdcall) os.HCURSOR;

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
            if (wparam == VK_ESCAPE) {
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
    _ = SetProcessDPIAware();

    const winclass = os.user32.WNDCLASSEXA{
        .style = 0,
        .lpfnWndProc = processWindowMessage,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hInstance = @ptrCast(os.HINSTANCE, os.kernel32.GetModuleHandleA(null)),
        .hIcon = null,
        .hCursor = LoadCursorA(null, @intToPtr(os.LPCSTR, 32512)),
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

    var rect = RECT{ .left = 0, .top = 0, .right = window_width, .bottom = window_height };
    _ = AdjustWindowRect(&rect, style, false);

    const window = os.user32.CreateWindowExA(
        0,
        window_name,
        window_name,
        style + WS_VISIBLE,
        -1,
        -1,
        rect.right - rect.left,
        rect.bottom - rect.top,
        null,
        null,
        winclass.hInstance,
        null,
    );

    d3d12.init();

    var debug: *d3d12.IDebug = undefined;
    vhr(d3d12.GetDebugInterface(&d3d12.IID_IDebug, @ptrCast(**c_void, &debug)));
    debug.EnableDebugLayer();
    _ = debug.Release();

    var device: *c_void = undefined;
    vhr(d3d12.CreateDevice(null, d3d12.FEATURE_LEVEL._11_1, &d3d12.IID_IDevice, &device));

    while (true) {
        var message = std.mem.zeroes(os.user32.MSG);
        if (os.user32.PeekMessageA(&message, null, 0, 0, os.user32.PM_REMOVE)) {
            _ = os.user32.DispatchMessageA(&message);
            if (message.message == os.user32.WM_QUIT)
                break;
        } else {
            const stats = updateFrameStats(window, window_name);
        }
    }
}