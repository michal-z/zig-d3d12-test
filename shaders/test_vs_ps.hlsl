#define root_signature "DescriptorTable(SRV(t0, numDescriptors = 2))"

struct Vertex {
    float2 position;
};
StructuredBuffer<Vertex> srv_vertices : register(t0);
Buffer<uint> srv_indices : register(t1);

[RootSignature(root_signature)]
void vsMain(
    in uint vid : SV_VertexID,
    out float4 out_position : SV_Position)
{
    uint index = srv_indices[vid];
    float2 position = srv_vertices[index].position;
    out_position = float4(position, 0.0f, 1.0f);
}

[RootSignature(root_signature)]
void psMain(
    in float4 in_position : SV_Position,
    out float4 out_color : SV_Target0)
{
    out_color = float4(1.0f, 0.5f, 0.0f, 1.0f);
}
