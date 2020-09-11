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

pub const COMMAND_QUEUE_FLAGS = extern enum {
    NONE = 0,
    DISABLE_GPU_TIMEOUT = 0x1,
};

pub const COMMAND_QUEUE_PRIORITY = extern enum {
    NORMAL = 0,
    HIGH = 100,
};

pub const COMMAND_QUEUE_DESC = extern struct {
    Type: COMMAND_LIST_TYPE,
    Priority: i32,
    Flags: COMMAND_QUEUE_FLAGS,
    NodeMask: u32,
};

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

    fn Methods(comptime T: type) type {
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

pub const IBlob = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        const Self = ID3DBlob;
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID3DBlob
        GetBufferPointer: fn (*Self) callconv(.Stdcall) *c_void,
        GetBufferSize: fn (*Self) callconv(.Stdcall) usize,
    },
    usingnamespace IUnknown.Methods(Self);
    usingnamespace IBlob.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetBufferPointer(self: *T) *c_void {
                return self.vtbl.GetBufferPointer(self);
            }
            pub inline fn GetBufferSize(self: *T) usize {
                return self.vtbl.GetBufferSize(self);
            }
        };
    }
};

pub const IDebug = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID3D12Debug
        EnableDebugLayer: fn (*Self) callconv(.Stdcall) void,
    },
    usingnamespace IUnknown.Methods(Self);
    usingnamespace IDebug.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn EnableDebugLayer(self: *T) void {
                self.vtbl.EnableDebugLayer(self);
            }
        };
    }
};

pub const IObject = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const GUID, *u32, ?*c_void) callconv(.Stdcall) HRESULT,
        SetPrivateData: fn (*Self, *const GUID, u32, ?*const c_void) callconv(.Stdcall) HRESULT,
        SetPrivateDataInterface: fn (*Self, *const GUID, ?*const IUnknown) callconv(.Stdcall) HRESULT,
        SetName: fn (*Self, ?*const u16) callconv(.Stdcall) HRESULT,
    },
    usingnamespace IUnknown.Methods(Self);
    usingnamespace IObject.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetPrivateData(
                self: *T,
                guid: *const os.GUID,
                data_size: *u32,
                data: ?*c_void,
            ) HRESULT {
                return self.vtbl.GetPrivateData(self, guid, data_size, data);
            }
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
                data: ?*const IUnknown,
            ) HRESULT {
                return self.vtbl.SetPrivateDataInterface(self, guid, data);
            }
            pub inline fn SetName(self: *T, name: ?*const u16) HRESULT {
                return self.vtbl.SetName(self, name);
            }
        };
    }
};

pub const IDeviceChild = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const GUID, *u32, ?*c_void) callconv(.Stdcall) HRESULT,
        SetPrivateData: fn (*Self, *const GUID, u32, ?*const c_void) callconv(.Stdcall) HRESULT,
        SetPrivateDataInterface: fn (*Self, *const GUID, ?*const IUnknown) callconv(.Stdcall) HRESULT,
        SetName: fn (*Self, ?*const u16) callconv(.Stdcall) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const GUID, **c_void) callconv(.Stdcall) HRESULT,
    },
    usingnamespace IUnknown.Methods(Self);
    usingnamespace IObject.Methods(Self);
    usingnamespace IDeviceChild.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetDevice(
                self: *T,
                guid: *const os.GUID,
                device: **c_void,
            ) HRESULT {
                return self.vtbl.GetDevice(self, guid, device);
            }
        };
    }
};

pub const IRootSignature = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const GUID, *u32, ?*c_void) callconv(.Stdcall) HRESULT,
        SetPrivateData: fn (*Self, *const GUID, u32, ?*const c_void) callconv(.Stdcall) HRESULT,
        SetPrivateDataInterface: fn (*Self, *const GUID, ?*const IUnknown) callconv(.Stdcall) HRESULT,
        SetName: fn (*Self, ?*const u16) callconv(.Stdcall) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const GUID, **c_void) callconv(.Stdcall) HRESULT,
    },
    usingnamespace IUnknown.Methods(Self);
    usingnamespace IObject.Methods(Self);
    usingnamespace IDeviceChild.Methods(Self);
};

pub const IPageable = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const GUID, *u32, ?*c_void) callconv(.Stdcall) HRESULT,
        SetPrivateData: fn (*Self, *const GUID, u32, ?*const c_void) callconv(.Stdcall) HRESULT,
        SetPrivateDataInterface: fn (*Self, *const GUID, ?*const IUnknown) callconv(.Stdcall) HRESULT,
        SetName: fn (*Self, ?*const u16) callconv(.Stdcall) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const GUID, **c_void) callconv(.Stdcall) HRESULT,
    },
    usingnamespace IUnknown.Methods(Self);
    usingnamespace IObject.Methods(Self);
    usingnamespace IDeviceChild.Methods(Self);
};

