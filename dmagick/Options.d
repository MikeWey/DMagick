/**
 * A class to expose ImageInfo QuantizeInfo and DrawInfo
 *
 * Copyright: Mike Wey 2011
 * License:   To be determined
 * Authors:   Mike Wey
 */


module dmagick.Options;

import std.conv;
import core.stdc.string;

import dmagick.c.draw;
import dmagick.c.image;
import dmagick.c.magickString;
import dmagick.c.magickType;
import dmagick.c.memory;
import dmagick.c.quantize;

class Options
{
	ImageInfo*    imageInfo;
	QuantizeInfo* quantizeInfo;
	DrawInfo*     drawInfo;

	this()
	{
		imageInfo = cast(ImageInfo*)AcquireMagickMemory(ImageInfo.sizeof);
		quantizeInfo = cast(QuantizeInfo*)AcquireMagickMemory(QuantizeInfo.sizeof);
		drawInfo = cast(DrawInfo*)AcquireMagickMemory(DrawInfo.sizeof);

	}

	this(const(ImageInfo)* imageInfo, const(QuantizeInfo)* quantizeInfo, const(DrawInfo)* drawInfo)
	{
		this.imageInfo = CloneImageInfo(imageInfo);
		this.quantizeInfo = CloneQuantizeInfo(quantizeInfo);
		this.drawInfo = CloneDrawInfo(imageInfo, drawInfo);
	}

	~this()
	{
		imageInfo = DestroyImageInfo(imageInfo);
		quantizeInfo = DestroyQuantizeInfo(quantizeInfo);
		drawInfo = DestroyDrawInfo(drawInfo);
	}

	/****************************************************************
	 * ImageInfo fields
	 ****************************************************************/

	void adjoin(bool flag)
	{
		imageInfo.adjoin = flag;
	}
	bool adjoin()
	{
		return imageInfo.adjoin;
	}

	/**
	 * Set the image background color. The default is "white".
	 */
	//void backgroundColor(string color)
	//{
	//
	//}
	//void backgroundColor(Color color)
	//{
	//
	//}
	//Color backgroundColor()
	//{
	//
	//}

	/**
	 * Set a texture to tile onto the image background.
	 * Corresponds to the -texture option to ImageMagick's
	 * convert and mogrify commands.
	 */
	void backgroundTexture(string str)
	{
		copyString(imageInfo.texture, str);
	}
	string backgroundTexture()
	{
		return to!(string)(imageInfo.texture);
	}

	//void borderColor(Color color)
	//{
	//
	//}
	//Color borderColor()
	//{
	//
	//}

	/**
	 * Set the image border color. The default is "#dfdfdf".
	 */
	void colorspace(ColorspaceType space)
	{
		imageInfo.colorspace = space;
	}
	ColorspaceType colorspace()
	{
		return imageInfo.colorspace;
	}

	/**
	 * Specifies the type of compression used when writing the image.
	 * Only some image formats support compression. For those that do,
	 * only some compression types are supported. If you specify an
	 * compression type that is not supported, the default compression
	 * type (usually NoCompression) is used instead.
	 */
	void compression(CompressionType compress)
	{
		imageInfo.compression = compress;
	}
	CompressionType compression()
	{
		return imageInfo.compression;
	}

	//void ddebug(bool d)
	//{
	//
	//}
	//bool ddebug()
	//{
	//
	//}

	/**
	 * Specifies the vertical and horizontal resolution in pixels.
	 * The default density is "72.0x72.0". This attribute can be used
	 * when writing JBIG, PCL, PS, PS2, and PS3 format images.
	 * 
	 * This attribute can also be used to specify the width and height
	 * of HISTOGRAM format images. For HISTOGRAM, the default is 256x200.
	 */
	void density(string str)
	{
		copyString(imageInfo.density, str);
	}
	string density()
	{
		return to!(string)(imageInfo.density);
	}

	/**
	 * Specifies the image depth
	 * 
	 * Either 8, 16, or 32. You can specify 16 and 32
	 * only when ImageMagick was compiled with a QuantumDepth
	 * that allows these depth values.
	 */
	void depth(size_t d)
	{
		imageInfo.depth = d;
	}
	size_t depth()
	{
		return imageInfo.depth;
	}

	/**
	 * This attribute can be used when writing GIF images.
	 * 
	 * Apply Floyd/Steinberg error diffusion to the image.
	 * The basic strategy of dithering is to trade intensity
	 * resolution for spatial resolution by averaging the intensities
	 * of several neighboring pixels. Images which suffer from severe
	 * contouring when reducing colors can be improved with this option.
	 */
	void dither(bool d)
	{
		imageInfo.dither = d;
	}
	size_t dither()
	{
		return imageInfo.dither;
	}

