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

class ImageView
{
	Image image;
	RectangleInfo extent;

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

	Row opIndex(size_t row)
	{
		PixelPacket* pixels = 
			GetAuthenticPixels(image.imageRef, extent.x, extent.y + row, 1, extent.width, DMagickExceptionInfo());

		return Row(image, pixels[0 .. extent.width]);
	}

	ImageView opSlice()
	{
		return opSlice(0, extent.height);
	}

	ImageView opSlice(size_t upper, size_t lower)
	{
		RectangleInfo newExtent = extent;

		newExtent.y += upper;
		newExtent.height = lower - upper;

		return new Rows(image, Geometry(newExtent));
	}

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

class Rows : ImageView
{
	this(Image image, Geometry area)
	{
		super(image, area);
	}

	override Row opIndex(size_t column)
	{
		PixelPacket* pixels = 
			GetAuthenticPixels(image.imageRef, extent.x, extent.y, extent.height, 1, DMagickExceptionInfo());

		return Row(image, pixels[0 .. extent.width]);
	}

	override ImageView opSlice()
	{
		return opSlice(0, extent.width);
	}

	override ImageView opSlice(size_t left, size_t right)
	{
		RectangleInfo newExtent = extent;

		newExtent.x += left;
		newExtent.width = right - left;

		return new ImageView(image, Geometry(newExtent));
	}
}

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

	Color opIndex(size_t pixel)
	{
		return new Color(&(pixels[pixel]));
	}

	void opIndexAssign(Color color, size_t i)
	{
		pixels[i] = color.pixelPacket;
	}

	Row opSlice()
	{
		return this;
	}

	Row opSilce(size_t left, size_t right)
	{
		return Row(image, pixels[left .. right]);
	}

	void opSliceAssign(Color color)
	{
		opSliceAssign(color, 0, pixels.length);
	}

	void opSliceAssign(Color color, size_t left, size_t right)
	{
		foreach( i; left .. right )
			this[i] = color;
	}

	@property bool empty()
	{
		return pixels.empty;
	}

	Color front()
	{
		return this[0];
	}

	void popFront()
	{
		pixels.popFront();
	}
}
