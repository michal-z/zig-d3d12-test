const builtin = @import("builtin");
const std = @import("std");
const os = @import("windows.zig");
const HRESULT = os.HRESULT;

pub const FACTORY_TYPE = extern enum {
    SHARED = 0,
    ISOLATED = 1,
};

pub const FONT_WEIGHT = extern enum {
    THIN = 100,
    EXTRA_LIGHT = 200,
    LIGHT = 300,
    SEMI_LIGHT = 350,
    NORMAL = 400,
    MEDIUM = 500,
    SEMI_BOLD = 600,
    BOLD = 700,
    EXTRA_BOLD = 800,
    HEAVY = 900,
    EXTRA_HEAVY = 950,
};

pub const FONT_STYLE = extern enum {
    NORMAL = 0,
    OBLIQUE = 1,
    ITALIC = 2,
};

pub const FONT_STRETCH = extern enum {
    UNDEFINED = 0,
    ULTRA_CONDENSED = 1,
    EXTRA_CONDENSED = 2,
    CONDENSED = 3,
    SEMI_CONDENSED = 4,
    NORMAL = 5,
    MEDIUM = 5,
    SEMI_EXPANDED = 6,
    EXPANDED = 7,
    EXTRA_EXPANDED = 8,
    ULTRA_EXPANDED = 9,
};

pub const TEXT_ALIGNMENT = extern enum {
    LEADING = 0,
    TRAILING = 1,
    CENTER = 2,
    JUSTIFIED = 3,
};

pub const PARAGRAPH_ALIGNMENT = extern enum {
    NEAR = 0,
    FAR = 1,
    CENTER = 2,
};

pub const IFactory = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // IDWriteFactory
        GetSystemFontCollection: *c_void,
        CreateCustomFontCollection: *c_void,
        RegisterFontCollectionLoader: *c_void,
        UnregisterFontCollectionLoader: *c_void,
        CreateFontFileReference: *c_void,
        CreateCustomFontFileReference: *c_void,
        CreateFontFace: *c_void,
        CreateRenderingParams: *c_void,
        CreateMonitorRenderingParams: *c_void,
        CreateCustomRenderingParams: *c_void,
        RegisterFontFileLoader: *c_void,
        UnregisterFontFileLoader: *c_void,
        CreateTextFormat: fn (
            *Self,
            os.LPCWSTR,
            ?*IFontCollection,
            FONT_WEIGHT,
            FONT_STYLE,
            FONT_STRETCH,
            f32,
            os.LPCWSTR,
            **ITextFormat,
        ) callconv(.C) HRESULT,
        CreateTypography: *c_void,
        GetGdiInterop: *c_void,
        CreateTextLayout: *c_void,
        CreateGdiCompatibleTextLayout: *c_void,
        CreateEllipsisTrimmingSign: *c_void,
        CreateTextAnalyzer: *c_void,
        CreateNumberSubstitution: *c_void,
        CreateGlyphRunAnalysis: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IFactory.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CreateTextFormat(
                self: *T,
                font_family_name: os.LPCWSTR,
                font_collection: ?*IFontCollection,
                font_weight: FONT_WEIGHT,
                font_style: FONT_STYLE,
                font_stretch: FONT_STRETCH,
                font_size: f32,
                locale_name: os.LPCWSTR,
                text_format: **ITextFormat,
            ) HRESULT {
                return self.vtbl.CreateTextFormat(
                    self,
                    font_family_name,
                    font_collection,
                    font_weight,
                    font_style,
                    font_stretch,
                    font_size,
                    locale_name,
                    text_format,
                );
            }
        };
    }
};

pub const IFontCollection = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // IDWriteFontCollection
        GetFontFamilyCount: *c_void,
        GetFontFamily: *c_void,
        FindFamilyName: *c_void,
        GetFontFromFontFace: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const ITextFormat = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // IDWriteTextFormat
        SetTextAlignment: fn (*Self, TEXT_ALIGNMENT) callconv(.C) HRESULT,
        SetParagraphAlignment: fn (*Self, PARAGRAPH_ALIGNMENT) callconv(.C) HRESULT,
        SetWordWrapping: *c_void,
        SetReadingDirection: *c_void,
        SetFlowDirection: *c_void,
        SetIncrementalTabStop: *c_void,
        SetTrimming: *c_void,
        SetLineSpacing: *c_void,
        GetTextAlignment: *c_void,
        GetParagraphAlignment: *c_void,
        GetWordWrapping: *c_void,
        GetReadingDirection: *c_void,
        GetFlowDirection: *c_void,
        GetIncrementalTabStop: *c_void,
        GetTrimming: *c_void,
        GetLineSpacing: *c_void,
        GetFontCollection: *c_void,
        GetFontFamilyNameLength: *c_void,
        GetFontFamilyName: *c_void,
        GetFontWeight: *c_void,
        GetFontStyle: *c_void,
        GetFontStretch: *c_void,
        GetFontSize: *c_void,
        GetLocaleNameLength: *c_void,
        GetLocaleName: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace ITextFormat.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn SetTextAlignment(self: *T, alignment: TEXT_ALIGNMENT) HRESULT {
                return self.vtbl.SetTextAlignment(self, alignment);
            }
            pub inline fn SetParagraphAlignment(self: *T, alignment: PARAGRAPH_ALIGNMENT) HRESULT {
                return self.vtbl.SetParagraphAlignment(self, alignment);
            }
        };
    }
};

pub const IID_IFactory = os.GUID{
    .Data1 = 0xb859ee5a,
    .Data2 = 0xd838,
    .Data3 = 0x4b5b,
    .Data4 = .{ 0xa2, 0xe8, 0x1a, 0xdc, 0x7d, 0x93, 0xdb, 0x48 },
};

pub var CreateFactory: fn (
    FACTORY_TYPE,
    *const os.GUID,
    **c_void,
) callconv(.C) HRESULT = undefined;

pub fn init() void {
    var dwrite_dll = os.LoadLibraryA("dwrite.dll").?;
    CreateFactory = @ptrCast(
        @TypeOf(CreateFactory),
        os.kernel32.GetProcAddress(dwrite_dll, "DWriteCreateFactory").?,
    );
}
