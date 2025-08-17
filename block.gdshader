shader_type canvas_item;
uniform bool rainbow;
uniform float speed;

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
				//clamp first value between 0 and 1
			//COLOR = vec4(  max(UV.y * ((sin(TIME*2.0)+2.5)/2.5),0.3)   , max(((UV.x)/2.0) * ((sin(TIME*2.0 +(PI/2.0))+2.5)/2.5),0.35)  ,  max((UV.x+UV.y)/2.0 * ((sin(TIME*2.0 +(PI/4.0))+2.5)/2.5),0.6),  COLOR.a);
			//COLOR = vec4( squareRadius* max((sin(5.0*TIME+(PI/2.0))+1.0)/2.0,0.4) , squareRadius * (sin(5.0*TIME+(PI/4.0))+1.0)/2.0, (sin(5.0*TIME)+1.0)/2.0,1.0);
			COLOR = vec4(  ((sin( (speed*TIME) + (UV.x * UV.y) + (PI/4.0) ))+ 1.0)/2.0, max((sin( (speed*TIME) +(UV.x * UV.y) + (PI/2.0) )+1.0)/2.0,0.5), (sin( (speed*TIME) +(UV.x * UV.y) )+1.0)/2.0, 1.0);
			alpha -=0.1;
		}

		if (squareRadius >0.55){
			//uses +1 to allow for animation player to change alpha value
			COLOR.a += clamp(0.0,alpha,1.0) -1.0;
			COLOR.b *=2.8;
			COLOR.r *=2.8;
			COLOR.g *=2.8;
		}



}




	//COLOR = vec4(input_color.r,input_color.g,input_color.b,alpha);

	//COLOR = vec4(squareRadius, 0.0, 0.0,1.0); // Shows UV gradient from red (X) and green (Y)
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
