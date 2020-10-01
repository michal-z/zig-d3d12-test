const std = @import("std");
const assert = std.debug.assert;
const os = @import("windows.zig");
const dxgi = @import("dxgi.zig");
const d3d12 = @import("d3d12.zig");
const gr = @import("graphics.zig");
usingnamespace @import("math.zig");

const window_name = "zig d3d12 test";
const window_width = 1920;
const window_height = 1080;
const window_num_samples = 8;

const max_num_vertices = 10_000;
const max_num_triangles = 10_000;

const Vertex = struct {
    position: Vec3,
    normal: Vec3,
};

const Triangle = struct {
    index0: u32,
    index1: u32,
    index2: u32,
};

comptime {
    assert(@sizeOf(Vertex) == 24 and @alignOf(Vertex) == 4);
    assert(@sizeOf(Triangle) == 12 and @alignOf(Triangle) == 4);
}

// NOTE: Do not change the order of fields.
const DrawCall = struct {
    start_index_location: u32,
    base_vertex_location: u32,
    transform_location: u32,
    num_indices: u32,
};

const DemoState = struct {
    dx: gr.DxContext,
    srgb_texture: gr.ResourceHandle,
    depth_texture: gr.ResourceHandle,
    vertex_buffer: gr.ResourceHandle,
    index_buffer: gr.ResourceHandle,
    transform_buffer: gr.ResourceHandle,
    pso: gr.PipelineHandle,
    srgb_texture_rtv: d3d12.CPU_DESCRIPTOR_HANDLE,
    depth_texture_dsv: d3d12.CPU_DESCRIPTOR_HANDLE,
    vertex_buffer_srv: d3d12.CPU_DESCRIPTOR_HANDLE,
    index_buffer_srv: d3d12.CPU_DESCRIPTOR_HANDLE,
    transform_buffer_srv: d3d12.CPU_DESCRIPTOR_HANDLE,
    draw_calls: [2]DrawCall,

    fn init(window: os.HWND) DemoState {
        var dx = gr.DxContext.init(window);

        const srgb_texture = dx.createCommittedResource(
            .DEFAULT,
            .{},
            &blk: {
                var desc = d3d12.RESOURCE_DESC.tex2d(.R8G8B8A8_UNORM_SRGB, window_width, window_height);
                desc.Flags = .{ .ALLOW_RENDER_TARGET = 1 };
                desc.SampleDesc.Count = window_num_samples;
                break :blk desc;
            },
            .{ .RENDER_TARGET = 1 },
            &d3d12.CLEAR_VALUE.color(.R8G8B8A8_UNORM_SRGB, [4]f32{ 0.2, 0.4, 0.8, 1.0 }),
        );
        const srgb_texture_rtv = dx.allocateCpuDescriptors(.RTV, 1);
        dx.device.CreateRenderTargetView(dx.getResource(srgb_texture), null, srgb_texture_rtv);

        const depth_texture = dx.createCommittedResource(
            .DEFAULT,
            .{},
            &blk: {
                var desc = d3d12.RESOURCE_DESC.tex2d(.D32_FLOAT, window_width, window_height);
                desc.Flags = .{ .ALLOW_DEPTH_STENCIL = 1, .DENY_SHADER_RESOURCE = 1 };
                desc.SampleDesc.Count = window_num_samples;
                break :blk desc;
            },
            .{ .DEPTH_WRITE = 1 },
            &d3d12.CLEAR_VALUE.depthStencil(.D32_FLOAT, 1.0, 0),
        );
        const depth_texture_dsv = dx.allocateCpuDescriptors(.DSV, 1);
        dx.device.CreateDepthStencilView(dx.getResource(depth_texture), null, depth_texture_dsv);

        const pso = dx.createGraphicsPipeline(d3d12.GRAPHICS_PIPELINE_STATE_DESC{
            .PrimitiveTopologyType = .TRIANGLE,
            .NumRenderTargets = 1,
            .RTVFormats = [_]dxgi.FORMAT{.R8G8B8A8_UNORM_SRGB} ++ [_]dxgi.FORMAT{.UNKNOWN} ** 7,
            .DSVFormat = .D32_FLOAT,
            .RasterizerState = .{ .CullMode = .NONE },
            .VS = blk: {
                const file = @embedFile("../shaders/test.vs.cso");
                break :blk .{ .pShaderBytecode = file, .BytecodeLength = file.len };
            },
            .PS = blk: {
                const file = @embedFile("../shaders/test.ps.cso");
                break :blk .{ .pShaderBytecode = file, .BytecodeLength = file.len };
            },
            .SampleDesc = .{ .Count = window_num_samples, .Quality = 0 },
        });

        const vertex_buffer = dx.createCommittedResource(
            .DEFAULT,
            .{},
            &d3d12.RESOURCE_DESC.buffer(max_num_vertices * @sizeOf(Vertex)),
            .{ .COPY_DEST = 1 },
            null,
        );
        const index_buffer = dx.createCommittedResource(
            .DEFAULT,
            .{},
            &d3d12.RESOURCE_DESC.buffer(max_num_triangles * @sizeOf(Triangle)),
            .{ .COPY_DEST = 1 },
            null,
        );
        const transform_buffer = dx.createCommittedResource(
            .DEFAULT,
            .{},
            &d3d12.RESOURCE_DESC.buffer(1024),
            .{ .COPY_DEST = 1 },
            null,
        );

        const vertex_buffer_srv = dx.allocateCpuDescriptors(.CBV_SRV_UAV, 1);
        dx.device.CreateShaderResourceView(
            dx.getResource(vertex_buffer),
            &d3d12.SHADER_RESOURCE_VIEW_DESC.structuredBuffer(0, max_num_vertices, @sizeOf(Vertex)),
            vertex_buffer_srv,
        );

        const index_buffer_srv = dx.allocateCpuDescriptors(.CBV_SRV_UAV, 1);
        dx.device.CreateShaderResourceView(
            dx.getResource(index_buffer),
            &d3d12.SHADER_RESOURCE_VIEW_DESC.typedBuffer(.R32_UINT, 0, 3 * max_num_triangles),
            index_buffer_srv,
        );

        const transform_buffer_srv = dx.allocateCpuDescriptors(.CBV_SRV_UAV, 1);
        dx.device.CreateShaderResourceView(
            dx.getResource(transform_buffer),
            &d3d12.SHADER_RESOURCE_VIEW_DESC.structuredBuffer(0, 1, @sizeOf(Mat4)),
            transform_buffer_srv,
        );

        dx.beginFrame();

        var draw_calls: [2]DrawCall = undefined;
        var start_index_location: u32 = 0;
        var base_vertex_location: u32 = 0;
        {
            var buf: [256]u8 = undefined;
            const path = std.fmt.bufPrint(
                buf[0..],
                "{}/data/cube.ply",
                .{std.fs.selfExeDirPath(buf[0..])},
            ) catch unreachable;

            var ply = PlyFileLoader.init(path);
            defer ply.deinit();

            const upload_verts = dx.allocateUploadBufferRegion(Vertex, ply.num_vertices);
            const upload_tris = dx.allocateUploadBufferRegion(Triangle, ply.num_triangles);

            ply.load(upload_verts.cpu_slice, upload_tris.cpu_slice);

            dx.cmdlist.CopyBufferRegion(
                dx.getResource(vertex_buffer),
                base_vertex_location * @sizeOf(Vertex),
                upload_verts.buffer,
                upload_verts.buffer_offset,
                upload_verts.cpu_slice.len * @sizeOf(Vertex),
            );
            dx.cmdlist.CopyBufferRegion(
                dx.getResource(index_buffer),
                start_index_location * @sizeOf(u32),
                upload_tris.buffer,
                upload_tris.buffer_offset,
                upload_tris.cpu_slice.len * @sizeOf(Triangle),
            );

            draw_calls[0] = DrawCall{
                .num_indices = ply.num_triangles * 3,
                .start_index_location = start_index_location,
                .base_vertex_location = base_vertex_location,
                .transform_location = 0,
            };

            start_index_location += ply.num_triangles * 3;
            base_vertex_location += ply.num_vertices;
        }
        {
            var buf: [256]u8 = undefined;
            const path = std.fmt.bufPrint(
                buf[0..],
                "{}/data/cube.ply",
                .{std.fs.selfExeDirPath(buf[0..])},
            ) catch unreachable;

            var ply = PlyFileLoader.init(path);
            defer ply.deinit();

            const upload_verts = dx.allocateUploadBufferRegion(Vertex, ply.num_vertices);
            const upload_tris = dx.allocateUploadBufferRegion(Triangle, ply.num_triangles);

            ply.load(upload_verts.cpu_slice, upload_tris.cpu_slice);

            dx.cmdlist.CopyBufferRegion(
                dx.getResource(vertex_buffer),
                base_vertex_location * @sizeOf(Vertex),
                upload_verts.buffer,
                upload_verts.buffer_offset,
                upload_verts.cpu_slice.len * @sizeOf(Vertex),
            );
            dx.cmdlist.CopyBufferRegion(
                dx.getResource(index_buffer),
                start_index_location * @sizeOf(u32),
                upload_tris.buffer,
                upload_tris.buffer_offset,
                upload_tris.cpu_slice.len * @sizeOf(Triangle),
            );

            draw_calls[1] = DrawCall{
                .num_indices = ply.num_triangles * 3,
                .start_index_location = start_index_location,
                .base_vertex_location = base_vertex_location,
                .transform_location = 0,
            };

            start_index_location += ply.num_triangles * 3;
            base_vertex_location += ply.num_vertices;
        }

        dx.addTransitionBarrier(vertex_buffer, .{ .NON_PIXEL_SHADER_RESOURCE = 1 });
        dx.addTransitionBarrier(index_buffer, .{ .NON_PIXEL_SHADER_RESOURCE = 1 });
        dx.flushResourceBarriers();
        dx.closeAndExecuteCommandList();
        dx.waitForGpu();

        return DemoState{
            .dx = dx,
            .srgb_texture = srgb_texture,
            .srgb_texture_rtv = srgb_texture_rtv,
            .depth_texture = depth_texture,
            .depth_texture_dsv = depth_texture_dsv,
            .vertex_buffer = vertex_buffer,
            .index_buffer = index_buffer,
            .transform_buffer = transform_buffer,
            .vertex_buffer_srv = vertex_buffer_srv,
            .index_buffer_srv = index_buffer_srv,
            .transform_buffer_srv = transform_buffer_srv,
            .pso = pso,
            .draw_calls = draw_calls,
        };
    }

    fn deinit(self: *DemoState) void {
        self.dx.waitForGpu();
        _ = self.dx.releaseResource(self.vertex_buffer);
        _ = self.dx.releaseResource(self.index_buffer);
        _ = self.dx.releaseResource(self.transform_buffer);
        _ = self.dx.releaseResource(self.srgb_texture);
        _ = self.dx.releaseResource(self.depth_texture);
        _ = self.dx.releasePipeline(self.pso);
        self.dx.deinit();
        self.* = undefined;
    }

    fn update(self: *DemoState) void {
        const stats = updateFrameStats(self.dx.window, window_name);
        var dx = &self.dx;

        dx.beginFrame();
        dx.addTransitionBarrier(self.srgb_texture, .{ .RENDER_TARGET = 1 });
        dx.flushResourceBarriers();
        dx.cmdlist.OMSetRenderTargets(1, &self.srgb_texture_rtv, os.TRUE, &self.depth_texture_dsv);
        dx.cmdlist.ClearRenderTargetView(
            self.srgb_texture_rtv,
            &[4]f32{ 0.2, 0.4, 0.8, 1.0 },
            0,
            null,
        );
        dx.cmdlist.ClearDepthStencilView(self.depth_texture_dsv, .{ .DEPTH = 1 }, 1.0, 0.0, 0, null);
        // Upload transform data.
        {
            const upload = dx.allocateUploadBufferRegion(Mat4, 1);
            upload.cpu_slice[0] = mat4.transpose(
                mat4.mul(
                    mat4.mul(
                        mat4.initRotationY(@floatCast(f32, stats.time)),
                        mat4.initLookAt(
                            vec3.init(0.0, 2.0, -4.0),
                            vec3.init(0.0, 0.0, 0.0),
                            vec3.init(0.0, 1.0, 0.0),
                        ),
                    ),
                    mat4.initPerspective(
                        math.pi / 3.0,
                        @intToFloat(f32, window_width) / @intToFloat(f32, window_height),
                        0.1,
                        10.0,
                    ),
                ),
            );
            dx.cmdlist.CopyBufferRegion(
                dx.getResource(self.transform_buffer),
                0,
                upload.buffer,
                upload.buffer_offset,
                upload.cpu_slice.len * @sizeOf(Mat4),
            );
        }
        dx.cmdlist.IASetPrimitiveTopology(.TRIANGLELIST);
        dx.setPipelineState(self.pso);

        dx.addTransitionBarrier(self.transform_buffer, .{ .NON_PIXEL_SHADER_RESOURCE = 1 });
        dx.flushResourceBarriers();

        const descriptor_table_base = blk: {
            const base = dx.copyDescriptorsToGpuHeap(1, self.vertex_buffer_srv);
            _ = dx.copyDescriptorsToGpuHeap(1, self.index_buffer_srv);
            _ = dx.copyDescriptorsToGpuHeap(1, self.transform_buffer_srv);
            break :blk base;
        };

        dx.cmdlist.SetGraphicsRoot32BitConstants(0, 3, &self.draw_calls[1], 0);
        dx.cmdlist.SetGraphicsRootDescriptorTable(1, descriptor_table_base);
        dx.cmdlist.DrawInstanced(self.draw_calls[1].num_indices, 1, 0, 0);

        dx.addTransitionBarrier(self.transform_buffer, .{ .COPY_DEST = 1 });

        const back_buffer = dx.getBackBuffer();
        dx.addTransitionBarrier(back_buffer.resource_handle, .{ .RESOLVE_DEST = 1 });
        dx.addTransitionBarrier(self.srgb_texture, .{ .RESOLVE_SOURCE = 1 });
        dx.flushResourceBarriers();

        dx.cmdlist.ResolveSubresource(
            dx.getResource(back_buffer.resource_handle),
            0,
            dx.getResource(self.srgb_texture),
            0,
            .R8G8B8A8_UNORM,
        );
        dx.addTransitionBarrier(back_buffer.resource_handle, .{});
        dx.flushResourceBarriers();
        dx.endFrame();
    }
};