	/**
	 * Specify the endianess of the image when reading the image file.
	 */
	void endian(EndianType type)
	{
		imageInfo.endian = type;
	}
	EndianType endian()
	{
		return imageInfo.endian;
	}

	/**
	 * Image file descriptor.
	 */
	void file(FILE* f)
	{
		imageInfo.file = f;
	}
	FILE* file()
	{
		return imageInfo.file;
	}

	/**
	 * Image filename/path.
	 */
	void filename(string str)
	{
		copyString(imageInfo.filename, str);
	}
	string filename()
	{
		return imageInfo.filename[0 .. strlen(imageInfo.filename.ptr)].idup;
	}

	/**
	 * Text rendering font. If the font is a fully qualified
	 * X server font name, the font is obtained from an X  server.
	 * To use a TrueType font, precede the TrueType filename with an @.
	 * Otherwise, specify  a  Postscript font name (e.g. "helvetica")
	 */
	void font(string str)
	{
		copyString(imageInfo.font, str);
		copyString(drawInfo.font, str);
	}
	string font()
	{
		return to!(string)(drawInfo.font);
	}

	/**
	 * Colors within this distance are considered equal. 
	 * A number of algorithms search for a target  color.
	 * By default the color must be exact. Use this option to match
	 * colors that are close to the target color in RGB space.
	 */
	void fuzz(double f)
	{
		imageInfo.fuzz = f;
	}
	double fuzz()
	{
		return imageInfo.fuzz;
	}

	/**
	 * Specify the type of interlacing scheme for raw image formats
	 * such as RGB or YUV. NoInterlace means do not interlace,
	 * LineInterlace uses scanline interlacing, and PlaneInterlace
	 * uses plane interlacing. PartitionInterlace is like PlaneInterlace
	 * except the different planes are saved to individual files
	 * (e.g. image.R, image.G, and image.B). Use LineInterlace or
	 * PlaneInterlace to create an interlaced GIF or
	 * progressive JPEG image. The default is NoInterlace.
	 */
	void interlace(InterlaceType type)
	{
		imageInfo.interlace = type;
	}
	InterlaceType interlace()
	{
		return imageInfo.interlace;
	}

	/**
	 * Image format (e.g. "GIF")
	 */
	void magick(string str)
	{
		copyString(imageInfo.magick, str);
	}
	string magick()
	{
		return imageInfo.magick[0 .. strlen(imageInfo.magick.ptr)].idup;
	}

	//void matteColor(Color color)
	//{
	//
	//}
	//Color matteColor()
	//{
	//
	//}

	/**
	 * Transform the image to black and white on input.
	 * Only the EPT, PDF, and PS formats respect this attribute.
	 */
	void monochrome(bool m)
	{
		imageInfo.monochrome = m;
	}
	bool monochrome()
	{
		return imageInfo.monochrome;
	}

	/**
	 * Use this option to specify the dimensions and position
	 * of the Postscript page in dots per inch or in pixels.
	 * This option is typically used in concert with density.
	 * 
	 * Page may also be used to position a GIF image
	 * (such as for a scene in an animation)
	 * The default is "612x792"
	 */
	void page(string str)
	{
		copyString(imageInfo.page, str);
	}
	string page()
	{
		return to!(string)(imageInfo.page);
	}

	/**
	 * Text rendering font point size
	 */
	void pointSize(double size)
	{
		imageInfo.pointsize = size;
		drawInfo.pointsize = size;
	}
	double pointSize()
	{
		return drawInfo.pointsize;
	}

	/**
	 * The compression level for JPEG, MPEG, JPEG-2000,
	 * MIFF, MNG, and PNG image format.
	 * The default is 75
	 */
	void quality(size_t q)
	{
		imageInfo.quality = q;
	}
	size_t quality()
	{
		return imageInfo.quality;
	}

	/**
	 * Units of image resolution.
	 */
	void resolutionUnits(ResolutionType type)
	{
		imageInfo.units = type;
	}
	ResolutionType resolutionUnits()
	{
		return imageInfo.units;
	}

