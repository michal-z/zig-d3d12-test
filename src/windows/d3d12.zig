const std = @import("std");
const os = @import("windows.zig");
const dxgi = @import("dxgi.zig");
const dcommon = @import("dcommon.zig");

pub const RESOURCE_BARRIER_ALL_SUBRESOURCES = 0xffffffff;

pub const GPU_VIRTUAL_ADDRESS = u64;

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
    CPUPageProperty: CPU_PAGE_PROPERTY = .UNKNOWN,
    MemoryPoolPreference: MEMORY_POOL = .UNKNOWN,
    CreationNodeMask: u32 = 0,
    VisibleNodeMask: u32 = 0,
};

pub const HEAP_FLAGS = packed struct {
    SHARED: bool = false,
    DENY_BUFFERS: bool = false,
    ALLOW_DISPLAY: bool = false,
    SHARED_CROSS_ADAPTER: bool = false,
    DENY_RT_DS_TEXTURES: bool = false,
    DENY_NON_RT_DS_TEXTURES: bool = false,
    HARDWARE_PROTECTED: bool = false,

    padding: u25 = 0,
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

pub const RESOURCE_FLAGS = packed struct {
    ALLOW_RENDER_TARGET: bool = false,
    ALLOW_DEPTH_STENCIL: bool = false,
    ALLOW_UNORDERED_ACCESS: bool = false,
    DENY_SHADER_RESOURCE: bool = false,
    ALLOW_CROSS_ADAPTER: bool = false,
    ALLOW_SIMULTANEOUS_ACCESS: bool = false,

    padding: u26 = 0,
};

pub const RESOURCE_DESC = extern struct {
    Dimension: RESOURCE_DIMENSION,
    Alignment: u64,
    Width: u64,
    Height: u32,
    DepthOrArraySize: u16,
    MipLevels: u16,
    Format: dxgi.FORMAT,
    SampleDesc: dxgi.SAMPLE_DESC,
    Layout: TEXTURE_LAYOUT,
    Flags: RESOURCE_FLAGS,

    pub fn buffer(width: u64) RESOURCE_DESC {
        return RESOURCE_DESC{
            .Dimension = .BUFFER,
            .Alignment = 0,
            .Width = width,
            .Height = 1,
            .DepthOrArraySize = 1,
            .MipLevels = 1,
            .Format = .UNKNOWN,
            .SampleDesc = .{ .Count = 1, .Quality = 0 },
            .Layout = .ROW_MAJOR,
            .Flags = .{},
        };
    }

    pub fn tex2d(format: dxgi.FORMAT, width: u64, height: u32) RESOURCE_DESC {
        return RESOURCE_DESC{
            .Dimension = .TEXTURE2D,
            .Alignment = 0,
            .Width = width,
            .Height = height,
            .DepthOrArraySize = 1,
            .MipLevels = 1,
            .Format = format,
            .SampleDesc = .{ .Count = 1, .Quality = 0 },
            .Layout = .UNKNOWN,
            .Flags = .{},
        };
    }
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

pub const RECT = os.RECT;

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
    Format: dxgi.FORMAT,
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

pub const TILED_RESOURCE_COORDINATE = extern struct {
    X: u32,
    Y: u32,
    Z: u32,
    Subresource: u32,
};

pub const TILE_REGION_SIZE = extern struct {
    NumTiles: u32,
    UseBox: os.BOOL,
    Width: u32,
    Height: u16,
    Depth: u16,
};

pub const TILE_RANGE_FLAGS = extern enum {
    NONE = 0,
    NULL = 1,
    SKIP = 2,
    REUSE_SINGLE_TILE = 4,
};

pub const SUBRESOURCE_TILING = extern struct {
    WidthInTiles: u32,
    HeightInTiles: u16,
    DepthInTiles: u16,
    StartTileIndexInOverallResource: u32,
};

pub const TILE_SHAPE = extern struct {
    WidthInTexels: u32,
    HeightInTexels: u32,
    DepthInTexels: u32,
};

pub const TILE_MAPPING_FLAGS = extern enum {
    NONE = 0,
    NO_HAZARD = 0x1,
};

pub const TILE_COPY_FLAGS = extern enum {
    NONE = 0,
    NO_HAZARD = 0x1,
    LINEAR_BUFFER_TO_SWIZZLED_TILED_RESOURCE = 0x2,
    SWIZZLED_TILED_RESOURCE_TO_LINEAR_BUFFER = 0x4,
};

pub const SHADER_BYTECODE = extern struct {
    pShaderBytecode: ?*const c_void = null,
    BytecodeLength: u64 = 0,
};

pub const SO_DECLARATION_ENTRY = extern struct {
    Stream: u32,
    SemanticName: os.LPCSTR,
    SemanticIndex: u32,
    StartComponent: u8,
    ComponentCount: u8,
    OutputSlot: u8,
};

pub const STREAM_OUTPUT_DESC = extern struct {
    pSODeclaration: ?[*]const SO_DECLARATION_ENTRY = null,
    NumEntries: u32 = 0,
    pBufferStrides: ?[*]const u32 = null,
    NumStrides: u32 = 0,
    RasterizedStream: u32 = 0,
};

pub const BLEND = extern enum {
    ZERO = 1,
    ONE = 2,
    SRC_COLOR = 3,
    INV_SRC_COLOR = 4,
    SRC_ALPHA = 5,
    INV_SRC_ALPHA = 6,
    DEST_ALPHA = 7,
    INV_DEST_ALPHA = 8,
    DEST_COLOR = 9,
    INV_DEST_COLOR = 10,
    SRC_ALPHA_SAT = 11,
    BLEND_FACTOR = 14,
    INV_BLEND_FACTOR = 15,
    SRC1_COLOR = 16,
    INV_SRC1_COLOR = 17,
    SRC1_ALPHA = 18,
    INV_SRC1_ALPHA = 19,
};

pub const BLEND_OP = extern enum {
    ADD = 1,
    SUBTRACT = 2,
    REV_SUBTRACT = 3,
    MIN = 4,
    MAX = 5,
};

pub const COLOR_WRITE_ENABLE = extern enum {
    RED = 1,
    GREEN = 2,
    BLUE = 4,
    ALPHA = 8,
    ALL = 1 | 2 | 4 | 8, // TODO: Fix this.
};

pub const LOGIC_OP = extern enum {
    CLEAR = 0,
    SET = 1,
    COPY = 2,
    COPY_INVERTED = 3,
    NOOP = 4,
    INVERT = 5,
    AND = 6,
    NAND = 7,
    OR = 8,
    NOR = 9,
    XOR = 10,
    EQUIV = 11,
    AND_REVERSE = 12,
    AND_INVERTED = 13,
    OR_REVERSE = 14,
    OR_INVERTED = 15,
};

pub const MESSAGE_CATEGORY = extern enum {
    APPLICATION_DEFINED = 0,
    MISCELLANEOUS = 1,
    INITIALIZATION = 2,
    CLEANUP = 3,
    COMPILATION = 4,
    STATE_CREATION = 5,
    STATE_SETTING = 6,
    STATE_GETTING = 7,
    RESOURCE_MANIPULATION = 8,
    EXECUTION = 9,
    SHADER = 10,
};

pub const MESSAGE_SEVERITY = extern enum {
    CORRUPTION = 0,
    ERROR = 1,
    WARNING = 2,
    INFO = 3,
    MESSAGE = 4,
};

pub const MESSAGE_ID = extern enum {
    CLEARRENDERTARGETVIEW_MISMATCHINGCLEARVALUE = 820,
};

pub const INFO_QUEUE_FILTER_DESC = extern struct {
    NumCategories: u32,
    pCategoryList: ?[*]MESSAGE_CATEGORY,
    NumSeverities: u32,
    pSeverityList: ?[*]MESSAGE_SEVERITY,
    NumIDs: u32,
    pIDList: ?[*]MESSAGE_ID,
};

pub const INFO_QUEUE_FILTER = extern struct {
    AllowList: INFO_QUEUE_FILTER_DESC,
    DenyList: INFO_QUEUE_FILTER_DESC,
};

pub const RENDER_TARGET_BLEND_DESC = extern struct {
    BlendEnable: os.BOOL = os.FALSE,
    LogicOpEnable: os.BOOL = os.FALSE,
    SrcBlend: BLEND = .ONE,
    DestBlend: BLEND = .ZERO,
    BlendOp: BLEND_OP = .ADD,
    SrcBlendAlpha: BLEND = .ONE,
    DestBlendAlpha: BLEND = .ZERO,
    BlendOpAlpha: BLEND_OP = .ADD,
    LogicOp: LOGIC_OP = .NOOP,
    RenderTargetWriteMask: u8 = 0x0f,
};

pub const BLEND_DESC = extern struct {
    AlphaToCoverageEnable: os.BOOL = os.FALSE,
    IndependentBlendEnable: os.BOOL = os.FALSE,
    RenderTarget: [8]RENDER_TARGET_BLEND_DESC = [_]RENDER_TARGET_BLEND_DESC{.{}} ** 8,
};

pub const RASTERIZER_DESC = extern struct {
    FillMode: FILL_MODE = .SOLID,
    CullMode: CULL_MODE = .BACK,
    FrontCounterClockwise: os.BOOL = os.FALSE,
    DepthBias: i32 = 0,
    DepthBiasClamp: f32 = 0.0,
    SlopeScaledDepthBias: f32 = 0.0,
    DepthClipEnable: os.BOOL = os.TRUE,
    MultisampleEnable: os.BOOL = os.FALSE,
    AntialiasedLineEnable: os.BOOL = os.FALSE,
    ForcedSampleCount: u32 = 0,
    ConservativeRaster: CONSERVATIVE_RASTERIZATION_MODE = .OFF,
};

pub const FILL_MODE = extern enum {
    WIREFRAME = 2,
    SOLID = 3,
};

pub const CONSERVATIVE_RASTERIZATION_MODE = extern enum {
    OFF = 0,
    ON = 1,
};

pub const COMPARISON_FUNC = extern enum {
    NEVER = 1,
    LESS = 2,
    EQUAL = 3,
    LESS_EQUAL = 4,
    GREATER = 5,
    NOT_EQUAL = 6,
    GREATER_EQUAL = 7,
    ALWAYS = 8,
};

pub const DEPTH_WRITE_MASK = extern enum {
    ZERO = 0,
    ALL = 1,
};

pub const STENCIL_OP = extern enum {
    KEEP = 1,
    ZERO = 2,
    REPLACE = 3,
    INCR_SAT = 4,
    DECR_SAT = 5,
    INVERT = 6,
    INCR = 7,
    DECR = 8,
};

pub const DEPTH_STENCILOP_DESC = extern struct {
    StencilFailOp: STENCIL_OP = .KEEP,
    StencilDepthFailOp: STENCIL_OP = .KEEP,
    StencilPassOp: STENCIL_OP = .KEEP,
    StencilFunc: COMPARISON_FUNC = .ALWAYS,
};

pub const DEPTH_STENCIL_DESC = extern struct {
    DepthEnable: os.BOOL = os.TRUE,
    DepthWriteMask: DEPTH_WRITE_MASK = .ALL,
    DepthFunc: COMPARISON_FUNC = .LESS,
    StencilEnable: os.BOOL = os.FALSE,
    StencilReadMask: u8 = 0xff,
    StencilWriteMask: u8 = 0xff,
    FrontFace: DEPTH_STENCILOP_DESC = .{},
    BackFace: DEPTH_STENCILOP_DESC = .{},
};

pub const INPUT_LAYOUT_DESC = extern struct {
    pInputElementDescs: ?[*]const INPUT_ELEMENT_DESC = null,
    NumElements: u32 = 0,
};

pub const INPUT_CLASSIFICATION = extern enum {
    PER_VERTEX_DATA = 0,
    PER_INSTANCE_DATA = 1,
};

pub const INPUT_ELEMENT_DESC = extern struct {
    SemanticName: os.LPCSTR,
    SemanticIndex: u32,
    Format: dxgi.FORMAT,
    InputSlot: u32,
    AlignedByteOffset: u32,
    InputSlotClass: INPUT_CLASSIFICATION,
    InstanceDataStepRate: u32,
};

pub const INDEX_BUFFER_STRIP_CUT_VALUE = extern enum {
    DISABLED = 0,
    _0xFFFF = 1,
    _0xFFFFFFFF = 2,
};

pub const VERTEX_BUFFER_VIEW = extern struct {
    BufferLocation: GPU_VIRTUAL_ADDRESS,
    SizeInBytes: u32,
    StrideInBytes: u32,
};

pub const INDEX_BUFFER_VIEW = extern struct {
    BufferLocation: GPU_VIRTUAL_ADDRESS,
    SizeInBytes: u32,
    Format: dxgi.FORMAT,
};

pub const STREAM_OUTPUT_BUFFER_VIEW = extern struct {
    BufferLocation: GPU_VIRTUAL_ADDRESS,
    SizeInBytes: u64,
    BufferFilledSizeLocation: GPU_VIRTUAL_ADDRESS,
};

pub const CACHED_PIPELINE_STATE = extern struct {
    pCachedBlob: ?*const c_void = null,
    CachedBlobSizeInBytes: u64 = 0,
};

pub const CLEAR_FLAGS = packed struct {
    DEPTH: bool = false,
    STENCIL: bool = false,

    padding: u30 = 0,
};

pub const PIPELINE_STATE_FLAGS = extern enum {
    NONE = 0,
    TOOL_DEBUG = 0x1,
};

pub const PRIMITIVE_TOPOLOGY = extern enum {
    UNDEFINED = 0,
    POINTLIST = 1,
    LINELIST = 2,
    LINESTRIP = 3,
    TRIANGLELIST = 4,
    TRIANGLESTRIP = 5,
    LINELIST_ADJ = 10,
    LINESTRIP_ADJ = 11,
    TRIANGLELIST_ADJ = 12,
    TRIANGLESTRIP_ADJ = 13,
    _1_CONTROL_POINT_PATCHLIST = 33,
    _2_CONTROL_POINT_PATCHLIST = 34,
    _3_CONTROL_POINT_PATCHLIST = 35,
    _4_CONTROL_POINT_PATCHLIST = 36,
    _5_CONTROL_POINT_PATCHLIST = 37,
    _6_CONTROL_POINT_PATCHLIST = 38,
    _7_CONTROL_POINT_PATCHLIST = 39,
    _8_CONTROL_POINT_PATCHLIST = 40,
    _9_CONTROL_POINT_PATCHLIST = 41,
    _10_CONTROL_POINT_PATCHLIST = 42,
    _11_CONTROL_POINT_PATCHLIST = 43,
    _12_CONTROL_POINT_PATCHLIST = 44,
    _13_CONTROL_POINT_PATCHLIST = 45,
    _14_CONTROL_POINT_PATCHLIST = 46,
    _15_CONTROL_POINT_PATCHLIST = 47,
    _16_CONTROL_POINT_PATCHLIST = 48,
    _17_CONTROL_POINT_PATCHLIST = 49,
    _18_CONTROL_POINT_PATCHLIST = 50,
    _19_CONTROL_POINT_PATCHLIST = 51,
    _20_CONTROL_POINT_PATCHLIST = 52,
    _21_CONTROL_POINT_PATCHLIST = 53,
    _22_CONTROL_POINT_PATCHLIST = 54,
    _23_CONTROL_POINT_PATCHLIST = 55,
    _24_CONTROL_POINT_PATCHLIST = 56,
    _25_CONTROL_POINT_PATCHLIST = 57,
    _26_CONTROL_POINT_PATCHLIST = 58,
    _27_CONTROL_POINT_PATCHLIST = 59,
    _28_CONTROL_POINT_PATCHLIST = 60,
    _29_CONTROL_POINT_PATCHLIST = 61,
    _30_CONTROL_POINT_PATCHLIST = 62,
    _31_CONTROL_POINT_PATCHLIST = 63,
    _32_CONTROL_POINT_PATCHLIST = 64,
};

pub const SHADER_COMPONENT_MAPPING = extern enum {
    FROM_MEMORY_COMPONENT_0 = 0,
    FROM_MEMORY_COMPONENT_1 = 1,
    FROM_MEMORY_COMPONENT_2 = 2,
    FROM_MEMORY_COMPONENT_3 = 3,
    FORCE_VALUE_0 = 4,
    FORCE_VALUE_1 = 5,
};

pub inline fn ENCODE_SHADER_4_COMPONENT_MAPPING(src0: u32, src1: u32, src2: u32, src3: u32) u32 {
    return (src0 & 0x7) |
        ((src1 & 0x7) << 3) |
        ((src2 & 0x7) << (3 * 2)) |
        ((src3 & 0x7) << (3 * 3)) |
        (1 << (3 * 4));
}
pub const DEFAULT_SHADER_4_COMPONENT_MAPPING = ENCODE_SHADER_4_COMPONENT_MAPPING(0, 1, 2, 3);

pub const BUFFER_SRV_FLAGS = extern enum {
    NONE = 0,
    RAW = 0x1,
};

pub const BUFFER_SRV = extern struct {
    FirstElement: u64,
    NumElements: u32,
    StructureByteStride: u32,
    Flags: BUFFER_SRV_FLAGS = .NONE,
};

pub const TEX1D_SRV = extern struct {
    MostDetailedMip: u32,
    MipLevels: u32,
    ResourceMinLODClamp: f32,
};

pub const TEX1D_ARRAY_SRV = extern struct {
    MostDetailedMip: u32,
    MipLevels: u32,
    FirstArraySlice: u32,
    ArraySize: u32,
    ResourceMinLODClamp: f32,
};

pub const TEX2D_SRV = extern struct {
    MostDetailedMip: u32,
    MipLevels: u32,
    PlaneSlice: u32,
    ResourceMinLODClamp: f32,
};

pub const TEX2D_ARRAY_SRV = extern struct {
    MostDetailedMip: u32,
    MipLevels: u32,
    FirstArraySlice: u32,
    ArraySize: u32,
    PlaneSlice: u32,
    ResourceMinLODClamp: f32,
};

pub const TEX3D_SRV = extern struct {
    MostDetailedMip: u32,
    MipLevels: u32,
    ResourceMinLODClamp: f32,
};

pub const TEXCUBE_SRV = extern struct {
    MostDetailedMip: u32,
    MipLevels: u32,
    ResourceMinLODClamp: f32,
};

pub const TEXCUBE_ARRAY_SRV = extern struct {
    MostDetailedMip: u32,
    MipLevels: u32,
    First2DArrayFace: u32,
    NumCubes: u32,
    ResourceMinLODClamp: f32,
};

pub const TEX2DMS_SRV = extern struct {
    UnusedField_NothingToDefine: u32,
};

pub const TEX2DMS_ARRAY_SRV = extern struct {
    FirstArraySlice: u32,
    ArraySize: u32,
};

pub const SRV_DIMENSION = extern enum {
    UNKNOWN = 0,
    BUFFER = 1,
    TEXTURE1D = 2,
    TEXTURE1DARRAY = 3,
    TEXTURE2D = 4,
    TEXTURE2DARRAY = 5,
    TEXTURE2DMS = 6,
    TEXTURE2DMSARRAY = 7,
    TEXTURE3D = 8,
    TEXTURECUBE = 9,
    TEXTURECUBEARRAY = 10,
};

pub const SHADER_RESOURCE_VIEW_DESC = extern struct {
    Format: dxgi.FORMAT = dxgi.FORMAT.UNKNOWN,
    ViewDimension: SRV_DIMENSION,
    Shader4ComponentMapping: u32 = DEFAULT_SHADER_4_COMPONENT_MAPPING,
    u: extern union {
        Buffer: BUFFER_SRV,
        Texture1D: TEX1D_SRV,
        Texture1DArray: TEX1D_ARRAY_SRV,
        Texture2D: TEX2D_SRV,
        Texture2DArray: TEX2D_ARRAY_SRV,
        Texture2DMS: TEX2DMS_SRV,
        Texture2DMSArray: TEX2DMS_ARRAY_SRV,
        Texture3D: TEX3D_SRV,
        TextureCube: TEXCUBE_SRV,
        TextureCubeArray: TEXCUBE_ARRAY_SRV,
    },

    pub fn typedBuffer(
        format: dxgi.FORMAT,
        first_element: u64,
        num_elements: u32,
    ) SHADER_RESOURCE_VIEW_DESC {
        return SHADER_RESOURCE_VIEW_DESC{
            .Format = format,
            .ViewDimension = .BUFFER,
            .u = .{
                .Buffer = BUFFER_SRV{
                    .FirstElement = first_element,
                    .NumElements = num_elements,
                    .StructureByteStride = 0,
                },
            },
        };
    }

    pub fn structuredBuffer(
        first_element: u64,
        num_elements: u32,
        stride: u32,
    ) SHADER_RESOURCE_VIEW_DESC {
        return SHADER_RESOURCE_VIEW_DESC{
            .ViewDimension = .BUFFER,
            .u = .{
                .Buffer = BUFFER_SRV{
                    .FirstElement = first_element,
                    .NumElements = num_elements,
                    .StructureByteStride = stride,
                },
            },
        };
    }
};

pub const FILTER = extern enum {
    MIN_MAG_MIP_POINT = 0,
    MIN_MAG_POINT_MIP_LINEAR = 0x1,
    MIN_POINT_MAG_LINEAR_MIP_POINT = 0x4,
    MIN_POINT_MAG_MIP_LINEAR = 0x5,
    MIN_LINEAR_MAG_MIP_POINT = 0x10,
    MIN_LINEAR_MAG_POINT_MIP_LINEAR = 0x11,
    MIN_MAG_LINEAR_MIP_POINT = 0x14,
    MIN_MAG_MIP_LINEAR = 0x15,
    ANISOTROPIC = 0x55,
    COMPARISON_MIN_MAG_MIP_POINT = 0x80,
    COMPARISON_MIN_MAG_POINT_MIP_LINEAR = 0x81,
    COMPARISON_MIN_POINT_MAG_LINEAR_MIP_POINT = 0x84,
    COMPARISON_MIN_POINT_MAG_MIP_LINEAR = 0x85,
    COMPARISON_MIN_LINEAR_MAG_MIP_POINT = 0x90,
    COMPARISON_MIN_LINEAR_MAG_POINT_MIP_LINEAR = 0x91,
    COMPARISON_MIN_MAG_LINEAR_MIP_POINT = 0x94,
    COMPARISON_MIN_MAG_MIP_LINEAR = 0x95,
    COMPARISON_ANISOTROPIC = 0xd5,
    MINIMUM_MIN_MAG_MIP_POINT = 0x100,
    MINIMUM_MIN_MAG_POINT_MIP_LINEAR = 0x101,
    MINIMUM_MIN_POINT_MAG_LINEAR_MIP_POINT = 0x104,
    MINIMUM_MIN_POINT_MAG_MIP_LINEAR = 0x105,
    MINIMUM_MIN_LINEAR_MAG_MIP_POINT = 0x110,
    MINIMUM_MIN_LINEAR_MAG_POINT_MIP_LINEAR = 0x111,
    MINIMUM_MIN_MAG_LINEAR_MIP_POINT = 0x114,
    MINIMUM_MIN_MAG_MIP_LINEAR = 0x115,
    MINIMUM_ANISOTROPIC = 0x155,
    MAXIMUM_MIN_MAG_MIP_POINT = 0x180,
    MAXIMUM_MIN_MAG_POINT_MIP_LINEAR = 0x181,
    MAXIMUM_MIN_POINT_MAG_LINEAR_MIP_POINT = 0x184,
    MAXIMUM_MIN_POINT_MAG_MIP_LINEAR = 0x185,
    MAXIMUM_MIN_LINEAR_MAG_MIP_POINT = 0x190,
    MAXIMUM_MIN_LINEAR_MAG_POINT_MIP_LINEAR = 0x191,
    MAXIMUM_MIN_MAG_LINEAR_MIP_POINT = 0x194,
    MAXIMUM_MIN_MAG_MIP_LINEAR = 0x195,
    MAXIMUM_ANISOTROPIC = 0x1d5,
};

pub const FILTER_TYPE = extern enum {
    POINT = 0,
    LINEAR = 1,
};

pub const FILTER_REDUCTION_TYPE = extern enum {
    STANDARD = 0,
    COMPARISON = 1,
    MINIMUM = 2,
    MAXIMUM = 3,
};

pub const TEXTURE_ADDRESS_MODE = extern enum {
    WRAP = 1,
    MIRROR = 2,
    CLAMP = 3,
    BORDER = 4,
    MIRROR_ONCE = 5,
};

pub const SAMPLER_DESC = extern struct {
    Filter: FILTER,
    AddressU: TEXTURE_ADDRESS_MODE,
    AddressV: TEXTURE_ADDRESS_MODE,
    AddressW: TEXTURE_ADDRESS_MODE,
    MipLODBias: f32,
    MaxAnisotropy: u32,
    ComparisonFunc: COMPARISON_FUNC,
    BorderColor: [4]f32,
    MinLOD: f32,
    MaxLOD: f32,
};

pub const CONSTANT_BUFFER_VIEW_DESC = extern struct {
    BufferLocation: GPU_VIRTUAL_ADDRESS,
    SizeInBytes: u32,
};

pub const BUFFER_UAV_FLAGS = extern enum {
    NONE = 0,
    RAW = 0x1,
};

pub const BUFFER_UAV = extern struct {
    FirstElement: u64,
    NumElements: u32,
    StructureByteStride: u32,
    CounterOffsetInBytes: u64,
    Flags: BUFFER_UAV_FLAGS,
};

pub const TEX1D_UAV = extern struct {
    MipSlice: u32,
};

pub const TEX1D_ARRAY_UAV = extern struct {
    MipSlice: u32,
    FirstArraySlice: u32,
    ArraySize: u32,
};

pub const TEX2D_UAV = extern struct {
    MipSlice: u32,
    PlaneSlice: u32,
};

pub const TEX2D_ARRAY_UAV = extern struct {
    MipSlice: u32,
    FirstArraySlice: u32,
    ArraySize: u32,
    PlaneSlice: u32,
};

pub const TEX3D_UAV = extern struct {
    MipSlice: u32,
    FirstWSlice: u32,
    WSize: u32,
};

pub const UAV_DIMENSION = extern enum {
    UNKNOWN = 0,
    BUFFER = 1,
    TEXTURE1D = 2,
    TEXTURE1DARRAY = 3,
    TEXTURE2D = 4,
    TEXTURE2DARRAY = 5,
    TEXTURE3D = 8,
};

pub const UNORDERED_ACCESS_VIEW_DESC = extern struct {
    Format: dxgi.FORMAT,
    ViewDimension: UAV_DIMENSION,
    u: extern union {
        Buffer: BUFFER_UAV,
        Texture1D: TEX1D_UAV,
        Texture1DArray: TEX1D_ARRAY_UAV,
        Texture2D: TEX2D_UAV,
        Texture2DArray: TEX2D_ARRAY_UAV,
        Texture3D: TEX3D_UAV,
    },
};

pub const BUFFER_RTV = extern struct {
    FirstElement: u64,
    NumElements: u32,
};

pub const TEX1D_RTV = extern struct {
    MipSlice: u32,
};

pub const TEX1D_ARRAY_RTV = extern struct {
    MipSlice: u32,
    FirstArraySlice: u32,
    ArraySize: u32,
};

pub const TEX2D_RTV = extern struct {
    MipSlice: u32,
    PlaneSlice: u32,
};

pub const TEX2DMS_RTV = extern struct {
    UnusedField_NothingToDefine: u32,
};

pub const TEX2D_ARRAY_RTV = extern struct {
    MipSlice: u32,
    FirstArraySlice: u32,
    ArraySize: u32,
    PlaneSlice: u32,
};

pub const TEX2DMS_ARRAY_RTV = extern struct {
    FirstArraySlice: u32,
    ArraySize: u32,
};

pub const TEX3D_RTV = extern struct {
    MipSlice: u32,
    FirstWSlice: u32,
    WSize: u32,
};

pub const RTV_DIMENSION = extern enum {
    UNKNOWN = 0,
    BUFFER = 1,
    TEXTURE1D = 2,
    TEXTURE1DARRAY = 3,
    TEXTURE2D = 4,
    TEXTURE2DARRAY = 5,
    TEXTURE2DMS = 6,
    TEXTURE2DMSARRAY = 7,
    TEXTURE3D = 8,
};

pub const RENDER_TARGET_VIEW_DESC = extern struct {
    Format: dxgi.FORMAT,
    ViewDimension: RTV_DIMENSION,
    u: extern union {
        Buffer: BUFFER_RTV,
        Texture1D: TEX1D_RTV,
        Texture1DArray: TEX1D_ARRAY_RTV,
        Texture2D: TEX2D_RTV,
        Texture2DArray: TEX2D_ARRAY_RTV,
        Texture2DMS: TEX2DMS_RTV,
        Texture2DMSArray: TEX2DMS_ARRAY_RTV,
        Texture3D: TEX3D_RTV,
    },
};

pub const TEX1D_DSV = extern struct {
    MipSlice: u32,
};

pub const TEX1D_ARRAY_DSV = extern struct {
    MipSlice: u32,
    FirstArraySlice: u32,
    ArraySize: u32,
};

pub const TEX2D_DSV = extern struct {
    MipSlice: u32,
};

pub const TEX2D_ARRAY_DSV = extern struct {
    MipSlice: u32,
    FirstArraySlice: u32,
    ArraySize: u32,
};

pub const TEX2DMS_DSV = extern struct {
    UnusedField_NothingToDefine: u32,
};

pub const TEX2DMS_ARRAY_DSV = extern struct {
    FirstArraySlice: u32,
    ArraySize: u32,
};

pub const DSV_FLAGS = extern enum {
    NONE = 0,
    READ_ONLY_DEPTH = 0x1,
    READ_ONLY_STENCIL = 0x2,
};

pub const DSV_DIMENSION = extern enum {
    UNKNOWN = 0,
    TEXTURE1D = 1,
    TEXTURE1DARRAY = 2,
    TEXTURE2D = 3,
    TEXTURE2DARRAY = 4,
    TEXTURE2DMS = 5,
    TEXTURE2DMSARRAY = 6,
};

pub const DEPTH_STENCIL_VIEW_DESC = extern struct {
    Format: dxgi.FORMAT,
    ViewDimension: DSV_DIMENSION,
    Flags: DSV_FLAGS,
    u: extern union {
        Texture1D: TEX1D_DSV,
        Texture1DArray: TEX1D_ARRAY_DSV,
        Texture2D: TEX2D_DSV,
        Texture2DArray: TEX2D_ARRAY_DSV,
        Texture2DMS: TEX2DMS_DSV,
        Texture2DMSArray: TEX2DMS_ARRAY_DSV,
    },
};

pub const DEPTH_STENCIL_VALUE = extern struct {
    Depth: f32,
    Stencil: u8,
};

pub const CLEAR_VALUE = extern struct {
    Format: dxgi.FORMAT,
    u: extern union {
        Color: [4]f32,
        DepthStencil: DEPTH_STENCIL_VALUE,
    },

    pub fn color(format: dxgi.FORMAT, in_color: [4]f32) CLEAR_VALUE {
        return CLEAR_VALUE{
            .Format = format,
            .u = .{ .Color = in_color },
        };
    }

    pub fn depthStencil(format: dxgi.FORMAT, depth: f32, stencil: u8) CLEAR_VALUE {
        return CLEAR_VALUE{
            .Format = format,
            .u = .{ .DepthStencil = .{ .Depth = depth, .Stencil = stencil } },
        };
    }
};

pub const FENCE_FLAGS = extern enum {
    NONE = 0,
    SHARED = 0x1,
    SHARED_CROSS_ADAPTER = 0x2,
};

// TODO: This has alignment of 1. How to force alignment of 4?
//'pub const RESOURCE_STATES align(4) = packed struct {' causes compiler error.
pub const RESOURCE_STATES = packed struct {
    VERTEX_AND_CONSTANT_BUFFER: bool = false,
    INDEX_BUFFER: bool = false,
    RENDER_TARGET: bool = false,
    UNORDERED_ACCESS: bool = false,
    DEPTH_WRITE: bool = false,
    DEPTH_READ: bool = false,
    NON_PIXEL_SHADER_RESOURCE: bool = false,
    PIXEL_SHADER_RESOURCE: bool = false,
    STREAM_OUT: bool = false,
    INDIRECT_ARGUMENT_AND_PREDICATION: bool = false,
    COPY_DEST: bool = false,
    COPY_SOURCE: bool = false,
    RESOLVE_DEST: bool = false,
    RESOLVE_SOURCE: bool = false,
    // TODO: Clean this up.
    // 'padding: u17 = 0,'
    // causes @sizeOf(RESOURCE_STATES) == 5 with current compiler version.
    RESERVED0: bool = false,
    RESERVED1: bool = false,
    RESERVED2: bool = false,
    RESERVED3: bool = false,
    RESERVED4: bool = false,
    RESERVED5: bool = false,
    RESERVED6: bool = false,
    RESERVED7: bool = false,
    RESERVED8: bool = false,
    RESERVED9: bool = false,
    RESERVED10: bool = false,
    RESERVED11: bool = false,
    RESERVED12: bool = false,
    RESERVED13: bool = false,
    RESERVED14: bool = false,
    RESERVED15: bool = false,
    RESERVED16: bool = false,
    RESERVED17: bool = false,

    pub fn genericRead() RESOURCE_STATES {
        return RESOURCE_STATES{
            .VERTEX_AND_CONSTANT_BUFFER = true,
            .INDEX_BUFFER = true,
            .NON_PIXEL_SHADER_RESOURCE = true,
            .PIXEL_SHADER_RESOURCE = true,
            .INDIRECT_ARGUMENT_AND_PREDICATION = true,
            .COPY_SOURCE = true,
        };
    }
};

pub const RESOURCE_BARRIER_TYPE = extern enum {
    TRANSITION = 0,
    ALIASING = 1,
    UAV = 2,
};

pub const RESOURCE_TRANSITION_BARRIER = extern struct {
    pResource: *IResource,
    Subresource: u32,
    StateBefore: RESOURCE_STATES,
    StateAfter: RESOURCE_STATES,
};

pub const RESOURCE_ALIASING_BARRIER = extern struct {
    pResourceBefore: *IResource,
    pResourceAfter: *IResource,
};

pub const RESOURCE_UAV_BARRIER = extern struct {
    pResource: *IResource,
};

pub const RESOURCE_BARRIER_FLAGS = extern enum {
    NONE = 0,
    BEGIN_ONLY = 0x1,
    END_ONLY = 0x2,
};

pub const RESOURCE_BARRIER = extern struct {
    Type: RESOURCE_BARRIER_TYPE,
    Flags: RESOURCE_BARRIER_FLAGS,
    u: extern union {
        Transition: RESOURCE_TRANSITION_BARRIER,
        Aliasing: RESOURCE_ALIASING_BARRIER,
        UAV: RESOURCE_UAV_BARRIER,
    },
};

pub const PLACED_SUBRESOURCE_FOOTPRINT = extern struct {
    Offset: u64,
    Footprint: SUBRESOURCE_FOOTPRINT,
};

pub const TEXTURE_COPY_TYPE = extern enum {
    SUBRESOURCE_INDEX = 0,
    PLACED_FOOTPRINT = 1,
};

pub const TEXTURE_COPY_LOCATION = extern struct {
    pResource: *IResource,
    Type: TEXTURE_COPY_TYPE,
    u: extern union {
        PlacedFootprint: PLACED_SUBRESOURCE_FOOTPRINT,
        SubresourceIndex: u32,
    },
};

pub const QUERY_HEAP_TYPE = extern enum {
    OCCLUSION = 0,
    TIMESTAMP = 1,
    PIPELINE_STATISTICS = 2,
    SO_STATISTICS = 3,
};

pub const QUERY_HEAP_DESC = extern struct {
    Type: QUERY_HEAP_TYPE,
    Count: u32,
    NodeMask: u32,
};

pub const QUERY_TYPE = extern enum {
    OCCLUSION = 0,
    BINARY_OCCLUSION = 1,
    TIMESTAMP = 2,
    PIPELINE_STATISTICS = 3,
    SO_STATISTICS_STREAM0 = 4,
    SO_STATISTICS_STREAM1 = 5,
    SO_STATISTICS_STREAM2 = 6,
    SO_STATISTICS_STREAM3 = 7,
};

pub const PREDICATION_OP = extern enum {
    EQUAL_ZERO = 0,
    NOT_EQUAL_ZERO = 1,
};

pub const INDIRECT_ARGUMENT_TYPE = extern enum {
    DRAW = 0,
    DRAW_INDEXED = 1,
    DISPATCH = 2,
    VERTEX_BUFFER_VIEW = 3,
    INDEX_BUFFER_VIEW = 4,
    CONSTANT = 5,
    CONSTANT_BUFFER_VIEW = 6,
    SHADER_RESOURCE_VIEW = 7,
    UNORDERED_ACCESS_VIEW = 8,
};

pub const INDIRECT_ARGUMENT_DESC = extern struct {
    Type: INDIRECT_ARGUMENT_TYPE,
    u: extern union {
        VertexBuffer: extern struct {
            Slot: u32,
        },
        Constant: extern struct {
            RootParameterIndex: u32,
            DestOffsetIn32BitValues: u32,
            Num32BitValuesToSet: u32,
        },
        ConstantBufferView: extern struct {
            RootParameterIndex: u32,
        },
        ShaderResourceView: extern struct {
            RootParameterIndex: u32,
        },
        UnorderedAccessView: extern struct {
            RootParameterIndex: u32,
        },
    },
};

pub const COMMAND_SIGNATURE_DESC = extern struct {
    ByteStride: u32,
    NumArgumentDescs: u32,
    pArgumentDescs: *const INDIRECT_ARGUMENT_DESC,
    NodeMask: u32,
};

pub const PACKED_MIP_INFO = extern struct {
    NumStandardMips: u8,
    NumPackedMips: u8,
    NumTilesForPackedMips: u32,
    StartTileIndexInOverallResource: u32,
};

pub const PRIMITIVE_TOPOLOGY_TYPE = extern enum {
    UNDEFINED = 0,
    POINT = 1,
    LINE = 2,
    TRIANGLE = 3,
    PATCH = 4,
};

pub const CULL_MODE = extern enum {
    NONE = 1,
    FRONT = 2,
    BACK = 3,
};

pub const FEATURE = extern enum {
    D3D12_OPTIONS = 0,
    ARCHITECTURE = 1,
    FEATURE_LEVELS = 2,
    FORMAT_SUPPORT = 3,
    MULTISAMPLE_QUALITY_LEVELS = 4,
    FORMAT_INFO = 5,
    GPU_VIRTUAL_ADDRESS_SUPPORT = 6,
    SHADER_MODEL = 7,
    D3D12_OPTIONS1 = 8,
    ROOT_SIGNATURE = 12,
};

pub const RESOURCE_ALLOCATION_INFO = extern struct {
    SizeInBytes: u64,
    Alignment: u64,
};

pub const GRAPHICS_PIPELINE_STATE_DESC = extern struct {
    pRootSignature: ?*IRootSignature = null,
    VS: SHADER_BYTECODE = .{},
    PS: SHADER_BYTECODE = .{},
    DS: SHADER_BYTECODE = .{},
    HS: SHADER_BYTECODE = .{},
    GS: SHADER_BYTECODE = .{},
    StreamOutput: STREAM_OUTPUT_DESC = .{},
    BlendState: BLEND_DESC = .{},
    SampleMask: u32 = 0xffff_ffff,
    RasterizerState: RASTERIZER_DESC = .{},
    DepthStencilState: DEPTH_STENCIL_DESC = .{},
    InputLayout: INPUT_LAYOUT_DESC = .{},
    IBStripCutValue: INDEX_BUFFER_STRIP_CUT_VALUE = .DISABLED,
    PrimitiveTopologyType: PRIMITIVE_TOPOLOGY_TYPE,
    NumRenderTargets: u32,
    RTVFormats: [8]dxgi.FORMAT,
    DSVFormat: dxgi.FORMAT = .UNKNOWN,
    SampleDesc: dxgi.SAMPLE_DESC = .{},
    NodeMask: u32 = 0,
    CachedPSO: CACHED_PIPELINE_STATE = .{},
    Flags: PIPELINE_STATE_FLAGS = .NONE,
};

pub const COMPUTE_PIPELINE_STATE_DESC = extern struct {
    pRootSignature: ?*IRootSignature = null,
    CS: SHADER_BYTECODE,
    NodeMask: u32 = 0,
    CachedPSO: CACHED_PIPELINE_STATE = .{},
    Flags: PIPELINE_STATE_FLAGS = .NONE,
};

pub const VIEWPORT = extern struct {
    TopLeftX: f32,
    TopLeftY: f32,
    Width: f32,
    Height: f32,
    MinDepth: f32,
    MaxDepth: f32,
};

const HRESULT = os.HRESULT;

pub const IBlob = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // ID3DBlob
        GetBufferPointer: fn (*Self) callconv(.C) *c_void,
        GetBufferSize: fn (*Self) callconv(.C) usize,
    },
    usingnamespace os.IUnknown.Methods(Self);
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

pub const IDebug1 = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // ID3D12Debug1
        EnableDebugLayer: fn (*Self) callconv(.C) void,
        SetEnableGPUBasedValidation: fn (*Self, os.BOOL) callconv(.C) void,
        SetEnableSynchronizedCommandQueueValidation: fn (*Self, os.BOOL) callconv(.C) void,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IDebug1.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn EnableDebugLayer(self: *T) void {
                self.vtbl.EnableDebugLayer(self);
            }
            pub inline fn SetEnableGPUBasedValidation(self: *T, enable: os.BOOL) void {
                self.vtbl.SetEnableGPUBasedValidation(self, enable);
            }
            pub inline fn SetEnableSynchronizedCommandQueueValidation(self: *T, enable: os.BOOL) void {
                self.vtbl.SetEnableSynchronizedCommandQueueValidation(self, enable);
            }
        };
    }
};

