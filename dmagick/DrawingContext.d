/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */

module dmagick.DrawingContext;

import dmagick.Color;
import dmagick.Exception;
import dmagick.Geometry;
import dmagick.Image;
import dmagick.Options;

import dmagick.c.draw;
import dmagick.c.geometry;
import dmagick.c.type;

/**
 * Drawable provides a convenient interface for preparing vector,
 * image, or text arguments.
 */
class DrawingContext
{
	private void delegate(Image)[] actions;

	/**
	 * Apply the drawing context to the image.
	 */
	void draw(Image image)
	{
		Options options = image.options.clone();

		foreach ( action; actions )
			action(image);

		image.options = options;

		//Make sure the ImageInfo an DrawInfo for these a in sync.
		image.backgroundColor = options.backgroundColor;
		image.borderColor = options.borderColor;
		image.fuzz = options.fuzz;
	}

	/**
	 * Specify a transformation matrix to adjust scaling, rotation, and
	 * translation (coordinate transformation) for subsequently drawn
	 * objects in the drawing context. 
	 */
	void affine(AffineMatrix affine)
	{
		actions ~= (Image image)
		{
			image.options.affine = affine;
		};
	}

	/**
	 * Transforms the image as specified by the affine matrix.
	 */
	void affineTransform(AffineMatrix affine)
	{
		actions ~= (Image image)
		{
			image.affineTransform(affine);
		};
	}

	/**
	 * Control antialiasing of rendered Postscript
	 * and Postscript or TrueType fonts. The default is true.
	 */
	void antialias(bool antialias)
	{
		actions ~= (Image image)
		{
			image.options.antialias = antialias;
		};
	}

	/**
	 * Set the image background color. The default is "white".
	 */
	void backgroundColor(Color color)
	{
		actions ~= (Image image)
		{
			image.backgroundColor = color;
		};
	}

	/**
	 * Set the image border color. The default is "#dfdfdf".
	 */
	void borderColor(string color)
	{
		actions ~= (Image image)
		{
			image.borderColor = color;
		};
	}


	/**
	 * If set, causes the text to be drawn over a box of the specified color.
	 */
	void boxColor(Color color)
	{
		actions ~= (Image image)
		{
			image.options.boxColor = color;
		};
	}

	/**
	 * Color to use when filling drawn objects.
	 * The default is "black".
	 */
	void fillColor(Color color)
	{
		actions ~= (Image image)
		{
			image.options.fillColor = color;
		};
	}

	/**
	 * Pattern image to use when filling drawn objects.
	 */
	void fillPattern(Image pattern)
	{
		actions ~= (Image image)
		{
			image.options.fillPattern = pattern;
		};
	}

