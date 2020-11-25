const std = @import("std");
pub usingnamespace std.os.windows;

pub const WS_VISIBLE = 0x10000000;
pub const VK_ESCAPE = 0x001B;
pub const VK_LBUTTON = 0x01;
pub const VK_RBUTTON = 0x02;

pub const POINT = extern struct {
    x: LONG,
    y: LONG,
};

pub const RECT = extern struct {
    left: LONG,
    top: LONG,
    right: LONG,
    bottom: LONG,
};

pub extern "kernel32" fn AdjustWindowRect(
    lpRect: ?*RECT,
    dwStyle: DWORD,
    bMenu: BOOL,
) callconv(.C) BOOL;

pub extern "kernel32" fn LoadLibraryA(lpLibFileName: [*:0]const u8) callconv(.C) ?HMODULE;

pub extern "user32" fn SetProcessDPIAware() callconv(.C) BOOL;

pub extern "user32" fn SetWindowTextA(hWnd: ?HWND, lpString: LPCSTR) callconv(.C) BOOL;

pub extern "user32" fn GetCursorPos(lpPoint: *POINT) callconv(.C) BOOL;

pub extern "user32" fn GetAsyncKeyState(vKey: c_int) callconv(.C) SHORT;

pub extern "user32" fn LoadCursorA(
    hInstance: ?HINSTANCE,
    lpCursorName: LPCSTR,
) callconv(.C) HCURSOR;

pub extern "user32" fn GetClientRect(HWND, *RECT) callconv(.C) BOOL;

pub const IUnknown = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
    },
    usingnamespace IUnknown.Methods(Self);

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn QueryInterface(self: *T, guid: *const GUID, outobj: **c_void) HRESULT {
                return self.vtbl.QueryInterface(self, guid, outobj);
            }
            pub inline fn AddRef(self: *T) u32 {
                return self.vtbl.AddRef(self);
            }
            pub inline fn Release(self: *T) u32 {
                return self.vtbl.Release(self);
            }
        };
    }
};
pub const CLSCTX_INPROC_SERVER = 0x1;

pub extern "ole32" fn CoInitialize(reserved: ?*c_void) callconv(.C) HRESULT;

pub extern "ole32" fn CoCreateInstance(
    rclsid: *const GUID,
    pUnkOuter: ?*IUnknown,
    dwClsContext: DWORD,
    riid: *const GUID,
    ppv: **c_void,
) callconv(.C) HRESULT;

pub inline fn vhr(hr: HRESULT) void {
    if (hr != 0) {
        std.debug.panic("HRESULT function failed ({}).", .{hr});
    }
}

pub inline fn releaseCom(obj: anytype) void {
    comptime std.debug.assert(@hasDecl(@TypeOf(obj.*.*), "Release"));
    _ = obj.*.Release();
    obj.* = undefined;
}