const PlyFileLoader = struct {
    num_vertices: u32,
    num_triangles: u32,
    file: std.fs.File,

    fn init(path: []const u8) PlyFileLoader {
        const file = std.fs.openFileAbsolute(path, .{ .read = true }) catch unreachable;

        var num_vertices: u32 = 0;
        var num_triangles: u32 = 0;

        var buf: [128]u8 = undefined;
        const reader = file.reader();
        line_loop: while (reader.readUntilDelimiterOrEof(buf[0..], '\n') catch null) |line| {
            var it = std.mem.split(line, " ");

            while (it.next()) |item| {
                if (std.mem.eql(u8, item, "end_header")) {
                    break :line_loop;
                } else if (std.mem.eql(u8, item, "vertex")) {
                    num_vertices = std.fmt.parseInt(u32, it.next().?, 10) catch unreachable;
                } else if (std.mem.eql(u8, item, "face")) {
                    num_triangles = std.fmt.parseInt(u32, it.next().?, 10) catch unreachable;
                }
            }
        }
        assert(num_vertices > 0 and num_triangles > 0);

        return PlyFileLoader{
            .num_vertices = num_vertices,
            .num_triangles = num_triangles,
            .file = file,
        };
    }

    fn deinit(self: *PlyFileLoader) void {
        self.file.close();
        self.* = undefined;
    }

    fn load(self: PlyFileLoader, vertices: []Vertex, triangles: []Triangle) void {
        var buf: [256]u8 = undefined;
        const reader = self.file.reader();

        for (vertices) |*vertex| {
            const line = reader.readUntilDelimiterOrEof(buf[0..], '\n') catch unreachable;
            var it = std.mem.split(line.?, " ");

            vertex.* = Vertex{
                .position = Vec3{
                    std.fmt.parseFloat(f32, it.next().?) catch unreachable,
                    std.fmt.parseFloat(f32, it.next().?) catch unreachable,
                    std.fmt.parseFloat(f32, it.next().?) catch unreachable,
                },
                .normal = Vec3{
                    std.fmt.parseFloat(f32, it.next().?) catch unreachable,
                    std.fmt.parseFloat(f32, it.next().?) catch unreachable,
                    std.fmt.parseFloat(f32, it.next().?) catch unreachable,
                },
            };
        }

        for (triangles) |*tri| {
            const line = reader.readUntilDelimiterOrEof(buf[0..], '\n') catch unreachable;
            var it = std.mem.split(line.?, " ");

            const num_verts = std.fmt.parseInt(u32, it.next().?, 10) catch unreachable;
            assert(num_verts == 3);

            tri.* = Triangle{
                .index0 = std.fmt.parseInt(u32, it.next().?, 10) catch unreachable,
                .index1 = std.fmt.parseInt(u32, it.next().?, 10) catch unreachable,
                .index2 = std.fmt.parseInt(u32, it.next().?, 10) catch unreachable,
            };
        }
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
