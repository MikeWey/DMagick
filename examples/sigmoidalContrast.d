/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 * 
 * This is an translation of the sigmoidal contrast example
 * that can be found on the ImageMagick website:
 * http://www.imagemagick.org/source/core/sigmoidal-contrast.c
 * 
 * Mainly to demonstrate the parallel execution of the foreach
 * over the ImageView, normaly you whould use Image.sigmoidalContrast.
 */

module examples.sigmoidalContrast;

import std.math;
import std.stdio;

import dmagick.ColorRGB;
import dmagick.Image;

void main(string[] args)
{
	if ( args.length != 3 )
	{
		writefln("Usage: %s image sigmoidal-image", args[0]);
		return;
	}

	Image image = new Image(args[1]);

	//The Body of this loop is executed in parallel.
	foreach ( row; image.view )
	{
		foreach ( ColorRGB pixel; row )
		{
			pixel.red     = SigmoidalContrast(pixel.red);
			pixel.green   = SigmoidalContrast(pixel.green);
			pixel.blue    = SigmoidalContrast(pixel.blue);
			pixel.opacity = SigmoidalContrast(pixel.opacity);
		}
	}

	image.write(args[2]);
}

double SigmoidalContrast(double q)
{
	return ((1.0/(1+exp(10.0*(0.5-q)))-0.0066928509)*1.0092503);
}
