const builtin = @import("builtin");
const std = @import("std");
const os = @import("windows.zig");
const HRESULT = os.HRESULT;

pub const FACTORY_TYPE = extern enum {
    SINGLE_THREADED = 0,
    MULTI_THREADED = 1,
};

pub const DEBUG_LEVEL = extern enum {
    NONE = 0,
    ERROR = 1,
    WARNING = 2,
    INFORMATION = 3,
};

pub const FACTORY_OPTIONS = extern struct {
    debugLevel: DEBUG_LEVEL,
};

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

pub const IResource = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: fn (*Self, **IFactory) callconv(.Stdcall) void,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IResource.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetFactory(self: *T, factory: **IFactory) void {
                self.vtbl.GetFactory(self, factory);
            }
        };
    }
};

pub const IImage = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: fn (*Self, **IFactory) callconv(.Stdcall) void,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IResource.Methods(Self);
};

pub const IBitmap = extern struct {
    // TODO:
};

pub const IFactory = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Factory
        ReloadSystemMetrics: fn (*Self) callconv(.Stdcall) HRESULT,
        GetDesktopDpi: fn (*Self, *f32, *f32) callconv(.Stdcall) void,
        // TODO: Add all members.
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IFactory.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn ReloadSystemMetrics(self: *T) HRESULT {
                return self.vtbl.ReloadSystemMetrics(self);
            }
            pub inline fn GetDesktopDpi(self: *T, dpi_x: *f32, dpi_y: *f32) usize {
                self.vtbl.GetDesktopDpi(self, dpi_x, dpi_y);
            }
        };
    }
};

pub const IID_IFactory = os.GUID{
    .Data1 = 0x06152247,
    .Data2 = 0x6f50,
    .Data3 = 0x465a,
    .Data4 = .{ 0x92, 0x45, 0x11, 0x8b, 0xfd, 0x3b, 0x60, 0x07 },
};

pub var CreateFactory: fn (
    FACTORY_TYPE,
    *const os.GUID,
    *const FACTORY_OPTIONS,
    **c_void,
) callconv(.Stdcall) HRESULT = undefined;

pub fn init() void {
    var d2d1_dll = std.DynLib.open("/windows/system32/d2d1.dll") catch unreachable;
    CreateFactory = d2d1_dll.lookup(@TypeOf(CreateFactory), "D2D1CreateFactory").?;
}
