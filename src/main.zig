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
    srgb_texture: gr.ResourceHandle,
    srgb_texture_rtv: d3d12.CPU_DESCRIPTOR_HANDLE,
    geometry_buffer: gr.ResourceHandle,
    geometry_buffer_srv: d3d12.CPU_DESCRIPTOR_HANDLE,
    pso: gr.PipelineHandle,

    fn init(window: os.HWND) DemoState {
        var dx = gr.DxContext.init(window);

        const srgb_texture = dx.createCommittedResource(
            .DEFAULT,
            d3d12.HEAP_FLAG_NONE,
            &blk: {
                var desc = gr.resource_desc.tex2d(.R8G8B8A8_UNORM_SRGB, window_width, window_height);
                desc.Flags = d3d12.RESOURCE_FLAG_ALLOW_RENDER_TARGET;
                desc.SampleDesc.Count = 8;
                break :blk desc;
            },
            .RENDER_TARGET,
            &d3d12.CLEAR_VALUE{
                .Format = .R8G8B8A8_UNORM_SRGB,
                .u = .{ .Color = [4]f32{ 0.2, 0.4, 0.8, 1.0 } },
            },
        );
        const srgb_texture_rtv = dx.allocateCpuDescriptors(.RTV, 1);
        dx.device.CreateRenderTargetView(dx.getRawResource(srgb_texture), null, srgb_texture_rtv);

        const pso = dx.createGraphicsPipeline(d3d12.GRAPHICS_PIPELINE_STATE_DESC{
            .PrimitiveTopologyType = .TRIANGLE,
            .NumRenderTargets = 1,
            .RTVFormats = [_]dxgi.FORMAT{.R8G8B8A8_UNORM_SRGB} ++ [_]dxgi.FORMAT{.UNKNOWN} ** 7,
            .DepthStencilState = blk: {
                var desc = d3d12.DEPTH_STENCIL_DESC{};
                desc.DepthEnable = os.FALSE;
                break :blk desc;
            },
            .VS = blk: {
                const file = @embedFile("../shaders/test.vs.cso");
                break :blk .{ .pShaderBytecode = file, .BytecodeLength = file.len };
            },
            .PS = blk: {
                const file = @embedFile("../shaders/test.ps.cso");
                break :blk .{ .pShaderBytecode = file, .BytecodeLength = file.len };
            },
            .SampleDesc = .{ .Count = 8, .Quality = 0 },
        });

        dx.beginFrame();

        const geometry_buffer = dx.createCommittedResource(
            .DEFAULT,
            d3d12.HEAP_FLAG_NONE,
            &gr.resource_desc.buffer(1024),
            .COPY_DEST,
            null,
        );
        const geometry_buffer_srv = dx.allocateCpuDescriptors(.CBV_SRV_UAV, 1);

        {
            const upload = dx.allocateUploadBufferRegion(4 * @sizeOf(f32));
            var slice = std.mem.bytesAsSlice(f32, upload.cpu_slice);
            slice[0] = -0.5;
            slice[1] = -0.5;
            slice[2] = 0.0;
            slice[3] = 1.0;
            dx.cmdlist.CopyBufferRegion(
                dx.getRawResource(geometry_buffer),
                0,
                upload.buffer,
                upload.buffer_offset,
                upload.cpu_slice.len,
            );
        }
        {
            const upload = dx.allocateUploadBufferRegion(2 * @sizeOf(f32));
            var slice = std.mem.bytesAsSlice(f32, upload.cpu_slice);
            slice[0] = 1.0;
            slice[1] = -1.0;
            dx.cmdlist.CopyBufferRegion(
                dx.getRawResource(geometry_buffer),
                16,
                upload.buffer,
                upload.buffer_offset,
                upload.cpu_slice.len,
            );
        }
        dx.device.CreateShaderResourceView(
            dx.getRawResource(geometry_buffer),
            &d3d12.SHADER_RESOURCE_VIEW_DESC{
                .ViewDimension = .BUFFER,
                .u = .{
                    .Buffer = d3d12.BUFFER_SRV{
                        .FirstElement = 0,
                        .NumElements = 3,
                        .StructureByteStride = 8,
                    },
                },
            },
            geometry_buffer_srv,
        );

        dx.closeAndExecuteCommandList();
        dx.waitForGpu();

        return DemoState{
            .dx = dx,
            .window = window,
            .srgb_texture = srgb_texture,
            .srgb_texture_rtv = srgb_texture_rtv,
            .geometry_buffer = geometry_buffer,
            .geometry_buffer_srv = geometry_buffer_srv,
            .pso = pso,
        };
    }

    fn deinit(self: *DemoState) void {
        _ = self.dx.releaseResource(self.geometry_buffer);
        _ = self.dx.releaseResource(self.srgb_texture);
        _ = self.dx.releasePipeline(self.pso);
        self.dx.deinit();
        self.* = undefined;
    }

    fn update(self: *DemoState) void {
        const stats = updateFrameStats(self.window, window_name);
        var dx = &self.dx;

        dx.beginFrame();
        dx.addTransitionBarrier(self.srgb_texture, .RENDER_TARGET);
        dx.flushResourceBarriers();
        dx.cmdlist.OMSetRenderTargets(1, &self.srgb_texture_rtv, os.TRUE, null);
        dx.cmdlist.ClearRenderTargetView(
            self.srgb_texture_rtv,
            &[4]f32{ 0.2, 0.4, 0.8, 1.0 },
            0,
            null,
        );
        dx.cmdlist.IASetPrimitiveTopology(.TRIANGLELIST);
        dx.setPipelineState(self.pso);
        dx.cmdlist.SetGraphicsRootShaderResourceView(
            0,
            dx.getRawResource(self.geometry_buffer).GetGPUVirtualAddress(),
        );
        dx.cmdlist.DrawInstanced(3, 1, 0, 0);

        const back_buffer = dx.getBackBuffer();
        dx.addTransitionBarrier(back_buffer.resource_handle, .RESOLVE_DEST);
        dx.addTransitionBarrier(self.srgb_texture, .RESOLVE_SOURCE);
        dx.flushResourceBarriers();

        dx.cmdlist.ResolveSubresource(
            dx.getRawResource(back_buffer.resource_handle),
            0,
            dx.getRawResource(self.srgb_texture),
            0,
            .R8G8B8A8_UNORM,
        );
        dx.addTransitionBarrier(back_buffer.resource_handle, .PRESENT);
        dx.flushResourceBarriers();
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
