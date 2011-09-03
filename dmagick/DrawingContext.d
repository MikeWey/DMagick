/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */

module dmagick.DrawingContext;

import std.array;
import std.conv;
import std.file;
import std.string;
import core.sys.posix.sys.types;

import dmagick.Color;
import dmagick.Exception;
import dmagick.Geometry;
import dmagick.Image;
import dmagick.Options;
import dmagick.Utils;

import dmagick.c.composite;
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
		scope(exit) copyString(image.options.drawInfo.primitive, null);

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
	void clipRule(FillRule rule)
	{
		final switch ( rule )
		{
			case FillRule.EvenOddRule:
				operations ~= " clip-rule evenodd";
				break;
			case FillRule.NonZeroRule:
				operations ~= " clip-rule nonzero";
				break;
			case FillRule.UndefinedRule: 
				throw new DrawException("Undefined Fill Rule");
				break;
		}
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

	/**
	 * Draw a circle.
	 * 
	 * Params:
	 *     xOrigin    = The x coordinate for the center of the circle.
	 *     yOrigin    = The y coordinate for the center of the circle.
	 *     xPerimeter = The x coordinate for a point on the perimeter of
	 *                  the circle.
	 *     yPerimeter = The x coordinate for a point on the perimeter of
	 *                  the circle.
	 */
	void circle(size_t xOrigin, size_t yOrigin, size_t xPerimeter, size_t yPerimeter)
	{
		operations ~= format(" circle %s,%s %s,%s",
			xOrigin, yOrigin, xPerimeter, yPerimeter);
	}

	///ditto
	void circle(size_t xOrigin, size_t yOrigin, size_t radius)
	{
		circle(xOrigin, yOrigin, xOrigin, yOrigin + radius);
	}

	/**
	 * Set color in image according to the specified PaintMethod constant.
	 * If you use the PaintMethod.FillToBorderMethod, assign the border
	 * color with the DrawingContext.borderColor property.
	 */
	void color(size_t x, size_t y, PaintMethod method)
	{
		if ( method == PaintMethod.UndefinedMethod )
			throw new DrawException("Undefined Paint Method");
		
		operations ~= format(" color %s,%s %s", x, y, to!(string)(method)[0 .. $-6]);
	}

	void composite(
		ssize_t xOffset,
		ssize_t yOffset,
		size_t width,
		size_t height,
		string filename,
		CompositeOperator compositeOp)
	{
		if ( compositeOp == CompositeOperator.UndefinedCompositeOp)
			throw new DrawException("Undefined Composite Operator");

		operations  ~= format(" image %s %s,%s %s,%s '%s'",
			to!(string)(compositeOp)[0 .. 11], xOffset, yOffset, width, height, filename);
	}

	void composite(
		ssize_t xOffset,
		ssize_t yOffset,
		size_t width,
		size_t height,
		Image image,
		CompositeOperator compositeOp)
	{
		if ( image.filename !is null && image.filename.exists && !image.changed )
		{
			composite(xOffset, yOffset, width, height, image.filename, compositeOp);
			return;
		}

		string filename = saveTempFile(image);

		composite(xOffset, yOffset, width, height, filename, compositeOp);
	}

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

	private static string saveTempFile(Image image)
	{
		import std.datetime;
		import std.path;
		import std.process;
		import core.runtime;

		string tempPath;
		string filename;

		version(Windows)
		{
			tempPath = getenv("TMP");
			if ( tempPath is null )
				tempPath = getenv("TEMP");
			if ( tempPath is null )
				tempPath = join(getenv("USERPROFILE"), "AppData/Local/Temp");
			if ( tempPath is null || !tempPath.exists )
				tempPath = join(getenv("WinDir"), "Temp");
		}
		else
		{
			import core.sys.posix.stdio;

			tempPath = getenv("TMPDIR");
			if ( tempPath is null )
				tempPath = P_tmpdir;
		}

		do
		{
			filename = join(tempPath, "DMagick."~to!(string)(Clock.currTime().stdTime));

			if ( image.magick !is null && toLower(image.magick) != "canvas" )
				filename ~= "."~image.magick;
			else
				filename ~= ".png";
		}
		while ( filename.exists )

		image.write(filename);

		return filename;
	}

	unittest
	{
		auto image = new Image(Geometry(200, 200), new Color("blue"));
		string filename = saveTempFile(image);

		assert(filename.exists);

		remove(filename);
	}
}
