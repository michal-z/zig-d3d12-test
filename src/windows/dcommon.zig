const std = @import("std");
const os = @import("windows.zig");
const dxgi = @import("dxgi.zig");

pub const FEATURE_LEVEL = extern enum {
    _9_1 = 0x9100,
    _9_2 = 0x9200,
    _9_3 = 0x9300,
    _10_0 = 0xa000,
    _10_1 = 0xa100,
    _11_0 = 0xb000,
    _11_1 = 0xb100,
    _12_0 = 0xc000,
    _12_1 = 0xc100,
};

pub const POINT_2F = extern struct {
    x: f32,
    y: f32,
};

pub const POINT_2U = extern struct {
    x: u32,
    y: u32,
};

pub const POINT_2L = os.POINT;

pub const RECT_F = extern struct {
    left: f32,
    top: f32,
    right: f32,
    bottom: f32,
};

pub const RECT_U = extern struct {
    left: u32,
    top: u32,
    right: u32,
    bottom: u32,
};

pub const RECT_L = os.RECT;

pub const SIZE_F = extern struct {
    width: f32,
    height: f32,
};

pub const SIZE_U = extern struct {
    width: u32,
    height: u32,
};

pub const MATRIX_3X2_F = extern struct {
    m: [3][2]f32,

    pub fn identity() MATRIX_3X2_F {
        return MATRIX_3X2_F{
            .m = [_][2]f32{
                [_]f32{ 1.0, 0.0 },
                [_]f32{ 0.0, 1.0 },
                [_]f32{ 0.0, 0.0 },
            },
        };
    }
};

pub const ALPHA_MODE = extern enum {
    UNKNOWN = 0,
    PREMULTIPLIED = 1,
    STRAIGHT = 2,
    IGNORE = 3,
};

pub const MEASURING_MODE = extern enum {
    NATURAL = 0,
    GDI_CLASSIC = 1,
    GDI_NATURAL = 2,
};

pub const PIXEL_FORMAT = extern struct {
    format: dxgi.FORMAT,
    alphaMode: ALPHA_MODE,
};
