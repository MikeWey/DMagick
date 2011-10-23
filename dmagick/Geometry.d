/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */

module dmagick.Geometry;

import std.conv;
import std.ascii;
import std.string;

import dmagick.c.geometry;
import dmagick.c.magickString;
import dmagick.c.magickType;

alias ptrdiff_t ssize_t;

/**
 * Geometry provides a convenient means to specify a geometry argument.
 */
struct Geometry
{
	size_t width;    ///
	size_t height;   ///
	ssize_t xOffset; ///
	ssize_t yOffset; ///
	bool percent;    /// The width and/or height are percentages of the original.
	bool minimum;    /// The specified width and/or height is the minimum value.
	bool keepAspect = true;  ///Retain the aspect ratio.
	bool greater;    /// Resize only if the image is greater than the width and/or height.
	bool less;       /// Resize only if the image is smaller than the width and/or height.

	/**
	 * Create a Geometry form a Imagemagick / X11 geometry string.
	 * 
	 * The string constist of a size and a optional offset, the size
	 * can be a width, a height (prefixed with an x), or both
	 * ( $(D widthxheight) ).
	 * 
	 * When a offset is needed ammend the size with an x an y offset
	 * ( signs are required ) like this: $(D {size}+x+Y).
	 * 
	 * The way the size is interpreted can be determined by the
	 * following flags:
	 * 
	 * $(TABLE 
	 *     $(HEADERS Flag,   Explanation)
	 *     $(ROW     $(D %), Normally the attributes are treated as pixels.
	 *                       Use this flag when the width and height
	 *                       attributes represent percentages.)
	 *     $(ROW     $(D !), Use this flag when you want to force the new
	 *                       image to have exactly the size specified by the
	 *                       the width and height attributes.)
	 *     $(ROW     $(D <), Use this flag when you want to change the size
	 *                       of the image only if both its width and height
	 *                       are smaller the values specified by those
	 *                       attributes. The image size is changed
	 *                       proportionally.)
	 *     $(ROW     $(D >), Use this flag when you want to change the size
	 *                       of the image if either its width and height
	 *                       exceed the values specified by those attributes.
	 *                       The image size is changed proportionally.)
	 *     $(ROW     $(D ^), Use ^ to set a minimum image size limit. The
	 *                       geometry $(D 640x480^) means the image width
	 *                       will not be less than 640 and the image height
	 *                       will not be less than 480 pixels after the
	 *                       resize. One of those dimensions will match
	 *                       the requested size. But the image will likely
	 *                       overflow the space requested to preserve its
	 *                       aspect ratio.)
	 * )
	 */
	this(string geometry)
	{
		MagickStatusType flags;

		//If the string starts with a letter assume it's a Page Geometry.
		if ( isAlpha(geometry[0]) )
		{
			char* geo = GetPageGeometry(toStringz(geometry));

			if( geo !is null )
			{
				geometry = to!(string)(geo);
				DestroyString(geo);
			}
		}

		flags = GetGeometry(toStringz(geometry), &xOffset, &yOffset, &width, &height);

		percent    = ( flags & GeometryFlags.PercentValue ) != 0;
		minimum    = ( flags & GeometryFlags.MinimumValue ) != 0;
		keepAspect = ( flags & GeometryFlags.AspectValue  ) == 0;
		greater    = ( flags & GeometryFlags.GreaterValue ) != 0;
		less       = ( flags & GeometryFlags.LessValue    ) != 0;
	}

	unittest
	{
		Geometry geo = Geometry("200x150-50+25!");
		assert( geo.width == 200 && geo.xOffset == -50 );
		assert( geo.keepAspect == false );

		geo = Geometry("A4");
		assert( geo.width == 595 && geo.height == 842);
	}

	/**
	 * Initialize with width heigt and offsets.
	 */
	this(size_t width, size_t height, ssize_t xOffset = 0, ssize_t yOffset = 0)
	{
		this.width   = width;
		this.height  = height;
		this.xOffset = xOffset;
		this.yOffset = yOffset;
	}

	/** */
	package this(RectangleInfo rectangle)
	{
		this.width = rectangle.width;
		this.height = rectangle.height;
		this.xOffset = rectangle.x;
		this.yOffset = rectangle.y;
	}

	/**
	 * Convert Geometry into a Imagemagick geometry string.
	 */
	string toString()
	{
		string geometry;

		if ( width > 0 )
			geometry ~= to!(string)(width);

		if ( height > 0 )
			geometry ~= "x" ~ to!(string)(height);

		geometry ~= format("%s%s%s%s%s",
			percent ? "%" : "",
			minimum ? "^" : "",
			keepAspect ? "" : "!",
			less ? "<" : "",
			greater ? ">" : "");

		if ( xOffset != 0 && yOffset != 0 )
			geometry ~= format("%+s%+s", xOffset, yOffset);

		return geometry;
	}

	unittest
	{
		Geometry geo = Geometry("200x150!-50+25");
		assert( geo.toString == "200x150!-50+25");
	}

	/**
	 * Calculate the absolute width and height based on the flags,
	 * and the profided width and height.
	 */
	Geometry toAbsolute(size_t width, size_t height)
	{
		ssize_t x, y;

		ParseMetaGeometry(toStringz(toString()), &x, &y, &width, &height);

		return Geometry(width, height, x, y);
	}

	unittest
	{
		Geometry percentage = Geometry("50%");
		Geometry absolute = percentage.toAbsolute(100, 100);

		assert(absolute.width  == 50);
		assert(absolute.height == 50);
	}

	/** */
	package RectangleInfo rectangleInfo()
	{
		RectangleInfo info;

		info.width  = width;
		info.height = height;
		info.x = xOffset;
		info.y = yOffset;

		return info;
	}

	/** */
	size_t opCmp(ref const Geometry geometry)
	{
		return width*height - geometry.width*geometry.height;
	}
}
