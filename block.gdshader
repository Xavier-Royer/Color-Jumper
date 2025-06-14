shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 input_color = texture(TEXTURE,UV);
	float xPos = 2.0*abs(0.5-UV.x);
	float yPos = 2.0*abs(0.5-UV.y);
	float radius = pow(pow(xPos,2.0) + pow(yPos,2.0),0.5);
	float alpha = 1.0-(radius/1.1);
	COLOR.a = alpha;
	//COLOR = vec4(input_color.r,input_color.g,input_color.b,alpha);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