pub const IInfoQueue = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // ID3D12InfoQueue
        SetMessageCountLimit: *c_void,
        ClearStoredMessages: *c_void,
        GetMessage: *c_void,
        GetNumMessagesAllowedByStorageFilter: *c_void,
        GetNumMessagesDeniedByStorageFilter: *c_void,
        GetNumStoredMessages: *c_void,
        GetNumStoredMessagesAllowedByRetrievalFilter: *c_void,
        GetNumMessagesDiscardedByMessageCountLimit: *c_void,
        GetMessageCountLimit: *c_void,
        AddStorageFilterEntries: fn (*Self, *INFO_QUEUE_FILTER) callconv(.C) HRESULT,
        GetStorageFilter: *c_void,
        ClearStorageFilter: *c_void,
        PushEmptyStorageFilter: *c_void,
        PushCopyOfStorageFilter: *c_void,
        PushStorageFilter: *c_void,
        PopStorageFilter: *c_void,
        GetStorageFilterStackSize: *c_void,
        AddRetrievalFilterEntries: *c_void,
        GetRetrievalFilter: *c_void,
        ClearRetrievalFilter: *c_void,
        PushEmptyRetrievalFilter: *c_void,
        PushCopyOfRetrievalFilter: *c_void,
        PushRetrievalFilter: *c_void,
        PopRetrievalFilter: *c_void,
        GetRetrievalFilterStackSize: *c_void,
        AddMessage: *c_void,
        AddApplicationMessage: *c_void,
        SetBreakOnCategory: *c_void,
        SetBreakOnSeverity: *c_void,
        SetBreakOnID: *c_void,
        GetBreakOnCategory: *c_void,
        GetBreakOnSeverity: *c_void,
        GetBreakOnID: *c_void,
        SetMuteDebugOutput: *c_void,
        GetMuteDebugOutput: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IInfoQueue.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn AddStorageFilterEntries(self: *T, filter: *INFO_QUEUE_FILTER) HRESULT {
                return self.vtbl.AddStorageFilterEntries(self, filter);
            }
        };
    }
};

