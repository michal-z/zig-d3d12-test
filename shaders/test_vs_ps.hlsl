#define root_signature "SRV(t0)"

struct Vertex {
    float2 position;
};
StructuredBuffer<Vertex> srv_vertex_buffer : register(t0);

[RootSignature(root_signature)]
void vsMain(
    in uint vid : SV_VertexID,
    out float4 out_position : SV_Position)
{
    float2 position = srv_vertex_buffer[vid].position;
    out_position = float4(position, 0.0f, 1.0f);
}

[RootSignature(root_signature)]
void psMain(
    in float4 in_position : SV_Position,
    out float4 out_color : SV_Target0)
{
    out_color = float4(1.0f, 0.5f, 0.0f, 1.0f);
}
