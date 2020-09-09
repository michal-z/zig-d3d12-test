const std = @import("std");
const os = std.os.windows;

pub const RESOURCE_BARRIER_ALL_SUBRESOURCES = 0xffffffff;
pub const DEFAULT_DEPTH_BIAS = 0;
pub const DEFAULT_DEPTH_BIAS_CLAMP = 0.0;
pub const DEFAULT_SLOPE_SCALED_DEPTH_BIAS = 0.0;
pub const DEFAULT_STENCIL_READ_MASK = 0xff;
pub const DEFAULT_STENCIL_WRITE_MASK = 0xff;

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
    FORCE_UINT = 0xffffffff,
};

pub const SAMPLE_DESC = extern struct {
    Count: u32,
    Quality: u32,
};

pub const GPU_VIRTUAL_ADDRESS = u64;

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

pub const HEAP_TYPE = extern enum {
    DEFAULT = 1,
    UPLOAD = 2,
    READBACK = 3,
    CUSTOM = 4,
};

pub const CPU_PAGE_PROPERTY = extern enum {
    UNKNOWN = 0,
    NOT_AVAILABLE = 1,
    WRITE_COMBINE = 2,
    WRITE_BACK = 3,
};

pub const MEMORY_POOL = extern enum {
    UNKNOWN = 0,
    L0 = 1,
    L1 = 2,
};

pub const HEAP_PROPERTIES = extern struct {
    Type: HEAP_TYPE,
    CPUPageProperty: CPU_PAGE_PROPERTY,
    MemoryPoolPreference: MEMORY_POOL,
    CreationNodeMask: u32,
    VisibleNodeMask: u32,
};

pub const HEAP_FLAGS = extern enum {
    NONE = 0,
    SHARED = 0x1,
    DENY_BUFFERS = 0x4,
    ALLOW_DISPLAY = 0x8,
    SHARED_CROSS_ADAPTER = 0x20,
    DENY_RT_DS_TEXTURES = 0x40,
    DENY_NON_RT_DS_TEXTURES = 0x80,
    HARDWARE_PROTECTED = 0x100,
    ALLOW_ALL_BUFFERS_AND_TEXTURES = 0,
    ALLOW_ONLY_BUFFERS = 0xc0,
    ALLOW_ONLY_NON_RT_DS_TEXTURES = 0x44,
    ALLOW_ONLY_RT_DS_TEXTURES = 0x84,
};

pub const HEAP_DESC = extern struct {
    SizeInBytes: u64,
    Properties: HEAP_PROPERTIES,
    Alignment: u64,
    Flags: HEAP_FLAGS,
};

pub const RANGE = extern struct {
    Begin: u64,
    End: u64,
};

pub const RESOURCE_DIMENSION = extern enum {
    UNKNOWN = 0,
    BUFFER = 1,
    TEXTURE1D = 2,
    TEXTURE2D = 3,
    TEXTURE3D = 4,
};

pub const TEXTURE_LAYOUT = extern enum {
    UNKNOWN = 0,
    ROW_MAJOR = 1,
    _64KB_UNDEFINED_SWIZZLE = 2,
    _64KB_STANDARD_SWIZZLE = 3,
};

pub const RESOURCE_FLAGS = extern enum {
    NONE = 0,
    ALLOW_RENDER_TARGET = 0x1,
    ALLOW_DEPTH_STENCIL = 0x2,
    ALLOW_UNORDERED_ACCESS = 0x4,
    DENY_SHADER_RESOURCE = 0x8,
    ALLOW_CROSS_ADAPTER = 0x10,
    ALLOW_SIMULTANEOUS_ACCESS = 0x20,
};

pub const RESOURCE_DESC = extern struct {
    Dimension: RESOURCE_DIMENSION,
    Alignment: u64,
    Width: u64,
    Height: u32,
    DepthOrArraySize: u16,
    MipLevels: u16,
    Format: FORMAT,
    SampleDesc: SAMPLE_DESC,
    Layout: TEXTURE_LAYOUT,
    Flags: RESOURCE_FLAGS,
};

pub const BOX = extern struct {
    left: u32,
    top: u32,
    front: u32,
    right: u32,
    bottom: u32,
    back: u32,
};

pub const DESCRIPTOR_HEAP_TYPE = extern enum {
    CBV_SRV_UAV = 0,
    SAMPLER = 1,
    RTV = 2,
    DSV = 3,
    NUM_TYPES = 4,
};

pub const DESCRIPTOR_HEAP_FLAGS = extern enum {
    NONE = 0,
    SHADER_VISIBLE = 1,
};

pub const DESCRIPTOR_HEAP_DESC = extern struct {
    Type: DESCRIPTOR_HEAP_TYPE,
    NumDescriptors: u32,
    Flags: DESCRIPTOR_HEAP_FLAGS,
    NodeMask: u32,
};