pub const IObject = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const os.GUID, *u32, ?*c_void) callconv(.C) HRESULT,
        SetPrivateData: fn (*Self, *const os.GUID, u32, ?*const c_void) callconv(.C) HRESULT,
        SetPrivateDataInterface: fn (
            *Self,
            *const os.GUID,
            ?*const os.IUnknown,
        ) callconv(.C) HRESULT,
        SetName: fn (*Self, ?os.LPCWSTR) callconv(.C) HRESULT,
    },
    usingnamespace os.IUnknown.Methods(Self);
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
                data: ?*const os.IUnknown,
            ) HRESULT {
                return self.vtbl.SetPrivateDataInterface(self, guid, data);
            }
            pub inline fn SetName(self: *T, name: ?os.LPCWSTR) HRESULT {
                return self.vtbl.SetName(self, name);
            }
        };
    }
};

pub const IDeviceChild = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const os.GUID, *u32, ?*c_void) callconv(.C) HRESULT,
        SetPrivateData: fn (*Self, *const os.GUID, u32, ?*const c_void) callconv(.C) HRESULT,
        SetPrivateDataInterface: fn (
            *Self,
            *const os.GUID,
            ?*const os.IUnknown,
        ) callconv(.C) HRESULT,
        SetName: fn (*Self, ?os.LPCWSTR) callconv(.C) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
    },
    usingnamespace os.IUnknown.Methods(Self);
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
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const os.GUID, *u32, ?*c_void) callconv(.C) HRESULT,
        SetPrivateData: fn (*Self, *const os.GUID, u32, ?*const c_void) callconv(.C) HRESULT,
        SetPrivateDataInterface: fn (
            *Self,
            *const os.GUID,
            ?*const os.IUnknown,
        ) callconv(.C) HRESULT,
        SetName: fn (*Self, ?os.LPCWSTR) callconv(.C) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IObject.Methods(Self);
    usingnamespace IDeviceChild.Methods(Self);
};

