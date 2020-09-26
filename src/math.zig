const std = @import("std");
pub const math = std.math;

pub const Vec3 = struct {
    _: [3]f32,

    pub fn dot(a: Vec3, b: Vec3) f32 {
        return a._[0] * b._[0] +
            a._[1] * b._[1] +
            a._[2] * b._[2];
    }

    pub fn add(a: Vec3, b: Vec3) Vec3 {
        return Vec3{
            ._ = [_]f32{
                a._[0] + b._[0],
                a._[1] + b._[1],
                a._[2] + b._[2],
            },
        };
    }
};

pub fn vec3(x: f32, y: f32, z: f32) Vec3 {
    return Vec3{ ._ = [_]f32{ x, y, z } };
}

pub const Mat4x4 = struct {
    _: [4][4]f32,

    pub fn identity() Mat4x4 {
        return Mat4x4{
            ._ = [_][4]f32{
                [_]f32{ 1.0, 0.0, 0.0, 0.0 },
                [_]f32{ 0.0, 1.0, 0.0, 0.0 },
                [_]f32{ 0.0, 0.0, 1.0, 0.0 },
                [_]f32{ 0.0, 0.0, 0.0, 1.0 },
            },
        };
    }

    pub fn translation(x: f32, y: f32, z: f32) Mat4x4 {
        return Mat4x4{
            ._ = [_][4]f32{
                [_]f32{ 1.0, 0.0, 0.0, 0.0 },
                [_]f32{ 0.0, 1.0, 0.0, 0.0 },
                [_]f32{ 0.0, 0.0, 1.0, 0.0 },
                [_]f32{ x, y, z, 1.0 },
            },
        };
    }
};
