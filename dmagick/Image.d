/**
 * Copyright: Mike Wey 2011
 * License:   To be determined
 * Authors:   Mike Wey
 */

module dmagick.Image;

import std.conv;
import std.math;
import std.string;
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
import dmagick.c.exception;
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
import dmagick.c.transform;

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
		GetTypeMetrics(imageRef, drawInfo, &metric);
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

	/**
	 * Splice the background color into the image as defined by the geometry.
	 * This method is the opposite of chop.
	 */
	void splice(Geometry geometry)
	{
		RectangleInfo rectangle = geometry.rectangleInfo;
		ExceptionInfo* exception = AcquireExceptionInfo();

		MagickCoreImage* image = SpliceImage(imageRef, &rectangle, exception);

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
	uint colormapSize() const
	{
		return cast(uint)imageRef.colors;
	}

	void colorspace(ColorspaceType type)
	{
		TransformImageColorspace(imageRef, type);

		options.colorspace = type;
	}
	ColorspaceType colorspace() const
	{
		return imageRef.colorspace;
	}

	void columns(size_t width)
	{
		imageRef.columns = width;
	}
	size_t columns() const
	{
		return imageRef.columns;
	}

	void compose(CompositeOperator op)
	{
		imageRef.compose = op;
	}
	CompositeOperator compose() const
	{
		return imageRef.compose;
	}

	void compression(CompressionType type)
	{
		imageRef.compression = type;
		options.compression = type;
	}
	CompressionType compression() const
	{
		return imageRef.compression;
	}

	void density(Geometry value)
	{
		options.density = value;

		imageRef.x_resolution = value.width;
		imageRef.y_resolution = ( value.width != 0 ) ? value.width : value.height;
	}
	Geometry density() const
	{
		ssize_t width  = cast(ssize_t)rndtol(imageRef.x_resolution);
		ssize_t height = cast(ssize_t)rndtol(imageRef.y_resolution);

		return Geometry(width, height);
	}

	void depth(size_t value)
	{
		if ( value > MagickQuantumDepth)
			value = MagickQuantumDepth;

		imageRef.depth = value;
		options.depth = value;
	}
	size_t depth() const
	{
		return imageRef.depth;
	}

	string directory() const
	{
		return to!(string)(imageRef.directory);
	}

	void endian(EndianType type)
	{
		imageRef.endian = type;
		options.endian = type;
	}
	EndianType endian() const
	{
		return imageRef.endian;
	}

	void exifProfile(void[] blob)
	{
		StringInfo* profile = AcquireStringInfo(blob.length);
		SetStringInfoDatum(profile, cast(ubyte*)blob.ptr);

		SetImageProfile(imageRef, "exif", profile);

		DestroyStringInfo(profile);		
	}
	void[] exifProfile() const
	{
		const(StringInfo)* profile = GetImageProfile(imageRef, "exif");

		if ( profile is null )
			return null;

		return GetStringInfoDatum(profile)[0 .. GetStringInfoLength(profile)].dup;
	}

	void filename(string str)
	{
		copyString(imageRef.filename, str);
		options.filename = str;
	}
	string filename() const
	{
		return options.filename;
	}

	MagickSizeType fileSize() const
	{
		return GetBlobSize(imageRef);
	}

	void filter(FilterTypes type)
	{
		imageRef.filter = type;
	}
	FilterTypes filter() const
	{
		return imageRef.filter;
	}

	string format() const
	{
		ExceptionInfo* exception = AcquireExceptionInfo();
		const(MagickInfo)* info = GetMagickInfo(imageRef.magick.ptr, exception);

		DMagickException.throwException(exception);
		DestroyExceptionInfo(exception);

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

	void gifDisposeMethod(DisposeType type)
	{
		imageRef.dispose = type;
	}
	DisposeType gifDisposeMethod() const
	{
		return imageRef.dispose;
	}

	void iccColorProfile(void[] blob)
	{
		profile("icm", blob);
	}
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

	void iptcProfile(void[] blob)
	{
		profile("iptc", blob);
	}
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

	void matte(bool flag)
	{
		// If the image has a matte channel, and it's
		// not desired set the matte channel to fully opaque.
		if ( !flag && imageRef.matte )
			SetImageOpacity(imageRef, OpaqueOpacity);

		imageRef.matte = flag;
	}
	bool matte() const
	{
		return imageRef.matte != 0;
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

	double meanErrorPerPixel() const
	{
		return imageRef.error.mean_error_per_pixel;
	}

	void modulusDepth(size_t depth)
	{
		SetImageDepth(imageRef, depth);
		options.depth = depth;
	}
	size_t modulusDepth() const
	{
		ExceptionInfo* exception = AcquireExceptionInfo();
		size_t depth = GetImageDepth(imageRef, exception);

		DMagickException.throwException(exception);
		DestroyExceptionInfo(exception);

		return depth;
	}

	Geometry montageGeometry() const
	{
		return Geometry( to!(string)(imageRef.geometry) );
	}

	double normalizedMaxError() const
	{
		return imageRef.error.normalized_maximum_error;
	}

	double normalizedMeanError() const
	{
		return imageRef.error.normalized_mean_error;
	}

	void orientation(OrientationType orientation)
	{
		imageRef.orientation = orientation;
	}
	OrientationType orientation() const
	{
		return imageRef.orientation;
	}

	void page(Geometry geometry)
	{
		options.page = geometry;
		imageRef.page = geometry.rectangleInfo;
	}
	Geometry page() const
	{
		return Geometry(imageRef.page);
	}

	void profile(string name, void[] blob)
	{
		ProfileImage(imageRef, toStringz(name), blob.ptr, blob.length, false);
	}
	void[] profile(string name) const
	{
		const(StringInfo)* profile = GetImageProfile(imageRef, toStringz(name));

		if ( profile is null )
			return null;

		return GetStringInfoDatum(profile)[0 .. GetStringInfoLength(profile)].dup;
	}

	void quality(size_t )
	{
		imageRef.quality = quality;
		options.quality = quality;
	}
	size_t quality() const
	{
		return imageRef.quality;
	}

	void renderingIntent(RenderingIntent intent)
	{
		imageRef.rendering_intent = intent;
	}
	RenderingIntent renderingIntent() const
	{
		return imageRef.rendering_intent;
	}

	void resolutionUnits(ResolutionType type)
	{
		imageRef.units = type;
		options.resolutionUnits = type;
	}
	ResolutionType resolutionUnits() const
	{
		return options.resolutionUnits;
	}

	void scene(size_t value)
	{
		imageRef.scene = value;
	}
	size_t scene() const
	{
		return imageRef.scene;
	}

	void rows(size_t height)
	{
		imageRef.rows = height;
	}
	size_t rows() const
	{
		return imageRef.rows;
	}

	void size(Geometry geometry)
	{
		options.size = geometry;

		imageRef.rows = geometry.height;
		imageRef.columns = geometry.width;
	}
	Geometry size() const
	{
		return Geometry(imageRef.columns, imageRef.rows);
	}

	//TODO: Statistics ?

	size_t totalColors() const
	{
		ExceptionInfo* exception = AcquireExceptionInfo();
		size_t colors = GetNumberColors(imageRef, null, exception);

		DMagickException.throwException(exception);
		DestroyExceptionInfo(exception);

		return colors;
	}

	void type(ImageType imageType)
	{
		options.type = imageType;
		SetImageType(imageRef, imageType);
	}
	ImageType type() const
	{
		if (options.type != ImageType.UndefinedType )
			return options.type;

		ExceptionInfo* exception = AcquireExceptionInfo();
		ImageType imageType = GetImageType(imageRef, exception);

		DMagickException.throwException(exception);
		DestroyExceptionInfo(exception);

		return imageType;
	}

	/**
	 * Image virtual pixel _method.
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

	double xResolution() const
	{
		return imageRef.x_resolution;
	}

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