	/**
	 * Rule to use when filling drawn objects.
	 */
	void fillRule(FillRule rule)
	{
		actions ~= (Image image)
		{
			image.options.fillRule = rule;
		};
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
	void font(string str)
	{
		actions ~= (Image image)
		{
			image.options.font = str;
		};
	}

	/**
	 * Specify font family, style, weight (one of the set { 100 | 200 |
	 * 300 | 400 | 500 | 600 | 700 | 800 | 900 } with 400 being the normal
	 * size), and stretch to be used to select the font used when drawing
	 * text. Wildcard matches may be applied to style via the AnyStyle
	 * enumeration, applied to weight if weight is zero, and applied to
	 * stretch via the AnyStretch enumeration.
	 */
	void font(string family, StyleType style = StyleType.NormalStyle, size_t weight = 400, StretchType stretch = StretchType.NormalStretch)
	{
		actions ~= (Image image)
		{
			image.options.fontFamily  = family;
			image.options.fontStyle   = style;
			image.options.fontWeight  = weight;
			image.options.fontStretch = stretch;
		};
	}

	/**
	 * Colors within this distance are considered equal. 
	 * A number of algorithms search for a target  color.
	 * By default the color must be exact. Use this option to match
	 * colors that are close to the target color in RGB space.
	 */
	void fuzz(double f)
	{
		actions ~= (Image image)
		{
			image.fuzz = f;
		};
	}

	/**
	 * Draw a line from start to end.
	 */
	void line(size_t startX, size_t startY, size_t endX, size_t endY)
	{
		actions ~= (Image image)
		{
			PrimitiveInfo[] primitiveInfo = new PrimitiveInfo[3];

			primitiveInfo[0].coordinates = 3;
			primitiveInfo[0].primitive = PrimitiveType.LinePrimitive;
			primitiveInfo[0].point = PointInfo(startX, startY);
			primitiveInfo[1].primitive = PrimitiveType.LinePrimitive;
			primitiveInfo[1].point = PointInfo(endX, endY);
			primitiveInfo[2].primitive = PrimitiveType.UndefinedPrimitive;

			DrawPrimitive(image.imageRef, image.options.drawInfo, primitiveInfo.ptr);

			DMagickException.throwException(&(image.imageRef.exception));
		};
	}

	/**
	 * Text rendering font point size
	 */
	void pointSize(double size)
	{
		actions ~= (Image image)
		{
			image.options.pointSize = size;
		};
	}

	/**
	 * Enable or disable anti-aliasing when drawing object outlines.
	 */
	void strokeAntialias(bool antialias)
	{
		actions ~= (Image image)
		{
			image.options.strokeAntialias = antialias;
		};
	}

	/**
	 * Color to use when drawing object outlines
	 */
	void strokeColor(Color color)
	{
		actions ~= (Image image)
		{
			image.options.strokeColor = color;
		};
	}

	/**
	 * The initial distance into the dash pattern. The units are pixels.
	 */
	void strokeDashOffset(double offset)
	{
		actions ~= (Image image)
		{
			image.options.strokeDashOffset = offset;
		};
	}

	/**
	 * Describe a _pattern of dashes to be used when stroking paths.
	 * The arguments are a list of pixel widths of
	 * alternating dashes and gaps.
	 * All elements must be > 0.
	 */
	void strokeDashPattern(const(double)[] pattern)
	{
		actions ~= (Image image)
		{
			image.options.strokeDashPattern = pattern;
		};
	}

	/**
	 * Specify how the line ends should be drawn.
	 */
	void strokeLineCap(LineCap cap)
	{
		actions ~= (Image image)
		{
			image.options.strokeLineCap = cap;
		};
	}

	/**
	 * Specify how corners are drawn.
	 */
	void strokeLineJoin(LineJoin join)
	{
		actions ~= (Image image)
		{
			image.options.strokeLineJoin = join;
		};
	}

	/**
	 * Specify a constraint on the length of the "miter"
	 * formed by two lines meeting at an angle. If the angle
	 * if very sharp, the miter could be very long relative
	 * to the line thickness. The miter _limit is a _limit on
	 * the ratio of the miter length to the line width.
	 * The default is 4.
	 */
	void strokeMiterlimit(size_t limit)
	{
		actions ~= (Image image)
		{
			image.options.strokeMiterlimit = limit;
		};
	}

	/**
	 * Pattern image to use while drawing object stroke
	 */
	void strokePattern(Image pattern)
	{
		actions ~= (Image image)
		{
			image.options.strokePattern = pattern;
		};
	}

	/**
	 * Stroke _width for use when drawing vector objects
	 */
	void strokeWidth(double width)
	{
		actions ~= (Image image)
		{
			image.options.strokeWidth = width;
		};
	}

	/**
	 * The text density in the x and y directions. The default is "72x72".
	 */
	void textDensity(Geometry geometry)
	{
		actions ~= (Image image)
		{
			image.options.textDensity = geometry;
		};
	}

	/**
	 * Specify the code set to use for text annotations.
	 * The only character encoding which may be specified at
	 * this time is "UTF-8" for representing Unicode as a
	 * sequence of bytes. Specify an empty string to use
	 * ASCII encoding. Successful text annotation using
	 * Unicode may require fonts designed to support Unicode.
	 * The default is "UTF-8"
	 */
	void textEncoding(string encoding)
	{
		actions ~= (Image image)
		{
			image.options.textEncoding = encoding;
		};
	}
}
