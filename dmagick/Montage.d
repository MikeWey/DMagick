/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 * 
 * A montage is a single image which is composed of thumbnail images
 * composed in a uniform grid. The size of the montage image is determined
 * by the size of the individual thumbnails and the number of rows and
 * columns in the grid.
 */

module dmagick.Montage;

import std.conv;

import dmagick.Color;
import dmagick.Geometry;
import dmagick.Utils;

import dmagick.c.geometry;
import dmagick.c.memory;
import dmagick.c.montage;

/**
 * Montage is used to provide montage options and provides methods
 * to set all options required to render simple (unframed) montages.
 */
class Montage
{
	alias RefCounted!( DestroyMontageInfo, MontageInfo ) MontageInfoRef;

	MontageInfoRef montageInfoRef;

	/** */
	this()
	{
		montageInfoRef = MontageInfoRef(cast(MontageInfo*)AcquireMagickMemory(MontageInfo.sizeof));
	}

	/**
	 * Specifies the background color that thumbnails are imaged upon.
	 */
	void backgroundColor(Color color)
	{
		montageInfoRef.background_color = color.pixelPacket;
	}
	///ditto
	Color backgroundColor()
	{
		return new Color(montageInfoRef.background_color);
	}

	/**
	 * Specifies the maximum number of columns in the montage.
	 */
	void columns(size_t columns)
	{
		Geometry size;

		if ( montageInfoRef.tile !is null )
			size = Geometry( to!(string)(montageInfoRef.tile) );

		size.width = columns;
	}
	///ditto
	size_t columns()
	{
		Geometry size;

		if ( montageInfoRef.tile !is null )
			size = Geometry( to!(string)(montageInfoRef.tile) );

		return size.width;
	}

	/**
	 * Specifies the fill color to use for the label text.
	 */
	void fillColor(Color color)
	{
		montageInfoRef.fill = color.pixelPacket;
	}
	///ditto
	Color fillColor()
	{
		return new Color(montageInfoRef.fill);
	}

	/**
	 * Specifies the thumbnail label font.
	 */
	void font(string font)
	{
		copyString(montageInfoRef.font, font);
	}
	///ditto
	string font()
	{
		return to!(string)(montageInfoRef.font);
	}

	/**
	 * Specifies the size of the generated thumbnail.
	 */
	void geometry(Geometry geometry)
	{
		copyString(montageInfoRef.geometry, geometry.toString());
	}
	///ditto
	Geometry geometry()
	{
		return Geometry( to!(string)(montageInfoRef.geometry) );
	}

	/**
	 * Specifies the thumbnail positioning within the specified geometry
	 * area. If the thumbnail is smaller in any dimension than the geometry,
	 * then it is placed according to this specification.
	 */
	void gravity(GravityType gravity)
	{
		montageInfoRef.gravity = gravity;
	}
	///ditto
	GravityType gravity()
	{
		return montageInfoRef.gravity;
	}

	/**
	 * Specifies the format used for the image label. Special format
	 * characters may be embedded in the format string to include
	 * information about the image.
	 * 
	 * See_Also: dmagick.Image.Image.annotate for the format characters.
	 */
	void label(string label)
	{
		copyString(montageInfoRef.title, label);
	}
	///ditto
	string label()
	{
		return to!(string)(montageInfoRef.title);
	}

	/**
	 * Specifies the thumbnail label font size.
	 */
	void pointSize(double size)
	{
		montageInfoRef.pointsize = size;
	}
	///ditto
	double pointSize()
	{
		return montageInfoRef.pointsize;
	}

	/**
	 * Specifies the maximum number of rows in the montage.
	 */
	void rows(size_t rows)
	{
		Geometry size;

		if ( montageInfoRef.tile !is null )
			size = Geometry( to!(string)(montageInfoRef.tile) );

		size.height = rows;
	}
	///ditto
	size_t rows()
	{
		Geometry size;

		if ( montageInfoRef.tile !is null )
			size = Geometry( to!(string)(montageInfoRef.tile) );

		return size.height;
	}

	/**
	 * Enable/disable drop-shadow on thumbnails.
	 */
	void shadow(bool shadow)
	{
		montageInfoRef.shadow = shadow;
	}
	///ditto
	bool shadow()
	{
		return montageInfoRef.shadow == 1;
	}

	/**
	 * Specifies the stroke color to use for the label text.
	 */
	void strokeColor(Color color)
	{
		montageInfoRef.stroke = color.pixelPacket;
	}
	///ditto
	Color strokeColor()
	{
		return new Color(montageInfoRef.stroke);
	}

	/**
	 * Specifies a texture image to use as montage background. The built-in
	 * textures "$(D granite:)" and "$(D plasma:)" are available. A texture
	 * is the same as a background image.
	 */
	void texture(string texture)
	{
		copyString(montageInfoRef.texture, texture);
	}
	///ditto
	string texture()
	{
		return to!(string)(montageInfoRef.texture);
	}
}

/**
 * MontageFramed provides the means to specify montage options when it is
 * desired to have decorative frames around the image thumbnails.
 */
class MontageFramed : Montage
{
	/**
	 * Construct the info to use for a framed montage.
	 * 
	 * Params:
	 *     frameGeometry = The size portion indicates the width and height
	 *         of the frame. If no offsets are given then the border
	 *         added is a solid color. Offsets x and y, if present,
	 *         specify that the width and height of the border is
	 *         partitioned to form an outer bevel of thickness x
	 *         pixels and an inner bevel of thickness y pixels.
	 *         Negative offsets make no sense as frame arguments.
	 */
	this(Geometry frameGeometry)
	{
		super();

		this.frameGeometry = frameGeometry;
	}

	/**
	 * Specifies the background color within the thumbnail frame.
	 */
	void borderColor(Color color)
	{
		montageInfoRef.background_color = color.pixelPacket;
	}
	///ditto
	Color borderColor()
	{
		return new Color(montageInfoRef.background_color);
	}

	/**
	 * Specifies the border to place between a thumbnail and its surrounding
	 * frame. This option only takes effect if geometry specification
	 * doesn't also specify the thumbnail border width.
	 */
	void borderWidth(size_t width)
	{
		montageInfoRef.border_width = width;
	}
	///ditto
	size_t borderWidth()
	{
		return montageInfoRef.border_width;
	}

	/**
	 * Specifies the geometry specification for frame to place around
	 * thumbnail. If this parameter is not specified, then the montage is
	 * unframed.
	 * 
	 * Params:
	 *     geometry = The size portion indicates the width and height of
	 *                the frame. If no offsets are given then the border
	 *                added is a solid color. Offsets x and y, if present,
	 *                specify that the width and height of the border is
	 *                partitioned to form an outer bevel of thickness x
	 *                pixels and an inner bevel of thickness y pixels.
	 *                Negative offsets make no sense as frame arguments.
	 */
	void frameGeometry(Geometry geometry)
	{
		copyString(montageInfoRef.frame, geometry.toString());
	}
	///ditto
	Geometry frameGeometry()
	{
		return Geometry( to!(string)(montageInfoRef.frame));
	}

	void matteColor(Color color)
	{
		montageInfoRef.matte_color = color.pixelPacket;
	}
	///ditto
	Color matteColor()
	{
		return new Color(montageInfoRef.matte_color);
	}
}
