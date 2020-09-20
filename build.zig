const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("zig-d3d12-test", "src/main.zig");
    exe.setTarget(.{
        .cpu_arch = .x86_64,
        .os_tag = .windows,
        .abi = .gnu,
    });
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const shader_step = b.step("shader", "build shaders");
    shader_step.dependOn(&b.addSystemCommand(&[_][]const u8{"shaders\\build.bat"}).step);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
