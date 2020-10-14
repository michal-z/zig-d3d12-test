const std = @import("std");
const assert = std.debug.assert;
pub const math = std.math;

pub const Scalar = f32;
pub const Vec3 = [3]Scalar;
pub const Mat4 = [4][4]Scalar;

pub const scalar = struct {
    pub fn modAngle(in_angle: Scalar) Scalar {
        const angle = in_angle + math.pi;
        var temp: Scalar = math.fabs(angle);
        temp = temp - (2.0 * math.pi * @intToFloat(Scalar, @floatToInt(i32, temp / math.pi)));
        temp = temp - math.pi;
        if (angle < 0.0) {
            temp = -temp;
        }
        return temp;
    }
};

pub const vec3 = struct {
    pub fn dot(a: Vec3, b: Vec3) Scalar {
        return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
    }

    pub fn cross(a: Vec3, b: Vec3) Vec3 {
        return .{
            a[1] * b[2] - a[2] * b[1],
            a[2] * b[0] - a[0] * b[2],
            a[0] * b[1] - a[1] * b[0],
        };
    }

    pub fn add(a: Vec3, b: Vec3) Vec3 {
        return .{ a[0] + b[0], a[1] + b[1], a[2] + b[2] };
    }

    pub fn sub(a: Vec3, b: Vec3) Vec3 {
        return .{ a[0] - b[0], a[1] - b[1], a[2] - b[2] };
    }

    pub fn scale(a: Vec3, b: Scalar) Vec3 {
        return .{ a[0] * b, a[1] * b, a[2] * b };
    }

    pub fn init(x: Scalar, y: Scalar, z: Scalar) Vec3 {
        return .{ x, y, z };
    }

    pub fn length(a: Vec3) Scalar {
        return math.sqrt(dot(a, a));
    }

    pub fn normalize(a: Vec3) Vec3 {
        const len = length(a);
        assert(!math.approxEq(Scalar, len, 0.0, 0.0001));
        const rcplen = 1.0 / len;
        return .{ rcplen * a[0], rcplen * a[1], rcplen * a[2] };
    }

    pub fn transform(a: Vec3, b: Mat4) Vec3 {
        return .{
            a[0] * b[0][0] + a[1] * b[1][0] + a[2] * b[2][0] + b[3][0],
            a[0] * b[0][1] + a[1] * b[1][1] + a[2] * b[2][1] + b[3][1],
            a[0] * b[0][2] + a[1] * b[1][2] + a[2] * b[2][2] + b[3][2],
        };
    }

    pub fn transformNormal(a: Vec3, b: Mat4) Vec3 {
        return .{
            a[0] * b[0][0] + a[1] * b[1][0] + a[2] * b[2][0],
            a[0] * b[0][1] + a[1] * b[1][1] + a[2] * b[2][1],
            a[0] * b[0][2] + a[1] * b[1][2] + a[2] * b[2][2],
        };
    }
};

