const std = @import("std");
const os = @import("windows.zig");
const HRESULT = os.HRESULT;

pub const Rect = extern struct {
    X: c_int,
    Y: c_int,
    Width: c_int,
    Height: c_int,
};

pub const DecodeOptions = extern enum {
    MetadataCacheOnDemand = 0,
    MetadataCacheOnLoad = 0x1,
};

pub const BitmapPaletteType = extern enum {
    Custom = 0,
    MedianCut = 0x1,
    FixedBW = 0x2,
    FixedHalftone8 = 0x3,
    FixedHalftone27 = 0x4,
    FixedHalftone64 = 0x5,
    FixedHalftone125 = 0x6,
    FixedHalftone216 = 0x7,
    FixedHalftone252 = 0x8,
    FixedHalftone256 = 0x9,
    FixedGray4 = 0xa,
    FixedGray16 = 0xb,
    FixedGray256 = 0xc,
};

pub const BitmapDitherType = extern enum {
    None = 0,
    Solid = 0,
    Ordered4x4 = 0x1,
    Ordered8x8 = 0x2,
    Ordered16x16 = 0x3,
    Spiral4x4 = 0x4,
    Spiral8x8 = 0x5,
    DualSpiral4x4 = 0x6,
    DualSpiral8x8 = 0x7,
    ErrorDiffusion = 0x8,
};

pub const IBitmapSource = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // IWICBitmapSource
        GetSize: fn (*Self, *u32, *u32) callconv(.Stdcall) HRESULT,
        GetPixelFormat: fn (*Self, *os.GUID) callconv(.Stdcall) HRESULT,
        GetResolution: *c_void,
        CopyPalette: *c_void,
        CopyPixels: fn (*Self, ?*const Rect, u32, u32, [*]u8) callconv(.Stdcall) HRESULT,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IBitmapSource.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetSize(self: *T, width: *u32, height: *u32) HRESULT {
                return self.vtbl.GetSize(self, width, height);
            }
            pub inline fn GetPixelFormat(self: *T, pPixelFormat: *os.GUID) HRESULT {
                return self.vtbl.GetPixelFormat(self, pPixelFormat);
            }
            pub inline fn CopyPixels(
                self: *T,
                prc: ?*const Rect,
                cbStride: u32,
                cbBufferSize: u32,
                pbBuffer: [*]u8,
            ) HRESULT {
                return self.vtbl.CopyPixels(self, prc, cbStride, cbBufferSize, pbBuffer);
            }
        };
    }
};

pub const IBitmapFrameDecode = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // IWICBitmapSource
        GetSize: fn (*Self, *u32, *u32) callconv(.Stdcall) HRESULT,
        GetPixelFormat: fn (*Self, *os.GUID) callconv(.Stdcall) HRESULT,
        GetResolution: *c_void,
        CopyPalette: *c_void,
        CopyPixels: fn (*Self, ?*const Rect, u32, u32, [*]u8) callconv(.Stdcall) HRESULT,
        // IBitmapFrameDecode
        GetMetadataQueryReader: *c_void,
        GetColorContexts: *c_void,
        GetThumbnail: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IBitmapSource.Methods(Self);
};

pub const IBitmap = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // IWICBitmapSource
        GetSize: fn (*Self, *u32, *u32) callconv(.Stdcall) HRESULT,
        GetPixelFormat: fn (*Self, *os.GUID) callconv(.Stdcall) HRESULT,
        GetResolution: *c_void,
        CopyPalette: *c_void,
        CopyPixels: fn (*Self, ?*const Rect, u32, u32, [*]u8) callconv(.Stdcall) HRESULT,
        // IWICBitmap
        Lock: *c_void,
        SetPalette: *c_void,
        SetResolution: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IBitmapSource.Methods(Self);
};

