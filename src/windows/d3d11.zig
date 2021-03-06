const std = @import("std");
const os = @import("windows.zig");
const dcommon = @import("dcommon.zig");
const HRESULT = os.HRESULT;
const RESOURCE_STATES = @import("d3d12.zig").RESOURCE_STATES;

pub const CREATE_DEVICE_FLAG = packed struct {
    SINGLETHREADED: bool = false,
    DEBUG: bool = false,
    SWITCH_TO_REF: bool = false,
    PREVENT_INTERNAL_THREADING_OPTIMIZATIONS: bool = false,
    RESERVED0: bool = false,
    BGRA_SUPPORT: bool = false,
    DEBUGGABLE: bool = false,
    PREVENT_ALTERING_LAYER_SETTINGS_FROM_REGISTRY: bool = false,
    DISABLE_GPU_TIMEOUT: bool = false,

    padding: u24 = 0,
};

pub const IDevice = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // ID3D11Device
        CreateBuffer: *c_void,
        CreateTexture1D: *c_void,
        CreateTexture2D: *c_void,
        CreateTexture3D: *c_void,
        CreateShaderResourceView: *c_void,
        CreateUnorderedAccessView: *c_void,
        CreateRenderTargetView: *c_void,
        CreateDepthStencilView: *c_void,
        CreateInputLayout: *c_void,
        CreateVertexShader: *c_void,
        CreateGeometryShader: *c_void,
        CreateGeometryShaderWithStreamOutput: *c_void,
        CreatePixelShader: *c_void,
        CreateHullShader: *c_void,
        CreateDomainShader: *c_void,
        CreateComputeShader: *c_void,
        CreateClassLinkage: *c_void,
        CreateBlendState: *c_void,
        CreateDepthStencilState: *c_void,
        CreateRasterizerState: *c_void,
        CreateSamplerState: *c_void,
        CreateQuery: *c_void,
        CreatePredicate: *c_void,
        CreateCounter: *c_void,
        CreateDeferredContext: *c_void,
        OpenSharedResource: *c_void,
        CheckFormatSupport: *c_void,
        CheckMultisampleQualityLevels: *c_void,
        CheckCounterInfo: *c_void,
        CheckCounter: *c_void,
        CheckFeatureSupport: *c_void,
        GetPrivateData: *c_void,
        SetPrivateData: *c_void,
        SetPrivateDataInterface: *c_void,
        GetFeatureLevel: *c_void,
        GetCreationFlags: *c_void,
        GetDeviceRemovedReason: *c_void,
        GetImmediateContext: *c_void,
        SetExceptionMode: *c_void,
        GetExceptionMode: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const IResource = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // ID3D11DeviceChild
        GetDevice: *c_void,
        GetPrivateData: *c_void,
        SetPrivateData: *c_void,
        SetPrivateDataInterface: *c_void,
        // ID3D11Resource
        GetType: *c_void,
        SetEvictionPriority: *c_void,
        GetEvictionPriority: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
};

pub const IDeviceContext = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // ID3D11DeviceChild
        GetDevice: *c_void,
        GetPrivateData: *c_void,
        SetPrivateData: *c_void,
        SetPrivateDataInterface: *c_void,
        // ID3D11DeviceContext
        VSSetConstantBuffers: *c_void,
        PSSetShaderResources: *c_void,
        PSSetShader: *c_void,
        PSSetSamplers: *c_void,
        VSSetShader: *c_void,
        DrawIndexed: *c_void,
        Draw: *c_void,
        Map: *c_void,
        Unmap: *c_void,
        PSSetConstantBuffers: *c_void,
        IASetInputLayout: *c_void,
        IASetVertexBuffers: *c_void,
        IASetIndexBuffer: *c_void,
        DrawIndexedInstanced: *c_void,
        DrawInstanced: *c_void,
        GSSetConstantBuffers: *c_void,
        GSSetShader: *c_void,
        IASetPrimitiveTopology: *c_void,
        VSSetShaderResources: *c_void,
        VSSetSamplers: *c_void,
        Begin: *c_void,
        End: *c_void,
        GetData: *c_void,
        SetPredication: *c_void,
        GSSetShaderResources: *c_void,
        GSSetSamplers: *c_void,
        OMSetRenderTargets: *c_void,
        OMSetRenderTargetsAndUnorderedAccessViews: *c_void,
        OMSetBlendState: *c_void,
        OMSetDepthStencilState: *c_void,
        SOSetTargets: *c_void,
        DrawAuto: *c_void,
        DrawIndexedInstancedIndirect: *c_void,
        DrawInstancedIndirect: *c_void,
        Dispatch: *c_void,
        DispatchIndirect: *c_void,
        RSSetState: *c_void,
        RSSetViewports: *c_void,
        RSSetScissorRects: *c_void,
        CopySubresourceRegion: *c_void,
        CopyResource: *c_void,
        UpdateSubresource: *c_void,
        CopyStructureCount: *c_void,
        ClearRenderTargetView: *c_void,
        ClearUnorderedAccessViewUint: *c_void,
        ClearUnorderedAccessViewFloat: *c_void,
        ClearDepthStencilView: *c_void,
        GenerateMips: *c_void,
        SetResourceMinLOD: *c_void,
        GetResourceMinLOD: *c_void,
        ResolveSubresource: *c_void,
        ExecuteCommandList: *c_void,
        HSSetShaderResources: *c_void,
        HSSetShader: *c_void,
        HSSetSamplers: *c_void,
        HSSetConstantBuffers: *c_void,
        DSSetShaderResources: *c_void,
        DSSetShader: *c_void,
        DSSetSamplers: *c_void,
        DSSetConstantBuffers: *c_void,
        CSSetShaderResources: *c_void,
        CSSetUnorderedAccessViews: *c_void,
        CSSetShader: *c_void,
        CSSetSamplers: *c_void,
        CSSetConstantBuffers: *c_void,
        VSGetConstantBuffers: *c_void,
        PSGetShaderResources: *c_void,
        PSGetShader: *c_void,
        PSGetSamplers: *c_void,
        VSGetShader: *c_void,
        PSGetConstantBuffers: *c_void,
        IAGetInputLayout: *c_void,
        IAGetVertexBuffers: *c_void,
        IAGetIndexBuffer: *c_void,
        GSGetConstantBuffers: *c_void,
        GSGetShader: *c_void,
        IAGetPrimitiveTopology: *c_void,
        VSGetShaderResources: *c_void,
        VSGetSamplers: *c_void,
        GetPredication: *c_void,
        GSGetShaderResources: *c_void,
        GSGetSamplers: *c_void,
        OMGetRenderTargets: *c_void,
        OMGetRenderTargetsAndUnorderedAccessViews: *c_void,
        OMGetBlendState: *c_void,
        OMGetDepthStencilState: *c_void,
        SOGetTargets: *c_void,
        RSGetState: *c_void,
        RSGetViewports: *c_void,
        RSGetScissorRects: *c_void,
        HSGetShaderResources: *c_void,
        HSGetShader: *c_void,
        HSGetSamplers: *c_void,
        HSGetConstantBuffers: *c_void,
        DSGetShaderResources: *c_void,
        DSGetShader: *c_void,
        DSGetSamplers: *c_void,
        DSGetConstantBuffers: *c_void,
        CSGetShaderResources: *c_void,
        CSGetUnorderedAccessViews: *c_void,
        CSGetShader: *c_void,
        CSGetSamplers: *c_void,
        CSGetConstantBuffers: *c_void,
        ClearState: *c_void,
        Flush: fn (*Self) callconv(.C) void,
        GetType: *c_void,
        GetContextFlags: *c_void,
        FinishCommandList: *c_void,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace IDeviceContext.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn Flush(self: *T) void {
                self.vtbl.Flush(self);
            }
        };
    }
};

