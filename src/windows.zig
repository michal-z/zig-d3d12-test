const std = @import("std");
const os = std.os.windows;

pub const WS_VISIBLE = 0x10000000;
pub const VK_ESCAPE = 0x001B;

pub const RECT = extern struct {
    left: os.LONG,
    top: os.LONG,
    right: os.LONG,
    bottom: os.LONG,
};

pub extern "kernel32" fn AdjustWindowRect(
    lpRect: ?*RECT,
    dwStyle: os.DWORD,
    bMenu: bool,
) callconv(.Stdcall) bool;

pub extern "user32" fn SetProcessDPIAware() callconv(.Stdcall) bool;

pub extern "user32" fn SetWindowTextA(hWnd: ?os.HWND, lpString: os.LPCSTR) callconv(.Stdcall) bool;

pub extern "user32" fn LoadCursorA(
    hInstance: ?os.HINSTANCE,
    lpCursorName: os.LPCSTR,
) callconv(.Stdcall) os.HCURSOR;

const HRESULT = os.HRESULT;

pub const IUnknown = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
    },
    usingnamespace IUnknown.Methods(Self);

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn QueryInterface(self: *T, guid: *const os.GUID, outobj: **c_void) HRESULT {
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