pub const IHeap = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const GUID, *u32, ?*c_void) callconv(.Stdcall) HRESULT,
        SetPrivateData: fn (*Self, *const GUID, u32, ?*const c_void) callconv(.Stdcall) HRESULT,
        SetPrivateDataInterface: fn (*Self, *const GUID, ?*const IUnknown) callconv(.Stdcall) HRESULT,
        SetName: fn (*Self, ?*const u16) callconv(.Stdcall) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const GUID, **c_void) callconv(.Stdcall) HRESULT,
        // ID3D12Heap
        GetDesc: fn (*Self, *HEAP_DESC) callconv(.Stdcall) *HEAP_DESC,
    },
    usingnamespace IUnknown.Methods(Self);
    usingnamespace IObject.Methods(Self);
    usingnamespace IDeviceChild.Methods(Self);
    usingnamespace IHeap.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetDesc(self: *T) HEAP_DESC {
                var desc: HEAP_DESC = undefined;
                self.vtbl.GetDesc(self, &desc);
                return desc;
            }
        };
    }
};

pub const IResource = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const GUID, *u32, ?*c_void) callconv(.Stdcall) HRESULT,
        SetPrivateData: fn (*Self, *const GUID, u32, ?*const c_void) callconv(.Stdcall) HRESULT,
        SetPrivateDataInterface: fn (*Self, *const GUID, ?*const IUnknown) callconv(.Stdcall) HRESULT,
        SetName: fn (*Self, ?*const u16) callconv(.Stdcall) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const GUID, **c_void) callconv(.Stdcall) HRESULT,
        // ID3D12Resource
        Map: fn (*Self, u32, *const RANGE, **c_void) callconv(.Stdcall) HRESULT,
        Unmap: fn (*Self, u32, *const RANGE) callconv(.Stdcall) void,
        GetDesc: fn (*Self, *RESOURCE_DESC) callconv(.Stdcall) *RESOURCE_DESC,
        GetGPUVirtualAddress: fn (*Self) callconv(.Stdcall) GPU_VIRTUAL_ADDRESS,
        WriteToSubresource: fn (
            *Self,
            u32,
            *const BOX,
            *const c_void,
            u32,
            u32,
        ) callconv(.Stdcall) HRESULT,
        ReadFromSubresource: fn (*Self, *c_void, u32, u32, u32, *const BOX) callconv(.Stdcall) HRESULT,
        GetHeapProperties: fn (*Self, *HEAP_PROPERTIES, *HEAP_FLAGS) callconv(.Stdcall) HRESULT,
    },
    usingnamespace IUnknown.Methods(Self);
    usingnamespace IObject.Methods(Self);
    usingnamespace IDeviceChild.Methods(Self);
    usingnamespace IResource.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn Map(
                self: *Self,
                subresource: u32,
                read_range: *const RANGE,
                data: **c_void,
            ) HRESULT {
                return self.vtbl.Map(self, subresource, read_range, data);
            }
            pub inline fn Unmap(self: *Self, subresource: u32, written_range: *const RANGE) void {
                self.vtbl.Unmap(self, subresource, written_range);
            }
            pub inline fn GetDesc(self: *Self, desc: *RESOURCE_DESC) *RESOURCE_DESC {}
            pub inline fn GetGPUVirtualAddress(self: *Self) GPU_VIRTUAL_ADDRESS {}
            pub inline fn WriteToSubresource(
                self: *Self,
                dst_subresource: u32,
                dst_box: *const BOX,
                src_data: *const c_void,
                src_row_pitch: u32,
                src_depth_pitch: u32,
            ) HRESULT {
                return self.vtbl.WriteToSubresource(
                    self,
                    dst_subresource,
                    dst_box,
                    src_data,
                    src_row_pitch,
                    src_depth_pitch,
                );
            }
            pub inline fn ReadFromSubresource(
                self: *Self,
                dst_data: *c_void,
                dst_row_pitch: u32,
                dst_depth_pitch: u32,
                src_subresource: u32,
                src_box: *const BOX,
            ) HRESULT {
                return self.vtbl.ReadFromSubresource(
                    self,
                    dst_data,
                    dst_row_pitch,
                    dst_depth_pitch,
                    src_subresource,
                    src_box,
                );
            }
            pub inline fn GetHeapProperties(
                self: *Self,
                properties: *HEAP_PROPERTIES,
                flags: *HEAP_FLAGS,
            ) HRESULT {
                return self.vtbl.GetHeapProperties(self, properties, flags);
            }
        };
    }
};

pub const ICommandAllocator = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const GUID, *u32, ?*c_void) callconv(.Stdcall) HRESULT,
        SetPrivateData: fn (*Self, *const GUID, u32, ?*const c_void) callconv(.Stdcall) HRESULT,
        SetPrivateDataInterface: fn (*Self, *const GUID, ?*const IUnknown) callconv(.Stdcall) HRESULT,
        SetName: fn (*Self, ?*const u16) callconv(.Stdcall) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const GUID, **c_void) callconv(.Stdcall) HRESULT,
        // ID3D12CommandAllocator
        Reset: fn (*Self) callconv(.Stdcall) HRESULT,
    },
    usingnamespace IUnknown.Methods(Self);
    usingnamespace IObject.Methods(Self);
    usingnamespace IDeviceChild.Methods(Self);
    usingnamespace ICommandAllocator.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn Reset(self: *T) HRESULT {
                return self.vtbl.Reset(self);
            }
        };
    }
};

