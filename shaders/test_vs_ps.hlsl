#define root_signature \
    "RootConstants(b0, num32BitConstants = 3), " \
    "DescriptorTable(SRV(t0, numDescriptors = 3), visibility = SHADER_VISIBILITY_VERTEX)"

struct Vertex {
    float3 position;
    float3 normal;
};

struct Transform {
    float4x4 m4x4;
};

struct DrawCallParams {
    uint start_index_location;
    uint base_vertex_location;
    uint transform_location;
};

ConstantBuffer<DrawCallParams> drawcall : register(b0);
StructuredBuffer<Vertex> srv_vertices : register(t0);
Buffer<uint> srv_indices : register(t1);
StructuredBuffer<Transform> srv_transforms : register(t2);

[RootSignature(root_signature)]
void vsMain(
    in uint vertex_id : SV_VertexID,
    out float4 out_position : SV_Position,
    out float3 out_color : _Color)
{
    const uint vertex_index = drawcall.base_vertex_location +
        srv_indices[vertex_id + drawcall.start_index_location];

    Vertex vertex = srv_vertices[vertex_index];

    float3 position = vertex.position;
    float3 normal = vertex.normal;

    float4x4 world_to_clip = srv_transforms[0].m4x4;
    float4x4 object_to_world = srv_transforms[drawcall.transform_location].m4x4;
    float4x4 object_to_clip = mul(object_to_world, world_to_clip);

    out_color = abs(normal);
    out_position = mul(float4(position, 1.0f), object_to_clip);
}

[RootSignature(root_signature)]
void psMain(
    in float4 in_position : SV_Position,
    in float3 in_color : _Color,
    out float4 out_color : SV_Target0)
{
    out_color = float4(in_color, 1.0f);
}