pub const IQueryHeap = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const os.GUID, *u32, ?*c_void) callconv(.C) HRESULT,
        SetPrivateData: fn (*Self, *const os.GUID, u32, ?*const c_void) callconv(.C) HRESULT,
        SetPrivateDataInterface: fn (
            *Self,
            *const os.GUID,
            ?*const os.IUnknown,
        ) callconv(.C) HRESULT,
        SetName: fn (*Self, ?os.LPCWSTR) callconv(.C) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IObject.Methods(Self);
    usingnamespace IDeviceChild.Methods(Self);
};

pub const ICommandSignature = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const os.GUID, *u32, ?*c_void) callconv(.C) HRESULT,
        SetPrivateData: fn (*Self, *const os.GUID, u32, ?*const c_void) callconv(.C) HRESULT,
        SetPrivateDataInterface: fn (
            *Self,
            *const os.GUID,
            ?*const os.IUnknown,
        ) callconv(.C) HRESULT,
        SetName: fn (*Self, ?os.LPCWSTR) callconv(.C) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IObject.Methods(Self);
    usingnamespace IDeviceChild.Methods(Self);
};

pub const IPageable = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const os.GUID, *u32, ?*c_void) callconv(.C) HRESULT,
        SetPrivateData: fn (*Self, *const os.GUID, u32, ?*const c_void) callconv(.C) HRESULT,
        SetPrivateDataInterface: fn (
            *Self,
            *const os.GUID,
            ?*const os.IUnknown,
        ) callconv(.C) HRESULT,
        SetName: fn (*Self, ?os.LPCWSTR) callconv(.C) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IObject.Methods(Self);
    usingnamespace IDeviceChild.Methods(Self);
};