pub const IFence = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const GUID, *u32, ?*c_void) callconv(.Stdcall) HRESULT,
        SetPrivateData: fn (*Self, *const GUID, u32, ?*const c_void) callconv(.Stdcall) HRESULT,
        SetPrivateDataInterface: fn (*Self, *const GUID, ?*const IUnknown) callconv(.Stdcall) HRESULT,
        SetName: fn (*Self, ?*const u16) callconv(.Stdcall) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const GUID, **c_void) callconv(.Stdcall) HRESULT,
        // ID3D12Fence
        GetCompletedValue: fn (*Self) callconv(.Stdcall) u64,
        SetEventOnCompletion: fn (*Self, u64, os.HANDLE) callconv(.Stdcall) HRESULT,
        Signal: fn (*Self, u64) callconv(.Stdcall) HRESULT,
    },
    usingnamespace IUnknown.Methods(Self);
    usingnamespace IObject.Methods(Self);
    usingnamespace IDeviceChild.Methods(Self);
    usingnamespace IFence.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetCompletedValue(self: *T) u64 {
                return self.vtbl.GetCompletedValue(self);
            }
            pub inline fn SetEventOnCompletion(self: *T, value: u64, event: os.HANDLE) HRESULT {
                return self.vtbl.SetEventOnCompletion(self, value, event);
            }
            pub inline fn Signal(self: *T, value: u64) HRESULT {
                return self.vtbl.Signal(self, value);
            }
        };
    }
};

pub const IPipelineState = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const GUID, *u32, ?*c_void) callconv(.Stdcall) HRESULT,
        SetPrivateData: fn (*Self, *const GUID, u32, ?*const c_void) callconv(.Stdcall) HRESULT,
        SetPrivateDataInterface: fn (*Self, *const GUID, ?*const IUnknown) callconv(.Stdcall) HRESULT,
        SetName: fn (*Self, ?*const u16) callconv(.Stdcall) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const GUID, **c_void) callconv(.Stdcall) HRESULT,
        // ID3D12PipelineState
        GetCachedBlob: fn (*Self, *IBlob) callconv(.Stdcall) HRESULT,
    },
    usingnamespace IUnknown.Methods(Self);
    usingnamespace IObject.Methods(Self);
    usingnamespace IDeviceChild.Methods(Self);
    usingnamespace IPipelineState.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetCachedBlob(self: *T, blob: *IBlob) HRESULT {
                return self.vtbl.GetCachedBlob(self, blob);
            }
        };
    }
};

pub const IDescriptorHeap = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const GUID, *u32, ?*c_void) callconv(.Stdcall) HRESULT,
        SetPrivateData: fn (*Self, *const GUID, u32, ?*const c_void) callconv(.Stdcall) HRESULT,
        SetPrivateDataInterface: fn (*Self, *const GUID, ?*const IUnknown) callconv(.Stdcall) HRESULT,
        SetName: fn (*Self, ?*const u16) callconv(.Stdcall) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const GUID, **c_void) callconv(.Stdcall) HRESULT,
        // ID3D12DescriptorHeap
        GetDesc: fn (*Self, *DESCRIPTOR_HEAP_DESC) callconv(.Stdcall) *DESCRIPTOR_HEAP_DESC,
        GetCPUDescriptorHandleForHeapStart: fn (
            *Self,
            *CPU_DESCRIPTOR_HANDLE,
        ) callconv(.Stdcall) *CPU_DESCRIPTOR_HANDLE,
        GetGPUDescriptorHandleForHeapStart: fn (
            *Self,
            *GPU_DESCRIPTOR_HANDLE,
        ) callconv(.Stdcall) *GPU_DESCRIPTOR_HANDLE,
    },
    usingnamespace IUnknown.Methods(Self);
    usingnamespace IObject.Methods(Self);
    usingnamespace IDeviceChild.Methods(Self);
    usingnamespace IDescriptorHeap.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetDesc(self: *T) DESCRIPTOR_HEAP_DESC {
                var desc: DESCRIPTOR_HEAP_DESC = undefined;
                self.vtbl.GetDesc(self, &desc);
                return desc;
            }
            pub inline fn GetCPUDescriptorHandleForHeapStart(self: *T) CPU_DESCRIPTOR_HANDLE {
                var handle: CPU_DESCRIPTOR_HANDLE = undefined;
                self.vtbl.GetCPUDescriptorHandleForHeapStart(self, &handle);
                return handle;
            }
            pub inline fn GetGPUDescriptorHandleForHeapStart(self: *T) GPU_DESCRIPTOR_HANDLE {
                var handle: GPU_DESCRIPTOR_HANDLE = undefined;
                self.vtbl.GetGPUDescriptorHandleForHeapStart(self, &handle);
                return handle;
            }
        };
    }
};

pub const ICommandList = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const GUID, *u32, ?*c_void) callconv(.Stdcall) HRESULT,
        SetPrivateData: fn (*Self, *const GUID, u32, ?*const c_void) callconv(.Stdcall) HRESULT,
        SetPrivateDataInterface: fn (*Self, *const GUID, ?*const IUnknown) callconv(.Stdcall) HRESULT,
        SetName: fn (*Self, ?*const u16) callconv(.Stdcall) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const GUID, **c_void) callconv(.Stdcall) HRESULT,
        // ID3D12CommandList
        GetType: fn (*Self) callconv(.Stdcall) COMMAND_LIST_TYPE,
    },
    usingnamespace IUnknown.Methods(Self);
    usingnamespace IObject.Methods(Self);
    usingnamespace IDeviceChild.Methods(Self);
    usingnamespace ICommandList.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetType(self: *T, blob: *IBlob) COMMAND_LIST_TYPE {
                return self.vtbl.GetType(self);
            }
        };
    }
};

