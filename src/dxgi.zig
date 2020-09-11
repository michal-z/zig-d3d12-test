const std = @import("std");
const os = std.os.windows;

pub const SAMPLE_DESC = extern struct {
    Count: u32,
    Quality: u32,
};

pub const FORMAT = extern enum {
    UNKNOWN = 0,
    R32G32B32A32_TYPELESS = 1,
    R32G32B32A32_FLOAT = 2,
    R32G32B32A32_UINT = 3,
    R32G32B32A32_SINT = 4,
    R32G32B32_TYPELESS = 5,
    R32G32B32_FLOAT = 6,
    R32G32B32_UINT = 7,
    R32G32B32_SINT = 8,
    R16G16B16A16_TYPELESS = 9,
    R16G16B16A16_FLOAT = 10,
    R16G16B16A16_UNORM = 11,
    R16G16B16A16_UINT = 12,
    R16G16B16A16_SNORM = 13,
    R16G16B16A16_SINT = 14,
    R32G32_TYPELESS = 15,
    R32G32_FLOAT = 16,
    R32G32_UINT = 17,
    R32G32_SINT = 18,
    R32G8X24_TYPELESS = 19,
    D32_FLOAT_S8X24_UINT = 20,
    R32_FLOAT_X8X24_TYPELESS = 21,
    X32_TYPELESS_G8X24_UINT = 22,
    R10G10B10A2_TYPELESS = 23,
    R10G10B10A2_UNORM = 24,
    R10G10B10A2_UINT = 25,
    R11G11B10_FLOAT = 26,
    R8G8B8A8_TYPELESS = 27,
    R8G8B8A8_UNORM = 28,
    R8G8B8A8_UNORM_SRGB = 29,
    R8G8B8A8_UINT = 30,
    R8G8B8A8_SNORM = 31,
    R8G8B8A8_SINT = 32,
    R16G16_TYPELESS = 33,
    R16G16_FLOAT = 34,
    R16G16_UNORM = 35,
    R16G16_UINT = 36,
    R16G16_SNORM = 37,
    R16G16_SINT = 38,
    R32_TYPELESS = 39,
    D32_FLOAT = 40,
    R32_FLOAT = 41,
    R32_UINT = 42,
    R32_SINT = 43,
    R24G8_TYPELESS = 44,
    D24_UNORM_S8_UINT = 45,
    R24_UNORM_X8_TYPELESS = 46,
    X24_TYPELESS_G8_UINT = 47,
    R8G8_TYPELESS = 48,
    R8G8_UNORM = 49,
    R8G8_UINT = 50,
    R8G8_SNORM = 51,
    R8G8_SINT = 52,
    R16_TYPELESS = 53,
    R16_FLOAT = 54,
    D16_UNORM = 55,
    R16_UNORM = 56,
    R16_UINT = 57,
    R16_SNORM = 58,
    R16_SINT = 59,
    R8_TYPELESS = 60,
    R8_UNORM = 61,
    R8_UINT = 62,
    R8_SNORM = 63,
    R8_SINT = 64,
    A8_UNORM = 65,
    R1_UNORM = 66,
    R9G9B9E5_SHAREDEXP = 67,
    R8G8_B8G8_UNORM = 68,
    G8R8_G8B8_UNORM = 69,
    BC1_TYPELESS = 70,
    BC1_UNORM = 71,
    BC1_UNORM_SRGB = 72,
    BC2_TYPELESS = 73,
    BC2_UNORM = 74,
    BC2_UNORM_SRGB = 75,
    BC3_TYPELESS = 76,
    BC3_UNORM = 77,
    BC3_UNORM_SRGB = 78,
    BC4_TYPELESS = 79,
    BC4_UNORM = 80,
    BC4_SNORM = 81,
    BC5_TYPELESS = 82,
    BC5_UNORM = 83,
    BC5_SNORM = 84,
    B5G6R5_UNORM = 85,
    B5G5R5A1_UNORM = 86,
    B8G8R8A8_UNORM = 87,
    B8G8R8X8_UNORM = 88,
    R10G10B10_XR_BIAS_A2_UNORM = 89,
    B8G8R8A8_TYPELESS = 90,
    B8G8R8A8_UNORM_SRGB = 91,
    B8G8R8X8_TYPELESS = 92,
    B8G8R8X8_UNORM_SRGB = 93,
    BC6H_TYPELESS = 94,
    BC6H_UF16 = 95,
    BC6H_SF16 = 96,
    BC7_TYPELESS = 97,
    BC7_UNORM = 98,
    BC7_UNORM_SRGB = 99,
    AYUV = 100,
    Y410 = 101,
    Y416 = 102,
    NV12 = 103,
    P010 = 104,
    P016 = 105,
    _420_OPAQUE = 106,
    YUY2 = 107,
    Y210 = 108,
    Y216 = 109,
    NV11 = 110,
    AI44 = 111,
    IA44 = 112,
    P8 = 113,
    A8P8 = 114,
    B4G4R4A4_UNORM = 115,
    P208 = 130,
    V208 = 131,
    V408 = 132,
};

