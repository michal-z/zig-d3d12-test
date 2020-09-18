const std = @import("std");
const assert = std.debug.assert;
const os = @import("windows.zig");
const dxgi = @import("dxgi.zig");
const d3d12 = @import("d3d12.zig");
const gr = @import("graphics.zig");

const window_name = "zig d3d12 test";
const window_width = 1920;
const window_height = 1080;

const DemoState = struct {
    dx: gr.DxContext,
    window: os.HWND,

    fn init(window: os.HWND) DemoState {
        var dx = gr.DxContext.init(window);

        const srgb_rt = dx.createCommittedResource(
            d3d12.HEAP_TYPE.DEFAULT,
            d3d12.HEAP_FLAGS.NONE,
            &d3d12.RESOURCE_DESC{
                .Dimension = d3d12.RESOURCE_DIMENSION.TEXTURE2D,
                .Alignment = 0,
                .Width = window_width,
                .Height = window_height,
                .DepthOrArraySize = 1,
                .MipLevels = 1,
                .Format = dxgi.FORMAT.R8G8B8A8_UNORM_SRGB,
                .SampleDesc = .{ .Count = 8, .Quality = 0 },
                .Layout = d3d12.TEXTURE_LAYOUT.UNKNOWN,
                .Flags = d3d12.RESOURCE_FLAGS.ALLOW_RENDER_TARGET,
            },
            d3d12.RESOURCE_STATES.RENDER_TARGET,
            null,
        );

        return DemoState{
            .dx = dx,
            .window = window,
        };
    }

    fn deinit(self: *DemoState) void {
        self.dx.deinit();
        self.* = undefined;
    }

    fn update(self: *DemoState) void {
        const stats = updateFrameStats(self.window, window_name);
        var dx = &self.dx;

        dx.beginFrame();
        const back_buffer = dx.getBackBuffer();
        dx.encodeTransitionBarrier(back_buffer.resource_handle, d3d12.RESOURCE_STATES.RENDER_TARGET);
        dx.cmdlist.OMSetRenderTargets(1, &back_buffer.cpu_handle, os.TRUE, null);
        dx.cmdlist.ClearRenderTargetView(
            back_buffer.cpu_handle,
            &[4]f32{ 0.2, 0.4, 0.8, 1.0 },
            0,
            null,
        );
        dx.encodeTransitionBarrier(back_buffer.resource_handle, d3d12.RESOURCE_STATES.PRESENT);
        dx.endFrame();
    }
};

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

    var demo_state = DemoState.init(window.?);
    defer demo_state.deinit();

    while (true) {
        var message = std.mem.zeroes(os.user32.MSG);
        if (os.user32.PeekMessageA(&message, null, 0, 0, os.user32.PM_REMOVE)) {
            _ = os.user32.DispatchMessageA(&message);
            if (message.message == os.user32.WM_QUIT)
                break;
        } else {
            demo_state.update();
        }
    }
}
