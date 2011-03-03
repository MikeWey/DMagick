/**
 * Copyright: Mike Wey 2011
 * License:   To be determined
 * Authors:   Mike Wey
 */

module dmagick.Image;

import std.string;

import dmagick.Color;
import dmagick.Exception;
import dmagick.Geometry;
import dmagick.Options;
import dmagick.Utils;

import dmagick.c.blob;
import dmagick.c.constitute;
import dmagick.c.exception;
import dmagick.c.image;

/**
 * The image
 */
class Image
{
	alias dmagick.c.image.Image MagickCoreImage;
	alias RefCounted!( DestroyImage, MagickCoreImage ) ImageRef;

	ImageRef imageRef;
	Options options;  ///The options for this image.

	///
	this()
	{
		options = new Options();
		imageRef = ImageRef(AcquireImage(options.imageInfo));
	}

	this(MagickCoreImage* image)
	{
		options = new Options();
		imageRef = ImageRef(image);
	}

	/**
	 * Construct an Image by reading from the file or
	 * URL specified by filename.
	 */
	this(string filename)
	{
		options = new Options();
		read(filename);
	}

	/**
	 * Construct a blank image with the specified color.
	 */
	this(Geometry size, Color color)
	{
		options = new Options();
		options.size = size;

		//Use read to create a cnavas with the spacified color.
		read( "canvas:"~ color.toString() );
	}

	/**
	 * Construct an image from an in-memory blob.
	 * The Blob size, depth and magick format may also be specified.
	 *
	 * Some image formats require size to be specified,
	 * the default depth Imagemagick uses is the Quantum size
	 * it's compiled with. If it doesn't match the depth of the image
	 * it may need to be specified.
	 *
	 * Imagemagick can usualy detect the image format, when the
	 * format can't be detected a magick format must be specified.
	 */
	this(void[] blob)
	{
		options = new Options();

		read(blob);
	}

	///ditto
	this(void[] blob, Geometry size)
	{
		options = new Options();

		read(blob, size);
	}

	///ditto
	this(void[] blob, Geometry size, size_t depth)
	{
		options = new Options();

		read(blob, size, depth);
	}

	///ditto
	this(void[] blob, Geometry size, size_t depth, string magick)
	{
		options = new Options();

		read(blob, size, depth, magick);
	}
	
	///ditto
	this(void[] blob, Geometry size, string magick)
	{
		options = new Options();

		read(blob, size, magick);
	}

	/**
	 * Constructs an image from an array of pixels.
	 *
	 * Params:
	 *     width  =  The number of columns in the image.
	 *     height =  The number of rows in the image.
	 *     map    =  A string describing the expected ordering
	 *               of the pixel array. It can be any combination
	 *               or order of R = red, G = green, B = blue, A = alpha
	 *               , C = cyan, Y = yellow, M = magenta, K = black,
	 *               or I = intensity (for grayscale).
	 *     storage = The pixel Staroage type (CharPixel,
	 *               ShortPixel, IntegerPixel, FloatPixel, or DoublePixel).
	 *     pixels  = The pixel data.
	 */
	this(size_t columns, size_t rows, string map, StorageType storage, void[] pixels)
	{
		options = new Options();

		read(columns, rows, map, storage, pixels);
	}

	/**
	 * Read an Image by reading from the file or
	 * URL specified by filename.
	 */
	void read(string filename)
	{
		options.filename = filename;

		ExceptionInfo* exception = AcquireExceptionInfo();
		MagickCoreImage* image = ReadImage(options.imageInfo, exception);

		DMagickException.throwException(exception);

		imageRef = ImageRef(image);
		DestroyExceptionInfo(exception);
	}

	/**
	 * Read an Image by reading from the file or
	 * URL specified by filename with the specified size.
	 * Usefull for images that don't specify their size.
	 */
	void read(string filename, Geometry size)
	{
		options.size = size;
		read(filename);
	}

	/**
	 * Reads an image from an in-memory blob.
	 * The Blob size, depth and magick format may also be specified.
	 *
	 * Some image formats require size to be specified,
	 * the default depth Imagemagick uses is the Quantum size
	 * it's compiled with. If it doesn't match the depth of the image
	 * it may need to be specified.
	 *
	 * Imagemagick can usualy detect the image format, when the
	 * format can't be detected a magick format must be specified.
	 */
	void read(void[] blob)
	{
		ExceptionInfo* exception = AcquireExceptionInfo();
		MagickCoreImage* image = 
			BlobToImage(options.imageInfo, blob.ptr, blob.length, exception);

		DMagickException.throwException(exception);

		imageRef = ImageRef(image);
		DestroyExceptionInfo(exception);
	}

	///ditto
	void read(void[] blob, Geometry size)
	{
		options.size = size;

		read(blob);
	}

	///ditto
	void read(void[] blob, Geometry size, size_t depth)
	{
		options.size = size;
		options.depth = depth;

		read(blob);
	}

	///ditto
	void read(void[] blob, Geometry size, size_t depth, string magick)
	{
		options.size = size;
		options.depth = depth;
		options.magick = magick;
		//Also set the filename to the image format
		options.filename = magick ~":";

		read(blob);
	}

	///ditto
	void read(void[] blob, Geometry size, string magick)
	{
		options.size = size;
		options.magick = magick;
		//Also set the filename to the image format
		options.filename = magick ~":";

		read(blob);
	}

	/**
	 * Reads an image from an array of pixels.
	 *
	 * Params:
	 *     width  =  The number of columns in the image.
	 *     height =  The number of rows in the image.
	 *     map    =  A string describing the expected ordering
	 *               of the pixel array. It can be any combination
	 *               or order of R = red, G = green, B = blue, A = alpha
	 *               , C = cyan, Y = yellow, M = magenta, K = black,
	 *               or I = intensity (for grayscale).
	 *     storage = The pixel Staroage type (CharPixel,
	 *               ShortPixel, IntegerPixel, FloatPixel, or DoublePixel).
	 *     pixels  = The pixel data.
	 */
	void read(size_t width, size_t height, string map, StorageType storage, void[] pixels)
	{
		ExceptionInfo* exception = AcquireExceptionInfo();
		MagickCoreImage* image = 
			ConstituteImage(width, height, toStringz(map), storage, pixels.ptr, exception);

		DMagickException.throwException(exception);

		imageRef = ImageRef(image);
		DestroyExceptionInfo(exception);
	}
}