pub const IFormatConverter = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // IWICBitmapSource
        GetSize: fn (*Self, *u32, *u32) callconv(.Stdcall) HRESULT,
        GetPixelFormat: fn (*Self, *os.GUID) callconv(.Stdcall) HRESULT,
        GetResolution: *c_void,
        CopyPalette: *c_void,
        CopyPixels: fn (*Self, ?*const Rect, u32, u32, [*]u8) callconv(.Stdcall) HRESULT,
        // IWICFormatConverter
        Initialize: fn (
            *Self,
            ?*IBitmapSource,
            *const os.GUID,
            BitmapDitherType,
            ?*IPalette,
            f64,
            BitmapPaletteType,
        ) callconv(.Stdcall) HRESULT,
        CanConvert: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IBitmapSource.Methods(Self);
    usingnamespace IFormatConverter.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn Initialize(
                self: *T,
                pISource: ?*IBitmapSource,
                dstFormat: *const os.GUID,
                dither: BitmapDitherType,
                pIPalette: ?*IPalette,
                alphaThresholdPercent: f64,
                paletteTranslate: BitmapPaletteType,
            ) HRESULT {
                return self.vtbl.Initialize(
                    self,
                    pISource,
                    dstFormat,
                    dither,
                    pIPalette,
                    alphaThresholdPercent,
                    paletteTranslate,
                );
            }
        };
    }
};

pub const IPalette = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // IWICPalette
        InitializePredefined: *c_void,
        InitializeCustom: *c_void,
        InitializeFromBitmap: *c_void,
        InitializeFromPalette: *c_void,
        GetType: *c_void,
        GetColorCount: *c_void,
        GetColors: *c_void,
        IsBlackWhite: *c_void,
        IsGrayscale: *c_void,
        HasAlpha: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const IBitmapDecoder = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // IWICBitmapDecoder
        QueryCapability: *c_void,
        Initialize: *c_void,
        GetContainerFormat: *c_void,
        GetDecoderInfo: *c_void,
        CopyPalette: *c_void,
        GetMetadataQueryReader: *c_void,
        GetPreview: *c_void,
        GetColorContexts: *c_void,
        GetThumbnail: *c_void,
        GetFrameCount: *c_void,
        GetFrame: fn (*Self, u32, **IBitmapFrameDecode) callconv(.Stdcall) HRESULT,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IBitmapDecoder.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetFrame(self: *T, index: u32, ppIBitmapFrame: **IBitmapFrameDecode) HRESULT {
                return self.vtbl.GetFrame(self, index, ppIBitmapFrame);
            }
        };
    }
};

pub const IImagingFactory = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.Stdcall) HRESULT,
        AddRef: fn (*Self) callconv(.Stdcall) u32,
        Release: fn (*Self) callconv(.Stdcall) u32,
        // IWICImagingFactory
        CreateDecoderFromFilename: fn (
            *Self,
            os.LPCWSTR,
            ?*const os.GUID,
            os.DWORD,
            DecodeOptions,
            **IBitmapDecoder,
        ) callconv(.Stdcall) HRESULT,
        CreateDecoderFromStream: *c_void,
        CreateDecoderFromFileHandle: *c_void,
        CreateComponentInfo: *c_void,
        CreateDecoder: *c_void,
        CreateEncoder: *c_void,
        CreatePalette: *c_void,
        CreateFormatConverter: fn (*Self, **IFormatConverter) callconv(.Stdcall) HRESULT,
        CreateBitmapScaler: *c_void,
        CreateBitmapClipper: *c_void,
        CreateBitmapFlipRotator: *c_void,
        CreateStream: *c_void,
        CreateColorContext: *c_void,
        CreateColorTransformer: *c_void,
        CreateBitmap: *c_void,
        CreateBitmapFromSource: *c_void,
        CreateBitmapFromSourceRect: *c_void,
        CreateBitmapFromMemory: *c_void,
        CreateBitmapFromHBITMAP: *c_void,
        CreateBitmapFromHICON: *c_void,
        CreateComponentEnumerator: *c_void,
        CreateFastMetadataEncoderFromDecoder: *c_void,
        CreateFastMetadataEncoderFromFrameDecode: *c_void,
        CreateQueryWriter: *c_void,
        CreateQueryWriterFromReader: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IImagingFactory.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CreateDecoderFromFilename(
                self: *T,
                wzFilename: os.LPCWSTR,
                pguidVendor: ?*const os.GUID,
                dwDesiredAccess: os.DWORD,
                metadataOptions: DecodeOptions,
                ppIDecoder: **IBitmapDecoder,
            ) HRESULT {
                return self.vtbl.CreateDecoderFromFilename(
                    self,
                    wzFilename,
                    pguidVendor,
                    dwDesiredAccess,
                    metadataOptions,
                    ppIDecoder,
                );
            }
            pub inline fn CreateFormatConverter(
                self: *T,
                ppIFormatConverter: **IFormatConverter,
            ) HRESULT {
                return self.vtbl.CreateFormatConverter(self, ppIFormatConverter);
            }
        };
    }
};

