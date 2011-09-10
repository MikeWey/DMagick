/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */

module dmagick.DrawingContext;

import std.algorithm;
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
	 * Specify if the text and stroke should be antialiased.
	 */
	void antialias(bool antialias)
	{
		strokeAntialias = antialias;
		textAntialias = antialias;
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
			"bezier needs an even number of arguments, "~
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
	void borderColor(const(Color) color)
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

		operations ~= format(" clip-rule %s", to!(string)(rule)[0 .. $-4]);
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
		if ( units == ClipPathUnits.UndefinedPathUnits )
			throw new DrawException("Undefined Path Unit");

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
			to!(string)(compositeOp)[0 .. $-11], xOffset, yOffset, width, height, filename);
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
	void fill(const(Color) fillColor)
	{
		operations ~= format(" fill %s", fillColor);
	}

	///ditto
	alias fill fillColor;

	/**
	 * Pattern to use when filling drawn objects.
	 */
	void fill(size_t x, size_t y, size_t width, size_t height, void delegate(DrawingContext path) pattern)
	{
		operations ~= format(" fill url(#%s)", definePattern(x, y, width, height, pattern));
	}
	
	///ditto
	alias fill fillPattern;

	/**
	 * The gradient to use when filling drawn objects.
	 */
	void fill(Gradient gradient)
	{
		operations ~= gradient.defineGradient();

		operations ~= format(" fill url(#%s)", gradient.id());
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

		operations ~= format(" fill-rule %s", to!(string)(rule)[0 .. $-4]);
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

		operations ~= format(" font-stretch %s", to!(string)(type)[0 .. $-7]);
	}

	/**
	 * Specify the font style, i.e. italic, oblique, or normal.
	 */
	void fontStyle(StyleType type)
	{
		if ( type == StyleType.UndefinedStyle )
			throw new DrawException("Undefined Style type");

		operations ~= format(" font-style %s", to!(string)(type)[0 .. $-5]);
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

		operations ~= format(" gravity %s", to!(string)(type)[0 .. $-7]);
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

	/**
	 * Draw a polygon.
	 * 
	 * The arguments are a sequence of 2 or more points. If the last
	 * point is not the same as the first, the polygon is closed by
	 * drawing a line from the last point to the first.
	 */
	void polygon(size_t[] points ...)
	in
	{
		assert ( points.length % 2 == 0,
			"polygon needs an even number of arguments, "~
			"each x coordinate needs a coresponding y coordinate." );
	}
	body
	{
		operations ~= " polygon";

		for( int i = 0; i < points.length; i+=2 )
			operations ~= format(" %s,%s", points[i], points[i+1]);
	}

	/**
	 * Draw a polyline. Unlike a polygon,
	 * a polyline is not automatically closed.
	 */
	void polyline(size_t[] points ...)
	in
	{
		assert ( points.length % 2 == 0,
			"polyline needs an even number of arguments, "~
			"each x coordinate needs a coresponding y coordinate." );
	}
	body
	{
		operations ~= " polyline";

		for( int i = 0; i < points.length; i+=2 )
			operations ~= format(" %s,%s", points[i], points[i+1]);
	}

	/**
	 * Restore the graphics context to the state it was in when
	 * push was called last.
	 */
	void pop()
	{
		operations ~= " pop graphic-context";
	}

	/**
	 * Save the current state of the graphics context, including the
	 * attribute settings and the current set of primitives. Use the
	 * pop primitive to restore the state.
	 */
	void push()
	{
		operations ~= " push graphic-context";
	}

	/**
	 * Draw a rectangle.
	 */
	void rectangle(size_t xStart, size_t yStart, size_t xEnd, size_t yEnd)
	{
		operations ~= format(" rectangle %s,%s %s,%s",
			xStart, yStart, xEnd, yEnd);
	}

	/**
	 * Specify a rotation transformation to the coordinate space.
	 */
	void rotate(double angle)
	{
		operations ~= format(" rotate %s", angle);
	}

	/**
	 * Draw a rectangle with rounded corners.
	 * 
	 * Params:
	 *     xStart       = The x coordinate for the upper left hand corner
	 *                    of the rectangle.
	 *     yStart       = The y coordinate for the upper left hand corner
	 *                    of the rectangle.
	 *     xEnd         = The x coordinate for the lower left hand corner
	 *                    of the rectangle.
	 *     yEnd         = The y coordinate for the lower left hand corner
	 *                    of the rectangle.
	 *     cornerWidth  = The width of the corner.
	 *     cornerHeight = The height of the corner.
	 */
	void roundRectangle(
		size_t xStart, size_t yStart,
		size_t xEnd, size_t yEnd,
		size_t cornerWidth, size_t cornerHeight)
	{
		operations ~= format(" roundRectangle %s,%s %s,%s %s,%s",
			xStart, yStart, xEnd, yEnd, cornerWidth, cornerHeight);
	}

	/**
	 * Define a scale transformation to the coordinate space.
	 */
	void scale(double xScale, double yScale)
	{
		operations ~= format(" scale %s,%s", xScale, yScale);
	}

	/**
	 * Define a skew transformation along the x-axis.
	 * 
	 * Params:
	 *     angle = The amount of skew, in degrees.
	 */
	void skewX(double angle)
	{
		operations ~= format(" skewX %s", angle);
	}

	/**
	 * Define a skew transformation along the y-axis.
	 * 
	 * Params:
	 *     angle = The amount of skew, in degrees.
	 */
	void skewY(double angle)
	{
		operations ~= format(" skewY %s", angle);
	}

	/**
	 * Color to use when drawing object outlines.
	 */
	void stroke(const(Color) strokeColor)
	{
		operations ~= format(" stroke %s", strokeColor);
	}

	///ditto
	alias stroke strokeColor;

	/**
	 * Pattern to use when filling drawn objects.
	 */
	void stroke(size_t x, size_t y, size_t width, size_t height, void delegate(DrawingContext path) pattern)
	{
		operations ~= format(" stroke url(#%s)", definePattern(x, y, width, height, pattern));
	}
	
	///ditto
	alias stroke strokePattern;

	/**
	 * The gradient to use when filling drawn objects.
	 */
	void stroke(Gradient gradient)
	{
		operations ~= gradient.defineGradient();

		operations ~= format(" stroke url(#%s)", gradient.id());
	}

	/**
	 * Specify if the stroke should be antialiased.
	 */
	void strokeAntialias(bool antialias)
	{
		operations ~= format(" stroke-antialias %s", (antialias ? 1 : 0));
	}

	/**
	 * Describe a pattern of dashes to be used when stroking paths.
	 * The arguments are a list of pixel widths of alternating
	 * dashes and gaps.
	 * 
	 * The first argument is the width of the first dash. The second is
	 * the width of the gap following the first dash. The third argument
	 * is another dash width, followed by another gap width, etc.
	 */
	void strokeDashArray(const(double)[] dashArray ...)
	{
		if ( dashArray.length == 0 )
		{
			operations ~= " stroke-dasharray none";
		}
		else
		{
			operations ~= format(" stroke-dasharray %s",
				array(joiner(map!"to!(string)(a)"(dashArray), ",")) );
		}
	}

	unittest
	{
		auto dc = new DrawingContext();
		dc.strokeDashArray(10, 10, 10);

		assert(dc.operations == " stroke-dasharray 10,10,10");
	}

	/**
	 * Specify the initial distance into the dash pattern.
	 */
	void strokeDashOffset(double offset)
	{
		operations ~= format(" stroke-dashoffset %s", offset);
	}

	/**
	 * Specify how the line ends should be drawn.
	 */
	void strokeLineCap(LineCap cap)
	{
		if ( cap == LineCap.UndefinedCap )
			throw new DrawException("Undefined Line cap.");

		operations ~= format(" stroke-linecap %s", to!(string)(cap)[0 .. $-3]);
	}

	/**
	 * Specify how corners are drawn.
	 */
	void strokeLineJoin(LineJoin join)
	{
		if ( join == LineJoin.UndefinedJoin )
			throw new DrawException("Undefined Line join.");

		operations ~= format(" stroke-linejoin %s", to!(string)(join)[0 .. $-4]);
	}

	/**
	 * Specify a constraint on the length of the "miter"
	 * formed by two lines meeting at an angle. If the angle
	 * if very sharp, the miter could be very long relative
	 * to the line thickness. The miter _limit is a _limit on
	 * the ratio of the miter length to the line width.
	 * The default is 4.
	 */
	void strokeMiterLimit(size_t limit)
	{
		operations ~= format(" stroke-miterlimit %s", limit);
	}

	/**
	 * Specify the stroke opacity.
	 * 
	 * Params:
	 *     opacity = A number between 0 and 1.
	 */
	void strokeOpacity(double opacity)
	in
	{
		assert(opacity >= 0);
		assert(opacity <= 1);
	}
	body
	{
		operations ~= format(" stroke-opacity %s", opacity);
	}

	/**
	 * Specify the stroke width in pixels. The default is 1.
	 */
	void strokeWidth(double width)
	{
		operations ~= format(" stroke-width %s", width);
	}

	/**
	 * Draw text at the location specified by (x,y). Use gravity to
	 * position text relative to (x, y). Specify the font appearance
	 * with the font, fontFamily, fontStretch, fontStyle, and fontWeight
	 * properties. Specify the text attributes with the textAlign,
	 * textAnchor, textAntialias, and textUndercolor properties.
	 * 
	 * To include a '%' in the text, use '%%'.
	 * 
	 * See_Also: Image.annotate for the image properties you can
	 *     include in the string.
	 */
	void text(size_t x, size_t y, string text)
	{
		operations ~= format(" text %s,%s %s", x, y, escapeText(text));
	}

	/**
	 * Align text relative to the starting point.
	 */
	void textAlign(AlignType type)
	{
		if ( type == AlignType.UndefinedAlign )
			throw new DrawException("Undefined Align type.");

		operations ~= format(" text-align %s", to!(string)(type)[0 .. $-5]);

	}

	/**
	 * Specify if the text should be antialiased.
	 */
	void textAntialias(bool antialias)
	{
		operations ~= format(" text-antialias %s", (antialias ? 1 : 0));
	}

	/**
	 * If set, causes the text to be drawn over a box of the specified color.
	 */
	void textUnderColor(Color color)
	{
		operations ~= format(" text-undercolor %s", color);
	}

	///ditto
	alias textUnderColor boxColor;

	/**
	 * Specify a translation operation on the coordinate space.
	 */
	void translate(size_t x, size_t y)
	{
		operations ~= format(" translate %s,%s", x, y);
	}

	/**
	 * Generate to operations for the profide pattern.
	 */
	private string definePattern(size_t x, size_t y, size_t width, size_t height, void delegate(DrawingContext path) pattern)
	{
		static size_t count;
		count++;

		DrawingContext patt = new DrawingContext();
		pattern(patt);

		operations ~= format(" push defs push pattern patt%s %s,%s %s,%s push graphic-context", count, x, y, width, height);
		operations ~= patt.operations;
		operations ~= " pop graphic-context pop pattern pop defs";

		return format("patt%s", count);
	}

	/**
	 * Escape the text so it can be added to the operations string.
	 */
	private static string escapeText(string text)
	{
		string escaped;

		//reserve text.lengt + 10% to avoid realocating when appending.
		escaped.reserve(cast(size_t)(text.length * 0.1));
		escaped ~= '\"';

		foreach ( c; text )
		{
			if ( c == '\"' || c == '\\' )
				escaped ~= '\\';

			escaped ~= c;
		}

		escaped ~= '\"';

		return escaped;
	}

	unittest
	{
		assert(escapeText(q{Hello world})       == q{"Hello world"});
		assert(escapeText(q{"Hello world"})     == q{"\"Hello world\""});
		assert(escapeText(q{"\"Hello world\""}) == q{"\"\\\"Hello world\\\"\""});
	}

	/**
	 * Save the image in the temp directory and return the filename.
	 */
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
 *
 */
struct Gradient
{
	private static size_t count;
	private size_t currentCount;

	//Is the id to use this gradient already set.
	private bool isDefined = false;

	GradientType  type;
	GradientUnits units;
	double x1, y1, x2, y2, radius;
	StopColor[] stopColors;

	/**
	 * Define a linear gradient.
	 * 
	 * x1, y1, x2 and y2 define a gradient vector for the linear gradient.
	 * This gradient vector provides starting and ending points onto which
	 * the gradient stops are mapped. The values of x1, y1, x2 and y2 can
	 * be either numbers or percentages.
	 */
	static Gradient linear(double x1, double y1, double x2, double y2)
	{
		Gradient gradient;

		gradient.type = GradientType.LinearGradient;

		gradient.currentCount = count++;
		gradient.x1 = x1;
		gradient.y1 = y1;
		gradient.x2 = x2;
		gradient.y2 = y2;

		return gradient;
	}

	/**
	 * Define a radial gradient.
	 * 
	 * cx, cy and r define the largest (i.e., outermost) circle for the
	 * radial gradient. The gradient will be drawn such that the 100%
	 * gradient stop is mapped to the perimeter of this largest
	 * (i.e., outermost) circle.
	 * 
	 * Params:
	 *     xCenter = x coordinate for the center of the circle.
	 *     yCenter = y coordinate for the center of the circle.
	 *     xFocal  = x coordinate the focal point for the radial gradient.
	 *               The gradient will be drawn such that the 0% gradient
	 *               stop is mapped to (xFocal, yFocal).
	 *     yFocal  = y coordinate the focal point
	 *     radius  = The radius of the gradient. A value of zero will cause
	 *               the area to be painted as a single color using the
	 *               color and opacity of the last gradient stop.
	 */
	static Gradient radial(double xCenter, double yCenter, double xFocal, double yFocal, double radius)
	{
		Gradient gradient;

		gradient.type = GradientType.RadialGradient;

		gradient.currentCount = count++;
		gradient.x1 = xCenter;
		gradient.y1 = yCenter;
		gradient.x2 = xFocal;
		gradient.y2 = yFocal;
		gradient.radius = radius;

		return gradient;
	}

	/**
	 * Define a radial gradient.
	 * 
	 * The same as above but with the focal point at
	 * the center of the circle.
	 */
	static Gradient radial(double xCenter, double yCenter, double radius)
	{
		return radial(xCenter, yCenter, xCenter, yCenter, radius);
	}

	/**
	 * Defines the coordinate system to use.
	 */
	Gradient gradientUnits(GradientUnits units)
	{
		this.units = units;

		return this;
	}

	/**
	 * Define the color to use, and there offsets in the gradient.
	 * 
	 * Params:
	 *     color  = The color to use at this stop.
	 *     offset = For linear gradients, the offset attribute represents
	 *              a location along the gradient vector. For radial
	 *              gradients, it represents a percentage distance
	 *              from (fx,fy) to the edge of the outermost/largest circle.
	 *              offset should bwe between 0 and 1.
	 */
	Gradient stopColor(Color color, double offset)
	{
		stopColors ~= StopColor(color, offset);

		return this;
	}

	/**
	 * Generate the string used to define this gradient.
	 */
	private string defineGradient()
	{
		if ( isDefined )
			return "";

		string operations = " push defs";

		if ( type == GradientType.LinearGradient )
		{
			operations ~= format(" push gradient grad%s linear %s,%s %s,%s",
				currentCount, x1, y1, x2, y2);
		}
		else
		{
			operations ~= format(" push gradient grad%s radial %s,%s %s,%s $s",
				currentCount, x1, y1, x2, y2, radius);
		}

		if ( units != GradientUnits.Undefined )
			operations ~= format(" gradient-units %s", units);

		foreach ( stop; stopColors )
		{
			operations ~= format(" stop-color %s %s", stop.color, stop.offset);
		}

		operations ~= " pop gradient pop defs";

		return operations;
	}

	/**
	 * If the gradient is defined, this id is neded to use it.
	 */
	private string id()
	{
		return format("grad%s", currentCount);
	}

	private struct StopColor
	{
		Color color;
		double offset;
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

/**
 * Defines the coordinate system to use for Gradients.
 */
enum GradientUnits : string
{
	/**
	 * No coordinate systewm defined.
	 */
	Undefined         = "",

	/**
	 * The values supplied to Gradient represent values in the coordinate
	 * system that results from taking the current user coordinate system
	 * in place at the time when the gradient element is referenced.
	 */
	UserSpace         = "userSpace",

	/**
	 * The user coordinate system for the values supplied to Gradient is
	 * established using the bounding box of the element to which the
	 * gradient is applied.
	 */
	UserSpaceOnUse    = "userSpaceOnUse",

	/**
	 * The normal of the linear gradient is perpendicular to the gradient
	 * vector in object bounding box space. When the object's bounding box
	 * is not square, the gradient normal which is initially perpendicular
	 * to the gradient vector within object bounding box space may render
	 * non-perpendicular relative to the gradient vector in user space.
	 * If the gradient vector is parallel to one of the axes of the bounding
	 * box, the gradient normal will remain perpendicular.
	 * This transformation is due to application of the non-uniform scaling
	 * transformation from bounding box space to user space.
	 */
	ObjectBoundingBox = "objectBoundingBox",
}
