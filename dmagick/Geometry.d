/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */

module dmagick.Geometry;

import std.conv;
import std.ctype;
import std.string;
import core.sys.posix.sys.types;

import dmagick.c.geometry;
import dmagick.c.magickString;
import dmagick.c.magickType;

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
	 */
	//TODO: expand the documentation for this constructor.
	this(string geometry)
	{
		MagickStatusType flags;

		//If the string starts with a letter assume it's a Page Geometry.
		if ( isalpha(geometry[0]) )
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

	this(RectangleInfo rectangle)
	{
		this.width = rectangle.width;
		this.height = rectangle.height;
		this.xOffset = rectangle.x;
		this.yOffset = rectangle.y;
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

	RectangleInfo rectangleInfo()
	{
		RectangleInfo info;

		info.width  = width;
		info.height = height;
		info.x = xOffset;
		info.y = yOffset;

		return info;
	}

	int opCmp(ref const Geometry geometry)
	{
		return width*height - geometry.width*geometry.height;
	}
}
