#define root_signature "DescriptorTable(SRV(t0, numDescriptors = 3))"

struct Vertex {
    float3 position;
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
    out float4 out_position : SV_Position)
{
    uint vertex_index = srv_indices[vertex_id];
    float3 position = srv_vertices[vertex_index].position;
    out_position = mul(float4(position, 1.0f), srv_transforms[0].m4x4);
}

[RootSignature(root_signature)]
void psMain(
    in float4 in_position : SV_Position,
    out float4 out_color : SV_Target0)
{
    out_color = float4(1.0f, 0.5f, 0.0f, 1.0f);
}