pub const CLSID_ImagingFactory = os.GUID{
    .Data1 = 0xcacaf262,
    .Data2 = 0x9370,
    .Data3 = 0x4615,
    .Data4 = .{ 0xa1, 0x3b, 0x9f, 0x55, 0x39, 0xda, 0x4c, 0xa },
};

pub const IID_IImagingFactory = os.GUID{
    .Data1 = 0xec5ec8a9,
    .Data2 = 0xc395,
    .Data3 = 0x4314,
    .Data4 = .{ 0x9c, 0x77, 0x54, 0xd7, 0xa9, 0x35, 0xff, 0x70 },
};

pub const GUID_PixelFormat24bppRGB = os.GUID{
    .Data1 = 0x6fddc324,
    .Data2 = 0x4e03,
    .Data3 = 0x4bfe,
    .Data4 = .{ 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x0d },
};
pub const GUID_PixelFormat32bppRGB = os.GUID{
    .Data1 = 0xd98c6b95,
    .Data2 = 0x3efe,
    .Data3 = 0x47d6,
    .Data4 = .{ 0xbb, 0x25, 0xeb, 0x17, 0x48, 0xab, 0x0c, 0xf1 },
};
pub const GUID_PixelFormat32bppRGBA = os.GUID{
    .Data1 = 0xf5c7ad2d,
    .Data2 = 0x6a8d,
    .Data3 = 0x43dd,
    .Data4 = .{ 0xa7, 0xa8, 0xa2, 0x99, 0x35, 0x26, 0x1a, 0xe9 },
};
pub const GUID_PixelFormat32bppPRGBA = os.GUID{
    .Data1 = 0x3cc4a650,
    .Data2 = 0xa527,
    .Data3 = 0x4d37,
    .Data4 = .{ 0xa9, 0x16, 0x31, 0x42, 0xc7, 0xeb, 0xed, 0xba },
};

pub const GUID_PixelFormat24bppBGR = os.GUID{
    .Data1 = 0x6fddc324,
    .Data2 = 0x4e03,
    .Data3 = 0x4bfe,
    .Data4 = .{ 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x0c },
};
pub const GUID_PixelFormat32bppBGR = os.GUID{
    .Data1 = 0x6fddc324,
    .Data2 = 0x4e03,
    .Data3 = 0x4bfe,
    .Data4 = .{ 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x0e },
};
pub const GUID_PixelFormat32bppBGRA = os.GUID{
    .Data1 = 0x6fddc324,
    .Data2 = 0x4e03,
    .Data3 = 0x4bfe,
    .Data4 = .{ 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x0f },
};
pub const GUID_PixelFormat32bppPBGRA = os.GUID{
    .Data1 = 0x6fddc324,
    .Data2 = 0x4e03,
    .Data3 = 0x4bfe,
    .Data4 = .{ 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x10 },
};

pub const GUID_PixelFormat8bppGray = os.GUID{
    .Data1 = 0x6fddc324,
    .Data2 = 0x4e03,
    .Data3 = 0x4bfe,
    .Data4 = .{ 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x08 },
};
pub const GUID_PixelFormat8bppAlpha = os.GUID{
    .Data1 = 0xe6cd0116,
    .Data2 = 0xeeba,
    .Data3 = 0x4161,
    .Data4 = .{ 0xaa, 0x85, 0x27, 0xdd, 0x9f, 0xb3, 0xa8, 0x95 },
};
