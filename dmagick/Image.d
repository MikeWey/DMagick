/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */

module dmagick.Image;

import std.conv;
import std.math;
import std.string;
import core.memory;
import core.stdc.string;
import core.sys.posix.sys.types;

import dmagick.Color;
import dmagick.Exception;
import dmagick.Geometry;
import dmagick.Options;
import dmagick.Utils;

import dmagick.c.annotate;
import dmagick.c.attribute;
import dmagick.c.blob;
import dmagick.c.cacheView;
import dmagick.c.constitute;
import dmagick.c.colormap;
import dmagick.c.colorspace;
import dmagick.c.composite;
import dmagick.c.compress;
import dmagick.c.draw;
import dmagick.c.effect;
import dmagick.c.enhance;
import dmagick.c.fx;
import dmagick.c.geometry;
import dmagick.c.histogram;
import dmagick.c.image;
import dmagick.c.layer;
import dmagick.c.magick;
import dmagick.c.magickString;
import dmagick.c.magickType;
import dmagick.c.memory;
import dmagick.c.pixel;
import dmagick.c.profile;
import dmagick.c.quantum;
import dmagick.c.resample;
import dmagick.c.resize;
import dmagick.c.resource;
import dmagick.c.shear;
import dmagick.c.transform;
import dmagick.c.threshold;

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
		MagickCoreImage* image =
			AdaptiveBlurImageChannel(imageRef, channel, radius, sigma, DMagickExcepionInfo());

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

		ParseMetaGeometry(toStringz(size.toString), &x, &y, &width, &height);
		MagickCoreImage* image =
			AdaptiveResizeImage(imageRef, width, height, DMagickExcepionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Adaptively sharpens the image by sharpening more intensely near
	 * image edges and less intensely far from edges. The adaptiveSharpen
	 * method sharpens the image with a Gaussian operator of the given
	 * radius and standard deviation (sigma). For reasonable results,
	 * radius should be larger than sigma. Use a radius of 0 and
	 * adaptiveSharpen selects a suitable radius for you.
	 *
	 * Params:
	 *     radius  = The radius of the Gaussian in pixels,
	 *               not counting the center pixel.
	 *     sigma   = The standard deviation of the Laplacian, in pixels.
	 *     channel = If no channels are specified, blurs all the channels.
	 */
	void adaptiveSharpen(double radius = 0, double sigma = 1, ChannelType channel = ChannelType.DefaultChannels)
	{
		MagickCoreImage* image =
			AdaptiveSharpenImageChannel(imageRef, channel, radius, sigma, DMagickExcepionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Selects an individual threshold for each pixel based on the range
	 * of intensity values in its local neighborhood. This allows for
	 * thresholding of an image whose global intensity histogram doesn't
	 * contain distinctive peaks.
	 *
	 * Params:
	 *     width  = define the width of the local neighborhood.
	 *     heigth = define the height of the local neighborhood.
	 *     offset = constant to subtract from pixel neighborhood mean.
	 */
	void adaptiveThreshold(size_t width = 3, size_t height = 3, ssize_t offset = 0)
	{
		MagickCoreImage* image =
			AdaptiveThresholdImage(imageRef, width, height, offset, DMagickExcepionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Adds random noise to the specified channel or channels in the image.
	 * The amount of time addNoise requires depends on the NoiseType argument.
	 *
	 * Params:
	 *     type    = A NoiseType value.
	 *     channel = 0 or more ChannelType arguments. If no channels are
	 *               specified, adds noise to all the channels
	 */
	void addNoise(NoiseType type, ChannelType channel = ChannelType.DefaultChannels)
	{
		MagickCoreImage* image =
			AddNoiseImageChannel(imageRef, channel, type, DMagickExcepionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Transforms the image as specified by the affine matrix.
	 */
	void affineTransform(AffineMatrix affine)
	{
		MagickCoreImage* image =
			AffineTransformImage(imageRef, &affine, DMagickExcepionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Extracts the pixel data from the specified rectangle.
	 *
	 * Params:
	 *     width   = Width in pixels of the region to extract.
	 *     height  = Height in pixels of the region to extract.
	 *     xOffset = Horizontal ordinate of left-most coordinate
	 *               of region to extract.
	 *     yOffset = Vertical ordinate of top-most coordinate of
	 *               region to extract.
	 *     map     = This character string can be any combination
	 *               or order of R = red, G = green, B = blue, A = 
	 *               alpha, C = cyan, Y = yellow, M = magenta, and K = black.
	 *               The ordering reflects the order of the pixels in
	 *               the supplied pixel array.
	 * 
	 * Returns: An array of values contain the pixel components as
	 *          defined by the map parameter and the Type.
	 */
	T[] exportPixels(T)(size_t width, size_t height, ssize_t xOffset = 0, ssize_t yOffset = 0, string map = "RGBA") const
	{
		StorageType storage;
		void[] pixels = new T[width*height];

		static if ( is( T == byte) )
		{
			storage = CharPixel;
		}
		else static if ( is( T == short) )
		{
			storage = ShortPixel;
		}
		else static if ( is( T == int) )
		{
			storage = IntegerPixel;
		}
		else static if ( is( T == long) )
		{
			storage = LongPixel;
		}
		else static if ( is( T == float) )
		{
			storage = FloatPixel;
		}
		else static if ( is( T == double) )
		{
			storage = DoublePixel;
		}
		else
		{
			assert(false, "Unsupported type");
		}

		ExportImagePixels(imageRef, xOffset, yOffset, width, height, map, storage, pixels.ptr, DMagickExcepionInfo());

		return pixels;
	}

	/**
	 * Returns the TypeMetric class witch provides the information
	 * regarding font metrics such as ascent, descent, text width,
	 * text height, and maximum horizontal advance. The units of
	 * these font metrics are in pixels, and that the metrics are
	 * dependent on the current Image font (default Ghostscript's
	 * "Helvetica"), pointsize (default 12 points), and x/y resolution
	 * (default 72 DPI) settings.
	 * 
	 * The pixel units may be converted to points (the standard
	 * resolution-independent measure used by the typesetting industry)
	 * via the following equation:
	 * ----------------------------------
	 * sizePoints = (sizePixels * 72)/resolution
	 * ----------------------------------
	 * where resolution is in dots-per-inch (DPI). This means that at the
	 * default image resolution, there is one pixel per point.
	 * See_Also:
	 *     $(LINK2 http://freetype.sourceforge.net/freetype2/docs/glyphs/index.html
	 *         FreeType Glyph Conventions) for a detailed description of
	 *     font metrics related issues.
	 */
	TypeMetric getTypeMetrics(string text)
	{
		TypeMetric metric;
		DrawInfo* drawInfo = options.drawInfo;

		copyString(drawInfo.text, text);
		GetMultilineTypeMetrics(imageRef, drawInfo, &metric);
		copyString(drawInfo.text, null);

		return metric;
	}

	/**
	 * Read an Image by reading from the file or
	 * URL specified by filename.
	 */
	void read(string filename)
	{
		options.filename = filename;

		MagickCoreImage* image = ReadImage(options.imageInfo, DMagickExcepionInfo());

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
		MagickCoreImage* image = 
			BlobToImage(options.imageInfo, blob.ptr, blob.length, DMagickExcepionInfo());

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
		MagickCoreImage* image = 
			ConstituteImage(width, height, toStringz(map), storage, pixels.ptr, DMagickExcepionInfo());

		imageRef = ImageRef(image);
	}

	///ditto
	void readPixels(T)(size_t width, size_t height, string map, T[] pixels)
	{
		StorageType storage;

		static if ( is( T == byte) )
		{
			storage = CharPixel;
		}
		else static if ( is( T == short) )
		{
			storage = ShortPixel;
		}
		else static if ( is( T == int) )
		{
			storage = IntegerPixel;
		}
		else static if ( is( T == long) )
		{
			storage = LongPixel;
		}
		else static if ( is( T == float) )
		{
			storage = FloatPixel;
		}
		else static if ( is( T == double) )
		{
			storage = DoublePixel;
		}
		else
		{
			assert(false, "Unsupported type");
		}

		read(width, height, map, storage, pixels);
	}

	//TODO: set process monitor.

	/**
	 * Splice the background color into the image as defined by the geometry.
	 * This method is the opposite of chop.
	 */
	void splice(Geometry geometry)
	{
		RectangleInfo rectangle = geometry.rectangleInfo;
		
		MagickCoreImage* image = SpliceImage(imageRef, &rectangle, DMagickExcepionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Creates a Binary Large OBject, a direct-to-memory
	 * version of the image.
	 *
	 * if an image format is selected which is capable of supporting
	 * fewer colors than the original image or quantization has been
	 * requested, the original image will be quantized to fewer colors.
	 * Use a copy of the original if this is a problem.
	 * 
	 * Params:
	 *     magick = specifies the image format to write.
	 *     depth  = specifies the image depth.
	 */
	void[] toBlob(string magick = null, size_t depth = 0)
	{
		size_t length;

		AcquireMemoryHandler oldMalloc;
		ResizeMemoryHandler  oldRealloc;
		DestroyMemoryHandler oldFree;

		if ( magick !is null )
			this.magick = magick;
		if ( depth != 0 )
			this.depth = depth;

		//Use the D GC to accolate the blob.
		GetMagickMemoryMethods(&oldMalloc, &oldRealloc, &oldFree);
		SetMagickMemoryMethods(&GC.malloc, &GC.realloc, &GC.free);
		scope(exit) SetMagickMemoryMethods(oldMalloc, oldRealloc, oldFree);

		void* blob = ImageToBlob(options.imageInfo, imageRef, &length, DMagickExcepionInfo());

		return blob[0 .. length];	
	}

	/**
	 * Writes the image to the specified file. ImageMagick
	 * determines image format from the prefix or extension.
	 * 
	 * if an image format is selected which is capable of supporting
	 * fewer colors than the original image or quantization has been
	 * requested, the original image will be quantized to fewer colors.
	 * Use a copy of the original if this is a problem.
	 */
	void write(string filename)
	{
		options.filename = filename;
		WriteImage(options.imageInfo, imageRef);

		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Set a flag to indicate whether or not to use alpha channel data.
	 */
	void alpha(AlphaChannelType type)
	{
		SetImageAlphaChannel(imageRef, type);
	}
	///ditto
	bool alpha() const
	{
		return GetImageAlphaChannel(imageRef) != 0;
	}

	/**
	 * Number of ticks which must expire before displaying the
	 * next image in an animated sequence. The default number
	 * of ticks is 0. By default there are 100 ticks per second.
	 */
	void animationDelay(ushort delay)
	{
		imageRef.delay = delay;
	}
	///ditto
	ushort annimationDelay() const
	{
		return cast(ushort)imageRef.delay;
	}

	/**
	 * Number of iterations to loop an animation.
	 */
	void animationIterations(size_t iterations)
	{
		imageRef.iterations = iterations;
	}
	///ditto
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
	Color backgroundColor() const
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
	Color borderColor() const
	{
		return options.borderColor;
	}

	/**
	 * Return smallest bounding box enclosing non-border pixels.
	 * The current fuzz value is used when discriminating between pixels.
	 */
	Geometry boundingBox() const
	{
		RectangleInfo box = GetImageBoundingBox(imageRef, DMagickExcepionInfo());

		return Geometry(box);
	}

	/**
	 * Pixel cache threshold in megabytes. Once this threshold is exceeded,
	 * all subsequent pixels cache operations are to/from disk.
	 * This is a static method and the attribute it sets is shared
	 * by all Image objects
	 */
	static void cacheThreshold(size_t threshold)
	{
		SetMagickResourceLimit(ResourceType.MemoryResource, threshold);
	}

	/**
	 * Channel modulus depth. The channel modulus depth represents
	 * the minimum number of bits required to support the channel without loss.
	 * Setting the channel's modulus depth modifies the channel (i.e. discards
	 * resolution) if the requested modulus depth is less than the current
	 * modulus depth, otherwise the channel is not altered. There is no
	 * attribute associated with the modulus depth so the current modulus
	 * depth is obtained by inspecting the pixels. As a result, the depth
	 * returned may be less than the most recently set channel depth.
	 * Subsequent image processing may result in increasing the channel depth.
	 */
	//TODO: Is this a property?
	void channelDepth(ChannelType channel, size_t depth)
	{
		SetImageChannelDepth(imageRef, channel, depth);
	}
	///ditto
	size_t channelDepth(ChannelType channel) const
	{
		size_t depth = GetImageChannelDepth(imageRef, channel, DMagickExcepionInfo());

		return depth;
	}

	/**
	 * The red, green, blue, and white-point chromaticity values.
	 */
	void chromaticity(ChromaticityInfo chroma)
	{
		imageRef.chromaticity = chroma;
	}
	///ditto
	ChromaticityInfo chromaticity() const
	{
		return imageRef.chromaticity;
	}

	/**
	 * The image's storage class. If DirectClass then the pixels
	 * contain valid RGB or CMYK colors. If PseudoClass then the
	 * image has a colormap referenced by the pixel's index member.
	 */
	void classType(ClassType type)
	{
		if ( imageRef.storage_class == ClassType.PseudoClass && type == ClassType.DirectClass )
		{
			SyncImage(imageRef);
			colormap() = null;
		}
		else if ( imageRef.storage_class == ClassType.DirectClass && type == ClassType.PseudoClass )
		{
			options.quantizeColors = MaxColormapSize;
			//TODO: implement quantize function.
			//quantize();
			assert(false);
		}

		imageRef.storage_class = type;
	}
	///ditto
	ClassType classType() const
	{
		return imageRef.storage_class;
	}

	/**
	 * Associate a clip mask image with the current image.
	 * The clip mask image must have the same dimensions as the current
	 * image or an exception is thrown. Clipping occurs wherever pixels are
	 * transparent in the clip mask image. Clipping Pass an invalid image
	 * to unset an existing clip mask.
	 */
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
	///ditto
	Image clipMask() const
	{
		MagickCoreImage* image = CloneImage(imageRef.clip_mask, 0, 0, true, DMagickExcepionInfo());

		return new Image(image);
	}

	/**
	 * Access the image color map.
	 * Only ClassType.PsseudoClass images have a colormap.
	 * ----------------------------------
	 * Color color = image.colormap[2];
	 * image.colormap()[2] = color;
	 * ----------------------------------
	 * To asign the complete colormap at once:
	 * ----------------------------------
	 * Color[] colors = new Colors[255];
	 * image.colormap() = colors;
	 * //Or
	 * image.colormap.size = 255;
	 * foreach(i, color; colors)
	 *     image.colormap()[i] = color;
	 * ----------------------------------
	 * Bugs: because of dmd bug 2152 the parentheses are needed when assigning;
	 */
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

			void opIndexAssign(Color value, size_t index)
			{
				if ( index >= img.colormapSize )
					throw new Exception("Index out of bounds");

				img.imageRef.colormap[index] = value.pixelPacket;
			}

			void opAssign(Color[] colors)
			{
				img.colormapSize = colors.length;

				if ( colors.length == 0 )
					return;

				foreach(i, color; colors)
					this[i] = color;
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
					this[i] = colors[i];
			}

			size_t size()
			{
				return img.colormapSize;
			}
			void size(size_t s)
			{
				img.colormapSize = s;
			}
		}

		return Colormap(this);
	}

	/**
	 * The number of colors in the colormap. Only meaningful for PseudoClass images.
	 * 
	 * Setting the colormap size may extend or truncate the colormap.
	 * The maximum number of supported entries is specified by the
	 * MaxColormapSize constant, and is dependent on the value of
	 * QuantumDepth when ImageMagick is compiled. An exception is thrown
	 * if more entries are requested than may be supported.
	 * Care should be taken when truncating the colormap to ensure that
	 * the image colormap indexes reference valid colormap entries.
	 */
	void colormapSize(size_t size)
	{
		if ( size > MaxColormapSize )
			throw new OptionException(
				"the size of the colormap can't exceed MaxColormapSize");

		if ( size == 0 && imageRef.colors > 0 )
		{
			imageRef.colormap = cast(PixelPacket*)RelinquishMagickMemory( imageRef.colormap );
			imageRef.colors = 0;

			return;
		}

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
	///ditto
	size_t colormapSize() const
	{
		return imageRef.colors;
	}

	/**
	 * The colorspace used to represent the image pixel colors.
	 * Image pixels are always stored as RGB(A) except for the case of CMY(K).
	 */
	void colorspace(ColorspaceType type)
	{
		TransformImageColorspace(imageRef, type);

		options.colorspace = type;
	}
	///ditto
	ColorspaceType colorspace() const
	{
		return imageRef.colorspace;
	}

	/**
	 * The width of the image in pixels.
	 */
	size_t columns() const
	{
		return imageRef.columns;
	}

	/**
	 * Composition operator to be used when composition is
	 * implicitly used (such as for image flattening).
	 */
	void compose(CompositeOperator op)
	{
		imageRef.compose = op;
	}
	///ditto
	CompositeOperator compose() const
	{
		return imageRef.compose;
	}

	/**
	 * The image compression type. The default is the
	 * compression type of the specified image file.
	 */
	void compression(CompressionType type)
	{
		imageRef.compression = type;
		options.compression = type;
	}
	///ditto
	CompressionType compression() const
	{
		return imageRef.compression;
	}

	/**
	 * The vertical and horizontal resolution in pixels of the image.
	 * This option specifies an image density when decoding
	 * a Postscript or Portable Document page.
	 * 
	 * The default is "72x72".
	 */
	void density(Geometry value)
	{
		options.density = value;

		imageRef.x_resolution = value.width;
		imageRef.y_resolution = ( value.width != 0 ) ? value.width : value.height;
	}
	///ditto
	Geometry density() const
	{
		ssize_t width  = cast(ssize_t)rndtol(imageRef.x_resolution);
		ssize_t height = cast(ssize_t)rndtol(imageRef.y_resolution);

		return Geometry(width, height);
	}

	/**
	 * Image depth. Used to specify the bit depth when reading or writing
	 * raw images or when the output format supports multiple depths.
	 * Defaults to the quantum depth that ImageMagick is compiled with.
	 */
	void depth(size_t value)
	{
		if ( value > MagickQuantumDepth)
			value = MagickQuantumDepth;

		imageRef.depth = value;
		options.depth = value;
	}
	///ditto
	size_t depth() const
	{
		return imageRef.depth;
	}

	/**
	 * Tile names from within an image montage.
	 * Only valid after calling montage or reading a MIFF file
	 * which contains a directory.
	 */
	string directory() const
	{
		return to!(string)(imageRef.directory);
	}

	/**
	 * Specify (or obtain) endian option for formats which support it.
	 */
	void endian(EndianType type)
	{
		imageRef.endian = type;
		options.endian = type;
	}
	///ditto
	EndianType endian() const
	{
		return imageRef.endian;
	}

	/**
	 * The EXIF profile.
	 */
	void exifProfile(void[] blob)
	{
		StringInfo* profile = AcquireStringInfo(blob.length);
		SetStringInfoDatum(profile, cast(ubyte*)blob.ptr);

		SetImageProfile(imageRef, "exif", profile);

		DestroyStringInfo(profile);		
	}
	///ditto
	void[] exifProfile() const
	{
		const(StringInfo)* profile = GetImageProfile(imageRef, "exif");

		if ( profile is null )
			return null;

		return GetStringInfoDatum(profile)[0 .. GetStringInfoLength(profile)].dup;
	}

	/**
	 * The image filename.
	 */
	void filename(string str)
	{
		copyString(imageRef.filename, str);
		options.filename = str;
	}

	/**
	 * The image filesize in bytes.
	 */
	MagickSizeType fileSize() const
	{
		return GetBlobSize(imageRef);
	}

	/**
	 * Filter to use when resizing image. The reduction filter employed
	 * has a significant effect on the time required to resize an image
	 * and the resulting quality. The default filter is Lanczos which has
	 * been shown to produce high quality results when reducing most images.
	 */
	void filter(FilterTypes type)
	{
		imageRef.filter = type;
	}
	///ditto
	FilterTypes filter() const
	{
		return imageRef.filter;
	}

	/**
	 * The image encoding format. For example, "GIF" or "PNG".
	 */
	string format() const
	{
		const(MagickInfo)* info = GetMagickInfo(imageRef.magick.ptr, DMagickExcepionInfo());

		return to!(string)( info.description );
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
	double fuzz() const
	{
		return options.fuzz;
	}

	/**
	 * GammaImage() gamma-corrects a particular image channel.
	 * The same image viewed on different devices will have perceptual
	 * differences in the way the image's intensities are represented
	 * on the screen.  Specify individual gamma levels for the red,
	 * green, and blue channels, or adjust all three with the gamma
	 * parameter.  Values typically range from 0.8 to 2.3.
	 * 
	 * You can also reduce the influence of a particular channel
	 * with a gamma value of 0.
	 */
	void gamma(double value)
	{
		GammaImageChannel(imageRef,
			( ChannelType.RedChannel | ChannelType.GreenChannel | ChannelType.BlueChannel ),
			value);
	}
	///ditto
	void gamma(double red, double green, double blue)
	{
		GammaImageChannel(imageRef, ChannelType.RedChannel, red);
		GammaImageChannel(imageRef, ChannelType.GreenChannel, green);
		GammaImageChannel(imageRef, ChannelType.BlueChannel, blue);
	}

	/**
	 * Gamma level of the image. The same color image displayed on
	 * two different workstations may look different due to differences
	 * in the display monitor. Use gamma correction to adjust for this
	 * color difference.
	 */
	double gamma() const
	{
		return imageRef.gamma;
	}

	/**
	 * Preferred size of the image when encoding.
	 */
	void geometry(string str)
	{
		copyString(imageRef.geometry, str);
	}
	///ditto
	void geometry(Geometry value)
	{
		geometry(value.toString());
	}
	///ditto
	Geometry geometry() const
	{
		return Geometry( to!(string)(imageRef.geometry) );
	}

	/**
	 * GIF disposal method. This attribute is used to control how
	 * successive images are rendered (how the preceding image
	 * is disposed of) when creating a GIF animation.
	 */
	void gifDisposeMethod(DisposeType type)
	{
		imageRef.dispose = type;
	}
	///ditto
	DisposeType gifDisposeMethod() const
	{
		return imageRef.dispose;
	}

	/**
	 * ICC color profile.
	 */
	void iccColorProfile(void[] blob)
	{
		profile("icm", blob);
	}
	///ditto
	void[] iccColorProfile() const
	{
		const(StringInfo)* profile = GetImageProfile(imageRef, "icm");

		if ( profile is null )
			return null;

		return GetStringInfoDatum(profile)[0 .. GetStringInfoLength(profile)].dup;
	}

	/**
	 * Specify the _type of interlacing scheme for raw image formats
	 * such as RGB or YUV. NoInterlace means do not _interlace,
	 * LineInterlace uses scanline interlacing, and PlaneInterlace
	 * uses plane interlacing. PartitionInterlace is like PlaneInterlace
	 * except the different planes are saved to individual files
	 * (e.g. image.R, image.G, and image.B). Use LineInterlace or
	 * PlaneInterlace to create an interlaced GIF or
	 * progressive JPEG image. The default is NoInterlace.
	 */
	void interlace(InterlaceType type)
	{
		imageRef.interlace = type;
		options.interlace = type;
	}
	///ditto
	InterlaceType interlace() const
	{
		return imageRef.interlace;
	}

	/**
	 * The International Press Telecommunications Council profile.
	 */
	void iptcProfile(void[] blob)
	{
		profile("iptc", blob);
	}
	///ditto
	void[] iptcProfile() const
	{
		const(StringInfo)* profile = GetImageProfile(imageRef, "iptc");

		if ( profile is null )
			return null;

		return GetStringInfoDatum(profile)[0 .. GetStringInfoLength(profile)].dup;
	}

	/**
	 * Image format (e.g. "GIF")
	 */
	void magick(string str)
	{
		copyString(imageRef.magick, str);
		options.magick = str;
	}
	///ditto
	string magick() const
	{
		if ( imageRef.magick !is null )
			return imageRef.magick[0 .. strlen(imageRef.magick.ptr)].idup;

		return options.magick;
	}

	/**
	 * Set the image transparent color. The default is "#bdbdbd".
	 */
	void matteColor(string color)
	{
		matteColor = new Color(color);
	}
	///ditto
	void matteColor(Color color)
	{
		imageRef.matte_color = color.pixelPacket;
		options.matteColor = color;
	}
	///ditto
	Color matteColor() const
	{
		return new Color(imageRef.matte_color);
	}

	/**
	 * The mean error per pixel computed when an image is color reduced.
	 * This parameter is only valid if verbose is set to true and the
	 * image has just been quantized.
	 */
	double meanErrorPerPixel() const
	{
		return imageRef.error.mean_error_per_pixel;
	}

	/**
	 * Image modulus depth (minimum number of bits required to
	 * support red/green/blue components without loss of accuracy).
	 * The pixel modulus depth may be decreased by supplying a value
	 * which is less than the current value, updating the pixels
	 * (reducing accuracy) to the new depth. The pixel modulus depth
	 * can not be increased over the current value using this method.
	 */
	void modulusDepth(size_t depth)
	{
		SetImageDepth(imageRef, depth);
		options.depth = depth;
	}
	///ditto
	size_t modulusDepth() const
	{
		size_t depth = GetImageDepth(imageRef, DMagickExcepionInfo());

		return depth;
	}

	/**
	 * Tile size and offset within an image montage.
	 * Only valid for images produced by montage.
	 */
	Geometry montageGeometry() const
	{
		return Geometry( to!(string)(imageRef.geometry) );
	}

	/**
	 * The normalized max error per pixel computed when
	 * an image is color reduced. This parameter is only
	 * valid if verbose is set to true and the image
	 * has just been quantized.
	 */
	double normalizedMaxError() const
	{
		return imageRef.error.normalized_maximum_error;
	}

	/**
	 * The normalized mean error per pixel computed when
	 * an image is color reduced. This parameter is only
	 * valid if verbose is set to true and the image
	 * has just been quantized.
	 */
	double normalizedMeanError() const
	{
		return imageRef.error.normalized_mean_error;
	}

	/**
	 * Image orientation.  Supported by some file formats
	 * such as DPX and TIFF. Useful for turning the right way up.
	 */
	void orientation(OrientationType orientation)
	{
		imageRef.orientation = orientation;
	}
	///ditto
	OrientationType orientation() const
	{
		return imageRef.orientation;
	}

	/**
	 * When compositing, this attribute describes the position
	 * of this image with respect to the underlying image.
	 * 
	 * Use this option to specify the dimensions and position of
	 * the Postscript page in dots per inch or a TEXT page in pixels.
	 * This option is typically used in concert with density.
	 * 
	 * Page may also be used to position a GIF image
	 * (such as for a scene in an animation).
	 */
	void page(Geometry geometry)
	{
		options.page = geometry;
		imageRef.page = geometry.rectangleInfo;
	}
	///ditto
	Geometry page() const
	{
		return Geometry(imageRef.page);
	}

	/**
	 * The pixel color interpolation method. Some methods (such
	 * as wave, swirl, implode, and composite) use the pixel color
	 * interpolation method to determine how to blend adjacent pixels.
	 */
	void pixelInterpolationMethod(InterpolatePixelMethod method)
	{
		imageRef.interpolate = method;
	}
	///ditto
	InterpolatePixelMethod pixelInterpolationMethod() const
	{
		return imageRef.interpolate;
	}

	/**
	 * Get/set/remove a named profile. Valid names include "*",
	 * "8BIM", "ICM", "IPTC", or a user/format-defined profile name. 
	 */
	void profile(string name, void[] blob)
	{
		ProfileImage(imageRef, toStringz(name), blob.ptr, blob.length, false);
	}
	///ditto
	void[] profile(string name) const
	{
		const(StringInfo)* profile = GetImageProfile(imageRef, toStringz(name));

		if ( profile is null )
			return null;

		return GetStringInfoDatum(profile)[0 .. GetStringInfoLength(profile)].dup;
	}

	/**
	 * JPEG/MIFF/PNG compression level (default 75).
	 */
	void quality(size_t )
	{
		imageRef.quality = quality;
		options.quality = quality;
	}
	///ditto
	size_t quality() const
	{
		return imageRef.quality;
	}

	/**
	 * The type of rendering intent.
	 * See_Also: 
	 * $(LINK http://www.cambridgeincolour.com/tutorials/color-space-conversion.htm)
	 */
	void renderingIntent(RenderingIntent intent)
	{
		imageRef.rendering_intent = intent;
	}
	///ditto
	RenderingIntent renderingIntent() const
	{
		return imageRef.rendering_intent;
	}

	/**
	 * Units of image resolution
	 */
	void resolutionUnits(ResolutionType type)
	{
		imageRef.units = type;
		options.resolutionUnits = type;
	}
	///ditto
	ResolutionType resolutionUnits() const
	{
		return options.resolutionUnits;
	}

	/**
	 * The scene number assigned to the image the last
	 * time the image was written to a multi-image image file.
	 */
	void scene(size_t value)
	{
		imageRef.scene = value;
	}
	///ditto
	size_t scene() const
	{
		return imageRef.scene;
	}

	/**
	 * The height of the image in pixels.
	 */
	size_t rows() const
	{
		return imageRef.rows;
	}

	/**
	 * Width and height of a image.
	 */
	Geometry size() const
	{
		return Geometry(imageRef.columns, imageRef.rows);
	}

	//TODO: Statistics ?

	/**
	 * Number of colors in the image.
	 */
	size_t totalColors() const
	{
		size_t colors = GetNumberColors(imageRef, null, DMagickExcepionInfo());

		return colors;
	}

	/**
	 * Image type.
	 */
	void type(ImageType imageType)
	{
		options.type = imageType;
		SetImageType(imageRef, imageType);
	}
	///ditto
	ImageType type() const
	{
		if (options.type != ImageType.UndefinedType )
			return options.type;

		ImageType imageType = GetImageType(imageRef, DMagickExcepionInfo());

		return imageType;
	}

	/**
	 * Specify how "virtual pixels" behave. Virtual pixels are
	 * pixels that are outside the boundaries of the image.
	 * Methods such as blurImage, sharpen, and wave use virtual pixels.
	 */
	void virtualPixelMethod(VirtualPixelMethod method)
	{
		options.virtualPixelMethod = method;
		SetImageVirtualPixelMethod(imageRef, method);
	}
	///ditto
	VirtualPixelMethod virtualPixelMethod() const
	{
		return GetImageVirtualPixelMethod(imageRef);
	}

	/**
	 * Horizontal resolution of the image.
	 */
	double xResolution() const
	{
		return imageRef.x_resolution;
	}

	/**
	 * Vertical resolution of the image.
	 */
	double yResolution() const
	{
		return imageRef.y_resolution;
	}

	//Image properties - set via SetImageProterties
	//Should we implement these as actual properties?
	//attribute
	//comment
	//label
	//signature

	//Other unimplemented porperties
	//pixelColor
}