	/**
	 * sampling factors used by JPEG or MPEG-2 encoder and
	 * YUV decoder/encoder.
	 * 
	 * This attribute specifies the sampling factors to be used
	 * by the JPEG encoder for chroma downsampling.
	 * If this attribute is omitted, the JPEG library will use its
	 * own default values. When reading or writing the YUV format and
	 * when writing the M2V (MPEG-2) format, use sampling-factor="2x1"
	 * to specify the 4:2:2 downsampling method.
	 */
	void samplingFactor(string str)
	{
		copyString(imageInfo.sampling_factor, str);
	}
	string samplingFactor()
	{
		return to!(string)(imageInfo.sampling_factor);
	}

	/**
	 * Set the width and height of the image when reading a
	 * built-in image format that does not have an inherent size,
	 * or when reading an image from a multi-resolution file format
	 * such as Photo CD, JBIG, or JPEG.
	 */
	void size(string str)
	{
		copyString(imageInfo.size, str);
	}
	string size()
	{
		return to!(string)(imageInfo.size);
	}

	/**
	 * Subimage of an image sequence
	 */
	void subImage(size_t num)
	{
		imageInfo.scene = num;
	}
	size_t subImage()
	{
		return imageInfo.scene;
	}

	/**
	 * Number of images relative to the base image
	 */
	void subRange(size_t num)
	{
		imageInfo.number_scenes = num;
	}
	size_t subRange()
	{
		return imageInfo.number_scenes;
	}

	/**
	 * Image type.
	 */
	void type(ImageType t)
	{
		imageInfo.type = t;
	}
	ImageType type()
	{
		return imageInfo.type;
	}

	/**
	 * Print detailed information about the image.
	 */
	void verbose(bool v)
	{
		imageInfo.verbose = v;
	}
	bool verbose()
	{
		return imageInfo.verbose;
	}

	/**
	 * FlashPix viewing parameters.
	 */
	void view(string str)
	{
		copyString(imageInfo.view, str);
	}
	string view()
	{
		return to!(string)(imageInfo.view);
	}

	/**
	 * Image virtual pixel method.
	 */
	//TODO: Delegates?
	void virtualPixelMethod(VirtualPixelMethod method)
	{
		imageInfo.virtual_pixel_method = method;
	}
	VirtualPixelMethod virtualPixelMethod()
	{
		return imageInfo.virtual_pixel_method;
	}

	/**
	 * X11 display to display to obtain fonts from or, to capture image from.
	 */
	void x11Display(string str)
	{
		copyString(imageInfo.server_name, str);
	}
	string x11Display()
	{
		return to!(string)(imageInfo.server_name);
	}

	//OrientationType orientation;
	//MagickBooleanType temporary,
	//MagickBooleanType affirm,
	//MagickBooleanType antialias;
	//char* extract,
	//char* scenes;
	//size_t colors;
	//PreviewType preview_type;
	//ssize_t group;
	//MagickBooleanType ping,
	//char* authenticate;
	//ChannelType channel;
	//void* options;
	//MagickProgressMonitor progress_monitor;
	//void* client_data,
	//void* cache;
	//StreamHandler stream;
	//void* blob;
	//size_t length;
	//char[MaxTextExtent] unique,
	//char[MaxTextExtent] zero,
	//size_t signature;
	//PixelPacket transparent_color;
	//void* profile;
	//MagickBooleanType synchronize;

	/**
	 * Copy a string into a static array used
	 * by ImageMagick for some atributes.
	 */
	private void copyString(ref char[MaxTextExtent] dest, string source)
	{
		if ( source.length < MaxTextExtent )
			throw new Exception("text is to long"); //TODO: a proper exception.

		dest[0 .. source.length] = str;
		dest[source.length] = '\0';
	}

	/**
	 * Our implementation of ImageMagick's CloneString.
	 *
	 * We use this since using CloneString forces us to
	 * append a \0 to the end of the string, and the realocation
	 * whould be wastefull if we are just going to copy it
	 */
	private void copyString(ref char* dest, string source)
	{
		if ( source is null )
		{
			if ( dest !is null )
				DestroyString(dest);
			return;
		}

		if ( ~source.length < MaxTextExtent )
			throw new Exception("UnableToAcquireString"); //TODO: a proper exception.

		if ( dest is null )
			dest = cast(char*)AcquireQuantumMemory(dest, source.length+MaxTextExtent, dest.sizeof);
		else
			dest = cast(char*)ResizeQuantumMemory(dest, source.length+MaxTextExtent, dest.sizeof);

		if ( dest is null )
			throw new Exception("UnableToAcquireString"); //TODO: a proper exception.

		if ( source.length > 0 )
			dest[0 .. source.length] = str;

		dest[source.length] = '\0';
	}
}
