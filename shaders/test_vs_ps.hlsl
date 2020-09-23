#define root_signature ""

[RootSignature(root_signature)]
void vsMain(
    in uint vid : SV_VertexID,
    out float4 out_position : SV_Position)
{
    float2 positions[3] = { float2(-1.0f, -1.0f), float2(0.0f, 1.0f), float2(1.0f, -1.0f) };
    out_position = float4(positions[vid], 0.0f, 1.0f);
}

[RootSignature(root_signature)]
void psMain(
    in float4 in_position : SV_Position,
    out float4 out_color : SV_Target0)
{
    out_color = float4(1.0f, 0.5f, 0.0f, 1.0f);
}
