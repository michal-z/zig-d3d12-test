#define root_signature \
    "RootConstants(b0, num32BitConstants = 3), " \
    "DescriptorTable(SRV(t0, numDescriptors = 3), visibility = SHADER_VISIBILITY_VERTEX)"

struct Vertex {
    float3 position;
    float3 normal;
    float2 texcoord;
};

struct EntityInfo {
    float4x4 m4x4;
    uint color;
};

struct DrawCallInfo {
    uint start_index_location;
    uint base_vertex_location;
    uint entity_id;
};

ConstantBuffer<DrawCallInfo> cbv_drawcall : register(b0);
StructuredBuffer<Vertex> srv_vertices : register(t0);
Buffer<uint> srv_indices : register(t1);
StructuredBuffer<EntityInfo> srv_entities : register(t2);

[RootSignature(root_signature)]
void vsMain(
    uint vertex_id : SV_VertexID,
    out float4 out_position : SV_Position,
    out float3 out_color : _Color)
{
    const uint vertex_index = cbv_drawcall.base_vertex_location +
        srv_indices[vertex_id + cbv_drawcall.start_index_location];

    Vertex vertex = srv_vertices[vertex_index];
    EntityInfo entity = srv_entities[cbv_drawcall.entity_id];

    float3 position = vertex.position;
    float3 normal = vertex.normal;

    float4x4 world_to_clip = srv_entities[0].m4x4;
    float4x4 object_to_world = entity.m4x4;
    float4x4 object_to_clip = mul(object_to_world, world_to_clip);

    out_color = float3((entity.color & 0x000000ff) / 255.0,
            ((entity.color & 0x0000ff00) >> 8) / 255.0,
            ((entity.color & 0x00ff0000) >> 16) / 255.0);
    out_position = mul(float4(position, 1.0f), object_to_clip);
}

float edgeInfluence(float3 distance, float line_width) {
    float3 dx = ddx(distance);
    float3 dy = ddy(distance);
    float3 dd = dx * dx + dy * dy;
    float3 pix = (distance * distance) / dd;
    float d = sqrt(min(min(pix.x, pix.y), pix.z));
    d = d - (0.5f * line_width - 1.0f);
    d = clamp(d, 0.0f, 2.0f);
    return exp2(-2.0f * d * d);
}

[RootSignature(root_signature)]
void psMain(
    float3 tri_distance : SV_Barycentrics,
    float4 in_position : SV_Position,
    float3 in_color : _Color,
    out float4 out_color : SV_Target0)
{
    float3 color = in_color;
    float tri_edge = edgeInfluence(tri_distance, 3.0);
    color = lerp(color, 0.0f, tri_edge);
    out_color = float4(color, 1.0f);
}
