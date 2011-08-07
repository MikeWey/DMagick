/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */
 
 module dmagick.ImageView;

import std.array;
import std.parallelism;
import std.range;
import std.string;
import core.atomic;

import dmagick.Color;
import dmagick.Exception;
import dmagick.Geometry;
import dmagick.Image;

import dmagick.c.cache;
import dmagick.c.geometry;
import dmagick.c.pixel;

/**
 * The ImageView allows changing induvidual pixels with the slicing and
 * indexing operators.
 *
 * --------------------
 * ImageView view = image.view();
 * 
 * //Assign a square.
 * view[4..40][5..50] = new Color("red");
 * 
 * //Reduce a view.
 * view = view[10..view.extend.height-10][20..view.extend.width-20];
 * 
 * //Assign a single row.
 * view[30] = new Color("blue");
 * //Or a column.
 * view[][30] = new Color("blue");
 * //And induvidual pixels.
 * view[3][5] = new Color("green");
 * 
 * //We can also use foreach.
 * foreach ( row; view )
 * {
 *     //This is executed in parallel.
 *     foreach ( ref pixel; row )
 *         pixel = new Color("black");
 * }
 * --------------------
 */
class ImageView
{
	Image image;
	RectangleInfo extent;

	/**
	 * Create a new view for image.
	 */
	this(Image image, Geometry area)
	{
		if ( area.width + area.xOffset > image.columns ||
			area.height + area.yOffset > image.rows )
		{
			throw new OptionException("Specified area is larger than the image");
		}

		this.image = image;
		this.extent = area.rectangleInfo;
	}

	/**
	 * The width of the view.
	 */
	@property size_t width() const
	{
		return extent.width;
	}

	/**
	 * The height of the view.
	 */
	@property size_t height() const
	{
		return extent.height;
	}

	/**
	 * The height or the width of the view, depending on in which slice
	 * it's used.
	 * 
	 * Bugs: dmd bug 3474: opDollar isn't implemented.
	 */
	size_t opDollar() const
	{
		return extent.height;
	}

	/**
	 * Indexing operators yield or modify the value at a specified index.
	 */
	Row opIndex(size_t row)
	{
		PixelPacket* pixels = 
			GetAuthenticPixels(image.imageRef, extent.x, extent.y + row, 1, extent.width, DMagickExceptionInfo());

		return Row(image, pixels[0 .. extent.width]);
	}

	///ditto
	void opIndexAssign(Color color, size_t index)
	{
		this[index][] = color;
	}

	/**
	 * Sliceing operators yield or modify the value in the specified slice.
	 */
	ImageView opSlice()
	{
		return opSlice(0, extent.height);
	}

	///ditto
	ImageView opSlice(size_t upper, size_t lower)
	{
		RectangleInfo newExtent = extent;

		newExtent.y += upper;
		newExtent.height = lower - upper;

		return new Rows(image, Geometry(newExtent));
	}

	///ditto
	void opSliceAssign(Color color)
	{
		foreach ( row; this )
			row[] = color;
	}

	///ditto
	void opSliceAssign(Color color, size_t upper, size_t lower)
	{
		foreach ( row; this[upper .. lower] )
			row[] = color;
	}

	/**
	 * Support the usage of foreach to loop over the rows in the view.
	 * The foreach is executed in parallel.
	 */
	//TODO: Should the foreach be parallel?
	int opApply(int delegate(ref Row) dg)
	{
		shared(int) progress;

		foreach ( row; taskPool.parallel(iota(extent.y, extent.y + extent.height)) )
		{
			PixelPacket* pixels = 
				GetAuthenticPixels(image.imageRef, extent.x, row, 1, extent.width, DMagickExceptionInfo());

			int result = dg(Row(image, pixels[0 .. extent.width]));

			if ( result )
				return result;

			if ( image.imageRef.progress_monitor !is null )
			{
				atomicOp!"+="(progress, 1);
				image.imageRef.progress_monitor(toStringz("ImageView/" ~ image.filename), progress, extent.height, image.imageRef.client_data);
			}
		}

		return 0;

		//Use UpdateImageViewIterator ?
	}
}


/*
 * A Rows object is returned when a ImageView is sliced, this is to support
 * sliceing the columns with a sceond slice.
 */
class Rows : ImageView
{
	this(Image image, Geometry area)
	{
		super(image, area);
	}

	/*
	 * The height or the width of the view, depending on in which slice
	 * it's used.
	 * 
	 * Bugs: dmd bug 3474: opDollar isn't implemented.
	 */
	override size_t opDollar() const
	{
		return extent.width;
	}

	/*
	 * Indexing operators yield or modify the value at a specified index.
	 */
	override Row opIndex(size_t column)
	{
		PixelPacket* pixels = 
			GetAuthenticPixels(image.imageRef, extent.x, extent.y, extent.height, 1, DMagickExceptionInfo());

		return Row(image, pixels[0 .. extent.width]);
	}

	/*
	 * Sliceing operators yield or modify the value in the specified slice.
	 */
	override ImageView opSlice()
	{
		return opSlice(0, extent.width);
	}

	///ditto
	override ImageView opSlice(size_t left, size_t right)
	{
		RectangleInfo newExtent = extent;

		newExtent.x += left;
		newExtent.width = right - left;

		return new ImageView(image, Geometry(newExtent));
	}
}

/**
 * Row reprecents a singe row of pixels in an ImageView.
 * 
 * Bugs: Only one row per thread is supported.
 */
struct Row
{
	Image image;
	PixelPacket[] pixels;
	
	this(Image image, PixelPacket[] pixels)
	{
		this.image = image;
		this.pixels = pixels;
	}

	~this()
	{
		SyncAuthenticPixels(image.imageRef, DMagickExceptionInfo());
	}

	/**
	 * The number of pixels in this row / column.
	 * 
	 * Bugs: dmd bug 3474: opDollar isn't implemented.
	 */
	@property size_t length() const
	{
		return pixels.length;
	}

	///ditto
	size_t opDollar() const
	{
		return pixels.length;
	}

	/**
	 * Indexing operators yield or modify the value at a specified index.
	 */
	Color opIndex(size_t pixel)
	{
		return new Color(&(pixels[pixel]));
	}

	///ditto
	void opIndexAssign(Color color, size_t index)
	{
		pixels[index] = color.pixelPacket;
	}

	/**
	 * Sliceing operators yield or modify the value in the specified slice.
	 */
	Row opSlice()
	{
		return this;
	}

	///ditto
	Row opSilce(size_t left, size_t right)
	{
		return Row(image, pixels[left .. right]);
	}

	///ditto
	void opSliceAssign(Color color)
	{
		opSliceAssign(color, 0, pixels.length);
	}

	///ditto
	void opSliceAssign(Color color, size_t left, size_t right)
	{
		foreach( i; left .. right )
			this[i] = color;
	}

	/**
	 * Support using foreach on a row.
	 */
	int opApply(int delegate(ref Color) dg)
	{
		foreach ( ref PixelPacket pixel; pixels )
		{
			Color color = new Color(pixel);
			int result = dg(color);

			pixel = color.pixelPacket;

			if ( result )
				return result;
		}

		return 0;
	}
}