pub const IHeap = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const os.GUID, *u32, ?*c_void) callconv(.C) HRESULT,
        SetPrivateData: fn (*Self, *const os.GUID, u32, ?*const c_void) callconv(.C) HRESULT,
        SetPrivateDataInterface: fn (
            *Self,
            *const os.GUID,
            ?*const os.IUnknown,
        ) callconv(.C) HRESULT,
        SetName: fn (*Self, ?os.LPCWSTR) callconv(.C) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        // ID3D12Heap
        GetDesc: fn (*Self, *HEAP_DESC) callconv(.C) *HEAP_DESC,
    },
    usingnamespace os.IUnknown.Methods(Self);
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
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const os.GUID, *u32, ?*c_void) callconv(.C) HRESULT,
        SetPrivateData: fn (*Self, *const os.GUID, u32, ?*const c_void) callconv(.C) HRESULT,
        SetPrivateDataInterface: fn (
            *Self,
            *const os.GUID,
            ?*const os.IUnknown,
        ) callconv(.C) HRESULT,
        SetName: fn (*Self, ?os.LPCWSTR) callconv(.C) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        // ID3D12Resource
        Map: fn (*Self, u32, *const RANGE, **c_void) callconv(.C) HRESULT,
        Unmap: fn (*Self, u32, *const RANGE) callconv(.C) void,
        GetDesc: fn (*Self, *RESOURCE_DESC) callconv(.C) *RESOURCE_DESC,
        GetGPUVirtualAddress: fn (*Self) callconv(.C) GPU_VIRTUAL_ADDRESS,
        WriteToSubresource: fn (
            *Self,
            u32,
            *const BOX,
            *const c_void,
            u32,
            u32,
        ) callconv(.C) HRESULT,
        ReadFromSubresource: fn (*Self, *c_void, u32, u32, u32, *const BOX) callconv(.C) HRESULT,
        GetHeapProperties: fn (*Self, *HEAP_PROPERTIES, *HEAP_FLAGS) callconv(.C) HRESULT,
    },
    usingnamespace os.IUnknown.Methods(Self);
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
            pub inline fn GetDesc(self: *Self) RESOURCE_DESC {
                var desc: RESOURCE_DESC = undefined;
                _ = self.vtbl.GetDesc(self, &desc);
                return desc;
            }
            pub inline fn GetGPUVirtualAddress(self: *Self) GPU_VIRTUAL_ADDRESS {
                return self.vtbl.GetGPUVirtualAddress(self);
            }
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
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const os.GUID, *u32, ?*c_void) callconv(.C) HRESULT,
        SetPrivateData: fn (*Self, *const os.GUID, u32, ?*const c_void) callconv(.C) HRESULT,
        SetPrivateDataInterface: fn (
            *Self,
            *const os.GUID,
            ?*const os.IUnknown,
        ) callconv(.C) HRESULT,
        SetName: fn (*Self, ?os.LPCWSTR) callconv(.C) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        // ID3D12CommandAllocator
        Reset: fn (*Self) callconv(.C) HRESULT,
    },
    usingnamespace os.IUnknown.Methods(Self);
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
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const os.GUID, *u32, ?*c_void) callconv(.C) HRESULT,
        SetPrivateData: fn (*Self, *const os.GUID, u32, ?*const c_void) callconv(.C) HRESULT,
        SetPrivateDataInterface: fn (
            *Self,
            *const os.GUID,
            ?*const os.IUnknown,
        ) callconv(.C) HRESULT,
        SetName: fn (*Self, ?os.LPCWSTR) callconv(.C) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        // ID3D12Fence
        GetCompletedValue: fn (*Self) callconv(.C) u64,
        SetEventOnCompletion: fn (*Self, u64, os.HANDLE) callconv(.C) HRESULT,
        Signal: fn (*Self, u64) callconv(.C) HRESULT,
    },
    usingnamespace os.IUnknown.Methods(Self);
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
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const os.GUID, *u32, ?*c_void) callconv(.C) HRESULT,
        SetPrivateData: fn (*Self, *const os.GUID, u32, ?*const c_void) callconv(.C) HRESULT,
        SetPrivateDataInterface: fn (
            *Self,
            *const os.GUID,
            ?*const os.IUnknown,
        ) callconv(.C) HRESULT,
        SetName: fn (*Self, ?os.LPCWSTR) callconv(.C) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        // ID3D12PipelineState
        GetCachedBlob: fn (*Self, *IBlob) callconv(.C) HRESULT,
    },
    usingnamespace os.IUnknown.Methods(Self);
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
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const os.GUID, *u32, ?*c_void) callconv(.C) HRESULT,
        SetPrivateData: fn (*Self, *const os.GUID, u32, ?*const c_void) callconv(.C) HRESULT,
        SetPrivateDataInterface: fn (
            *Self,
            *const os.GUID,
            ?*const os.IUnknown,
        ) callconv(.C) HRESULT,
        SetName: fn (*Self, ?os.LPCWSTR) callconv(.C) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        // ID3D12DescriptorHeap
        GetDesc: fn (*Self, *DESCRIPTOR_HEAP_DESC) callconv(.C) *DESCRIPTOR_HEAP_DESC,
        GetCPUDescriptorHandleForHeapStart: fn (
            *Self,
            *CPU_DESCRIPTOR_HANDLE,
        ) callconv(.C) *CPU_DESCRIPTOR_HANDLE,
        GetGPUDescriptorHandleForHeapStart: fn (
            *Self,
            *GPU_DESCRIPTOR_HANDLE,
        ) callconv(.C) *GPU_DESCRIPTOR_HANDLE,
    },
    usingnamespace os.IUnknown.Methods(Self);
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
                _ = self.vtbl.GetCPUDescriptorHandleForHeapStart(self, &handle);
                return handle;
            }
            pub inline fn GetGPUDescriptorHandleForHeapStart(self: *T) GPU_DESCRIPTOR_HANDLE {
                var handle: GPU_DESCRIPTOR_HANDLE = undefined;
                _ = self.vtbl.GetGPUDescriptorHandleForHeapStart(self, &handle);
                return handle;
            }
        };
    }
};