pub const IGraphicsCommandList = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const GUID, *u32, ?*c_void) callconv(.Stdcall) HRESULT,
        SetPrivateData: fn (*Self, *const GUID, u32, ?*const c_void) callconv(.Stdcall) HRESULT,
        SetPrivateDataInterface: fn (*Self, *const GUID, ?*const IUnknown) callconv(.Stdcall) HRESULT,
        SetName: fn (*Self, ?*const u16) callconv(.Stdcall) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const GUID, **c_void) callconv(.Stdcall) HRESULT,
        // ID3D12CommandList
        GetType: fn (*Self) callconv(.Stdcall) COMMAND_LIST_TYPE,
        // ID3D12GraphicsCommandList
        Close: fn (*Self) callconv(.Stdcall) HRESULT,
        Reset: fn (*Self, *ICommandAllocator) callconv(.Stdcall) HRESULT,
        ClearState: fn (*Self, *IPipelineState) callconv(.Stdcall) void,
        DrawInstanced: fn (*Self, u32, u32, u32, u32) callconv(.Stdcall) void,
        DrawIndexedInstanced: fn (*Self, u32, u32, u32, i32, u32) callconv(.Stdcall) void,
        Dispatch: fn (*Self, u32, u32, u32) callconv(.Stdcall) void,
        CopyBufferRegion: fn (*Self, *IResource, u64, *IResource, u64, u64) callconv(.Stdcall) void,
        CopyTextureRegion: fn (
            *Self,
            *const D3D12_TEXTURE_COPY_LOCATION,
            u32,
            u32,
            u32,
            *const D3D12_TEXTURE_COPY_LOCATION,
            *const D3D12_BOX,
        ) callconv(.Stdcall) void,
        CopyResource: fn (*Self, *IResource, *IResource) callconv(.Stdcall) void,
        CopyTiles: fn (
            *Self,
            *IResource,
            *const TILED_RESOURCE_COORDINATE,
            *const TILE_REGION_SIZE,
            *IResource,
            buffer_start_offset_in_bytes: u64,
            TILE_COPY_FLAGS,
        ) callconv(.Stdcall) void,
        ResolveSubresource: fn (*Self, *IResource, u32, *IResource, u32, FORMAT) callconv(.Stdcall) void,
        IASetPrimitiveTopology: fn (*Self, PRIMITIVE_TOPOLOGY) callconv(.Stdcall) void,
        RSSetViewports: fn (*Self, u32, [*]const VIEWPORT) callconv(.Stdcall) void,
        RSSetScissorRects: fn (*Self, u32, [*]const RECT) callconv(.Stdcall) void,
        OMSetBlendFactor: fn (*Self, *const [4]f32) callconv(.Stdcall) void,
        OMSetStencilRef: fn (*Self, u32) callconv(.Stdcall) void,
        SetPipelineState: fn (*Self, *IPipelineState) callconv(.Stdcall) void,
        ResourceBarrier: fn (*Self, u32, [*]const RESOURCE_BARRIER) callconv(.Stdcall) void,
        ExecuteBundle: fn (*Self, *IGraphicsCommandList) callconv(.Stdcall) void,
        SetDescriptorHeaps: fn (*Self, u32, [*]const *IDescriptorHeap) callconv(.Stdcall) void,
        SetComputeRootSignature: fn (*Self, *IRootSignature) callconv(.Stdcall) void,
        SetGraphicsRootSignature: fn (*Self, *IRootSignature) callconv(.Stdcall) void,
        SetComputeRootDescriptorTable: fn (*Self, u32, GPU_DESCRIPTOR_HANDLE) callconv(.Stdcall) void,
        SetGraphicsRootDescriptorTable: fn (*Self, u32, GPU_DESCRIPTOR_HANDLE) callconv(.Stdcall) void,
        SetComputeRoot32BitConstant: fn (*Self, u32, u32, u32) callconv(.Stdcall) void,
        SetGraphicsRoot32BitConstant: fn (*Self, u32, u32, u32) callconv(.Stdcall) void,
        SetComputeRoot32BitConstants: fn (*Self, u32, u32, [*]const c_void, u32) callconv(.Stdcall) void,
        SetGraphicsRoot32BitConstants: fn (*Self, u32, u32, [*]const c_void, u32) callconv(.Stdcall) void,
        SetComputeRootConstantBufferView: fn (*Self, u32, GPU_VIRTUAL_ADDRESS) callconv(.Stdcall) void,
        SetGraphicsRootConstantBufferView: fn (*Self, u32, GPU_VIRTUAL_ADDRESS) callconv(.Stdcall) void,
        SetComputeRootShaderResourceView: fn (*Self, u32, GPU_VIRTUAL_ADDRESS) callconv(.Stdcall) void,
        SetGraphicsRootShaderResourceView: fn (*Self, u32, GPU_VIRTUAL_ADDRESS) callconv(.Stdcall) void,
        SetComputeRootUnorderedAccessView: fn (*Self, u32, GPU_VIRTUAL_ADDRESS) callconv(.Stdcall) void,
        SetGraphicsRootUnorderedAccessView: fn (*Self, u32, GPU_VIRTUAL_ADDRESS) callconv(.Stdcall) void,
        IASetIndexBuffer: fn (*Self, *const INDEX_BUFFER_VIEW) callconv(.Stdcall) void,
        IASetVertexBuffers: fn (*Self, u32, u32, [*]const VERTEX_BUFFER_VIEW) callconv(.Stdcall) void,
        SOSetTargets: fn (*Self, u32, u32, [*]const STREAM_OUTPUT_BUFFER_VIEW) callconv(.Stdcall) void,
        OMSetRenderTargets: fn (
            *Self,
            u32,
            [*]const CPU_DESCRIPTOR_HANDLE,
            i32,
            *const CPU_DESCRIPTOR_HANDLE,
        ) callconv(.Stdcall) void,
        ClearDepthStencilView: fn (
            *Self,
            CPU_DESCRIPTOR_HANDLE,
            CLEAR_FLAGS,
            f32,
            u8,
            u32,
            [*]const D3D12_RECT,
        ) callconv(.Stdcall) void,
        ClearRenderTargetView: fn (
            *Self,
            CPU_DESCRIPTOR_HANDLE,
            *const [4]f32,
            u32,
            [*]const RECT,
        ) callconv(.Stdcall) void,
        ClearUnorderedAccessViewUint: fn (
            *Self,
            GPU_DESCRIPTOR_HANDLE,
            CPU_DESCRIPTOR_HANDLE,
            *IResource,
            *const [4]u32,
            u32,
            [*]const RECT,
        ) callconv(.Stdcall) void,
        ClearUnorderedAccessViewFloat: fn (
            *Self,
            GPU_DESCRIPTOR_HANDLE,
            CPU_DESCRIPTOR_HANDLE,
            *IResource,
            *const [4]f32,
            u32,
            [*]const RECT,
        ) callconv(.Stdcall) void,
    },
    usingnamespace IUnknown.Methods(Self);
    usingnamespace IObject.Methods(Self);
    usingnamespace IDeviceChild.Methods(Self);
    usingnamespace ICommandList.Methods(Self);
    usingnamespace IGraphicsCommandList.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn Close(self: *T) HRESULT {
                return self.vtbl.Close(self);
            }
            pub inline fn Reset(self: *T, allocator: *ICommandAllocator) HRESULT {
                return self.vtbl.Reset(self, allocator);
            }
            pub inline fn ClearState(self: *T, pso: *IPipelineState) void {
                self.vtbl.ClearState(self, pso);
            }
            pub inline fn DrawInstanced(
                self: *T,
                vertex_count_per_instance: u32,
                instance_count: u32,
                start_vertex_location: u32,
                start_instance_location: u32,
            ) void {
                self.vtbl.DrawInstanced(
                    self,
                    vertex_count_per_instance,
                    instance_count,
                    start_vertex_location,
                    start_instance_location,
                );
            }
            pub inline fn DrawIndexedInstanced(
                self: *T,
                index_count_per_instance: u32,
                instance_count: u32,
                start_index_location: u32,
                base_vertex_location: i32,
                start_instance_location: u32,
            ) void {
                self.vtbl.DrawIndexedInstanced(
                    self,
                    index_count_per_instance,
                    instance_count,
                    start_index_location,
                    base_vertex_location,
                    start_instance_location,
                );
            }
            pub inline fn Dispatch(self: *T, count_x: u32, count_y: u32, count_z: u32) void {
                self.vtbl.Dispatch(self, count_x, count_y, count_z);
            }
            pub inline fn CopyBufferRegion(
                self: *T,
                dst_buffer: *IResource,
                dst_offset: u64,
                src_buffer: *IResource,
                src_offset: u64,
                num_bytes: u64,
            ) void {
                self.vtbl.CopyBufferRegion(
                    self,
                    dst_buffer,
                    dst_offset,
                    src_buffer,
                    src_offset,
                    num_bytes,
                );
            }
            pub inline fn CopyTextureRegion(
                self: *T,
                dst: *const D3D12_TEXTURE_COPY_LOCATION,
                dst_x: u32,
                dst_y: u32,
                dst_z: u32,
                src: *const D3D12_TEXTURE_COPY_LOCATION,
                src_box: *const D3D12_BOX,
            ) void {
                self.vtbl.CopyTextureRegion(self, dst, dst_x, dst_y, dst_z, src, src_box);
            }
            pub inline fn CopyResource(self: *T, dst: *IResource, src: *ID3D12Resource) void {
                self.vtbl.CopyResource(self, dst, src);
            }
            pub inline fn CopyTiles(
                self: *T,
                tiled_resource: *IResource,
                tile_region_start_coordinate: *const TILED_RESOURCE_COORDINATE,
                tile_region_size: *const D3D12_TILE_REGION_SIZE,
                buffer: *IResource,
                buffer_start_offset_in_bytes: u64,
                flags: TILE_COPY_FLAGS,
            ) void {
                self.vtbl.CopyTiles(
                    self,
                    tiled_resource,
                    tile_region_start_coordinate,
                    tile_region_size,
                    buffer,
                    buffer_start_offset_in_bytes,
                    flags,
                );
            }
            pub inline fn ResolveSubresource(
                self: *T,
                dst_resource: *IResource,
                dst_subresource: u32,
                src_resource: *ID3D12Resource,
                src_subresource: u32,
                format: FORMAT,
            ) void {
                self.vtbl.ResolveSubresource(
                    self,
                    dst_resource,
                    dst_subresource,
                    src_resource,
                    src_subresource,
                    format,
                );
            }
            pub inline fn IASetPrimitiveTopology(self: *T, topology: PRIMITIVE_TOPOLOGY) void {
                self.vtbl.IASetPrimitiveTopology(self, topology);
            }
            pub inline fn RSSetViewports(self: *T, num: u32, viewports: [*]const VIEWPORT) void {
                self.vtbl.RSSetViewports(self, num, viewports);
            }
            pub inline fn RSSetScissorRects(self: *T, num: u32, rects: [*]const RECT) void {
                self.vtbl.RSSetScissorRects(self, num, rects);
            }
            pub inline fn OMSetBlendFactor(self: *T, blend_factor: *const [4]f32) void {
                self.vtbl.OMSetBlendFactor(self, blend_factor);
            }
            pub inline fn OMSetStencilRef(self: *T, stencil_ref: u32) void {
                self.vtbl.OMSetStencilRef(self, stencil_ref);
            }
            pub inline fn SetPipelineState(self: *T, pso: *IPipelineState) void {
                self.vtbl.SetPipelineState(self, pso);
            }
            pub inline fn ResourceBarrier(
                self: *T,
                num: u32,
                barriers: [*]const D3D12_RESOURCE_BARRIER,
            ) void {
                self.vtbl.ResourceBarrier(self, num, barriers);
            }
            pub inline fn ExecuteBundle(self: *T, cmdlist: *IGraphicsCommandList) void {
                self.vtbl.ExecuteBundle(self, cmdlist);
            }
            pub inline fn SetDescriptorHeaps(self: *T, num: u32, heaps: [*]const *IDescriptorHeap) void {
                self.vtbl.SetDescriptorHeaps(self, num, heaps);
            }
            pub inline fn SetComputeRootSignature(self: *T, root_signature: *IRootSignature) void {
                self.vtbl.SetComputeRootSignature(self, root_signature);
            }
            pub inline fn SetGraphicsRootSignature(self: *T, root_signature: *IRootSignature) void {
                self.vtbl.SetGraphicsRootSignature(self, root_signature);
            }
            pub inline fn SetComputeRootDescriptorTable(
                self: *T,
                root_index: u32,
                base_descriptor: GPU_DESCRIPTOR_HANDLE,
            ) void {
                self.vtbl.SetComputeRootDescriptorTable(self, root_index, base_descriptor);
            }
            pub inline fn SetGraphicsRootDescriptorTable(
                self: *T,
                root_index: u32,
                base_descriptor: GPU_DESCRIPTOR_HANDLE,
            ) void {
                self.vtbl.SetGraphicsRootDescriptorTable(self, root_index, base_descriptor);
            }
            pub inline fn SetComputeRoot32BitConstant(self: *T, index: u32, data: u32, off: u32) void {
                self.vtbl.SetComputeRoot32BitConstant(self, index, data, off);
            }
            pub inline fn SetGraphicsRoot32BitConstant(self: *T, index: u32, data: u32, off: u32) void {
                self.vtbl.SetGraphicsRoot32BitConstant(self, index, data, off);
            }
            pub inline fn SetComputeRoot32BitConstants(
                self: *T,
                root_index: u32,
                num: u32,
                data: [*]const c_void,
                offset: u32,
            ) void {
                self.vtbl.SetComputeRoot32BitConstants(self, root_index, num, data, offset);
            }
            pub inline fn SetGraphicsRoot32BitConstants(
                self: *T,
                root_index: u32,
                num: u32,
                data: [*]const c_void,
                offset: u32,
            ) void {
                self.vtbl.SetGraphicsRoot32BitConstants(self, root_index, num, data, offset);
            }
            pub inline fn SetComputeRootConstantBufferView(
                self: *T,
                index: u32,
                buffer_location: GPU_VIRTUAL_ADDRESS,
            ) void {
                self.vtbl.SetComputeRootConstantBufferView(self, index, buffer_location);
            }
            pub inline fn SetGraphicsRootConstantBufferView(
                self: *T,
                index: u32,
                buffer_location: GPU_VIRTUAL_ADDRESS,
            ) void {
                self.vtbl.SetGraphicsRootConstantBufferView(self, index, buffer_location);
            }
            pub inline fn SetComputeRootShaderResourceView(
                self: *T,
                index: u32,
                buffer_location: GPU_VIRTUAL_ADDRESS,
            ) void {
                self.vtbl.SetComputeRootShaderResourceView(self, index, buffer_location);
            }
            pub inline fn SetGraphicsRootShaderResourceView(
                self: *T,
                index: u32,
                buffer_location: GPU_VIRTUAL_ADDRESS,
            ) void {
                self.vtbl.SetGraphicsRootShaderResourceView(self, index, buffer_location);
            }
            pub inline fn SetComputeRootUnorderedAccessView(
                self: *T,
                index: u32,
                buffer_location: GPU_VIRTUAL_ADDRESS,
            ) void {
                self.vtbl.SetComputeRootUnorderedAccessView(self, index, buffer_location);
            }
            pub inline fn SetGraphicsRootUnorderedAccessView(
                self: *T,
                index: u32,
                buffer_location: GPU_VIRTUAL_ADDRESS,
            ) void {
                self.vtbl.SetGraphicsRootUnorderedAccessView(self, index, buffer_location);
            }
            pub inline fn IASetIndexBuffer(self: *T, view: *const INDEX_BUFFER_VIEW) void {
                self.vtbl.IASetIndexBuffer(self, view);
            }
            pub inline fn IASetVertexBuffers(
                self: *T,
                start_slot: u32,
                num_views: u32,
                views: [*]const VERTEX_BUFFER_VIEW,
            ) void {
                self.vtbl.IASetVertexBuffers(self, start_slot, num_views, views);
            }
            pub inline fn SOSetTargets(
                self: *T,
                start_slot: u32,
                num_views: u32,
                views: [*]const STREAM_OUTPUT_BUFFER_VIEW,
            ) void {
                self.vtbl.SOSetTargets(self, start_slot, num_views, views);
            }
            pub inline fn OMSetRenderTargets(
                self: *T,
                num_rt_descriptors: u32,
                rt_descriptors: [*]const CPU_DESCRIPTOR_HANDLE,
                single_handle: bool,
                ds_descriptors: *const CPU_DESCRIPTOR_HANDLE,
            ) void {
                self.vtbl.OMSetRenderTargets(
                    self,
                    num_rt_descriptors,
                    rt_descriptors,
                    single_handle,
                    ds_descriptors,
                );
            }
            pub inline fn ClearDepthStencilView(
                self: *T,
                ds_view: CPU_DESCRIPTOR_HANDLE,
                clear_flags: CLEAR_FLAGS,
                depth: f32,
                stencil: u8,
                num_rects: u32,
                rects: ?[*]const D3D12_RECT,
            ) void {
                self.vtbl.ClearDepthStencilView(
                    self,
                    ds_view,
                    clear_flags,
                    depth,
                    stencil,
                    num_rects,
                    rects,
                );
            }
            pub inline fn ClearRenderTargetView(
                self: *T,
                rt_view: CPU_DESCRIPTOR_HANDLE,
                rgba: *const [4]f32,
                num_rects: u32,
                rects: [*]const RECT,
            ) void {
                self.vtbl.ClearRenderTargetView(self, rt_view, rgba, num_rects, rects);
            }
            pub inline fn ClearUnorderedAccessViewUint(
                self: *T,
                gpu_view: GPU_DESCRIPTOR_HANDLE,
                cpu_view: CPU_DESCRIPTOR_HANDLE,
                resource: *IResource,
                values: *const [4]u32,
                num_rects: u32,
                rects: [*]const RECT,
            ) void {
                self.vtbl.ClearUnorderedAccessViewUint(
                    self,
                    gpu_view,
                    cpu_view,
                    resource,
                    values,
                    num_rects,
                    rects,
                );
            }
            pub inline fn ClearUnorderedAccessViewFloat(
                self: *T,
                gpu_view: GPU_DESCRIPTOR_HANDLE,
                cpu_view: CPU_DESCRIPTOR_HANDLE,
                resource: *IResource,
                values: *const [4]f32,
                num_rects: u32,
                rects: [*]const RECT,
            ) void {
                self.vtbl.ClearUnorderedAccessViewFloat(
                    self,
                    gpu_view,
                    cpu_view,
                    resource,
                    values,
                    num_rects,
                    rects,
                );
            }
        };
    }
};

