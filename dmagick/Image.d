/**
 * Copyright: Mike Wey 2011
 * License:   To be determined
 * Authors:   Mike Wey
 */

module dmagick.Image;

import std.string;
import core.sys.posix.sys.types;

import dmagick.Color;
import dmagick.Exception;
import dmagick.Geometry;
import dmagick.Options;
import dmagick.Utils;

import dmagick.c.attribute;
import dmagick.c.blob;
import dmagick.c.constitute;
import dmagick.c.colormap;
import dmagick.c.colorspace;
import dmagick.c.effect;
import dmagick.c.exception;
import dmagick.c.geometry;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.memory;
import dmagick.c.pixel;
import dmagick.c.resize;
import dmagick.c.resource;

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
	 * Adaptively blurs the image by blurring more intensely near
	 * image edges and less intensely far from edges.
	 * The adaptiveBlur method blurs the image with a Gaussian operator
	 * of the given radius and standard deviation (sigma).
	 * For reasonable results, radius should be larger than sigma.
	 * Use a radius of 0 and adaptive_blur selects a suitable radius for you.
	 *
	 * Params:
	 *     radius  = The radius of the Gaussian in pixels,
	 *               not counting the center pixel.
	 *     sigma   = The standard deviation of the Laplacian, in pixels.
	 *     channel = If no channels are specified, blurs all the channels.
	 */
	void adaptiveBlur(double radius = 0, double sigma = 1, ChannelType channel = ChannelType.DefaultChannels)
	{
		ExceptionInfo* exception = AcquireExceptionInfo();
		MagickCoreImage* image =
			AdaptiveBlurImageChannel(imageRef, channel, radius, sigma, exception);

		DMagickException.throwException(exception);
		DestroyExceptionInfo(exception);

		imageRef = ImageRef(image);
	}

	/**
	 * adaptiveResize uses the special Mesh Interpolation method
	 * to resize images. Basically adaptiveResize avoids the excessive
	 * blurring that resize can produce with sharp color changes.
	 * This works well for slight image size adjustments and in
	 * particularly for magnification, And especially with images
	 * with sharp color changes. But when images are enlarged or reduced
	 * by more than 50% it will start to produce aliasing,
	 * and Moiré effects in the results.
	 */
	void adaptiveResize(Geometry size)
	{
		ssize_t x, y;
		size_t width  = columns;
		size_t height = rows;

		ExceptionInfo* exception = AcquireExceptionInfo();
		ParseMetaGeometry(toStringz(size.toString), &x, &y, &width, &height);

		MagickCoreImage* image =
			AdaptiveResizeImage(imageRef, width, height, exception);

		DMagickException.throwException(exception);
		DestroyExceptionInfo(exception);

		imageRef = ImageRef(image);
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
		DestroyExceptionInfo(exception);

		imageRef = ImageRef(image);
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
		DestroyExceptionInfo(exception);

		imageRef = ImageRef(image);
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
		DestroyExceptionInfo(exception);

		imageRef = ImageRef(image);
	}

	void animationDelay(size_t delay)
	{
		imageRef.delay = delay;
	}
	size_t annimationDelay() const
	{
		return imageRef.delay;
	}

	void animationIterations(size_t iterations)
	{
		imageRef.iterations = iterations;
	}
	size_t animationIterations() const
	{
		return imageRef.iterations;
	}

	/**
	 * Set the image background color. The default is "white".
	 */
	void backgroundColor(string color)
	{
		backgroundColor = new Color(color);
	}
	///ditto	
	void backgroundColor(Color color)
	{
		options.backgroundColor(color);

		imageRef.background_color = color.pixelPacket;
	}
	///ditto
	Color backgroundColor() //const
	{
		return options.backgroundColor;
	}

	/**
	 * Set the image border color. The default is "#dfdfdf".
	 */
	void borderColor(string color)
	{
		borderColor = new Color(color);
	}
	///ditto
	void borderColor(Color color)
	{
		options.borderColor = color;

		imageRef.border_color = color.pixelPacket;
	}
	///ditto
	Color borderColor() //const
	{
		return options.borderColor;
	}

	Geometry boundingBox() const
	{
		ExceptionInfo* exception = AcquireExceptionInfo();
		RectangleInfo box = GetImageBoundingBox(imageRef, exception);

		DMagickException.throwException(exception);
		DestroyExceptionInfo(exception);

		return Geometry(box);
	}

	static void cacheThreshold(size_t threshold)
	{
		SetMagickResourceLimit(ResourceType.MemoryResource, threshold);
	}

	//TODO: Is this a property?
	void channelDepth(ChannelType channel, size_t depth)
	{
		SetImageChannelDepth(imageRef, channel, depth);
	}
	size_t channelDepth(ChannelType channel) const
	{
		ExceptionInfo* exception = AcquireExceptionInfo();
		size_t depth = GetImageChannelDepth(imageRef, channel, exception);

		DMagickException.throwException(exception);
		DestroyExceptionInfo(exception);

		return depth;
	}

	void chromaticity(ChromaticityInfo chroma)
	{
		imageRef.chromaticity = chroma;
	}
	ChromaticityInfo chromaticity() const
	{
		return imageRef.chromaticity;
	}

	//TODO: Should setting the classType convert the image.
	void classType(ClassType type)
	{
		imageRef.storage_class = type;
	}
	ClassType classType() const
	{
		return imageRef.storage_class;
	}

	void clipMask(const(Image) image)
	{
		if ( image is null )
		{
			SetImageClipMask(imageRef, null);
			return;
		}

		//Throw a chatchable exception when the size differs.
		if ( image.columns != columns || image.rows != rows )
			throw new ImageException("image size differs");

		SetImageClipMask(imageRef, image.imageRef);
	}
	Image clipMask() const
	{
		ExceptionInfo* exception = AcquireExceptionInfo();
		MagickCoreImage* image = CloneImage(imageRef.clip_mask, 0, 0, true, exception);

		DMagickException.throwException(exception);
		DestroyExceptionInfo(exception);

		return new Image(image);
	}

	auto colormap()
	{
		struct Colormap
		{
			Image img;

			this(Image img)
			{
				this.img = img;
			}

			Color opIndex(uint index)
			{
				if ( index >= img.colormapSize )
					throw new Exception("Index out of bounds");

				return new Color(img.imageRef.colormap[index]);
			}

			void opIndexAssign(Color value, uint index)
			{
				if ( index >= img.colormapSize )
					throw new Exception("Index out of bounds");

				img.imageRef.colormap[index] = value.pixelPacket;
			}

			void opOpAssign(string op)(Color color) if ( op == "~" )
			{
				img.colormapSize = img.colormapSize + 1;

				this[img.colormapSize] = color;
			}

			void opOpAssign(string op)(Color[] colors) if ( op == "~" )
			{
				uint oldSize = img.colormapSize;

				img.colormapSize = oldSize + colors.length;

				foreach ( i; oldSize..img.colormapSize)
				{
					this[i] = colors[i];
				}
			}

			uint size()
			{
				return img.colormapSize;
			}
			void size(uint s)
			{
				img.colormapSize = s;
			}
		}

		return Colormap(this);
	}

	void colormapSize(uint size)
	{
		if ( size > MaxColormapSize )
			throw new OptionException(
				"the size of the colormap can't exceed MaxColormapSize");

		if ( imageRef.colormap is null )
		{
			AcquireImageColormap(imageRef, size);
			imageRef.colors = 0;
		}
		else
		{
			imageRef.colormap = cast(PixelPacket*)
				ResizeMagickMemory(imageRef.colormap, size * PixelPacket.sizeof);
		}

		//Initialize the colors as black.
		foreach ( i; imageRef.colors .. size )
		{
			imageRef.colormap[i].blue    = 0;
			imageRef.colormap[i].green   = 0;
			imageRef.colormap[i].red     = 0;
			imageRef.colormap[i].opacity = 0;
		}

		imageRef.colors = size;
	}
	uint colormapSize() const
	{
		return cast(uint)imageRef.colors;
	}

	void colorspace(ColorspaceType type)
	{
		TransformImageColorspace(imageRef, type);
	}
	ColorspaceType colorspace() const
	{
		return imageRef.colorspace;
	}

	size_t columns() const
	{
		return imageRef.columns;
	}

	/**
	 * Colors within this distance are considered equal. 
	 * A number of algorithms search for a target  color.
	 * By default the color must be exact. Use this option to match
	 * colors that are close to the target color in RGB space.
	 */
	void fuzz(double f)
	{
		options.fuzz = f;
		imageRef.fuzz = f;
	}
	///ditto
	double fuzz() //const
	{
		return options.fuzz;
	}

	size_t rows() const
	{
		return imageRef.rows;
	}
}