pub const ICommandList = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const os.GUID, *u32, ?*c_void) callconv(.C) HRESULT,
        SetPrivateData: fn (*Self, *const os.GUID, u32, ?*const c_void) callconv(.C) HRESULT,
        SetPrivateDataInterface: fn (
            *Self,
            *const os.GUID,
            ?*const os.IUnknown,
        ) callconv(.C) HRESULT,
        SetName: fn (*Self, ?os.LPCWSTR) callconv(.C) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        // ID3D12CommandList
        GetType: fn (*Self) callconv(.C) COMMAND_LIST_TYPE,
    },
    usingnamespace os.IUnknown.Methods(Self);
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
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const os.GUID, *u32, ?*c_void) callconv(.C) HRESULT,
        SetPrivateData: fn (*Self, *const os.GUID, u32, ?*const c_void) callconv(.C) HRESULT,
        SetPrivateDataInterface: fn (
            *Self,
            *const os.GUID,
            ?*const os.IUnknown,
        ) callconv(.C) HRESULT,
        SetName: fn (*Self, ?os.LPCWSTR) callconv(.C) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        // ID3D12CommandList
        GetType: fn (*Self) callconv(.C) COMMAND_LIST_TYPE,
        // ID3D12GraphicsCommandList
        Close: fn (*Self) callconv(.C) HRESULT,
        Reset: fn (*Self, *ICommandAllocator, ?*IPipelineState) callconv(.C) HRESULT,
        ClearState: fn (*Self, *IPipelineState) callconv(.C) void,
        DrawInstanced: fn (*Self, u32, u32, u32, u32) callconv(.C) void,
        DrawIndexedInstanced: fn (*Self, u32, u32, u32, i32, u32) callconv(.C) void,
        Dispatch: fn (*Self, u32, u32, u32) callconv(.C) void,
        CopyBufferRegion: fn (*Self, *IResource, u64, *IResource, u64, u64) callconv(.C) void,
        CopyTextureRegion: fn (
            *Self,
            *const TEXTURE_COPY_LOCATION,
            u32,
            u32,
            u32,
            *const TEXTURE_COPY_LOCATION,
            ?*const BOX,
        ) callconv(.C) void,
        CopyResource: fn (*Self, *IResource, *IResource) callconv(.C) void,
        CopyTiles: fn (
            *Self,
            *IResource,
            *const TILED_RESOURCE_COORDINATE,
            *const TILE_REGION_SIZE,
            *IResource,
            buffer_start_offset_in_bytes: u64,
            TILE_COPY_FLAGS,
        ) callconv(.C) void,
        ResolveSubresource: fn (
            *Self,
            *IResource,
            u32,
            *IResource,
            u32,
            dxgi.FORMAT,
        ) callconv(.C) void,
        IASetPrimitiveTopology: fn (*Self, PRIMITIVE_TOPOLOGY) callconv(.C) void,
        RSSetViewports: fn (*Self, u32, [*]const VIEWPORT) callconv(.C) void,
        RSSetScissorRects: fn (*Self, u32, [*]const RECT) callconv(.C) void,
        OMSetBlendFactor: fn (*Self, *const [4]f32) callconv(.C) void,
        OMSetStencilRef: fn (*Self, u32) callconv(.C) void,
        SetPipelineState: fn (*Self, *IPipelineState) callconv(.C) void,
        ResourceBarrier: fn (*Self, u32, [*]const RESOURCE_BARRIER) callconv(.C) void,
        ExecuteBundle: fn (*Self, *IGraphicsCommandList) callconv(.C) void,
        SetDescriptorHeaps: fn (*Self, u32, [*]const *IDescriptorHeap) callconv(.C) void,
        SetComputeRootSignature: fn (*Self, *IRootSignature) callconv(.C) void,
        SetGraphicsRootSignature: fn (*Self, *IRootSignature) callconv(.C) void,
        SetComputeRootDescriptorTable: fn (*Self, u32, GPU_DESCRIPTOR_HANDLE) callconv(.C) void,
        SetGraphicsRootDescriptorTable: fn (*Self, u32, GPU_DESCRIPTOR_HANDLE) callconv(.C) void,
        SetComputeRoot32BitConstant: fn (*Self, u32, u32, u32) callconv(.C) void,
        SetGraphicsRoot32BitConstant: fn (*Self, u32, u32, u32) callconv(.C) void,
        SetComputeRoot32BitConstants: fn (*Self, u32, u32, *const c_void, u32) callconv(.C) void,
        SetGraphicsRoot32BitConstants: fn (*Self, u32, u32, *const c_void, u32) callconv(.C) void,
        SetComputeRootConstantBufferView: fn (*Self, u32, GPU_VIRTUAL_ADDRESS) callconv(.C) void,
        SetGraphicsRootConstantBufferView: fn (*Self, u32, GPU_VIRTUAL_ADDRESS) callconv(.C) void,
        SetComputeRootShaderResourceView: fn (*Self, u32, GPU_VIRTUAL_ADDRESS) callconv(.C) void,
        SetGraphicsRootShaderResourceView: fn (*Self, u32, GPU_VIRTUAL_ADDRESS) callconv(.C) void,
        SetComputeRootUnorderedAccessView: fn (*Self, u32, GPU_VIRTUAL_ADDRESS) callconv(.C) void,
        SetGraphicsRootUnorderedAccessView: fn (*Self, u32, GPU_VIRTUAL_ADDRESS) callconv(.C) void,
        IASetIndexBuffer: fn (*Self, *const INDEX_BUFFER_VIEW) callconv(.C) void,
        IASetVertexBuffers: fn (*Self, u32, u32, [*]const VERTEX_BUFFER_VIEW) callconv(.C) void,
        SOSetTargets: fn (*Self, u32, u32, [*]const STREAM_OUTPUT_BUFFER_VIEW) callconv(.C) void,
        OMSetRenderTargets: fn (
            *Self,
            u32,
            ?[*]const CPU_DESCRIPTOR_HANDLE,
            os.BOOL,
            ?*const CPU_DESCRIPTOR_HANDLE,
        ) callconv(.C) void,
        ClearDepthStencilView: fn (
            *Self,
            CPU_DESCRIPTOR_HANDLE,
            CLEAR_FLAGS,
            f32,
            u8,
            u32,
            ?[*]const RECT,
        ) callconv(.C) void,
        ClearRenderTargetView: fn (
            *Self,
            CPU_DESCRIPTOR_HANDLE,
            *const [4]f32,
            u32,
            ?[*]const RECT,
        ) callconv(.C) void,
        ClearUnorderedAccessViewUint: fn (
            *Self,
            GPU_DESCRIPTOR_HANDLE,
            CPU_DESCRIPTOR_HANDLE,
            *IResource,
            *const [4]u32,
            u32,
            ?[*]const RECT,
        ) callconv(.C) void,
        ClearUnorderedAccessViewFloat: fn (
            *Self,
            GPU_DESCRIPTOR_HANDLE,
            CPU_DESCRIPTOR_HANDLE,
            *IResource,
            *const [4]f32,
            u32,
            ?[*]const RECT,
        ) callconv(.C) void,
        DiscardResource: fn (*Self, *IResource, *const DISCARD_REGION) callconv(.C) void,
        BeginQuery: fn (*Self, *IQueryHeap, QUERY_TYPE, u32) callconv(.C) void,
        EndQuery: fn (*Self, *IQueryHeap, QUERY_TYPE, u32) callconv(.C) void,
        ResolveQueryData: fn (
            *Self,
            *IQueryHeap,
            QUERY_TYPE,
            u32,
            u32,
            *IResource,
            u64,
        ) callconv(.C) void,
        SetPredication: fn (*Self, *IResource, u64, PREDICATION_OP) callconv(.C) void,
        SetMarker: fn (*Self, u32, *const c_void, u32) callconv(.C) void,
        BeginEvent: fn (*Self, u32, *const c_void, u32) callconv(.C) void,
        EndEvent: fn (*Self) callconv(.C) void,
        ExecuteIndirect: fn (
            *Self,
            *ICommandSignature,
            u32,
            *IResource,
            u64,
            *IResource,
            u64,
        ) callconv(.C) void,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IObject.Methods(Self);
    usingnamespace IDeviceChild.Methods(Self);
    usingnamespace ICommandList.Methods(Self);
    usingnamespace IGraphicsCommandList.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn Close(self: *T) HRESULT {
                return self.vtbl.Close(self);
            }
            pub inline fn Reset(
                self: *T,
                allocator: *ICommandAllocator,
                initial_state: ?*IPipelineState,
            ) HRESULT {
                return self.vtbl.Reset(self, allocator, initial_state);
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
                dst: *const TEXTURE_COPY_LOCATION,
                dst_x: u32,
                dst_y: u32,
                dst_z: u32,
                src: *const TEXTURE_COPY_LOCATION,
                src_box: ?*const BOX,
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
                tile_region_size: *const TILE_REGION_SIZE,
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
                src_resource: *IResource,
                src_subresource: u32,
                format: dxgi.FORMAT,
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
                barriers: [*]const RESOURCE_BARRIER,
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
                data: *const c_void,
                offset: u32,
            ) void {
                self.vtbl.SetComputeRoot32BitConstants(self, root_index, num, data, offset);
            }
            pub inline fn SetGraphicsRoot32BitConstants(
                self: *T,
                root_index: u32,
                num: u32,
                data: *const c_void,
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
                rt_descriptors: ?[*]const CPU_DESCRIPTOR_HANDLE,
                single_handle: os.BOOL,
                ds_descriptors: ?*const CPU_DESCRIPTOR_HANDLE,
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
                rects: ?[*]const RECT,
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
                rects: ?[*]const RECT,
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
                rects: ?[*]const RECT,
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
                rects: ?[*]const RECT,
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
            pub inline fn DiscardResource(
                self: *T,
                resource: *IResource,
                region: *const DISCARD_REGION,
            ) void {
                self.vtbl.DiscardResource(self, resource, region);
            }
            pub inline fn BeginQuery(
                self: *T,
                query: *IQueryHeap,
                query_type: QUERY_TYPE,
                index: u32,
            ) void {
                self.vtbl.BeginQuery(self, query, query_type, index);
            }
            pub inline fn EndQuery(
                self: *T,
                query: *IQueryHeap,
                query_type: QUERY_TYPE,
                index: u32,
            ) void {
                self.vtbl.EndQuery(self, query, query_type, index);
            }
            pub inline fn ResolveQueryData(
                self: *T,
                query: *IQueryHeap,
                query_type: QUERY_TYPE,
                start_index: u32,
                num_queries: u32,
                dst_resource: *IResource,
                buffer_offset: u64,
            ) void {
                self.vtbl.ResolveQueryData(
                    self,
                    query,
                    query_type,
                    start_index,
                    num_queries,
                    dst_resource,
                    buffer_offset,
                );
            }
            pub inline fn SetPredication(
                self: *T,
                buffer: *IResource,
                buffer_offset: u64,
                operation: PREDICATION_OP,
            ) void {
                self.vtbl.SetPredication(self, buffer, buffer_offset, operation);
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
            pub inline fn ExecuteIndirect(
                self: *T,
                command_signature: *ICommandSignature,
                max_command_count: u32,
                arg_buffer: *IResource,
                arg_buffer_offset: u64,
                count_buffer: *IResource,
                count_buffer_offset: u64,
            ) void {
                self.vtbl.ExecuteIndirect(
                    self,
                    command_signature,
                    max_command_count,
                    arg_buffer,
                    arg_buffer_offset,
                    count_buffer,
                    count_buffer_offset,
                );
            }
        };
    }
};

pub const ICommandQueue = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const os.GUID, *u32, ?*c_void) callconv(.C) HRESULT,
        SetPrivateData: fn (*Self, *const os.GUID, u32, ?*const c_void) callconv(.C) HRESULT,
        SetPrivateDataInterface: fn (
            *Self,
            *const os.GUID,
            ?*const os.IUnknown,
        ) callconv(.C) HRESULT,
        SetName: fn (*Self, ?os.LPCWSTR) callconv(.C) HRESULT,
        // ID3D12DeviceChild
        GetDevice: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
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
        ) callconv(.C) void,
        CopyTileMappings: fn (
            *Self,
            *IResource,
            *const TILED_RESOURCE_COORDINATE,
            *IResource,
            *const TILED_RESOURCE_COORDINATE,
            *const TILE_REGION_SIZE,
            TILE_MAPPING_FLAGS,
        ) callconv(.C) void,
        ExecuteCommandLists: fn (*Self, u32, [*]const *ICommandList) callconv(.C) void,
        SetMarker: fn (*Self, u32, *const c_void, u32) callconv(.C) void,
        BeginEvent: fn (*Self, u32, *const c_void, u32) callconv(.C) void,
        EndEvent: fn (*Self) callconv(.C) void,
        Signal: fn (*Self, *IFence, u64) callconv(.C) HRESULT,
        Wait: fn (*Self, *IFence, u64) callconv(.C) HRESULT,
        GetTimestampFrequency: fn (*Self, *u64) callconv(.C) HRESULT,
        GetClockCalibration: fn (*Self, *u64, *u64) callconv(.C) HRESULT,
        GetDesc: fn (*Self, *COMMAND_QUEUE_DESC) callconv(.C) *COMMAND_QUEUE_DESC,
    },
    usingnamespace os.IUnknown.Methods(Self);
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