pub const CPU_DESCRIPTOR_HANDLE = extern struct {
    ptr: u64,
};

pub const GPU_DESCRIPTOR_HANDLE = extern struct {
    ptr: u64,
};

pub const RECT = extern struct {
    left: c_long,
    top: c_long,
    right: c_long,
    bottom: c_long,
};

pub const DISCARD_REGION = extern struct {
    NumRects: u32,
    pRects: *const RECT,
    FirstSubresource: u32,
    NumSubresources: u32,
};

pub const COMMAND_LIST_TYPE = extern enum {
    DIRECT = 0,
    BUNDLE = 1,
    COMPUTE = 2,
    COPY = 3,
};

pub const SUBRESOURCE_FOOTPRINT = extern struct {
    Format: FORMAT,
    Width: u32,
    Height: u32,
    Depth: u32,
    RowPitch: u32,
};

pub const IUnknown = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) os.HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) os.ULONG,
        Release: fn (*Self) callconv(.Stdcall) os.ULONG,
    },
    // IUnknown
    pub inline fn QueryInterface(self: *Self, guid: *const os.GUID, outobj: **c_void) os.HRESULT {
        return self.vtbl.QueryInterface(self, guid, outobj);
    }
    pub inline fn AddRef(self: *Self) os.ULONG {
        return self.vtbl.AddRef(self);
    }
    pub inline fn Release(self: *Self) os.ULONG {
        return self.vtbl.Release(self);
    }
};

pub const IBlob = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        const Self = ID3DBlob;
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) os.HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) os.ULONG,
        Release: fn (*Self) callconv(.Stdcall) os.ULONG,
        // ID3DBlob
        GetBufferPointer: fn (*Self) callconv(.Stdcall) os.LPVOID,
        GetBufferSize: fn (*Self) callconv(.Stdcall) os.SIZE_T,
    },
    // IUnknown
    pub inline fn QueryInterface(self: *Self, guid: *const os.GUID, outobj: **c_void) os.HRESULT {
        return self.vtbl.QueryInterface(self, guid, outobj);
    }
    pub inline fn AddRef(self: *Self) os.ULONG {
        return self.vtbl.AddRef(self);
    }
    pub inline fn Release(self: *Self) os.ULONG {
        return self.vtbl.Release(self);
    }
    // ID3DBlob
    pub inline fn GetBufferPointer(self: *Self) os.LPVOID {
        return self.vtbl.GetBufferPointer(self);
    }
    pub inline fn GetBufferSize(self: *Self) os.SIZE_T {
        return self.vtbl.GetBufferSize(self);
    }
};

pub const IDebug = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) os.HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) os.ULONG,
        Release: fn (*Self) callconv(.Stdcall) os.ULONG,
        // ID3D12Debug
        EnableDebugLayer: fn (*Self) callconv(.Stdcall) void,
    },
    // IUnknown
    pub inline fn QueryInterface(self: *Self, guid: *const os.GUID, outobj: **c_void) os.HRESULT {
        return self.vtbl.QueryInterface(self, guid, outobj);
    }
    pub inline fn AddRef(self: *Self) os.ULONG {
        return self.vtbl.AddRef(self);
    }
    pub inline fn Release(self: *Self) os.ULONG {
        return self.vtbl.Release(self);
    }
    // IDebug
    pub inline fn EnableDebugLayer(self: *Self) void {
        self.vtbl.EnableDebugLayer(self);
    }
};

pub const IObject = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) os.HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) os.ULONG,
        Release: fn (*Self) callconv(.Stdcall) os.ULONG,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const GUID, *u32, ?*c_void) callconv(.Stdcall) os.HRESULT,
        SetPrivateData: fn (*Self, *const GUID, u32, ?*const c_void) callconv(.Stdcall) os.HRESULT,
        SetPrivateDataInterface: fn (*Self, *const GUID, ?*const IUnknown) callconv(.Stdcall) os.HRESULT,
        SetName: fn (*Self, ?*const u16) callconv(.Stdcall) os.HRESULT,
    },
    // IUnknown
    pub inline fn QueryInterface(self: *Self, guid: *const os.GUID, outobj: **c_void) os.HRESULT {
        return self.vtbl.QueryInterface(self, guid, outobj);
    }
    pub inline fn AddRef(self: *Self) os.ULONG {
        return self.vtbl.AddRef(self);
    }
    pub inline fn Release(self: *Self) os.ULONG {
        return self.vtbl.Release(self);
    }
    // ID3D12Object
    pub inline fn GetPrivateData(
        self: *Self,
        guid: *const GUID,
        data_size: *u32,
        data: ?*c_void,
    ) callconv(.Stdcall) os.HRESULT {
        return self.vtbl.GetPrivateData(self, guid, data_size, data);
    }
    pub inline fn SetPrivateData(
        self: *Self,
        guid: *const GUID,
        data_size: u32,
        data: ?*const c_void,
    ) callconv(.Stdcall) os.HRESULT {
        return self.vtbl.SetPrivateData(self, guid, data_size, data);
    }
    pub inline fn SetPrivateDataInterface(
        self: *Self,
        guid: *const GUID,
        data: ?*const IUnknown,
    ) callconv(.Stdcall) os.HRESULT {
        return self.vtbl.SetPrivateDataInterface(self, guid, data);
    }
    pub inline fn SetName(self: *Self, name: ?*const u16) callconv(.Stdcall) os.HRESULT {
        return self.vtbl.SetName(self, name);
    }
};

