const builtin = @import("builtin");
const std = @import("std");
const os = @import("windows.zig");
const dxgi = @import("dxgi.zig");
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

pub const DEVICE_CONTEXT_OPTIONS = packed struct {
    ENABLE_MULTITHREADED_OPTIMIZATIONS: bool = false,
};

pub const RECT_F = extern struct {
    left: f32,
    top: f32,
    right: f32,
    bottom: f32,
};

pub const COLOR_F = extern struct {
    r: f32,
    g: f32,
    b: f32,
    a: f32,
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

pub const BITMAP_OPTIONS = packed struct {
    TARGET: bool = false,
    CANNOT_DRAW: bool = false,
    CPU_READ: bool = false,
    GDI_COMPATIBLE: bool = false,

    padding: u28 = 0,
};

pub const ALPHA_MODE = extern enum {
    UNKNOWN = 0,
    PREMULTIPLIED = 1,
    STRAIGHT = 2,
    IGNORE = 3,
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

pub const BRUSH_PROPERTIES = extern struct {
    opacity: f32,
    transform: MATRIX_3X2_F,
};

pub const PIXEL_FORMAT = extern struct {
    format: dxgi.FORMAT,
    alphaMode: ALPHA_MODE,
};

pub const BITMAP_PROPERTIES1 = extern struct {
    pixelFormat: PIXEL_FORMAT,
    dpiX: f32,
    dpiY: f32,
    bitmapOptions: BITMAP_OPTIONS,
    colorContext: ?*IColorContext = null,
};

pub const IResource = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const IImage = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const IColorContext = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const IBitmap1 = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: *c_void,
        // ID2D1Bitmap
        GetSize: *c_void,
        GetPixelSize: *c_void,
        GetPixelFormat: *c_void,
        GetPixelDpi: *c_void,
        CopyFromBitmap: *c_void,
        CopyFromRenderTarget: *c_void,
        CopyFromMemory: *c_void,
        // ID2D1Bitmap1
        GetColorContext: *c_void,
        GetOptions: *c_void,
        GetSurface: *c_void,
        Map: *c_void,
        Unmap: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const IGradientStopCollection = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: *c_void,
        // ID2D1GradientStopCollection
        GetGradientStopCount: *c_void,
        GetGradientStops: *c_void,
        GetColorInterpolationGamma: *c_void,
        GetExtendMode: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const IBrush = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: *c_void,
        // ID2D1Brush
        SetOpacity: *c_void,
        SetTransform: *c_void,
        GetOpacity: *c_void,
        GetTransform: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const IBitmapBrush = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: fn (*Self, **IFactory) callconv(.Stdcall) void,
        GetFactory: *c_void,
        // ID2D1Brush
        SetOpacity: *c_void,
        SetTransform: *c_void,
        GetOpacity: *c_void,
        GetTransform: *c_void,
        // ID2D1BitmapBrush
        SetExtendModeX: *c_void,
        SetExtendModeY: *c_void,
        SetInterpolationMode: *c_void,
        SetBitmap: *c_void,
        GetExtendModeX: *c_void,
        GetExtendModeY: *c_void,
        GetInterpolationMode: *c_void,
        GetBitmap: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const ISolidColorBrush = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: *c_void,
        // ID2D1Brush
        SetOpacity: *c_void,
        SetTransform: *c_void,
        GetOpacity: *c_void,
        GetTransform: *c_void,
        // ID2D1SolidColorBrush
        SetColor: *c_void,
        GetColor: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const ILinearGradientBrush = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: *c_void,
        // ID2D1Brush
        SetOpacity: *c_void,
        SetTransform: *c_void,
        GetOpacity: *c_void,
        GetTransform: *c_void,
        // ID2D1LinearGradientBrush
        SetStartPoint: *c_void,
        SetEndPoint: *c_void,
        GetStartPoint: *c_void,
        GetEndPoint: *c_void,
        GetGradientStopCollection: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const IRadialGradientBrush = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: *c_void,
        // ID2D1Brush
        SetOpacity: *c_void,
        SetTransform: *c_void,
        GetOpacity: *c_void,
        GetTransform: *c_void,
        // ID2D1RadialGradientBrush
        SetCenter: *c_void,
        SetGradientOriginOffset: *c_void,
        SetRadiusX: *c_void,
        SetRadiusY: *c_void,
        GetCenter: *c_void,
        GetGradientOriginOffset: *c_void,
        GetRadiusX: *c_void,
        GetRadiusY: *c_void,
        GetGradientStopCollection: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const IStrokeStyle = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: *c_void,
        // ID2D1StrokeStyle
        GetStartCap: *c_void,
        GetEndCap: *c_void,
        GetDashCap: *c_void,
        GetMiterLimit: *c_void,
        GetLineJoin: *c_void,
        GetDashOffset: *c_void,
        GetDashStyle: *c_void,
        GetDashesCount: *c_void,
        GetDashes: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const IGeometry = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: *c_void,
        // ID2D1Geometry
        GetBounds: *c_void,
        GetWidenedBounds: *c_void,
        StrokeContainsPoint: *c_void,
        FillContainsPoint: *c_void,
        CompareWithGeometry: *c_void,
        Simplify: *c_void,
        Tessellate: *c_void,
        CombineWithGeometry: *c_void,
        Outline: *c_void,
        ComputeArea: *c_void,
        ComputeLength: *c_void,
        ComputePointAtLength: *c_void,
        Widen: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const IRectangleGeometry = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: *c_void,
        // ID2D1Geometry
        GetBounds: *c_void,
        GetWidenedBounds: *c_void,
        StrokeContainsPoint: *c_void,
        FillContainsPoint: *c_void,
        CompareWithGeometry: *c_void,
        Simplify: *c_void,
        Tessellate: *c_void,
        CombineWithGeometry: *c_void,
        Outline: *c_void,
        ComputeArea: *c_void,
        ComputeLength: *c_void,
        ComputePointAtLength: *c_void,
        Widen: *c_void,
        // ID2D1RectangleGeometry
        GetRect: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const IRoundedRectangleGeometry = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: *c_void,
        // ID2D1Geometry
        GetBounds: *c_void,
        GetWidenedBounds: *c_void,
        StrokeContainsPoint: *c_void,
        FillContainsPoint: *c_void,
        CompareWithGeometry: *c_void,
        Simplify: *c_void,
        Tessellate: *c_void,
        CombineWithGeometry: *c_void,
        Outline: *c_void,
        ComputeArea: *c_void,
        ComputeLength: *c_void,
        ComputePointAtLength: *c_void,
        Widen: *c_void,
        // ID2D1RoundedRectangleGeometry
        GetRoundRect: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const IEllipseGeometry = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: *c_void,
        // ID2D1Geometry
        GetBounds: *c_void,
        GetWidenedBounds: *c_void,
        StrokeContainsPoint: *c_void,
        FillContainsPoint: *c_void,
        CompareWithGeometry: *c_void,
        Simplify: *c_void,
        Tessellate: *c_void,
        CombineWithGeometry: *c_void,
        Outline: *c_void,
        ComputeArea: *c_void,
        ComputeLength: *c_void,
        ComputePointAtLength: *c_void,
        Widen: *c_void,
        // ID2D1EllipseGeometry
        GetEllipse: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const IGeometryGroup = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: *c_void,
        // ID2D1Geometry
        GetBounds: *c_void,
        GetWidenedBounds: *c_void,
        StrokeContainsPoint: *c_void,
        FillContainsPoint: *c_void,
        CompareWithGeometry: *c_void,
        Simplify: *c_void,
        Tessellate: *c_void,
        CombineWithGeometry: *c_void,
        Outline: *c_void,
        ComputeArea: *c_void,
        ComputeLength: *c_void,
        ComputePointAtLength: *c_void,
        Widen: *c_void,
        // ID2D1GeometryGroup
        GetFillMode: *c_void,
        GetSourceGeometryCount: *c_void,
        GetSourceGeometries: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const ITransformedGeometry = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: *c_void,
        // ID2D1Geometry
        GetBounds: *c_void,
        GetWidenedBounds: *c_void,
        StrokeContainsPoint: *c_void,
        FillContainsPoint: *c_void,
        CompareWithGeometry: *c_void,
        Simplify: *c_void,
        Tessellate: *c_void,
        CombineWithGeometry: *c_void,
        Outline: *c_void,
        ComputeArea: *c_void,
        ComputeLength: *c_void,
        ComputePointAtLength: *c_void,
        Widen: *c_void,
        // ID2D1TransformedGeometry
        GetSourceGeometry: *c_void,
        GetTransform: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const ISimplifiedGeometrySink = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1SimplifiedGeometrySink
        SetFillMode: *c_void,
        SetSegmentFlags: *c_void,
        BeginFigure: *c_void,
        AddLines: *c_void,
        AddBeziers: *c_void,
        EndFigure: *c_void,
        Close: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const IGeometrySink = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1SimplifiedGeometrySink
        SetFillMode: *c_void,
        SetSegmentFlags: *c_void,
        BeginFigure: *c_void,
        AddLines: *c_void,
        AddBeziers: *c_void,
        EndFigure: *c_void,
        Close: *c_void,
        // ID2D1GeometrySink
        AddLine: *c_void,
        AddBezier: *c_void,
        AddQuadraticBezier: *c_void,
        AddQuadraticBeziers: *c_void,
        AddArc: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const ITessellationSink = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1TessellationSink
        AddTriangles: *c_void,
        Close: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const IPathGeometry = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: *c_void,
        // ID2D1Geometry
        GetBounds: *c_void,
        GetWidenedBounds: *c_void,
        StrokeContainsPoint: *c_void,
        FillContainsPoint: *c_void,
        CompareWithGeometry: *c_void,
        Simplify: *c_void,
        Tessellate: *c_void,
        CombineWithGeometry: *c_void,
        Outline: *c_void,
        ComputeArea: *c_void,
        ComputeLength: *c_void,
        ComputePointAtLength: *c_void,
        Widen: *c_void,
        // ID2D1PathGeometry
        Open: *c_void,
        Stream: *c_void,
        GetSegmentCount: *c_void,
        GetFigureCount: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const IMesh = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: *c_void,
        // ID2D1Mesh
        Open: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const ILayer = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: *c_void,
        // ID2D1Layer
        GetSize: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const IDrawingStateBlock = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: *c_void,
        // ID2D1DrawingStateBlock
        GetDescription: *c_void,
        SetDescription: *c_void,
        SetTextRenderingParams: *c_void,
        GetTextRenderingParams: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const IDeviceContext6 = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: *c_void,
        // ID2D1RenderTarget
        CreateBitmap: *c_void,
        CreateBitmapFromWicBitmap: *c_void,
        CreateSharedBitmap: *c_void,
        CreateBitmapBrush: *c_void,
        CreateSolidColorBrush: fn (
            *Self,
            *const COLOR_F,
            ?*const BRUSH_PROPERTIES,
            **ISolidColorBrush,
        ) callconv(.Stdcall) HRESULT,
        CreateGradientStopCollection: *c_void,
        CreateLinearGradientBrush: *c_void,
        CreateRadialGradientBrush: *c_void,
        CreateCompatibleRenderTarget: *c_void,
        CreateLayer: *c_void,
        CreateMesh: *c_void,
        DrawLine: *c_void,
        DrawRectangle: *c_void,
        FillRectangle: fn (*Self, *const RECT_F, *IBrush) callconv(.Stdcall) void,
        DrawRoundedRectangle: *c_void,
        FillRoundedRectangle: *c_void,
        DrawEllipse: *c_void,
        FillEllipse: *c_void,
        DrawGeometry: *c_void,
        FillGeometry: *c_void,
        FillMesh: *c_void,
        FillOpacityMask: *c_void,
        DrawBitmap: *c_void,
        DrawText: *c_void,
        DrawTextLayout: *c_void,
        DrawGlyphRun: *c_void,
        SetTransform: fn (*Self, *const MATRIX_3X2_F) callconv(.Stdcall) void,
        GetTransform: *c_void,
        SetAntialiasMode: *c_void,
        GetAntialiasMode: *c_void,
        SetTextAntialiasMode: *c_void,
        GetTextAntialiasMode: *c_void,
        SetTextRenderingParams: *c_void,
        GetTextRenderingParams: *c_void,
        SetTags: *c_void,
        GetTags: *c_void,
        PushLayer: *c_void,
        PopLayer: *c_void,
        Flush: *c_void,
        SaveDrawingState: *c_void,
        RestoreDrawingState: *c_void,
        PushAxisAlignedClip: *c_void,
        PopAxisAlignedClip: *c_void,
        Clear: fn (*Self, *const COLOR_F) callconv(.Stdcall) void,
        BeginDraw: fn (*Self) callconv(.Stdcall) void,
        EndDraw: fn (*Self, ?*u64, ?*u64) callconv(.Stdcall) HRESULT,
        GetPixelFormat: *c_void,
        SetDpi: *c_void,
        GetDpi: *c_void,
        GetSize: *c_void,
        GetPixelSize: *c_void,
        GetMaximumBitmapSize: *c_void,
        IsSupported: *c_void,
        // ID2D1DeviceContext
        CreateBitmap1: *c_void,
        CreateBitmapFromWicBitmap1: *c_void,
        CreateColorContext: *c_void,
        CreateColorContextFromFilename: *c_void,
        CreateColorContextFromWicColorContext: *c_void,
        CreateBitmapFromDxgiSurface: fn (
            *Self,
            *dxgi.ISurface,
            *const BITMAP_PROPERTIES1,
            **IBitmap1,
        ) callconv(.Stdcall) HRESULT,
        CreateEffect: *c_void,
        CreateGradientStopCollection1: *c_void,
        CreateImageBrush: *c_void,
        CreateBitmapBrush1: *c_void,
        CreateCommandList: *c_void,
        IsDxgiFormatSupported: *c_void,
        IsBufferPrecisionSupported: *c_void,
        GetImageLocalBounds: *c_void,
        GetImageWorldBounds: *c_void,
        GetGlyphRunWorldBounds: *c_void,
        GetDevice: *c_void,
        SetTarget: fn (*Self, *IImage) callconv(.Stdcall) void,
        GetTarget: *c_void,
        SetRenderingControls: *c_void,
        GetRenderingControls: *c_void,
        SetPrimitiveBlend: *c_void,
        GetPrimitiveBlend: *c_void,
        SetUnitMode: *c_void,
        GetUnitMode: *c_void,
        DrawGlyphRun1: *c_void,
        DrawImage: *c_void,
        DrawGdiMetafile: *c_void,
        DrawBitmap1: *c_void,
        PushLayer1: *c_void,
        InvalidateEffectInputRectangle: *c_void,
        GetEffectInvalidRectangleCount: *c_void,
        GetEffectInvalidRectangles: *c_void,
        GetEffectRequiredInputRectangles: *c_void,
        FillOpacityMask1: *c_void,
        // ID2D1DeviceContext1
        CreateFilledGeometryRealization: *c_void,
        CreateStrokedGeometryRealization: *c_void,
        DrawGeometryRealization: *c_void,
        // ID2D1DeviceContext2
        CreateInk: *c_void,
        CreateInkStyle: *c_void,
        CreateGradientMesh: *c_void,
        CreateImageSourceFromWic: *c_void,
        CreateLookupTable3D: *c_void,
        CreateImageSourceFromDxgi: *c_void,
        GetGradientMeshWorldBounds: *c_void,
        DrawInk: *c_void,
        DrawGradientMesh: *c_void,
        DrawGdiMetafile1: *c_void,
        CreateTransformedImageSource: *c_void,
        // ID2D1DeviceContext3
        CreateSpriteBatch: *c_void,
        DrawSpriteBatch: *c_void,
        // ID2D1DeviceContext4
        CreateSvgGlyphStyle: *c_void,
        DrawText1: *c_void,
        DrawTextLayout1: *c_void,
        DrawColorBitmapGlyphRun: *c_void,
        DrawSvgGlyphRun: *c_void,
        GetColorBitmapGlyphImage: *c_void,
        GetSvgGlyphImage: *c_void,
        // ID2D1DeviceContext5
        CreateSvgDocument: *c_void,
        DrawSvgDocument: *c_void,
        CreateColorContextFromDxgiColorSpace: *c_void,
        CreateColorContextFromSimpleColorProfile: *c_void,
        // ID2D1DeviceContext6
        BlendImage: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IDeviceContext6.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CreateBitmapFromDxgiSurface(
                self: *T,
                surface: *dxgi.ISurface,
                properties: *const BITMAP_PROPERTIES1,
                bitmap: **IBitmap1,
            ) HRESULT {
                return self.vtbl.CreateBitmapFromDxgiSurface(self, surface, properties, bitmap);
            }
            pub inline fn CreateSolidColorBrush(
                self: *T,
                color: *const COLOR_F,
                properties: ?*const BRUSH_PROPERTIES,
                brush: **ISolidColorBrush,
            ) HRESULT {
                return self.vtbl.CreateSolidColorBrush(self, color, properties, brush);
            }
            pub inline fn SetTarget(self: *T, image: *IImage) void {
                self.vtbl.SetTarget(self, image);
            }
            pub inline fn BeginDraw(self: *T) void {
                self.vtbl.BeginDraw(self);
            }
            pub inline fn EndDraw(self: *T, tag1: ?*u64, tag2: ?*u64) HRESULT {
                return self.vtbl.EndDraw(self, tag1, tag2);
            }
            pub inline fn SetTransform(self: *T, transform: *const MATRIX_3X2_F) void {
                self.vtbl.SetTransform(self, transform);
            }
            pub inline fn Clear(self: *T, color: *const COLOR_F) void {
                self.vtbl.Clear(self, color);
            }
            pub inline fn FillRectangle(self: *T, rect: *const RECT_F, brush: *IBrush) void {
                self.vtbl.FillRectangle(self, rect, brush);
            }
        };
    }
};