pub const IObject = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // IDXGIObject
        SetPrivateData: fn (*Self, *const os.GUID, u32, ?*const c_void) callconv(.Stdcall) HRESULT,
        SetPrivateDataInterface: fn (
            *Self,
            *const os.GUID,
            ?*const osl.IUnknown,
        ) callconv(.Stdcall) HRESULT,
        GetPrivateData: fn (*Self, *const os.GUID, *u32, ?*c_void) callconv(.Stdcall) HRESULT,
        GetParent: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
    },
    usingnamespace osl.IUnknown.Methods(Self);
    usingnamespace IObject.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn SetPrivateData(
                self: *T,
                guid: *const os.GUID,
                data_size: u32,
                data: ?*const c_void,
            ) HRESULT {
                return self.vtbl.SetPrivateData(self, guid, data_size, data);
            }
            pub inline fn SetPrivateDataInterface(
                self: *T,
                guid: *const os.GUID,
                data: ?*const osl.IUnknown,
            ) HRESULT {
                return self.vtbl.SetPrivateDataInterface(self, guid, data);
            }
            pub inline fn GetPrivateData(
                self: *T,
                guid: *const os.GUID,
                data_size: *u32,
                data: ?*c_void,
            ) HRESULT {
                return self.vtbl.GetPrivateData(self, guid, data_size, data);
            }
            pub inline fn GetParent(self: *T, guid: *const os.GUID, parent: **c_void) HRESULT {
                return self.vtbl.GetParent(self, guid, parent);
            }
        };
    }
};

pub const IDeviceSubObject = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // IDXGIObject
        SetPrivateData: fn (*Self, *const os.GUID, u32, ?*const c_void) callconv(.Stdcall) HRESULT,
        SetPrivateDataInterface: fn (
            *Self,
            *const os.GUID,
            ?*const osl.IUnknown,
        ) callconv(.Stdcall) HRESULT,
        GetPrivateData: fn (*Self, *const os.GUID, *u32, ?*c_void) callconv(.Stdcall) HRESULT,
        GetParent: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        // IDXGIDeviceSubObject
        GetDevice: fn (*Self, *const GUID, **c_void) callconv(.Stdcall) HRESULT,
    },
    usingnamespace osl.IUnknown.Methods(Self);
    usingnamespace IObject.Methods(Self);
    usingnamespace IDeviceSubObject.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetDevice(self: *T, guid: *const os.GUID, device: **c_void) HRESULT {
                return self.vtbl.GetDevice(self, guid, device);
            }
        };
    }
};

pub const IID_ISwapChain = os.GUID{
    .Data1 = 0x310d36a0,
    .Data2 = 0xd2e7,
    .Data3 = 0x4c0a,
    .Data4 = .{ 0xaa, 0x04, 0x6a, 0x9d, 0x23, 0xb8, 0x88, 0x6a },
};
pub const IID_ISwapChain3 = os.GUID{
    .Data1 = 0x94d99bdb,
    .Data2 = 0xf1f8,
    .Data3 = 0x4ab0,
    .Data4 = .{ 0xb2, 0x36, 0x7d, 0xa0, 0x17, 0x0e, 0xda, 0xb1 },
};
pub const IID_IFactory4 = os.GUID{
    .Data1 = 0x1bc6ea02,
    .Data2 = 0xef36,
    .Data3 = 0x464f,
    .Data4 = .{ 0xbf, 0x0c, 0x21, 0xca, 0x39, 0xe5, 0x16, 0x8a },
};

pub var CreateFactory2: fn (u32, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT = undefined;

pub fn init() void {
    // TODO: Handle error.
    var dxgi_dll = std.DynLib.open("/windows/system32/dxgi.dll") catch unreachable;
    CreateFactory2 = dxgi_dll.lookup(@TypeOf(CreateFactory2), "CreateDXGIFactory2").?;
}
