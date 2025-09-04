shader_type canvas_item;
uniform bool rainbow;
uniform float speed;


vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 getColor(int i) {
    float hue = float(i) / 100.0;
    return hsv2rgb(vec3(hue, 1.0, 1.0));
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (true){
		vec4 input_color = texture(TEXTURE,UV);
		float xPos = 2.0*abs(0.5-UV.x);
		float yPos = 2.0*abs(0.5-UV.y);

		//for circluar shader
		//float radius = pow(pow(xPos,2.0) + pow(yPos,2.0),0.5);
		//float alpha = 1.0-(radius/1.1);
		//COLOR.a = alpha;

		//for square shader
		float squareRadius = max(xPos,yPos);
		float alpha = 1.0-(squareRadius/1.1); //1.0-(squareRadius/1.5);
		alpha += sin(TIME*10.0)/40.0;
	
		if (rainbow) {
			//old rainbow code
			COLOR = vec4(  max(UV.y * ((sin(TIME*2.0)+2.5)/2.5),0.3)   , max(((UV.x)/2.0) * ((sin(TIME*2.0 +(PI/2.0))+2.5)/2.5),0.35)  ,  max((UV.x+UV.y)/2.0 * ((sin(TIME*2.0 +(PI/4.0))+2.5)/2.5),0.6),  COLOR.a);
			alpha -=0.1;
			
			//float xValue = 1.0 - max(xPos,yPos);
			//xValue = UV.x+UV.y;
			//float offset;  
			//
			//offset = mod(TIME/0.5,4);
			//xValue = xValue + offset;
			//int index = int(floor(xValue*25.0));
			////index =10;
			//COLOR.r = getColor(index).x;
			//COLOR.g = getColor(index).y;
			//COLOR.b = getColor(index).z;
		} else {
			//COLOR = vec4(input_color.r,input_color.g,input_color.b,alpha);
		}
	
	

		
	
}




	//COLOR = vec4(input_color.r,input_color.g,input_color.b,alpha);

	//COLOR = vec4(squareRadius, 0.0, 0.0,1.0); // Shows UV gradient from red (X) and green (Y)
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
