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
import core.sys.posix.sys.types;

import dmagick.Color;
import dmagick.Exception;
import dmagick.Geometry;
import dmagick.Image;

import dmagick.c.cache;
import dmagick.c.exception;
import dmagick.c.geometry;
import dmagick.c.image : MagickCoreImage = Image;
import dmagick.c.magickType;
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
		return Row.row(image, row + extent.x, extent.width, extent.y);
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
			Row data = Row.row(image, row, extent.width, extent.x);

			int result = dg(data);

			if ( result )
				return result;

			if ( image.imageRef.progress_monitor !is null )
			{
				atomicOp!"+="(progress, 1);
				image.imageRef.progress_monitor(toStringz("ImageView/" ~ image.filename), progress, extent.height, image.imageRef.client_data);
			}
		}

		return 0;
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
		return Row.column(image, column + extent.y, extent.height, extent.x);
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
	NexusInfo nexus;
	PixelPacket[] pixels;

	/**
	 * Get an row in the image.
	 */
	static Row row(Image image, size_t row, size_t width, ssize_t offset)
	{
		Row pixelData;

		Quantum* data =
			GetAuthenticPixelCacheNexus(image.imageRef, offset, cast(ssize_t)row, width, 1, &(pixelData.nexus), DMagickExceptionInfo());

		pixelData.image = image;
		pixelData.pixels = (cast(PixelPacket*)data)[0..width];

		return pixelData;
	}

	/**
	 * Get an column in the image.
	 */
	static Row column(Image image, size_t column, size_t height, ssize_t offset)
	{
		Row pixelData;

		Quantum* data =
			GetAuthenticPixelCacheNexus(image.imageRef, cast(ssize_t)column, offset, 1, height, &(pixelData.nexus), DMagickExceptionInfo());

		pixelData.image = image;
		pixelData.pixels = (cast(PixelPacket*)data)[0..height];

		return pixelData;
	}

	~this()
	{
		if ( !pixels.empty )
			SyncAuthenticPixelCacheNexus(image.imageRef, &nexus, DMagickExceptionInfo());
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
		return new Color(pixels.ptr + pixel);
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
		return Row(image, nexus, pixels[left .. right]);
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

	unittest
	{
		Image image = new Image(Geometry(100, 100), new Color("Blue"));
		{
			Row row = Row.row(image, 50, 50, 25);
			row[] = new Color("red");
		}

		assert(image.view[50][50] == new Color("red"));
	}
}

/*
 * Note: these defenitions aren't public.
 */
private extern(C)
{
	struct NexusInfo
	{
		MagickBooleanType
			mapped;

		RectangleInfo
			region;

		MagickSizeType
			length;

		Quantum*
			cache,
			pixels;

		void*
			metacontent;

		size_t
			signature;
	}

	Quantum* GetAuthenticPixelCacheNexus(MagickCoreImage* image, const ssize_t x, const ssize_t y, const size_t columns, const size_t rows, NexusInfo* nexus_info, ExceptionInfo* exception);
	MagickBooleanType SyncAuthenticPixelCacheNexus(MagickCoreImage* image, NexusInfo* nexus_info, ExceptionInfo* exception);
}

