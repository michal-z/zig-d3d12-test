const std = @import("std");
pub const math = std.math;

pub const Vec3 = packed struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn dot(self: Vec3, other: Vec3) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }
};