pub const mat4 = struct {
    pub fn transpose(a: Mat4) Mat4 {
        return .{
            [_]Scalar{ a[0][0], a[1][0], a[2][0], a[3][0] },
            [_]Scalar{ a[0][1], a[1][1], a[2][1], a[3][1] },
            [_]Scalar{ a[0][2], a[1][2], a[2][2], a[3][2] },
            [_]Scalar{ a[0][3], a[1][3], a[2][3], a[3][3] },
        };
    }

    pub fn mul(a: Mat4, b: Mat4) Mat4 {
        return .{
            [_]Scalar{
                a[0][0] * b[0][0] + a[0][1] * b[1][0] + a[0][2] * b[2][0] + a[0][3] * b[3][0],
                a[0][0] * b[0][1] + a[0][1] * b[1][1] + a[0][2] * b[2][1] + a[0][3] * b[3][1],
                a[0][0] * b[0][2] + a[0][1] * b[1][2] + a[0][2] * b[2][2] + a[0][3] * b[3][2],
                a[0][0] * b[0][3] + a[0][1] * b[1][3] + a[0][2] * b[2][3] + a[0][3] * b[3][3],
            },
            [_]Scalar{
                a[1][0] * b[0][0] + a[1][1] * b[1][0] + a[1][2] * b[2][0] + a[1][3] * b[3][0],
                a[1][0] * b[0][1] + a[1][1] * b[1][1] + a[1][2] * b[2][1] + a[1][3] * b[3][1],
                a[1][0] * b[0][2] + a[1][1] * b[1][2] + a[1][2] * b[2][2] + a[1][3] * b[3][2],
                a[1][0] * b[0][3] + a[1][1] * b[1][3] + a[1][2] * b[2][3] + a[1][3] * b[3][3],
            },
            [_]Scalar{
                a[2][0] * b[0][0] + a[2][1] * b[1][0] + a[2][2] * b[2][0] + a[2][3] * b[3][0],
                a[2][0] * b[0][1] + a[2][1] * b[1][1] + a[2][2] * b[2][1] + a[2][3] * b[3][1],
                a[2][0] * b[0][2] + a[2][1] * b[1][2] + a[2][2] * b[2][2] + a[2][3] * b[3][2],
                a[2][0] * b[0][3] + a[2][1] * b[1][3] + a[2][2] * b[2][3] + a[2][3] * b[3][3],
            },
            [_]Scalar{
                a[3][0] * b[0][0] + a[3][1] * b[1][0] + a[3][2] * b[2][0] + a[3][3] * b[3][0],
                a[3][0] * b[0][1] + a[3][1] * b[1][1] + a[3][2] * b[2][1] + a[3][3] * b[3][1],
                a[3][0] * b[0][2] + a[3][1] * b[1][2] + a[3][2] * b[2][2] + a[3][3] * b[3][2],
                a[3][0] * b[0][3] + a[3][1] * b[1][3] + a[3][2] * b[2][3] + a[3][3] * b[3][3],
            },
        };
    }

    pub fn initRotationX(angle: Scalar) Mat4 {
        const sinv = math.sin(angle);
        const cosv = math.cos(angle);
        return .{
            [_]Scalar{ 1.0, 0.0, 0.0, 0.0 },
            [_]Scalar{ 0.0, cosv, sinv, 0.0 },
            [_]Scalar{ 0.0, -sinv, cosv, 0.0 },
            [_]Scalar{ 0.0, 0.0, 0.0, 1.0 },
        };
    }

    pub fn initRotationY(angle: Scalar) Mat4 {
        const sinv = math.sin(angle);
        const cosv = math.cos(angle);
        return .{
            [_]Scalar{ cosv, 0.0, -sinv, 0.0 },
            [_]Scalar{ 0.0, 1.0, 0.0, 0.0 },
            [_]Scalar{ sinv, 0.0, cosv, 0.0 },
            [_]Scalar{ 0.0, 0.0, 0.0, 1.0 },
        };
    }

    pub fn initRotationZ(angle: Scalar) Mat4 {
        const sinv = math.sin(angle);
        const cosv = math.cos(angle);
        return .{
            [_]Scalar{ cosv, sinv, 0.0, 0.0 },
            [_]Scalar{ -sinv, cosv, 0.0, 0.0 },
            [_]Scalar{ 0.0, 0.0, 1.0, 0.0 },
            [_]Scalar{ 0.0, 0.0, 0.0, 1.0 },
        };
    }

    pub fn initPerspective(fovy: Scalar, aspect: Scalar, near: Scalar, far: Scalar) Mat4 {
        const sinfov = math.sin(0.5 * fovy);
        const cosfov = math.cos(0.5 * fovy);

        assert(near > 0.0 and far > 0.0 and far > near);
        assert(!math.approxEq(Scalar, sinfov, 0.0, 0.0001));
        assert(!math.approxEq(Scalar, far, near, 0.001));
        assert(!math.approxEq(Scalar, aspect, 0.0, 0.01));

        const h = cosfov / sinfov;
        const w = h / aspect;
        const r = far / (far - near);
        return .{
            [_]Scalar{ w, 0.0, 0.0, 0.0 },
            [_]Scalar{ 0.0, h, 0.0, 0.0 },
            [_]Scalar{ 0.0, 0.0, r, 1.0 },
            [_]Scalar{ 0.0, 0.0, -r * near, 0.0 },
        };
    }

    pub fn initIdentity() Mat4 {
        return .{
            [_]Scalar{ 1.0, 0.0, 0.0, 0.0 },
            [_]Scalar{ 0.0, 1.0, 0.0, 0.0 },
            [_]Scalar{ 0.0, 0.0, 1.0, 0.0 },
            [_]Scalar{ 0.0, 0.0, 0.0, 1.0 },
        };
    }

    pub fn initTranslation(a: Vec3) Mat4 {
        return .{
            [_]Scalar{ 1.0, 0.0, 0.0, 0.0 },
            [_]Scalar{ 0.0, 1.0, 0.0, 0.0 },
            [_]Scalar{ 0.0, 0.0, 1.0, 0.0 },
            [_]Scalar{ a[0], a[1], a[2], 1.0 },
        };
    }

    pub fn initLookAt(eye: Vec3, at: Vec3, up: Vec3) Mat4 {
        const az = vec3.normalize(vec3.sub(at, eye));
        const ax = vec3.normalize(vec3.cross(up, az));
        const ay = vec3.normalize(vec3.cross(az, ax));
        return .{
            [_]Scalar{ ax[0], ay[0], az[0], 0.0 },
            [_]Scalar{ ax[1], ay[1], az[1], 0.0 },
            [_]Scalar{ ax[2], ay[2], az[2], 0.0 },
            [_]Scalar{ -vec3.dot(ax, eye), -vec3.dot(ay, eye), -vec3.dot(az, eye), 1.0 },
        };
    }
};
