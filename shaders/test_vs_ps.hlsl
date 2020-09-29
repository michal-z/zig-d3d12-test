#define root_signature \
    "DescriptorTable(SRV(t0, numDescriptors = 3), visibility = SHADER_VISIBILITY_VERTEX)"

struct Vertex {
    float3 position;
    float3 normal;
};

struct Transform {
    float4x4 m4x4;
};

StructuredBuffer<Vertex> srv_vertices : register(t0);
Buffer<uint> srv_indices : register(t1);
StructuredBuffer<Transform> srv_transforms : register(t2);

[RootSignature(root_signature)]
void vsMain(
    in uint vertex_id : SV_VertexID,
    out float4 out_position : SV_Position,
    out float3 out_color : _Color)
{
    uint vertex_index = srv_indices[vertex_id];
    Vertex vertex = srv_vertices[vertex_index];

    float3 position = vertex.position;
    float3 normal = vertex.normal;

    out_color = abs(normal);
    out_position = mul(float4(position, 1.0f), srv_transforms[0].m4x4);
}

[RootSignature(root_signature)]
void psMain(
    in float4 in_position : SV_Position,
    in float3 in_color : _Color,
    out float4 out_color : SV_Target0)
{
    out_color = float4(in_color, 1.0f);
}
