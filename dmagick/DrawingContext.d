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
		if ( rule == FillRule.UndefinedRule )
			throw new DrawException("Undefined Fill Rule");

		operations ~= format(" clip-rule %s", to!(string)(rule)[0 .. 4]);
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

	/**
	 * Composite filename/image with the receiver image.
	 * 
	 * Params:
	 *     xOffset     = The x-offset of the composited image,
	 *                   measured from the upper-left corner
	 *                   of the image.
	 *     yOffset     = The y-offset of the composited image,
	 *                   measured from the upper-left corner
	 *                   of the image.
	 *     width       = Scale the composite image to this size.
	 *                   If value is 0, the composite image is not scaled.
	 *     height      = Scale the composite image to this size.
	 *                   If value is 0, the composite image is not scaled.
	 *     filename    = Filename of the mage to use in the
	 *                   composite operation.
	 *     image       = Image to use in the composite operation.
	 *     compositeOp = The composite operation to use.
	 */
	void composite(
		ssize_t xOffset,
		ssize_t yOffset,
		size_t width,
		size_t height,
		string filename,
		CompositeOperator compositeOp = CompositeOperator.OverCompositeOp)
	{
		if ( compositeOp == CompositeOperator.UndefinedCompositeOp)
			throw new DrawException("Undefined Composite Operator");

		operations  ~= format(" image %s %s,%s %s,%s '%s'",
			to!(string)(compositeOp)[0 .. 11], xOffset, yOffset, width, height, filename);
	}

	///ditto
	void composite(
		ssize_t xOffset,
		ssize_t yOffset,
		size_t width,
		size_t height,
		Image image,
		CompositeOperator compositeOp = CompositeOperator.OverCompositeOp)
	{
		if ( image.filename !is null && image.filename.exists && !image.changed )
		{
			composite(xOffset, yOffset, width, height, image.filename, compositeOp);
			return;
		}

		string filename = saveTempFile(image);

		composite(xOffset, yOffset, width, height, filename, compositeOp);
	}

	/**
	 * Specify text decoration.
	 */
	void decorate(DecorationType decoration)
	{
		//TODO: support oring decorations together.
		operations ~= " decorate ";

		final switch ( decoration )
		{
			case DecorationType.NoDecoration:
				operations ~= "none";         break;
			case DecorationType.UnderlineDecoration:
				operations ~= "underline";    break;
			case DecorationType.OverlineDecoration:
				operations ~= "overline";     break;
			case DecorationType.LineThroughDecoration:
				operations ~= "line-through"; break;

			case DecorationType.UndefinedDecoration:
				throw new DrawException("Undefined Decoration");
				break;
		}
	}

	/**
	 * Draw an ellipse.
	 * 
	 * Params:
	 *     xOrigin      = The x coordinate of the ellipse.
	 *     yOrigin      = The y coordinate of the ellipse.
	 *     width        = The horizontal radii. 
	 *     height       = The vertical radii.
	 *     startDegrees = Where to start the ellipse.
	 *                    0 degrees is at 3 o'clock.
	 *     endDegrees   = Whare to end the ellipse.
	 */
	void ellipse(size_t xOrigin, size_t yOrigin, size_t width, size_t height, double startDegrees, double endDegrees)
	{
		operations ~= format(" ellipse %s,%s %s,%s %s,%s",
			xOrigin, yOrigin, width, height, startDegrees, endDegrees);
	}

	/**
	 * Specify the font encoding.
	 * Note: This specifies the character repertory (i.e., charset),
	 * and not the text encoding method (e.g., UTF-8, UTF-16, etc.).
	 */
	void encoding(FontEncoding encoding)
	{
		operations ~= format(" encoding %s", encoding);
	}

	unittest
	{
		auto dc = new DrawingContext();
		dc.encoding(FontEncoding.Latin1);

		assert(dc.operations == " encoding Latin-1");
	}

	/**
	 * Color to use when filling drawn objects.
	 * The default is "black".
	 */
	void fill(Color fillColor)
	{
		operations ~= format(" fill %s", fillColor);
	}

	/**
	 * Specify the fill opacity.
	 * 
	 * Params:
	 *     opacity = A number between 0 and 1.
	 */
	void fillOpacity(double opacity)
	in
	{
		assert(opacity >= 0);
		assert(opacity <= 1);
	}
	body
	{
		operations ~= format(" fill-opacity %s", opacity);
	}

	/**
	 * Specify how to determine if a point on the image is inside a shape.
	 * 
	 * See_Also: $(LINK2 http://www.w3.org/TR/SVG/painting.html#FillRuleProperty,
	 *     the 'fill-rule' property) in the Scalable Vector Graphics (SVG)
	 *     1.1 Specification.
	 */
	void fillRule(FillRule rule)
	{
		if ( rule == FillRule.UndefinedRule )
			throw new DrawException("Undefined Fill Rule");

		operations ~= format(" fill-rule %s", to!(string)(rule)[0 .. 4]);
	}

	/**
	 * The _font name or filename.
	 * You can tag a _font to specify whether it is a Postscript,
	 * Truetype, or OPTION1 _font. For example, Arial.ttf is a
	 * Truetype _font, ps:helvetica is Postscript, and x:fixed is OPTION1.
	 * 
	 * The _font name can be a complete filename such as
	 * "/mnt/windows/windows/fonts/Arial.ttf". The _font name can
	 * also be a fully qualified X font name such as
	 * "-urw-times-medium-i-normal--0-0-0-0-p-0-iso8859-13".
	 */
	void font(string font)
	{
		operations ~= format(" font '%s'", font);
	}

	/**
	 * Specify the font family, such as "arial" or "helvetica".
	 */
	void fontFamily(string family)
	{
		operations ~= format(" font-family '%s'", family);
	}	

	/**
	 * Text rendering font point size
	 */
	void fontSize(double pointSize)
	{
		operations ~= format(" font-size %s", pointSize);
	}

	/**
	 * Specify the spacing between text characters.
	 */
	void fontStretch(StretchType type)
	{
		if ( type == StretchType.UndefinedStretch )
			throw new DrawException("Undefined Stretch type");

		operations ~= format(" font-stretch %s", to!(string)(type)[0 .. 7]);
	}

	/**
	 * Specify the font style, i.e. italic, oblique, or normal.
	 */
	void fontStyle(StyleType type)
	{
		if ( type == StyleType.UndefinedStyle )
			throw new DrawException("Undefined Style type");

		operations ~= format(" font-style %s", to!(string)(type)[0 .. 5]);
	}

	/**
	 * Specify the font weight.
	 * 
	 * Eighter use the FontWeight enum or specify a number
	 * between 100 and 900.
	 */
	void fontWeight(size_t weight)
	{
		operations ~= format("font-weight %s", weight);		
	}

	///ditto
	void fontWeight(FontWeight weight)
	{
		operations ~= format("font-weight %s", weight);
	}

	/**
	 * Specify how the text is positioned. The default is NorthWestGravity.
	 */
	void gravity(GravityType type)
	{
		if ( type == GravityType.UndefinedGravity )
			throw new DrawException("Undefined Gravity type");

		operations ~= format(" gravity %s", to!(string)(type)[0 .. 7]);
	}

	/**
	 * Modify the spacing between lines when text has multiple lines.
	 * 
	 * If positive, inserts additional space between lines. If negative,
	 * removes space between lines. The amount of space inserted
	 * or removed depends on the font.
	 */
	void interlineSpacing(double spacing)
	{
		operations ~= format(" interline-spacing %s", spacing);
	}

	/**
	 * Modify the spacing between words in text.
	 * 
	 * If positive, inserts additional space between words. If negative,
	 * removes space between words. The amount of space inserted
	 * or removed depends on the font.
	 */
	void interwordSpacing(double spacing)
	{
		operations ~= format(" interword-spacing %s", spacing);
	}

	/**
	 * Modify the spacing between letters in text.
	 * 
	 * If positive, inserts additional space between letters. If negative,
	 * removes space between letters. The amount of space inserted or
	 * removed depends on the font but is usually measured in pixels. That
	 * is, the following call adds about 5 pixels between each letter.
	 */
	void kerning(double kerning)
	{
		operations ~= format(" kerning %s", kerning);
	}

	/**
	 * Draw a line from start to end.
	 */
	void line(size_t xStart, size_t yStart, size_t xEnd, size_t yEnd)
	{
		operations ~= format(" line %s,%s %s,%s",
			xStart, yStart, xEnd, yEnd);
	}

	/**
	 * Make the image transparent according to the specified
	 * PaintMethod constant.
	 * 
	 * If you use the PaintMethod.FillToBorderMethod, assign the border
	 * color with the DrawingContext.borderColor property.
	 */
	void matte(size_t x, size_t y, PaintMethod method)
	{
		if ( method == PaintMethod.UndefinedMethod )
			throw new DrawException("Undefined Paint Method");
		
		operations ~= format(" matte %s,%s %s", x, y, to!(string)(method)[0 .. $-6]);
	}

	/**
	 * Specify the fill and stroke opacities.
	 * 
	 * Params:
	 *     opacity = A number between 0 and 1.
	 */
	void opacity(double opacity)
	in
	{
		assert(opacity >= 0);
		assert(opacity <= 1);
	}
	body
	{
		operations ~= format(" opacity %s", opacity);
	}

	/**
	 * Draw using SVG-compatible path drawing commands.
	 * 
	 * See_Also: "$(LINK2 http://www.w3.org/TR/SVG/paths.html,
	 *     Paths)" in the Scalable Vector Graphics (SVG) 1.1 Specification. 
	 */
	void path(string svgPath)
	{
		operations ~= " path "~svgPath;
	}

	/**
	 * Set the pixel at x,y to the fill color.
	 */
	void point(size_t x, size_t y)
	{
		operations ~= format(" point %s,%s", x,y);
	}

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

