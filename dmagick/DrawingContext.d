/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */

module dmagick.DrawingContext;

import std.array;
import std.conv;
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

	/**
	 * Draw a cubic Bezier curve.
	 * 
	 * The arguments are pairs of points. At least 4 pairs must be specified.
	 * Each point xn, yn on the curve is associated with a control point
	 * cxn, cyn. The first point, x1, y1, is the starting point. The last
	 * point, xn, yn, is the ending point. Other point/control point pairs
	 * specify intermediate points on a polybezier curve.
	 */
	void bezier(size_t x1, size_t y1, size_t cx1, size_t cy1,
		size_t cx2, size_t cy2, size_t x2, size_t y2,
		size_t[] points ...)
	in
	{
		assert ( points.length % 2 == 0,
			"bezier needs an even number of argumants, "~
			"each x coordinate needs a coresponding y coordinate." );
	}
	body
	{
		operations ~= format(" bezier %s,%s %s,%s %s,%s %s,%s",
			x1, y1, cx1, cy1, cx2, cy2, x2, y2);

		for( int i = 0; i < points.length; i+=2 )
			operations ~= format(" %s,%s", points[i], points[i+1]);
	}

	/**
	 * Set the image border color. The default is "#dfdfdf".
	 */
	void borderColor(Color color)
	{
		operations ~= format(" border-color %s", color);
	}

	/**
	 * Defines a clip-path. Within the delegate, call other drawing
	 * primitive methods (rectangle, polygon, text, etc.) to define the
	 * clip-path. The union of all the primitives (excluding the effects
	 * of rendering methods such as stroke_width, etc.) is the clip-path.
	 * 
	 * Params:
	 *     path = The delegate that defines the clip-path using
	 *            using the provided DrawingContext.
	 */
	void clipPath(void delegate(DrawingContext path) defineClipPath)
	{
		static size_t count;

		DrawingContext path = new DrawingContext();
		defineClipPath(path);

		operations ~= format(" push defs push clip-path path%s push graphic-context", count);
		operations ~= path.operations;
		operations ~= " pop graphic-context pop clip-path pop defs";
		operations ~= format(" clip-path url(#path%s)", count);

		count++;
	}

	/**
	 * Specify how to determine if a point on the image is inside
	 * clipping region.
	 * 
	 * See_Also: $(LINK2 http://www.w3.org/TR/SVG/painting.html#FillRuleProperty,
	 *     the 'fill-rule' property) in the Scalable Vector Graphics (SVG)
	 *     1.1 Specification.
	 */
	void clipRule(ClipPathRule rule)
	{
		if ( rule == ClipPathRule.EvenOdd)
			operations ~= " clip-rule evenodd";
		else
			operations ~= " clip-rule nonzero";
	}

	/**
	 * Defines the coordinate space within the clipping region.
	 * 
	 * See_Also: $(LINK2 http://www.w3.org/TR/SVG/masking.html#EstablishingANewClippingPath,
	 *     Establishing a New Clipping Path) in the
	 *     Scalable Vector Graphics (SVG) 1.1 Specification.
	 */
	void clipUnits(ClipPathUnits units)
	{
		operations ~= format( " clip-units %s", toLower(to!(string)(units)) );
	}

	unittest
	{
		auto dc = new DrawingContext();
		dc.clipUnits(ClipPathUnits.UserSpace);

		assert(dc.operations == " clip-units userspace");
	}

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
//stop-color for gradients.
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

enum ClipPathRule
{
	EvenOdd,
	NonZero
}