pub const IDevice6 = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: *c_void,
        // ID2D1Device
        CreateDeviceContext: *c_void,
        CreatePrintControl: *c_void,
        SetMaximumTextureMemory: *c_void,
        GetMaximumTextureMemory: *c_void,
        ClearResources: *c_void,
        // ID2D1Device1
        GetRenderingPriority: *c_void,
        SetRenderingPriority: *c_void,
        CreateDeviceContext1: *c_void,
        // ID2D1Device2
        CreateDeviceContext2: *c_void,
        FlushDeviceContexts: *c_void,
        GetDxgiDevice: *c_void,
        // ID2D1Device3
        CreateDeviceContext3: *c_void,
        // ID2D1Device4
        CreateDeviceContext4: *c_void,
        SetMaximumColorGlyphCacheMemory: *c_void,
        GetMaximumColorGlyphCacheMemory: *c_void,
        // ID2D1Device5
        CreateDeviceContext5: *c_void,
        // ID2D1Device6
        CreateDeviceContext6: fn (
            *Self,
            DEVICE_CONTEXT_OPTIONS,
            **IDeviceContext6,
        ) callconv(.Stdcall) HRESULT,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IDevice6.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CreateDeviceContext6(
                self: *T,
                options: DEVICE_CONTEXT_OPTIONS,
                device_context6: **IDeviceContext6,
            ) HRESULT {
                return self.vtbl.CreateDeviceContext6(self, options, device_context6);
            }
        };
    }
};

