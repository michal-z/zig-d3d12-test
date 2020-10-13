const std = @import("std");
const assert = std.debug.assert;
const os = @import("windows/windows.zig");
const dxgi = @import("windows/dxgi.zig");
const d3d12 = @import("windows/d3d12.zig");
const d2d1 = @import("windows/d2d1.zig");
const dwrite = @import("windows/dwrite.zig");
const dcommon = @import("windows/dcommon.zig");
const gr = @import("graphics.zig");
usingnamespace @import("math.zig");

const window_name = "zig d3d12 test";
const window_width = 1920;
const window_height = 1080;
const window_num_samples = 8;

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

const Mesh = struct {
    start_index_location: u32,
    base_vertex_location: u32,
    num_indices: u32,
};

const Entity = struct {
    mesh: Mesh,
    id: u32,
    position: Vec3,
};

const DemoState = struct {
    dx: gr.DxContext,
    srgb_texture: gr.ResourceHandle,
    depth_texture: gr.ResourceHandle,
    vertex_buffer: gr.ResourceHandle,
    index_buffer: gr.ResourceHandle,
    transform_buffer: gr.ResourceHandle,
    srgb_texture_rtv: d3d12.CPU_DESCRIPTOR_HANDLE,
    depth_texture_dsv: d3d12.CPU_DESCRIPTOR_HANDLE,
    vertex_buffer_srv: d3d12.CPU_DESCRIPTOR_HANDLE,
    index_buffer_srv: d3d12.CPU_DESCRIPTOR_HANDLE,
    transform_buffer_srv: d3d12.CPU_DESCRIPTOR_HANDLE,
    pipelines: std.ArrayList(gr.PipelineHandle),
    entities: std.ArrayList(Entity),
    brush: *d2d1.ISolidColorBrush,
    text_format: *dwrite.ITextFormat,

    fn init(allocator: *std.mem.Allocator, window: os.HWND) DemoState {
        var dx = gr.DxContext.init(window);

        var srgb_texture: gr.ResourceHandle = undefined;
        var depth_texture: gr.ResourceHandle = undefined;
        var srgb_texture_rtv: d3d12.CPU_DESCRIPTOR_HANDLE = undefined;
        var depth_texture_dsv: d3d12.CPU_DESCRIPTOR_HANDLE = undefined;
        initRenderTarget(&dx, &srgb_texture, &depth_texture, &srgb_texture_rtv, &depth_texture_dsv);

        var pipelines = std.ArrayList(gr.PipelineHandle).init(allocator);
        initDx12Pipelines(&dx, &pipelines);

        var brush: *d2d1.ISolidColorBrush = undefined;
        var text_format: *dwrite.ITextFormat = undefined;
        init2dResources(dx, &brush, &text_format);

        dx.beginFrame();

        var meshes = std.ArrayList(Mesh).init(allocator);
        defer meshes.deinit();
        var vertex_buffer: gr.ResourceHandle = undefined;
        var index_buffer: gr.ResourceHandle = undefined;
        var vertex_buffer_srv: d3d12.CPU_DESCRIPTOR_HANDLE = undefined;
        var index_buffer_srv: d3d12.CPU_DESCRIPTOR_HANDLE = undefined;
        initMeshes(
            &dx,
            &meshes,
            &vertex_buffer,
            &index_buffer,
            &vertex_buffer_srv,
            &index_buffer_srv,
        );

        var entities = std.ArrayList(Entity).init(allocator);
        var transform_buffer: gr.ResourceHandle = undefined;
        var transform_buffer_srv: d3d12.CPU_DESCRIPTOR_HANDLE = undefined;
        initEntities(&dx, meshes.items, &entities, &transform_buffer, &transform_buffer_srv);

        dx.addTransitionBarrier(vertex_buffer, .{ .NON_PIXEL_SHADER_RESOURCE = true });
        dx.addTransitionBarrier(index_buffer, .{ .NON_PIXEL_SHADER_RESOURCE = true });
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
            .pipelines = pipelines,
            .entities = entities,
            .brush = brush,
            .text_format = text_format,
        };
    }

    fn deinit(self: *DemoState) void {
        self.dx.waitForGpu();
        self.entities.deinit();
        for (self.pipelines.items) |pso| {
            _ = self.dx.releasePipeline(pso);
        }
        self.pipelines.deinit();
        _ = self.brush.Release();
        _ = self.text_format.Release();
        _ = self.dx.releaseResource(self.vertex_buffer);
        _ = self.dx.releaseResource(self.index_buffer);
        _ = self.dx.releaseResource(self.transform_buffer);
        _ = self.dx.releaseResource(self.srgb_texture);
        _ = self.dx.releaseResource(self.depth_texture);
        self.dx.deinit();
        self.* = undefined;
    }

    fn update(self: *DemoState) void {
        const stats = updateFrameStats(self.dx.window, window_name);
        var dx = &self.dx;

        dx.beginFrame();
        dx.addTransitionBarrier(self.srgb_texture, .{ .RENDER_TARGET = true });
        dx.flushResourceBarriers();

        dx.cmdlist.OMSetRenderTargets(
            1,
            &[_]d3d12.CPU_DESCRIPTOR_HANDLE{self.srgb_texture_rtv},
            os.TRUE,
            &self.depth_texture_dsv,
        );
        dx.cmdlist.ClearRenderTargetView(
            self.srgb_texture_rtv,
            &[4]f32{ 0.2, 0.4, 0.8, 1.0 },
            0,
            null,
        );
        dx.cmdlist.ClearDepthStencilView(self.depth_texture_dsv, .{ .DEPTH = true }, 1.0, 0.0, 0, null);
        dx.cmdlist.IASetPrimitiveTopology(.TRIANGLELIST);
        dx.setPipelineState(self.pipelines.items[0]);

        dx.addTransitionBarrier(self.transform_buffer, .{ .NON_PIXEL_SHADER_RESOURCE = true });
        dx.flushResourceBarriers();

        dx.cmdlist.SetGraphicsRootDescriptorTable(1, blk: {
            const base = dx.copyDescriptorsToGpuHeap(1, self.vertex_buffer_srv);
            _ = dx.copyDescriptorsToGpuHeap(1, self.index_buffer_srv);
            _ = dx.copyDescriptorsToGpuHeap(1, self.transform_buffer_srv);
            break :blk base;
        });

        for (self.entities.items) |entity| {
            dx.cmdlist.SetGraphicsRoot32BitConstants(0, 3, &[_]u32{
                entity.mesh.start_index_location,
                entity.mesh.base_vertex_location,
                entity.id,
            }, 0);
            dx.cmdlist.DrawInstanced(entity.mesh.num_indices, 1, 0, 0);
        }

        dx.addTransitionBarrier(self.transform_buffer, .{ .COPY_DEST = true });

        const back_buffer = dx.getBackBuffer();
        dx.addTransitionBarrier(back_buffer.resource_handle, .{ .RESOLVE_DEST = true });
        dx.addTransitionBarrier(self.srgb_texture, .{ .RESOLVE_SOURCE = true });
        dx.flushResourceBarriers();

        dx.cmdlist.ResolveSubresource(
            dx.getResource(back_buffer.resource_handle),
            0,
            dx.getResource(self.srgb_texture),
            0,
            .R8G8B8A8_UNORM,
        );
        dx.addTransitionBarrier(back_buffer.resource_handle, .{ .RENDER_TARGET = true });
        dx.flushResourceBarriers();
        dx.closeAndExecuteCommandList();

        dx.beginDraw2d();
        dx.d2d.context.SetTransform(&dcommon.MATRIX_3X2_F.identity());
        self.brush.SetColor(&d2d1.COLOR_F.linearToSrgb(0.8, 0.0, 0.0, 0.5));
        dx.d2d.context.FillEllipse(
            &d2d1.ELLIPSE{ .point = .{ .x = 1200.0, .y = 300 }, .radiusX = 200.0, .radiusY = 100.0 },
            @ptrCast(*d2d1.IBrush, self.brush),
        );
        dx.d2d.context.DrawLine(
            .{ .x = 100.0, .y = 100.0 },
            .{ .x = 800.0, .y = 800.0 },
            @ptrCast(*d2d1.IBrush, self.brush),
            30.0,
            null,
        );
        const text = std.unicode.utf8ToUtf16LeStringLiteral("magic is everywhere");
        self.brush.SetColor(&d2d1.COLOR_F.Black);
        dx.d2d.context.DrawText(
            text[0..],
            text.len,
            self.text_format,
            &dcommon.RECT_F{
                .left = 0.0,
                .top = 0.0,
                .right = @intToFloat(f32, window_width),
                .bottom = @intToFloat(f32, window_height),
            },
            @ptrCast(*d2d1.IBrush, self.brush),
            .{},
            .NATURAL,
        );
        dx.endDraw2d();

        dx.endFrame();
    }

    fn initMeshes(
        dx: *gr.DxContext,
        meshes: *std.ArrayList(Mesh),
        vertex_buffer: *gr.ResourceHandle,
        index_buffer: *gr.ResourceHandle,
        vertex_buffer_srv: *d3d12.CPU_DESCRIPTOR_HANDLE,
        index_buffer_srv: *d3d12.CPU_DESCRIPTOR_HANDLE,
    ) void {
        const max_num_vertices = 10_000;
        const max_num_triangles = 10_000;

        vertex_buffer.* = dx.createCommittedResource(
            .DEFAULT,
            .{},
            &d3d12.RESOURCE_DESC.buffer(max_num_vertices * @sizeOf(Vertex)),
            .{ .COPY_DEST = true },
            null,
        );
        index_buffer.* = dx.createCommittedResource(
            .DEFAULT,
            .{},
            &d3d12.RESOURCE_DESC.buffer(max_num_triangles * @sizeOf(Triangle)),
            .{ .COPY_DEST = true },
            null,
        );

        vertex_buffer_srv.* = dx.allocateCpuDescriptors(.CBV_SRV_UAV, 1);
        dx.device.CreateShaderResourceView(
            dx.getResource(vertex_buffer.*),
            &d3d12.SHADER_RESOURCE_VIEW_DESC.structuredBuffer(0, max_num_vertices, @sizeOf(Vertex)),
            vertex_buffer_srv.*,
        );

        index_buffer_srv.* = dx.allocateCpuDescriptors(.CBV_SRV_UAV, 1);
        dx.device.CreateShaderResourceView(
            dx.getResource(index_buffer.*),
            &d3d12.SHADER_RESOURCE_VIEW_DESC.typedBuffer(.R32_UINT, 0, 3 * max_num_triangles),
            index_buffer_srv.*,
        );

        const mesh_names = [_][]const u8{ "cube", "sphere" };
        var start_index_location: u32 = 0;
        var base_vertex_location: u32 = 0;

        for (mesh_names) |mesh_name, mesh_idx| {
            var buf: [256]u8 = undefined;
            const path = std.fmt.bufPrint(
                buf[0..],
                "{}/data/{}.ply",
                .{ std.fs.selfExeDirPath(buf[0..]), mesh_name },
            ) catch unreachable;

            var ply = PlyFileLoader.init(path);
            defer ply.deinit();

            const upload_verts = dx.allocateUploadBufferRegion(Vertex, ply.num_vertices);
            const upload_tris = dx.allocateUploadBufferRegion(Triangle, ply.num_triangles);

            ply.load(upload_verts.cpu_slice, upload_tris.cpu_slice);

            dx.cmdlist.CopyBufferRegion(
                dx.getResource(vertex_buffer.*),
                base_vertex_location * @sizeOf(Vertex),
                upload_verts.buffer,
                upload_verts.buffer_offset,
                upload_verts.cpu_slice.len * @sizeOf(Vertex),
            );
            dx.cmdlist.CopyBufferRegion(
                dx.getResource(index_buffer.*),
                start_index_location * @sizeOf(u32),
                upload_tris.buffer,
                upload_tris.buffer_offset,
                upload_tris.cpu_slice.len * @sizeOf(Triangle),
            );

            meshes.append(Mesh{
                .num_indices = ply.num_triangles * 3,
                .start_index_location = start_index_location,
                .base_vertex_location = base_vertex_location,
            }) catch unreachable;

            start_index_location += ply.num_triangles * 3;
            base_vertex_location += ply.num_vertices;
        }
    }

    fn initEntities(
        dx: *gr.DxContext,
        meshes: []Mesh,
        entities: *std.ArrayList(Entity),
        transform_buffer: *gr.ResourceHandle,
        transform_buffer_srv: *d3d12.CPU_DESCRIPTOR_HANDLE,
    ) void {
        var buf: [256]u8 = undefined;
        const path = std.fmt.bufPrint(
            buf[0..],
            "{}/data/map.ppm",
            .{std.fs.selfExeDirPath(buf[0..])},
        ) catch unreachable;

        const file = std.fs.openFileAbsolute(path, .{ .read = true }) catch unreachable;
        defer file.close();

        // Line 1.
        const reader = file.reader();
        if (reader.readUntilDelimiterOrEof(buf[0..], '\n') catch unreachable) |line| {
            assert(std.mem.eql(u8, "P6", line));
        }

        // Line 2.
        var map_width: u32 = 0;
        var map_height: u32 = 0;
        if (reader.readUntilDelimiterOrEof(buf[0..], '\n') catch unreachable) |line| {
            var it = std.mem.split(line, " ");
            map_width = std.fmt.parseInt(u32, it.next().?, 10) catch unreachable;
            map_height = std.fmt.parseInt(u32, it.next().?, 10) catch unreachable;
        }

        // Line 3.
        if (reader.readUntilDelimiterOrEof(buf[0..], '\n') catch unreachable) |line| {
            assert(std.mem.eql(u8, "255", line));
        }

        var y: u32 = 0;
        var current_id: u32 = 1;
        while (y < map_height) : (y += 1) {
            var x: u32 = 0;
            while (x < map_width) : (x += 1) {
                const desc = reader.readBytesNoEof(3) catch unreachable;
                if (desc[0] == 0 and desc[1] == 0 and desc[2] == 0) {
                    entities.append(
                        Entity{
                            .mesh = meshes[0],
                            .id = current_id,
                            .position = vec3.init(@intToFloat(f32, x), 0.0, @intToFloat(f32, y)),
                        },
                    ) catch unreachable;
                    current_id += 1;
                }
            }
        }

        const num_transforms: u32 = @intCast(u32, entities.items.len + 1);
        transform_buffer.* = dx.createCommittedResource(
            .DEFAULT,
            .{},
            &d3d12.RESOURCE_DESC.buffer(num_transforms * @sizeOf(Mat4)),
            .{ .COPY_DEST = true },
            null,
        );

        transform_buffer_srv.* = dx.allocateCpuDescriptors(.CBV_SRV_UAV, 1);
        dx.device.CreateShaderResourceView(
            dx.getResource(transform_buffer.*),
            &d3d12.SHADER_RESOURCE_VIEW_DESC.structuredBuffer(0, num_transforms, @sizeOf(Mat4)),
            transform_buffer_srv.*,
        );

        // Upload transform data.
        {
            const upload = dx.allocateUploadBufferRegion(Mat4, num_transforms);
            upload.cpu_slice[0] = mat4.transpose(
                mat4.mul(
                    mat4.initLookAt(
                        vec3.init(8.0, 8.0, -8.0),
                        vec3.init(0.0, 0.0, 0.0),
                        vec3.init(0.0, 1.0, 0.0),
                    ),
                    mat4.initPerspective(
                        math.pi / 3.0,
                        @intToFloat(f32, window_width) / @intToFloat(f32, window_height),
                        0.1,
                        100.0,
                    ),
                ),
            );

            for (entities.items) |entity, entity_idx| {
                upload.cpu_slice[entity_idx + 1] = mat4.transpose(mat4.initTranslation(entity.position));
            }

            dx.cmdlist.CopyBufferRegion(
                dx.getResource(transform_buffer.*),
                0,
                upload.buffer,
                upload.buffer_offset,
                upload.cpu_slice.len * @sizeOf(Mat4),
            );
        }
    }

    fn initRenderTarget(
        dx: *gr.DxContext,
        srgb_texture: *gr.ResourceHandle,
        depth_texture: *gr.ResourceHandle,
        srgb_texture_rtv: *d3d12.CPU_DESCRIPTOR_HANDLE,
        depth_texture_dsv: *d3d12.CPU_DESCRIPTOR_HANDLE,
    ) void {
        srgb_texture.* = dx.createCommittedResource(
            .DEFAULT,
            .{},
            &blk: {
                var desc = d3d12.RESOURCE_DESC.tex2d(.R8G8B8A8_UNORM_SRGB, window_width, window_height);
                desc.Flags = .{ .ALLOW_RENDER_TARGET = true };
                desc.SampleDesc.Count = window_num_samples;
                break :blk desc;
            },
            .{ .RENDER_TARGET = true },
            &d3d12.CLEAR_VALUE.color(.R8G8B8A8_UNORM_SRGB, [4]f32{ 0.2, 0.4, 0.8, 1.0 }),
        );
        srgb_texture_rtv.* = dx.allocateCpuDescriptors(.RTV, 1);
        dx.device.CreateRenderTargetView(dx.getResource(srgb_texture.*), null, srgb_texture_rtv.*);

        depth_texture.* = dx.createCommittedResource(
            .DEFAULT,
            .{},
            &blk: {
                var desc = d3d12.RESOURCE_DESC.tex2d(.D32_FLOAT, window_width, window_height);
                desc.Flags = .{ .ALLOW_DEPTH_STENCIL = true, .DENY_SHADER_RESOURCE = true };
                desc.SampleDesc.Count = window_num_samples;
                break :blk desc;
            },
            .{ .DEPTH_WRITE = true },
            &d3d12.CLEAR_VALUE.depthStencil(.D32_FLOAT, 1.0, 0),
        );
        depth_texture_dsv.* = dx.allocateCpuDescriptors(.DSV, 1);
        dx.device.CreateDepthStencilView(dx.getResource(depth_texture.*), null, depth_texture_dsv.*);
    }

    fn initDx12Pipelines(dx: *gr.DxContext, pipelines: *std.ArrayList(gr.PipelineHandle)) void {
        pipelines.append(dx.createGraphicsPipeline(d3d12.GRAPHICS_PIPELINE_STATE_DESC{
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
        })) catch unreachable;
    }

    fn init2dResources(
        dx: gr.DxContext,
        brush: **d2d1.ISolidColorBrush,
        text_format: **dwrite.ITextFormat,
    ) void {
        gr.vhr(dx.d2d.context.CreateSolidColorBrush(
            &d2d1.COLOR_F{ .r = 1.0, .g = 0.0, .b = 0.0, .a = 0.5 },
            null,
            &brush.*,
        ));

        gr.vhr(dx.d2d.dwrite_factory.CreateTextFormat(
            std.unicode.utf8ToUtf16LeStringLiteral("Verdana")[0..],
            null,
            .NORMAL,
            .NORMAL,
            .NORMAL,
            50.0,
            std.unicode.utf8ToUtf16LeStringLiteral("en-us")[0..],
            &text_format.*,
        ));
        gr.vhr(text_format.*.SetTextAlignment(.CENTER));
        gr.vhr(text_format.*.SetParagraphAlignment(.CENTER));
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

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        assert(leaked == false);
    }

    var demo_state = DemoState.init(&gpa.allocator, window.?);
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
