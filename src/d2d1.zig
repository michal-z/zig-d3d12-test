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
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: fn (*Self, **IFactory) callconv(.Stdcall) void,
        // ID2D1Bitmap
        GetSize: *c_void,
        GetPixelSize: *c_void,
        GetPixelFormat: *c_void,
        GetPixelDpi: *c_void,
        CopyFromBitmap: *c_void,
        CopyFromRenderTarget: *c_void,
        CopyFromMemory: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IResource.Methods(Self);
};

pub const IGradientStopCollection = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: fn (*Self, **IFactory) callconv(.Stdcall) void,
        // ID2D1GradientStopCollection
        GetGradientStopCount: *c_void,
        GetGradientStops: *c_void,
        GetColorInterpolationGamma: *c_void,
        GetExtendMode: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IResource.Methods(Self);
};

pub const IBrush = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: fn (*Self, **IFactory) callconv(.Stdcall) void,
        // ID2D1Brush
        SetOpacity: *c_void,
        SetTransform: *c_void,
        GetOpacity: *c_void,
        GetTransform: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IResource.Methods(Self);
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
    usingnamespace IResource.Methods(Self);
};

pub const ISolidColorBrush = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: fn (*Self, **IFactory) callconv(.Stdcall) void,
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
    usingnamespace IResource.Methods(Self);
};

pub const ILinearGradientBrush = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: fn (*Self, **IFactory) callconv(.Stdcall) void,
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
    usingnamespace IResource.Methods(Self);
};

pub const IRadialGradientBrush = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: fn (*Self, **IFactory) callconv(.Stdcall) void,
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
    usingnamespace IResource.Methods(Self);
};

pub const IStrokeStyle = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: fn (*Self, **IFactory) callconv(.Stdcall) void,
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
    usingnamespace IResource.Methods(Self);
};

pub const IGeometry = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: fn (*Self, **IFactory) callconv(.Stdcall) void,
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
    usingnamespace IResource.Methods(Self);
};

pub const IRectangleGeometry = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: fn (*Self, **IFactory) callconv(.Stdcall) void,
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
    usingnamespace IResource.Methods(Self);
};

pub const IRoundedRectangleGeometry = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: fn (*Self, **IFactory) callconv(.Stdcall) void,
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
    usingnamespace IResource.Methods(Self);
};

pub const IEllipseGeometry = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: fn (*Self, **IFactory) callconv(.Stdcall) void,
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
    usingnamespace IResource.Methods(Self);
};

pub const IGeometryGroup = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: fn (*Self, **IFactory) callconv(.Stdcall) void,
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
    usingnamespace IResource.Methods(Self);
};

pub const ITransformedGeometry = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // ID2D1Resource
        GetFactory: fn (*Self, **IFactory) callconv(.Stdcall) void,
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
    usingnamespace IResource.Methods(Self);
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