//For gradients:
//gradient-units
//stop-color

//Does this do anything?
//offset

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
				tempPath = buildPath(getenv("USERPROFILE"), "AppData/Local/Temp");
			if ( tempPath is null || !tempPath.exists )
				tempPath = buildPath(getenv("WinDir"), "Temp");
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
			filename = buildPath(tempPath, "DMagick."~to!(string)(Clock.currTime().stdTime));

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

/**
 * This enumeration lists specific character repertories (i.e., charsets),
 * and not text encoding methods (e.g., UTF-8, UTF-16, etc.).
 */
enum FontEncoding : string
{
	AdobeCustom   = "AdobeCustom",    ///
	AdobeExpert   = "AdobeExpert",    ///ditto
	AdobeStandard = "AdobeStandard",  ///ditto
	AppleRoman    = "AppleRoman",     ///ditto
	BIG5     = "BIG5",                ///ditto
	GB2312   = "GB2312",              ///ditto
	Johab    = "Johab",               ///ditto
	Latin1   = "Latin-1",             ///ditto
	Latin2   = "Latin-2",             ///ditto
	None     = "None",                ///ditto
	SJIScode = "SJIScode",            ///ditto
	Symbol   = "Symbol",              ///ditto
	Unicode  = "Unicode",             ///ditto
	Wansung  = "Wansung",             ///ditto
}

/**
 * The font weight can be specified as one of 100, 200, 300, 400, 500,
 * 600, 700, 800, or 900, or one of the following constants.
 */
enum FontWeight : string
{
        Any     = "all",     /// No weight specified.
        Normal  = "normal",  /// Normal weight, equivalent to 400.
        Bold    = "bold",    /// Bold. equivalent to 700. 
        Bolder  = "bolder",  /// Increases weight by 100.
        Lighter = "lighter", /// Decreases weight by 100.
}