pub const IDevice = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // ID3D12Object
        GetPrivateData: fn (*Self, *const os.GUID, *u32, ?*c_void) callconv(.C) HRESULT,
        SetPrivateData: fn (*Self, *const os.GUID, u32, ?*const c_void) callconv(.C) HRESULT,
        SetPrivateDataInterface: fn (
            *Self,
            *const os.GUID,
            ?*const os.IUnknown,
        ) callconv(.C) HRESULT,
        SetName: fn (*Self, ?os.LPCWSTR) callconv(.C) HRESULT,
        // ID3D12Device
        GetNodeCount: fn (*Self) callconv(.C) u32,
        CreateCommandQueue: fn (
            *Self,
            *const COMMAND_QUEUE_DESC,
            *const os.GUID,
            **c_void,
        ) callconv(.C) HRESULT,
        CreateCommandAllocator: fn (
            *Self,
            COMMAND_LIST_TYPE,
            *const os.GUID,
            **c_void,
        ) callconv(.C) HRESULT,
        CreateGraphicsPipelineState: fn (
            *Self,
            *const GRAPHICS_PIPELINE_STATE_DESC,
            *const os.GUID,
            **c_void,
        ) callconv(.C) HRESULT,
        CreateComputePipelineState: fn (
            *Self,
            *const COMPUTE_PIPELINE_STATE_DESC,
            *const os.GUID,
            **c_void,
        ) callconv(.C) HRESULT,
        CreateCommandList: fn (
            *Self,
            u32,
            COMMAND_LIST_TYPE,
            *ICommandAllocator,
            ?*IPipelineState,
            *const os.GUID,
            **c_void,
        ) callconv(.C) HRESULT,
        CheckFeatureSupport: fn (*Self, FEATURE, *c_void, u32) callconv(.C) HRESULT,
        CreateDescriptorHeap: fn (
            *Self,
            *const DESCRIPTOR_HEAP_DESC,
            *const os.GUID,
            **c_void,
        ) callconv(.C) HRESULT,
        GetDescriptorHandleIncrementSize: fn (*Self, DESCRIPTOR_HEAP_TYPE) callconv(.C) u32,
        CreateRootSignature: fn (
            *Self,
            u32,
            *const c_void,
            u64,
            *const os.GUID,
            **c_void,
        ) callconv(.C) HRESULT,
        CreateConstantBufferView: fn (
            *Self,
            *const CONSTANT_BUFFER_VIEW_DESC,
            CPU_DESCRIPTOR_HANDLE,
        ) callconv(.C) void,
        CreateShaderResourceView: fn (
            *Self,
            ?*IResource,
            ?*const SHADER_RESOURCE_VIEW_DESC,
            CPU_DESCRIPTOR_HANDLE,
        ) callconv(.C) void,
        CreateUnorderedAccessView: fn (
            *Self,
            ?*IResource,
            ?*IResource,
            ?*const UNORDERED_ACCESS_VIEW_DESC,
            CPU_DESCRIPTOR_HANDLE,
        ) callconv(.C) void,
        CreateRenderTargetView: fn (
            *Self,
            ?*IResource,
            ?*const RENDER_TARGET_VIEW_DESC,
            CPU_DESCRIPTOR_HANDLE,
        ) callconv(.C) void,
        CreateDepthStencilView: fn (
            *Self,
            ?*IResource,
            ?*const DEPTH_STENCIL_VIEW_DESC,
            CPU_DESCRIPTOR_HANDLE,
        ) callconv(.C) void,
        CreateSampler: fn (*Self, *const SAMPLER_DESC, CPU_DESCRIPTOR_HANDLE) callconv(.C) void,
        CopyDescriptors: fn (
            *Self,
            u32,
            [*]const CPU_DESCRIPTOR_HANDLE,
            [*]const u32,
            u32,
            [*]const CPU_DESCRIPTOR_HANDLE,
            [*]const u32,
            DESCRIPTOR_HEAP_TYPE,
        ) callconv(.C) void,
        CopyDescriptorsSimple: fn (
            *Self,
            u32,
            CPU_DESCRIPTOR_HANDLE,
            CPU_DESCRIPTOR_HANDLE,
            DESCRIPTOR_HEAP_TYPE,
        ) callconv(.C) void,
        GetResourceAllocationInfo: fn (
            *Self,
            u32,
            u32,
            [*]const RESOURCE_DESC,
            *RESOURCE_ALLOCATION_INFO,
        ) callconv(.C) *RESOURCE_ALLOCATION_INFO,
        GetCustomHeapProperties: fn (
            *Self,
            u32,
            HEAP_TYPE,
            *HEAP_PROPERTIES,
        ) callconv(.C) *HEAP_PROPERTIES,
        CreateCommittedResource: fn (
            *Self,
            *const HEAP_PROPERTIES,
            HEAP_FLAGS,
            *const RESOURCE_DESC,
            RESOURCE_STATES,
            ?*const CLEAR_VALUE,
            *const os.GUID,
            **c_void,
        ) callconv(.C) HRESULT,
        CreateHeap: fn (*Self, *const HEAP_DESC, *const os.GUID, **c_void) callconv(.C) HRESULT,
        CreatePlacedResource: fn (
            *Self,
            *IHeap,
            u64,
            *const RESOURCE_DESC,
            RESOURCE_STATES,
            *const CLEAR_VALUE,
            *const os.GUID,
            **c_void,
        ) callconv(.C) HRESULT,
        CreateReservedResource: fn (
            *Self,
            *const RESOURCE_DESC,
            RESOURCE_STATES,
            *const CLEAR_VALUE,
            *const os.GUID,
            **c_void,
        ) callconv(.C) HRESULT,
        CreateSharedHandle: fn (
            *Self,
            *IDeviceChild,
            ?*const os.SECURITY_ATTRIBUTES,
            os.DWORD,
            ?os.LPCWSTR,
            *os.HANDLE,
        ) callconv(.C) HRESULT,
        OpenSharedHandle: fn (*Self, os.HANDLE, *const os.GUID, **c_void) callconv(.C) HRESULT,
        OpenSharedHandleByName: fn (*Self, os.LPCWSTR, os.DWORD, *os.HANDLE) callconv(.C) HRESULT,
        MakeResident: fn (*Self, u32, [*]const *IPageable) callconv(.C) HRESULT,
        Evict: fn (*Self, u32, [*]const *IPageable) callconv(.C) HRESULT,
        CreateFence: fn (*Self, u64, FENCE_FLAGS, *const os.GUID, **c_void) callconv(.C) HRESULT,
        GetDeviceRemovedReason: fn (*Self) callconv(.C) HRESULT,
        GetCopyableFootprints: fn (
            *Self,
            *const RESOURCE_DESC,
            u32,
            u32,
            u64,
            ?*PLACED_SUBRESOURCE_FOOTPRINT,
            ?*u32,
            ?*u64,
            ?*u64,
        ) callconv(.C) void,
        CreateQueryHeap: fn (
            *Self,
            *const QUERY_HEAP_DESC,
            *const os.GUID,
            **c_void,
        ) callconv(.C) HRESULT,
        SetStablePowerState: fn (*Self, os.BOOL) callconv(.C) HRESULT,
        CreateCommandSignature: fn (
            *Self,
            *const COMMAND_SIGNATURE_DESC,
            *IRootSignature,
            *const os.GUID,
            **c_void,
        ) callconv(.C) HRESULT,
        GetResourceTiling: fn (
            *Self,
            *IResource,
            *u32,
            *PACKED_MIP_INFO,
            *TILE_SHAPE,
            *u32,
            u32,
            *SUBRESOURCE_TILING,
        ) callconv(.C) void,
        GetAdapterLuid: fn (*Self) callconv(.C) i64,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IObject.Methods(Self);
    usingnamespace IDevice.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetNodeCount(self: *T) u32 {
                return self.vtbl.GetNodeCount(self);
            }
            pub inline fn CreateCommandQueue(
                self: *T,
                desc: *const COMMAND_QUEUE_DESC,
                guid: *const os.GUID,
                obj: **c_void,
            ) HRESULT {
                return self.vtbl.CreateCommandQueue(self, desc, guid, obj);
            }
            pub inline fn CreateCommandAllocator(
                self: *T,
                cmdlist_type: COMMAND_LIST_TYPE,
                guid: *const os.GUID,
                obj: **c_void,
            ) HRESULT {
                return self.vtbl.CreateCommandAllocator(self, cmdlist_type, guid, obj);
            }
            pub inline fn CreateGraphicsPipelineState(
                self: *T,
                desc: *const GRAPHICS_PIPELINE_STATE_DESC,
                guid: *const os.GUID,
                pso: **c_void,
            ) HRESULT {
                return self.vtbl.CreateGraphicsPipelineState(self, desc, guid, pso);
            }
            pub inline fn CreateComputePipelineState(
                self: *T,
                desc: *const COMPUTE_PIPELINE_STATE_DESC,
                guid: *const os.GUID,
                pso: **c_void,
            ) HRESULT {
                return self.vtbl.CreateComputePipelineState(self, desc, guid, pso);
            }
            pub inline fn CreateCommandList(
                self: *T,
                node_mask: u32,
                cmdlist_type: COMMAND_LIST_TYPE,
                cmdalloc: *ICommandAllocator,
                initial_state: ?*IPipelineState,
                guid: *const os.GUID,
                cmdlist: **c_void,
            ) HRESULT {
                return self.vtbl.CreateCommandList(
                    self,
                    node_mask,
                    cmdlist_type,
                    cmdalloc,
                    initial_state,
                    guid,
                    cmdlist,
                );
            }
            pub inline fn CheckFeatureSupport(
                self: *T,
                feature: FEATURE,
                data: *c_void,
                data_size: u32,
            ) HRESULT {
                return self.vtbl.CheckFeatureSupport(self, feature, data, data_size);
            }
            pub inline fn CreateDescriptorHeap(
                self: *T,
                desc: *const DESCRIPTOR_HEAP_DESC,
                guid: *const os.GUID,
                heap: **c_void,
            ) HRESULT {
                return self.vtbl.CreateDescriptorHeap(self, desc, guid, heap);
            }
            pub inline fn GetDescriptorHandleIncrementSize(
                self: *T,
                heap_type: DESCRIPTOR_HEAP_TYPE,
            ) u32 {
                return self.vtbl.GetDescriptorHandleIncrementSize(self, heap_type);
            }
            pub inline fn CreateRootSignature(
                self: *T,
                node_mask: u32,
                blob: *const c_void,
                blob_size: u64,
                guid: *const os.GUID,
                signature: **c_void,
            ) HRESULT {
                return self.vtbl.CreateRootSignature(self, node_mask, blob, blob_size, guid, signature);
            }
            pub inline fn CreateConstantBufferView(
                self: *T,
                desc: *const CONSTANT_BUFFER_VIEW_DESC,
                dst_descriptor: CPU_DESCRIPTOR_HANDLE,
            ) void {
                self.vtbl.CreateConstantBufferView(self, desc, dst_descriptor);
            }
            pub inline fn CreateShaderResourceView(
                self: *T,
                resource: ?*IResource,
                desc: ?*const SHADER_RESOURCE_VIEW_DESC,
                dst_descriptor: CPU_DESCRIPTOR_HANDLE,
            ) void {
                self.vtbl.CreateShaderResourceView(self, resource, desc, dst_descriptor);
            }
            pub inline fn CreateUnorderedAccessView(
                self: *T,
                resource: ?*IResource,
                counter_resource: ?*IResource,
                desc: ?*const UNORDERED_ACCESS_VIEW_DESC,
                dst_descriptor: CPU_DESCRIPTOR_HANDLE,
            ) void {
                self.vtbl.CreateUnorderedAccessView(
                    self,
                    resource,
                    counter_resource,
                    desc,
                    dst_descriptor,
                );
            }
            pub inline fn CreateRenderTargetView(
                self: *T,
                resource: ?*IResource,
                desc: ?*const RENDER_TARGET_VIEW_DESC,
                dst_descriptor: CPU_DESCRIPTOR_HANDLE,
            ) void {
                self.vtbl.CreateRenderTargetView(self, resource, desc, dst_descriptor);
            }
            pub inline fn CreateDepthStencilView(
                self: *T,
                resource: ?*IResource,
                desc: ?*const DEPTH_STENCIL_VIEW_DESC,
                dst_descriptor: CPU_DESCRIPTOR_HANDLE,
            ) void {
                self.vtbl.CreateDepthStencilView(self, resource, desc, dst_descriptor);
            }
            pub inline fn CreateSampler(
                self: *T,
                desc: *const SAMPLER_DESC,
                dst_descriptor: CPU_DESCRIPTOR_HANDLE,
            ) void {
                self.vtbl.CreateSampler(self, desc, dst_descriptor);
            }
            pub inline fn CopyDescriptors(
                self: *T,
                num_dst_ranges: u32,
                dst_range_starts: [*]const CPU_DESCRIPTOR_HANDLE,
                dst_range_sizes: [*]const u32,
                num_src_ranges: u32,
                src_range_starts: [*]const CPU_DESCRIPTOR_HANDLE,
                src_range_sizes: [*]const u32,
                heap_type: DESCRIPTOR_HEAP_TYPE,
            ) void {
                self.vtbl.CopyDescriptors(
                    self,
                    num_dst_ranges,
                    dst_range_starts,
                    dst_range_sizes,
                    num_src_ranges,
                    src_range_starts,
                    src_range_sizes,
                    heap_type,
                );
            }
            pub inline fn CopyDescriptorsSimple(
                self: *T,
                num: u32,
                dst_range_start: CPU_DESCRIPTOR_HANDLE,
                src_range_start: CPU_DESCRIPTOR_HANDLE,
                heap_type: DESCRIPTOR_HEAP_TYPE,
            ) void {
                self.vtbl.CopyDescriptorsSimple(self, num, dst_range_start, src_range_start, heap_type);
            }
            pub inline fn GetResourceAllocationInfo(
                self: *T,
                visible_mask: u32,
                num_descs: u32,
                descs: [*]const RESOURCE_DESC,
            ) RESOURCE_ALLOCATION_INFO {
                var info: RESOURCE_ALLOCATION_INFO = undefined;
                self.vtbl.GetResourceAllocationInfo(self, visible_mask, num_descs, descs, &info);
                return info;
            }
            pub inline fn GetCustomHeapProperties(
                self: *T,
                node_mask: u32,
                heap_type: HEAP_TYPE,
            ) HEAP_PROPERTIES {
                var props: HEAP_PROPERTIES = undefined;
                self.vtbl.GetCustomHeapProperties(self, node_mask, heap_type, &props);
                return props;
            }
            pub inline fn CreateCommittedResource(
                self: *T,
                heap_props: *const HEAP_PROPERTIES,
                heap_flags: HEAP_FLAGS,
                desc: *const RESOURCE_DESC,
                state: RESOURCE_STATES,
                clear_value: ?*const CLEAR_VALUE,
                guid: *const os.GUID,
                resource: **c_void,
            ) HRESULT {
                return self.vtbl.CreateCommittedResource(
                    self,
                    heap_props,
                    heap_flags,
                    desc,
                    state,
                    clear_value,
                    guid,
                    resource,
                );
            }
            pub inline fn CreateHeap(
                self: *T,
                desc: *const HEAP_DESC,
                guid: *const os.GUID,
                heap: **c_void,
            ) HRESULT {
                return self.vtbl.CreateHeap(self, desc, guid, heap);
            }
            pub inline fn CreatePlacedResource(
                self: *T,
                heap: *IHeap,
                heap_offset: u64,
                desc: *const RESOURCE_DESC,
                state: RESOURCE_STATES,
                clear_value: *const CLEAR_VALUE,
                guid: *const os.GUID,
                resource: **c_void,
            ) HRESULT {
                return self.vtbl.CreatePlacedResource(
                    self,
                    heap,
                    heap_offset,
                    desc,
                    state,
                    clear_value,
                    guid,
                    resource,
                );
            }
            pub inline fn CreateReservedResource(
                self: *T,
                desc: *const RESOURCE_DESC,
                state: RESOURCE_STATES,
                clear_value: *const CLEAR_VALUE,
                guid: *const os.GUID,
                resource: **c_void,
            ) HRESULT {
                return self.vtbl.CreateReservedResource(self, desc, state, clear_value, guid, resource);
            }
            pub inline fn CreateSharedHandle(
                self: *T,
                object: *IDeviceChild,
                attributes: ?*const os.SECURITY_ATTRIBUTES,
                access: os.DWORD,
                name: ?os.LPCWSTR,
                handle: *os.HANDLE,
            ) HRESULT {
                return self.vtbl.CreateSharedHandle(self, object, attributes, access, name, handle);
            }
            pub inline fn OpenSharedHandle(
                self: *T,
                handle: os.HANDLE,
                guid: *const os.GUID,
                object: **c_void,
            ) HRESULT {
                return self.vtbl.OpenSharedHandle(self, handle, guid, object);
            }
            pub inline fn OpenSharedHandleByName(
                self: *T,
                name: os.LPCWSTR,
                access: os.DWORD,
                handle: *os.HANDLE,
            ) HRESULT {
                return self.vtbl.OpenSharedHandleByName(self, name, access, handle);
            }
            pub inline fn MakeResident(self: *T, num: u32, objects: [*]const *IPageable) HRESULT {
                return self.vtbl.MakeResident(self, num, objects);
            }
            pub inline fn Evict(self: *T, num: u32, objects: [*]const *IPageable) HRESULT {
                return self.vtbl.Evict(self, num, objects);
            }
            pub inline fn CreateFence(
                self: *T,
                initial_value: u64,
                flags: FENCE_FLAGS,
                guid: *const os.GUID,
                fence: **c_void,
            ) HRESULT {
                return self.vtbl.CreateFence(self, initial_value, flags, guid, fence);
            }
            pub inline fn GetDeviceRemovedReason(self: *T) HRESULT {
                return self.vtbl.GetDeviceRemovedReason(self);
            }
            pub inline fn GetCopyableFootprints(
                self: *T,
                desc: *const RESOURCE_DESC,
                first_subresource: u32,
                num_subresources: u32,
                base_offset: u64,
                layouts: ?*PLACED_SUBRESOURCE_FOOTPRINT,
                num_rows: ?*u32,
                row_size: ?*u64,
                total_sizie: ?*u64,
            ) void {
                self.vtbl.GetCopyableFootprints(
                    self,
                    desc,
                    first_subresource,
                    num_subresources,
                    base_offset,
                    layouts,
                    num_rows,
                    row_size,
                    total_sizie,
                );
            }
            pub inline fn CreateQueryHeap(
                self: *T,
                desc: *const QUERY_HEAP_DESC,
                guid: *const os.GUID,
                query_heap: **c_void,
            ) HRESULT {
                return self.vtbl.CreateQueryHeap(self, desc, guid, query_heap);
            }
            pub inline fn SetStablePowerState(self: *T, enable: os.BOOL) HRESULT {
                return self.vtbl.SetStablePowerState(self, enable);
            }
            pub inline fn CreateCommandSignature(
                self: *T,
                desc: *const COMMAND_SIGNATURE_DESC,
                root_signature: *IRootSignature,
                guid: *const os.GUID,
                cmd_signature: **c_void,
            ) HRESULT {
                return self.vtbl.CreateCommandSignature(self, desc, root_signature, guid, cmd_signature);
            }
            pub inline fn GetResourceTiling(
                self: *T,
                resource: *IResource,
                num_resource_tiles: *u32,
                packed_mip_desc: *PACKED_MIP_INFO,
                std_tile_shape_non_packed_mips: *TILE_SHAPE,
                num_subresource_tilings: *u32,
                first_subresource: u32,
                subresource_tiling_for_non_packed_mips: *SUBRESOURCE_TILING,
            ) void {
                self.vtbl.GetResourceTiling(
                    self,
                    resource,
                    num_resource_tiles,
                    packed_mip_desc,
                    std_tile_shape_non_packed_mips,
                    num_subresource_tilings,
                    first_subresource,
                    subresource_tiling_for_non_packed_mips,
                );
            }
            pub inline fn GetAdapterLuid(self: *T) i64 {
                return self.vtbl.GetAdapterLuid(self);
            }
        };
    }
};

