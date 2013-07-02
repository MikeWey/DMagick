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
import dmagick.c.exception;
import dmagick.c.geometry;
import dmagick.c.image : MagickCoreImage = Image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;
import dmagick.c.memory;
import dmagick.c.pixel;

//These symbols are publicly imported by dmagick.Image.
private alias dmagick.c.magickType.Quantum Quantum;

alias ptrdiff_t ssize_t;

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
	 * Bugs: dmd bug 7097: opDollar doesn't work with slicing.
	 */
	size_t opDollar() const
	{
		return extent.height;
	}

	/**
	 * Indexing operators yield or modify the value at a specified index.
	 */
	Pixels opIndex(size_t row)
	{
		return Pixels(image, extent.x, extent.y + row, extent.width, 1);
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
	int opApply(int delegate(Pixels) dg)
	{
		shared(int) progress;

		foreach ( row; taskPool.parallel(iota(extent.y, extent.y + extent.height)) )
		{
			int result = dg(Pixels(image, extent.x, row, extent.width, 1));

			if ( result )
				return result;

			if ( image.monitor !is null )
			{
				atomicOp!"+="(progress, 1);
				image.monitor()("ImageView/" ~ image.filename, progress, extent.height);
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
	 * Bugs: dmd bug 7097: opDollar doesn't work with slicing.
	 */
	override size_t opDollar() const
	{
		return extent.width;
	}

	/*
	 * Indexing operators yield or modify the value at a specified index.
	 */
	override Pixels opIndex(size_t column)
	{
		return Pixels(image, extent.x + column, extent.y, 1, extent.height);
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
 */
struct Pixels
{
	Image image;
	PixelPacket[] pixels;

	private size_t* refcount;
	private NexusInfo nexus;

	/**
	 * Get the pixels of the specifies area in the image.
	 */
	this(Image image, ssize_t x, ssize_t y, size_t columns, size_t rows)
	{
		this.image = image;

		Quantum* data =
			GetAuthenticPixelCacheNexus(image.imageRef, x, y, columns, rows, &nexus, DMagickExceptionInfo());
		this.pixels = (cast(PixelPacket*)data)[0..columns*rows];

		refcount  = new size_t;
		*refcount = 1;
	}

	/*
	 * Copy constructor.
	 */
	private this(Image image, PixelPacket[] pixels, size_t* refCount, NexusInfo nexus)
	{
		this.image = image;
		this.pixels = pixels;
		this.refcount = refcount;
		this.nexus = nexus;

		(*refcount)++;
	}

	this(this)
	{
		if ( !pixels.empty )
			(*refcount)++;
	}

	~this()
	{
		if ( pixels.empty )
			return;

		(*refcount)--;

		if ( *refcount == 0 )
		{
			sync();

			if ( !nexus.mapped )
				RelinquishMagickMemory(nexus.cache);
			else
				UnmapBlob(nexus.cache, cast(size_t)nexus.length);

			nexus.cache = null;
		}
	}

	/**
	 * The number of pixels in this row / column.
	 * 
	 * Bugs: dmd bug 7097: opDollar doesn't work with slicing.
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
	Pixels opSlice()
	{
		return this;
	}

	///ditto
	Pixels opSilce(size_t left, size_t right)
	{
		return Pixels(image, pixels[left .. right], refcount, nexus);
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
	 * Sync the pixels back to the image. The destructor does this for you.
	 */
	void sync()
	{
		SyncAuthenticPixelCacheNexus(image.imageRef, &nexus, DMagickExceptionInfo());
	}

	/**
	 * Support using foreach on a row.
	 */
	int opApply(T : Color)(int delegate(ref T) dg)
	{
		T color = new T();

		foreach ( ref PixelPacket pixel; pixels )
		{
			color.pixelPacket = pixel;

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
			Pixels row = Pixels(image, 25, 50, 50, 1);
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

		static if ( MagickLibVersion >= 0x686 )
		{
			MagickBooleanType
				authentic_pixel_cache;
		}

		void*
			metacontent;

		size_t
			signature;
	}

	Quantum* GetAuthenticPixelCacheNexus(MagickCoreImage* image, const ssize_t x, const ssize_t y, const size_t columns, const size_t rows, NexusInfo* nexus_info, ExceptionInfo* exception);
	MagickBooleanType SyncAuthenticPixelCacheNexus(MagickCoreImage* image, NexusInfo* nexus_info, ExceptionInfo* exception);
	MagickBooleanType UnmapBlob(void* map, const size_t length);
}

