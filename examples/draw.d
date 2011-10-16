/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */

module examples.draw;

import std.conv;

import dmagick.Color;
import dmagick.ColorRGB;
import dmagick.DrawingContext;
import dmagick.Geometry;
import dmagick.Image;

//TODO: Easier way to import symbols from the headers used by DMagick.
import dmagick.c.geometry;

void main()
{
	int percentage = 95;

	int imageWidth = 320;
	int imageHeight = 200;

	//Define the colors to use
	Color borderColor = new Color("snow4");
	Color cylinderTop = new ColorRGB(1, 1, 1, 0.4);
	Color textColor   = new Color("red");
	Color textShadow  = new Color("firebrick3");

	//Define the Gradients to use;
	Gradient cylinderEmptyColor  = Gradient(new Color("white"),  new Color("gray"),      imageHeight/2);
	Gradient cylinderFullColor   = Gradient(new Color("green2"), new Color("darkgreen"), imageHeight/2);
	Gradient cylinderOutColor    = Gradient(new Color("lime"),   new Color("green4"),    imageHeight/2);

	int progressYmax = (imageHeight * 95) / 100; 
	int progressYmin = (imageHeight * 55) / 100;
	int progressXmin = (imageWidth * 5) / 100;
	int progressXmax = imageWidth - progressXmin;
	int max = ((percentage * (progressXmax - progressXmin)) / 100) + progressXmin;
	int wc = (progressYmax - progressYmin) / 4;
	int hc = (progressYmax - progressYmin) / 2;
	int fontsize = (imageHeight * 2) / 5;

	//Minimum progress width.
	if ( max < progressXmin + (2 * wc))
		max = progressXmin + (2 * wc);

	Image cylinder = new Image(Geometry(imageWidth, imageHeight), new Color("white"));
	DrawingContext dc = new DrawingContext();

	dc.stroke(borderColor);

	dc.push();
	dc.fill(cylinderEmptyColor);
	dc.roundRectangle(progressXmin, progressYmin, progressXmax, progressYmax, wc, hc);

	dc.fill(cylinderFullColor);
	dc.roundRectangle(progressXmin, progressYmin, max, progressYmax, wc, hc);

	dc.fill(cylinderOutColor);
	dc.roundRectangle(max - (2 * wc), progressYmin, max, progressYmax, wc, hc);
	dc.pop();

	dc.fill(cylinderTop);
	dc.roundRectangle(progressXmax - (2 * wc), progressYmin, progressXmax, progressYmax, wc, hc);

	dc.font("Helvetica");
	dc.fontSize(fontsize);
	dc.stroke(textShadow);
	dc.fill(textColor);
	dc.gravity(GravityType.NorthGravity);
	dc.text(0,(imageHeight * 10) / 100, to!(string)(percentage)~" %");

	dc.draw(cylinder);
	cylinder.display();
}
