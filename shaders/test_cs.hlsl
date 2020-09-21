#define root_signature \
    "DescriptorTable(UAV(u0))"

RWTexture2D<float4> uav_image : register(u0);

[RootSignature(root_signature)]
[numthreads(8, 8, 1)]
void csMain(uint3 global_id : SV_DispatchThreadId) {
	float2 resolution;
	uav_image.GetDimensions(resolution.x, resolution.y);
	float2 p = global_id.xy / resolution;
	uav_image[global_id.xy] = float4(p, 0.0f, 1.0f);
}
