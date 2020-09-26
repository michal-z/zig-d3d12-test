const std = @import("std");
const assert = std.debug.assert;
pub const math = std.math;

pub const Vec3 = [3]f32;
pub const Vec4 = [4]f32;
pub const Mat4 = [4][4]f32;

pub const vec3 = struct {
    pub fn dot(a: Vec3, b: Vec3) f32 {
        return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
    }

    pub fn add(a: Vec3, b: Vec3) Vec3 {
        return Vec3{ a[0] + b[0], a[1] + b[1], a[2] + b[2] };
    }

    pub fn init(x: f32, y: f32, z: f32) Vec3 {
        return Vec3{ x, y, z };
    }

    pub fn length(a: Vec3) f32 {
        return math.sqrt(dot(a, a));
    }
};

pub const mat4 = struct {
    pub fn transpose(a: Mat4) Mat4 {
        return Mat4{
            [_]f32{ a[0][0], a[1][0], a[2][0], a[3][0] },
            [_]f32{ a[0][1], a[1][1], a[2][1], a[3][1] },
            [_]f32{ a[0][2], a[1][2], a[2][2], a[3][2] },
            [_]f32{ a[0][3], a[1][3], a[2][3], a[3][3] },
        };
    }

    pub fn mul(a: Mat4, b: Mat4) Mat4 {
        return Mat4{
            [_]f32{
                a[0][0] * b[0][0] + a[0][1] * b[1][0] + a[0][2] * b[2][0] + a[0][3] * b[3][0],
                a[0][0] * b[0][1] + a[0][1] * b[1][1] + a[0][2] * b[2][1] + a[0][3] * b[3][1],
                a[0][0] * b[0][2] + a[0][1] * b[1][2] + a[0][2] * b[2][2] + a[0][3] * b[3][2],
                a[0][0] * b[0][3] + a[0][1] * b[1][3] + a[0][2] * b[2][3] + a[0][3] * b[3][3],
            },
            [_]f32{
                a[1][0] * b[0][0] + a[1][1] * b[1][0] + a[1][2] * b[2][0] + a[1][3] * b[3][0],
                a[1][0] * b[0][1] + a[1][1] * b[1][1] + a[1][2] * b[2][1] + a[1][3] * b[3][1],
                a[1][0] * b[0][2] + a[1][1] * b[1][2] + a[1][2] * b[2][2] + a[1][3] * b[3][2],
                a[1][0] * b[0][3] + a[1][1] * b[1][3] + a[1][2] * b[2][3] + a[1][3] * b[3][3],
            },
            [_]f32{
                a[2][0] * b[0][0] + a[2][1] * b[1][0] + a[2][2] * b[2][0] + a[2][3] * b[3][0],
                a[2][0] * b[0][1] + a[2][1] * b[1][1] + a[2][2] * b[2][1] + a[2][3] * b[3][1],
                a[2][0] * b[0][2] + a[2][1] * b[1][2] + a[2][2] * b[2][2] + a[2][3] * b[3][2],
                a[2][0] * b[0][3] + a[2][1] * b[1][3] + a[2][2] * b[2][3] + a[2][3] * b[3][3],
            },
            [_]f32{
                a[3][0] * b[0][0] + a[3][1] * b[1][0] + a[3][2] * b[2][0] + a[3][3] * b[3][0],
                a[3][0] * b[0][1] + a[3][1] * b[1][1] + a[3][2] * b[2][1] + a[3][3] * b[3][1],
                a[3][0] * b[0][2] + a[3][1] * b[1][2] + a[3][2] * b[2][2] + a[3][3] * b[3][2],
                a[3][0] * b[0][3] + a[3][1] * b[1][3] + a[3][2] * b[2][3] + a[3][3] * b[3][3],
            },
        };
    }

    pub fn initRotationY(angle: f32) Mat4 {
        const sinv = math.sin(angle);
        const cosv = math.cos(angle);
        return Mat4{
            [_]f32{ cosv, 0.0, -sinv, 0.0 },
            [_]f32{ 0.0, 1.0, 0.0, 0.0 },
            [_]f32{ sinv, 0.0, cosv, 0.0 },
            [_]f32{ 0.0, 0.0, 0.0, 1.0 },
        };
    }

    pub fn initPerspective(fovy: f32, aspect: f32, near: f32, far: f32) Mat4 {
        const sinfov = math.sin(0.5 * fovy);
        const cosfov = math.cos(0.5 * fovy);

        assert(near > 0.0 and far > 0.0 and far > near);
        assert(!math.approxEq(f32, sinfov, 0.0, 0.0001));
        assert(!math.approxEq(f32, far, near, 0.001));
        assert(!math.approxEq(f32, aspect, 0.0, 0.01));

        const h = cosfov / sinfov;
        const w = h / aspect;
        const r = far / (far - near);
        return Mat4{
            [_]f32{ w, 0.0, 0.0, 0.0 },
            [_]f32{ 0.0, h, 0.0, 0.0 },
            [_]f32{ 0.0, 0.0, r, 1.0 },
            [_]f32{ 0.0, 0.0, -r * near, 0.0 },
        };
    }

    pub fn initIdentity() Mat4 {
        return Mat4{
            [_]f32{ 1.0, 0.0, 0.0, 0.0 },
            [_]f32{ 0.0, 1.0, 0.0, 0.0 },
            [_]f32{ 0.0, 0.0, 1.0, 0.0 },
            [_]f32{ 0.0, 0.0, 0.0, 1.0 },
        };
    }

    pub fn initTranslation(x: f32, y: f32, z: f32) Mat4 {
        return Mat4{
            [_]f32{ 1.0, 0.0, 0.0, 0.0 },
            [_]f32{ 0.0, 1.0, 0.0, 0.0 },
            [_]f32{ 0.0, 0.0, 1.0, 0.0 },
            [_]f32{ x, y, z, 1.0 },
        };
    }
};