pub const IID_IDebug = os.GUID{
    .Data1 = 0x344488b7,
    .Data2 = 0x6846,
    .Data3 = 0x474b,
    .Data4 = .{ 0xb9, 0x89, 0xf0, 0x27, 0x44, 0x82, 0x45, 0xe0 },
};
pub const IID_IDebug1 = os.GUID{
    .Data1 = 0xaffaa4ca,
    .Data2 = 0x63fe,
    .Data3 = 0x4d8e,
    .Data4 = .{ 0xb8, 0xad, 0x15, 0x90, 0x00, 0xaf, 0x43, 0x04 },
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
pub const IID_IGraphicsCommandList = os.GUID{
    .Data1 = 0x5b160d0f,
    .Data2 = 0xac1b,
    .Data3 = 0x4185,
    .Data4 = .{ 0x8b, 0xa8, 0xb3, 0xae, 0x42, 0xa5, 0xa4, 0x55 },
};
pub const IID_ICommandQueue = os.GUID{
    .Data1 = 0x0ec870a6,
    .Data2 = 0x5d7e,
    .Data3 = 0x4c22,
    .Data4 = .{ 0x8c, 0xfc, 0x5b, 0xaa, 0xe0, 0x76, 0x16, 0xed },
};
pub const IID_IDevice = os.GUID{
    .Data1 = 0x189819f1,
    .Data2 = 0x1db6,
    .Data3 = 0x4b57,
    .Data4 = .{ 0xbe, 0x54, 0x18, 0x21, 0x33, 0x9b, 0x85, 0xf7 },
};
pub const IID_IDescriptorHeap = os.GUID{
    .Data1 = 0x8efb471d,
    .Data2 = 0x616c,
    .Data3 = 0x4f49,
    .Data4 = .{ 0x90, 0xf7, 0x12, 0x7b, 0xb7, 0x63, 0xfa, 0x51 },
};
pub const IID_IResource = os.GUID{
    .Data1 = 0x696442be,
    .Data2 = 0xa72e,
    .Data3 = 0x4059,
    .Data4 = .{ 0xbc, 0x79, 0x5b, 0x5c, 0x98, 0x04, 0x0f, 0xad },
};
pub const IID_IRootSignature = os.GUID{
    .Data1 = 0xc54a6b66,
    .Data2 = 0x72df,
    .Data3 = 0x4ee8,
    .Data4 = .{ 0x8b, 0xe5, 0xa9, 0x46, 0xa1, 0x42, 0x92, 0x14 },
};
pub const IID_ICommandAllocator = os.GUID{
    .Data1 = 0x6102dee4,
    .Data2 = 0xaf59,
    .Data3 = 0x4b09,
    .Data4 = .{ 0xb9, 0x99, 0xb4, 0x4d, 0x73, 0xf0, 0x9b, 0x24 },
};
pub const IID_IFence = os.GUID{
    .Data1 = 0x0a753dcf,
    .Data2 = 0xc4d8,
    .Data3 = 0x4b91,
    .Data4 = .{ 0xad, 0xf6, 0xbe, 0x5a, 0x60, 0xd9, 0x5a, 0x76 },
};
pub const IID_IPipelineState = os.GUID{
    .Data1 = 0x765a30f3,
    .Data2 = 0xf624,
    .Data3 = 0x4c6f,
    .Data4 = .{ 0xa8, 0x28, 0xac, 0xe9, 0x48, 0x62, 0x24, 0x45 },
};

pub var GetDebugInterface: fn (*const os.GUID, **c_void) callconv(.Stdcall) os.HRESULT = undefined;
pub var CreateDevice: fn (
    pAdapter: ?*IUnknown,
    MinimumFeatureLevel: FEATURE_LEVEL,
    guid: *const os.GUID,
    ppDevice: **c_void,
) callconv(.Stdcall) os.HRESULT = undefined;

pub fn init() void {
    // TODO: Handle error.
    var d3d12_dll = std.DynLib.open("/windows/system32/d3d12.dll") catch unreachable;
    GetDebugInterface = d3d12_dll.lookup(@TypeOf(GetDebugInterface), "D3D12GetDebugInterface").?;
    CreateDevice = d3d12_dll.lookup(@TypeOf(CreateDevice), "D3D12CreateDevice").?;
}