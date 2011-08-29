/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */

module dmagick.DrawingContext;

import std.string;

import dmagick.Color;
import dmagick.Exception;
import dmagick.Geometry;
import dmagick.Image;
import dmagick.Options;
import dmagick.Utils;

import dmagick.c.draw;
import dmagick.c.geometry;
import dmagick.c.type;

/**
 * Drawable provides a convenient interface for preparing vector,
 * image, or text arguments.
 */
class DrawingContext
{
	string operations;

	/**
	 * Apply the drawing context to the image.
	 */
	void draw(Image image)
	{
		copyString(image.options.drawInfo.primitive, operations);
		DrawImage(image.imageRef, image.options.drawInfo);

		DMagickException.throwException(&(image.imageRef.exception));
	}

	/**
	 * Transforms the coordinate system by a 3x3 transformation matrix.
	 */
	void affine(AffineMatrix matrix)
	{
		operations ~= format(" affine %s,%s,%s,%s,%s,%s",
			matrix.sx, matrix.rx, matrix.ry, matrix.sy, matrix.tx, matrix.ty);
	}

	/**
	 * Draws an arc within a rectangle.
	 */
	void arc(size_t startX, size_t startY, size_t endX, size_t endY, double startDegrees, double endDegrees)
	{
		operations ~= format(" arc %s,%s %s,%s %s,%s",
			startX, startY, endX, endY, startDegrees, endDegrees);
	}

//bezier
//border-color
//clip-path
//clip-rule
//clip-units
//circle
//color
//decorate
//ellipse
//encoding
//fill
//fill-opacity
//fill-rule
//font
//font-family
//font-size
//font-stretch
//font-style
//font-weight
//gradient-units
//gravity
//image
//interline-spacing
//interword-spacing
//kerning
//line
//matte
//offset
//opacity
//path
//point
//polyline
//polygon
//pop
//push
//rectangle
//rotate
//roundRectangle
//scale
//skewX
//skewY
//stop-color
//stroke
//stroke-antialias
//stroke-dasharray
//stroke-dashoffset
//stroke-linecap
//stroke-linejoin
//stroke-miterlimit
//stroke-opacity
//stroke-width
//text
//text-align
//text-anchor
//text-antialias
//text-undercolor
//translate
//viewbox
}