pub const RESOURCE_FLAGS_11ON12 = extern struct {
    BindFlags: u32 = 0x20, // D3D11_BIND_RENDER_TARGET
    MiscFlags: u32 = 0,
    CPUAccessFlags: u32 = 0,
    StructureByteStride: u32 = 0,
};

pub const I11On12Device = extern struct {
    const Self = @This();
    vtbl: *const extern struct {
        // IUnknown
        QueryInterface: fn (*Self, *const os.GUID, **c_void) callconv(.C) HRESULT,
        AddRef: fn (*Self) callconv(.C) u32,
        Release: fn (*Self) callconv(.C) u32,
        // ID3D11On12Device
        CreateWrappedResource: fn (
            *Self,
            *os.IUnknown,
            *const RESOURCE_FLAGS_11ON12,
            RESOURCE_STATES,
            RESOURCE_STATES,
            *const os.GUID,
            **c_void,
        ) callconv(.C) HRESULT,
        ReleaseWrappedResources: fn (*Self, [*]const *IResource, u32) callconv(.C) void,
        AcquireWrappedResources: fn (*Self, [*]const *IResource, u32) callconv(.C) void,
    },
    usingnamespace os.IUnknown.Methods(Self);
    usingnamespace I11On12Device.Methods(Self);

    fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CreateWrappedResource(
                self: *T,
                resource12: *os.IUnknown,
                flags11: *const RESOURCE_FLAGS_11ON12,
                in_state: RESOURCE_STATES,
                out_state: RESOURCE_STATES,
                guid: *const os.GUID,
                resource11: **c_void,
            ) HRESULT {
                return self.vtbl.CreateWrappedResource(
                    self,
                    resource12,
                    flags11,
                    in_state,
                    out_state,
                    guid,
                    resource11,
                );
            }
            pub inline fn ReleaseWrappedResources(
                self: *T,
                resources: [*]const *IResource,
                num_resources: u32,
            ) void {
                self.vtbl.ReleaseWrappedResources(self, resources, num_resources);
            }
            pub inline fn AcquireWrappedResources(
                self: *T,
                resources: [*]const *IResource,
                num_resources: u32,
            ) void {
                self.vtbl.AcquireWrappedResources(self, resources, num_resources);
            }
        };
    }
};

pub const IID_IResource = os.GUID{
    .Data1 = 0xdc8e63f3,
    .Data2 = 0xd12b,
    .Data3 = 0x4952,
    .Data4 = .{ 0xb4, 0x7b, 0x5e, 0x45, 0x02, 0x6a, 0x86, 0x2d },
};

pub const IID_I11On12Device = os.GUID{
    .Data1 = 0x85611e73,
    .Data2 = 0x70a9,
    .Data3 = 0x490e,
    .Data4 = .{ 0x96, 0x14, 0xa9, 0xe3, 0x02, 0x77, 0x79, 0x04 },
};

pub var Create11On12Device: fn (
    *os.IUnknown,
    CREATE_DEVICE_FLAG,
    ?[*]const dcommon.FEATURE_LEVEL,
    u32,
    [*]const *os.IUnknown,
    u32,
    u32,
    ?**IDevice,
    ?**IDeviceContext,
    ?*dcommon.FEATURE_LEVEL,
) callconv(.C) HRESULT = undefined;

pub fn init() void {
    // TODO: Handle error.
    var d3d11_dll = os.LoadLibraryA("d3d11.dll").?;
    Create11On12Device = @ptrCast(
        @TypeOf(Create11On12Device),
        os.kernel32.GetProcAddress(d3d11_dll, "D3D11On12CreateDevice").?,
    );
}
