///**
// * Noise Wave
// * by Daniel Shiffman.  
// * 
// * Using Perlin Noise to generate a wave-like pattern. 
// */

//float yoff = 0.0;        // 2nd dimension of perlin noise

//void setup() {
//  size(640, 360);
//}

//void draw() {
//  background(0);

//  fill(255);
//  // We are going to draw a polygon out of the wave points
//  beginShape(); 
  
//  float xoff = 0;       // Option #1: 2D Noise
//  // float xoff = yoff; // Option #2: 1D Noise
  
//  // Iterate over horizontal pixels
//  for (float x = 0; x <= width; x += 8) {
//    // Calculate a y value according to noise, map to 
//    float y = map(noise(xoff, yoff), 0, 1, 200,300); // Option #1: 2D Noise
    
//    // Set the vertex
//    vertex(x, y); 
//    // Increment x dimension for noise
//    xoff += 0.03;
//  }
//  // increment y dimension for noise
//  yoff += 0.01;
//  vertex(width, height);
//  vertex(0, height);
//  endShape(CLOSE);
//}