pub const IFactory7 = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Factory
        ReloadSystemMetrics: *c_void,
        GetDesktopDpi: *c_void,
        CreateRectangleGeometry: *c_void,
        CreateRoundedRectangleGeometry: *c_void,
        CreateEllipseleGeometry: *c_void,
        CreateGeometryGroup: *c_void,
        CreateTransformedGeometry: *c_void,
        CreatePathGeometry: *c_void,
        CreateStrokeStyle: *c_void,
        CreateDrawingStateBlock: *c_void,
        CreateWicBitmapRenderTarget: *c_void,
        CreateHwndRenderTarget: *c_void,
        CreateDxgiSurfaceRenderTarget: *c_void,
        CreateDCRenderTarget: *c_void,
        // ID2D1Factory1
        CreateDevice: *c_void,
        CreateStrokeStyle1: *c_void,
        CreatePathGeometry1: *c_void,
        CreateDrawingStateBlock1: *c_void,
        CreateGdiMetafile: *c_void,
        RegisterEffectFromStream: *c_void,
        RegisterEffectFromString: *c_void,
        UnregisterEffect: *c_void,
        GetRegisteredEffects: *c_void,
        GetEffectProperties: *c_void,
        // ID2D1Factory2
        CreateDevice1: *c_void,
        // ID2D1Factory3
        CreateDevice2: *c_void,
        // ID2D1Factory4
        CreateDevice3: *c_void,
        // ID2D1Factory5
        CreateDevice4: *c_void,
        // ID2D1Factory6
        CreateDevice5: *c_void,
        // ID2D1Factory7
        CreateDevice6: fn (*Self, *dxgi.IDevice, **IDevice6) callconv(.Stdcall) HRESULT,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IFactory7.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CreateDevice6(
                self: *T,
                dxgi_device: *dxgi.IDevice,
                d2d_device6: **IDevice6,
            ) HRESULT {
                return self.vtbl.CreateDevice6(self, dxgi_device, d2d_device6);
            }
        };
    }
};

pub const IID_IFactory7 = os.GUID{
    .Data1 = 0xbdc2bdd3,
    .Data2 = 0xb96c,
    .Data3 = 0x4de6,
    .Data4 = .{ 0xbd, 0xf7, 0x99, 0xd4, 0x74, 0x54, 0x54, 0xde },
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