pub const ICommandQueue = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const GUID, *u32, ?*c_void) callconv(.Stdcall) HRESULT,
        SetPrivateData: fn (*Self, *const GUID, u32, ?*const c_void) callconv(.Stdcall) HRESULT,
        SetPrivateDataInterface: fn (*Self, *const GUID, ?*const IUnknown) callconv(.Stdcall) HRESULT,
        SetName: fn (*Self, ?*const u16) callconv(.Stdcall) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const GUID, **c_void) callconv(.Stdcall) HRESULT,
        // ID3D12CommandQueue
        UpdateTileMappings: fn (
            *Self,
            *IResource,
            u32,
            [*]const TILED_RESOURCE_COORDINATE,
            [*]const TILE_REGION_SIZE,
            *IHeap,
            u32,
            [*]const TILE_RANGE_FLAGS,
            [*]const u32,
            [*]const u32,
            flags: TILE_MAPPING_FLAGS,
        ) callconv(.Stdcall) void,
        CopyTileMappings: fn (
            *Self,
            *IResource,
            *const TILED_RESOURCE_COORDINATE,
            *IResource,
            *const TILED_RESOURCE_COORDINATE,
            *const TILE_REGION_SIZE,
            TILE_MAPPING_FLAGS,
        ) callconv(.Stdcall) void,
        ExecuteCommandLists: fn (*Self, u32, [*]const *ICommandList) callconv(.Stdcall) void,
        SetMarker: fn (*Self, u32, *const c_void, u32) callconv(.Stdcall) void,
        BeginEvent: fn (*Self, u32, *const c_void, u32) callconv(.Stdcall) void,
        EndEvent: fn (*Self) callconv(.Stdcall) void,
        Signal: fn (*Self, *IFence, u64) callconv(.Stdcall) HRESULT,
        Wait: fn (*Self, *IFence, u64) callconv(.Stdcall) HRESULT,
        GetTimestampFrequency: fn (*Self, *u64) callconv(.Stdcall) HRESULT,
        GetClockCalibration: fn (*Self, *u64, *u64) callconv(.Stdcall) HRESULT,
        GetDesc: fn (*Self, *COMMAND_QUEUE_DESC) callconv(.Stdcall) *COMMAND_QUEUE_DESC,
    },
    usingnamespace IUnknown.Methods(Self);
    usingnamespace IObject.Methods(Self);
    usingnamespace IDeviceChild.Methods(Self);
    usingnamespace ICommandQueue.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn UpdateTileMappings(
                self: *T,
                resource: *IResource,
                num_resource_regions: u32,
                resource_region_start_coordinates: [*]const TILED_RESOURCE_COORDINATE,
                resource_region_sizes: [*]const TILE_REGION_SIZE,
                heap: *IHeap,
                num_ranges: u32,
                range_flags: [*]const TILE_RANGE_FLAGS,
                heap_range_start_offsets: [*]const u32,
                range_tile_counts: [*]const u32,
                flags: TILE_MAPPING_FLAGS,
            ) void {
                self.vtbl.UpdateTileMappings(
                    self,
                    resource,
                    num_resource_regions,
                    resource_region_start_coordinates,
                    resource_region_sizes,
                    heap,
                    num_ranges,
                    range_flags,
                    heap_range_start_offsets,
                    range_tile_counts,
                    flags,
                );
            }
            pub inline fn CopyTileMappings(
                self: *T,
                dst_resource: *IResource,
                dst_region_start_coordinate: *const TILED_RESOURCE_COORDINATE,
                src_resource: *IResource,
                src_region_start_coordinate: *const TILED_RESOURCE_COORDINATE,
                region_size: *const TILE_REGION_SIZE,
                flags: TILE_MAPPING_FLAGS,
            ) void {
                self.vtbl.CopyTileMappings(
                    self,
                    dst_resource,
                    dst_region_start_coordinate,
                    src_resource,
                    src_region_start_coordinate,
                    region_size,
                    flags,
                );
            }
            pub inline fn ExecuteCommandLists(
                self: *T,
                num: u32,
                cmdlists: [*]const *ICommandList,
            ) void {
                self.vtbl.ExecuteCommandLists(self, num, cmdlists);
            }
            pub inline fn SetMarker(self: *T, metadata: u32, data: *const c_void, size: u32) void {
                self.vtbl.SetMarker(self, metadata, data, size);
            }
            pub inline fn BeginEvent(self: *T, metadata: u32, data: *const c_void, size: u32) void {
                self.vtbl.BeginEvent(self, metadata, data, size);
            }
            pub inline fn EndEvent(self: *T) void {
                self.vtbl.EndEvent(self);
            }
            pub inline fn Signal(self: *T, fence: *IFence, value: u64) HRESULT {
                return self.vtbl.Signal(self, fence, value);
            }
            pub inline fn Wait(self: *T, fence: *IFence, value: u64) HRESULT {
                return self.vtbl.Wait(self, fence, value);
            }
            pub inline fn GetTimestampFrequency(self: *T, frequency: *u64) HRESULT {
                return self.vtbl.GetTimestampFrequency(self, frequency);
            }
            pub inline fn GetClockCalibration(
                self: *T,
                gpu_timestamp: *u64,
                cpu_timestamp: *u64,
            ) HRESULT {
                return self.vtbl.GetClockCalibration(self, gpu_timestamp, cpu_timestamp);
            }
            pub inline fn GetDesc(self: *T) COMMAND_QUEUE_DESC {
                var desc: COMMAND_QUEUE_DESC = undefined;
                self.vtbl.GetDesc(self, &desc);
                return desc;
            }
        };
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

pub var GetDebugInterface: fn (*const os.GUID, **c_void) callconv(.Stdcall) HRESULT = undefined;
pub var CreateDevice: fn (
    ?*IUnknown,
    FEATURE_LEVEL,
    *const os.GUID,
    **c_void,
) callconv(.Stdcall) HRESULT = undefined;

pub fn init() void {
    // TODO: Handle error.
    var d3d12_dll = std.DynLib.open("/windows/system32/d3d12.dll") catch unreachable;
    GetDebugInterface = d3d12_dll.lookup(@TypeOf(GetDebugInterface), "D3D12GetDebugInterface").?;
    CreateDevice = d3d12_dll.lookup(@TypeOf(CreateDevice), "D3D12CreateDevice").?;
}