pub const IID_IDebug1 = os.GUID{
    .Data1 = 0xaffaa4ca,
    .Data2 = 0x63fe,
    .Data3 = 0x4d8e,
    .Data4 = .{ 0xb8, 0xad, 0x15, 0x90, 0x00, 0xaf, 0x43, 0x04 },
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
pub const IID_IInfoQueue = os.GUID{
    .Data1 = 0x0742a90b,
    .Data2 = 0xc387,
    .Data3 = 0x483f,
    .Data4 = .{ 0xb9, 0x46, 0x30, 0xa7, 0xe4, 0xe6, 0x14, 0x58 },
};

pub var GetDebugInterface: fn (*const os.GUID, **c_void) callconv(.C) HRESULT = undefined;
pub var CreateDevice: fn (
    ?*os.IUnknown,
    dcommon.FEATURE_LEVEL,
    *const os.GUID,
    **c_void,
) callconv(.C) HRESULT = undefined;

pub fn init() void {
    // TODO: Handle error.
    var d3d12_dll = os.LoadLibraryA("d3d12.dll").?;
    GetDebugInterface = @ptrCast(
        @TypeOf(GetDebugInterface),
        os.kernel32.GetProcAddress(d3d12_dll, "D3D12GetDebugInterface").?,
    );
    CreateDevice = @ptrCast(
        @TypeOf(CreateDevice),
        os.kernel32.GetProcAddress(d3d12_dll, "D3D12CreateDevice").?,
    );
}
