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
