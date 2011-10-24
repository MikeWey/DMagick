/**
 * A class to expose ImageInfo QuantizeInfo and DrawInfo
 *
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */

module dmagick.Options;

import std.conv;
import std.math;
import std.string;
import core.stdc.stdio;
import core.stdc.string;

import dmagick.Color;
import dmagick.Geometry;
import dmagick.Image;
import dmagick.Utils;

import dmagick.c.cacheView;
import dmagick.c.colorspace;
import dmagick.c.compress;
import dmagick.c.draw;
import dmagick.c.geometry;
import dmagick.c.image;
import dmagick.c.list;
import dmagick.c.magickType;
import dmagick.c.memory;
import dmagick.c.option;
import dmagick.c.quantize;
import dmagick.c.quantum;
import dmagick.c.type;

/// See_Also: $(CXREF quantize, _DitherMethod)
public alias dmagick.c.quantize.DitherMethod DitherMethod;

//These symbols are publicly imported by dmagick.Image.
private alias dmagick.c.geometry.AffineMatrix AffineMatrix;
private alias dmagick.c.colorspace.ColorspaceType ColorspaceType;
private alias dmagick.c.compress.CompressionType CompressionType;
private alias dmagick.c.quantum.EndianType EndianType;
private alias dmagick.c.image.ImageType ImageType;
private alias dmagick.c.image.InterlaceType InterlaceType;
private alias dmagick.c.image.ResolutionType ResolutionType;
private alias dmagick.c.cacheView.VirtualPixelMethod VirtualPixelMethod;

/**
 * A class that wraps ImageInfo, DrawInfo and QuantizeInfo
 */
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

		//Initialize with defaults.
		GetImageInfo(imageInfo);
		GetDrawInfo(imageInfo, drawInfo);
		GetQuantizeInfo(quantizeInfo);

		//In D strings are UTF encoded.
		textEncoding("UTF-8");
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

	Options clone() const
	{
		return new Options(imageInfo, quantizeInfo, drawInfo);
	}

	/+***************************************************************
	 * ImageInfo fields
	 ***************************************************************+/

	/**
	 * Join images into a single multi-image file.
	 */
	void adjoin(bool flag)
	{
		imageInfo.adjoin = flag;
	}
	///ditto
	bool adjoin() const
	{
		return imageInfo.adjoin == 1;
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
		imageInfo.background_color = color.pixelPacket;	
	}
	///ditto
	Color backgroundColor() const
	{
		return new Color(imageInfo.background_color);
	}

	/**
	 * Set a texture to tile onto the image background.
	 * Corresponds to the -texture option to ImageMagick's
	 * convert and mogrify commands.
	 */
	void backgroundTexture(string str)
	{
		copyString(imageInfo.texture, str);
	}
	///ditto
	string backgroundTexture() const
	{
		return to!(string)(imageInfo.texture);
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
		imageInfo.border_color = color.pixelPacket;
		drawInfo.border_color = color.pixelPacket;
	}
	///ditto
	Color borderColor() const
	{
		return new Color(imageInfo.border_color);
	}

	/**
	 * Specifies the image pixel interpretation.
	 */
	void colorspace(ColorspaceType space)
	{
		imageInfo.colorspace = space;
	}
	///ditto
	ColorspaceType colorspace() const
	{
		return imageInfo.colorspace;
	}

	/**
	 * Specifies the type of _compression used when writing the image.
	 * Only some image formats support _compression. For those that do,
	 * only some _compression types are supported. If you specify an
	 * _compression type that is not supported, the default _compression
	 * type (usually NoCompression) is used instead.
	 */
	void compression(CompressionType compress)
	{
		imageInfo.compression = compress;
	}
	///ditto
	CompressionType compression() const
	{
		return imageInfo.compression;
	}

	//void ddebug(bool d)
	//{
	//
	//}
	//ditto
	//bool ddebug()
	//{
	//
	//}

	/**
	 * Define an option. Use this method to set options for
	 * reading or writing certain image formats. The list of
	 * supported options changes from release to release.
	 * For a list of the valid image formats, keys, and values,
	 * refer to the documentation for the -define option for the
	 * release of ImageMagick installed on your system.
	 * Params:
	 *     format = An image format name such as "ps" or "tiff".
	 *     key    = A string that identifies the option.
	 *     vaule  = The value of the option.
	 */
	void define(string format, string key, string value = "")
	{
		string option = format ~":"~ key ~ "\0";

		SetImageOption(imageInfo, option.ptr, toStringz(value));
	}

	//TODO: opindex / opiindexassign for the options.

	/**
	 * Delete an option definition set by define.
	 * This is not the same as setting the option to a null value.
	 * The undefine method removes the option name from the list
	 * of options for the specified format.
	 *     format = An image format name such as "ps" or "tiff".
	 *     key    = A string that identifies the option.
	 */
	void undefine(string format, string key)
	{
		string option = format ~":"~ key ~ "\0";

		DeleteImageOption(imageInfo, option.ptr);
	}

	/**
	 * Specifies the vertical and horizontal resolution in pixels.
	 * The default _density is "72.0x72.0". This attribute can be used
	 * when writing JBIG, PCL, PS, PS2, and PS3 format images.
	 * 
	 * This attribute can also be used to specify the width and height
	 * of HISTOGRAM format images. For HISTOGRAM, the default is 256x200.
	 */
	void density(string str)
	{
		copyString(imageInfo.density, str);
	}
	///ditto
	void density(Geometry geometry)
	{
		density(geometry.toString());
	}
	///ditto
	Geometry density() const
	{
		return Geometry( to!(string)(imageInfo.density) );
	}

	/**
	 * Specifies the image _depth
	 * 
	 * Either 8, 16, or 32. You can specify 16 and 32
	 * only when ImageMagick was compiled with a QuantumDepth
	 * that allows these _depth values.
	 */
	void depth(size_t d)
	{
		imageInfo.depth = d;
	}
	///ditto
	size_t depth() const
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
		quantizeInfo.dither = d;
	}
	///ditto
	size_t dither() const
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
	///ditto
	EndianType endian() const
	{
		return imageInfo.endian;
	}

	/**
	 * Image _file descriptor.
	 */
	void file(FILE* f)
	{
		imageInfo.file = f;
	}
	///ditto
	FILE* file()
	{
		return imageInfo.file;
	}

	/**
	 * Image _filename/path.
	 */
	void filename(string str)
	{
		copyString(imageInfo.filename, str);
	}
	///ditto
	string filename() const
	{
		return imageInfo.filename[0 .. strlen(imageInfo.filename.ptr)].idup;
	}

	/**
	 * The _font name or filename.
	 * You can tag a _font to specify whether it is a Postscript,
	 * Truetype, or OPTION1 _font. For example, Arial.ttf is a
	 * Truetype _font, ps:helvetica is Postscript, and x:fixed is OPTION1.
	 * 
	 * The _font name can be a complete filename such as
	 * "/mnt/windows/windows/fonts/Arial.ttf". The _font name can
	 * also be a fully qualified X font name such as
	 * "-urw-times-medium-i-normal--0-0-0-0-p-0-iso8859-13".
	 */
	void font(string str)
	{
		copyString(imageInfo.font, str);
		copyString(drawInfo.font, str);
	}
	///ditto
	string font() const
	{
		return to!(string)(drawInfo.font);
	}

	/**
	 * Text rendering font point size
	 */
	void fontSize(double size)
	{
		imageInfo.pointsize = size;
		drawInfo.pointsize = size;
	}
	///ditto
	double fontSize() const
	{
		return drawInfo.pointsize;
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
	///ditto
	double fuzz() const
	{
		return imageInfo.fuzz;
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
		imageInfo.interlace = type;
	}
	///ditto
	InterlaceType interlace() const
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
	///ditto
	string magick() const
	{
		return imageInfo.magick[0 .. strlen(imageInfo.magick.ptr)].idup;
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
		imageInfo.matte_color = color.pixelPacket;
	}
	///ditto
	Color matteColor() const
	{
		return new Color(imageInfo.matte_color);
	}

	/**
	 * Transform the image to black and white on input.
	 * Only the EPT, PDF, and PS formats respect this attribute.
	 */
	void monochrome(bool m)
	{
		imageInfo.monochrome = m;
	}
	///ditto
	bool monochrome() const
	{
		return imageInfo.monochrome == 1;
	}

	/**
	 * Use this option to specify the dimensions and position
	 * of the Postscript _page in dots per inch or in pixels.
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
	///ditto
	void page(Geometry geometry)
	{
		page(geometry.toString());
	}
	///ditto
	Geometry page() const
	{
		return Geometry( to!(string)(imageInfo.page) );
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
	///ditto
	size_t quality() const
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
	///ditto
	ResolutionType resolutionUnits() const
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
	///ditto
	string samplingFactor() const
	{
		return to!(string)(imageInfo.sampling_factor);
	}

	/**
	 * Set the width and height of the image when reading a
	 * built-in image format that does not have an inherent _size,
	 * or when reading an image from a multi-resolution file format
	 * such as Photo CD, JBIG, or JPEG.
	 */
	void size(string str)
	{
		copyString(imageInfo.size, str);
	}
	///ditto
	void size(Geometry geometry)
	{
		size(geometry.toString());
	}
	///ditto
	Geometry size() const
	{
		return Geometry( to!(string)(imageInfo.size) );
	}

	/**
	 * Subimage of an image sequence
	 */
	void subImage(size_t num)
	{
		imageInfo.scene = num;
	}
	///ditto
	size_t subImage() const
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
	///ditto
	size_t subRange() const
	{
		return imageInfo.number_scenes;
	}

	/**
	 * Image _type.
	 */
	void type(ImageType t)
	{
		imageInfo.type = t;
	}
	///ditto
	ImageType type() const
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
	///ditto
	bool verbose() const
	{
		return imageInfo.verbose == 1;
	}

	/**
	 * FlashPix viewing parameters.
	 */
	void view(string str)
	{
		copyString(imageInfo.view, str);
	}
	///ditto
	string view() const
	{
		return to!(string)(imageInfo.view);
	}

	/**
	 * Image virtual pixel _method.
	 */
	void virtualPixelMethod(VirtualPixelMethod method)
	{
		imageInfo.virtual_pixel_method = method;
	}
	///ditto
	VirtualPixelMethod virtualPixelMethod() const
	{
		return imageInfo.virtual_pixel_method;
	}

	/**
	 * X11 display to display to obtain fonts from or, to capture image from.
	 */
	void x11Display(string str)
	{
		copyString(imageInfo.server_name, str);
		drawInfo.server_name = imageInfo.server_name;
	}
	///ditto
	string x11Display() const
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

	/+***************************************************************
	 * DrawInfo fields
	 ***************************************************************+/

	void affine(AffineMatrix affine)
	{
		drawInfo.affine = affine;
	}
	AffineMatrix affine() const
	{
		return drawInfo.affine;
	}

	/**
	 * Origin of coordinate system to use when annotating or drawing
	 */
	void transformOrigin (double tx, double ty)
	{
		AffineMatrix affine;
		affine.sx = 1.0;
		affine.rx = 0.0;
		affine.ry = 0.0;
		affine.sy = 1.0;
		affine.tx = tx;
		affine.ty = ty;

		drawInfo.affine = multiplyMatrix(drawInfo.affine, affine);
	}

	/**
	 * Rotation to use when annotating or drawing
	 */
	void transformRotation(double angle)
	{
		AffineMatrix affine;
		affine.sx = cos(degreesToRadians(angle % 360.0));
		affine.rx = sin(degreesToRadians(angle % 360.0));
		affine.ry = -affine.rx;
		affine.sy =  affine.sx;
		affine.tx = 0.0;
		affine.ty = 0.0;

		drawInfo.affine = multiplyMatrix(drawInfo.affine, affine);
	}

	/**
	 * Scale to use when annotating or drawing
	 */
	void transformScale(double sx, double sy)
	{
		AffineMatrix affine;
		affine.sx = sx;
		affine.rx = 0.0;
		affine.ry = 0.0;
		affine.sy = sy;
		affine.tx = 0.0;
		affine.ty = 0.0;

		drawInfo.affine = multiplyMatrix(drawInfo.affine, affine);
	}

	/**
	 * Shear to use in X axis when annotating or drawing
	 */
	void transformShearX(double skewx)
	{
		AffineMatrix affine;
		affine.sx = 1.0;
		affine.rx = 0.0;
		affine.ry = tan(degreesToRadians(skewx % 360.0));
		affine.sy = 1.0;
		affine.tx = 0.0;
		affine.ty = 0.0;

		drawInfo.affine = multiplyMatrix(drawInfo.affine, affine);
	}

	/**
	 * Shear to use in X axis when annotating or drawing
	 */
	void transformShearY(double skewy)
	{
		AffineMatrix affine;
		affine.sx = 1.0;
		affine.rx = tan(degreesToRadians(skewy % 360.0));
		affine.ry = 0.0;
		affine.sy = 1.0;
		affine.tx = 0.0;
		affine.ty = 0.0;

		drawInfo.affine = multiplyMatrix(drawInfo.affine, affine);
	}

	/**
	 * Reset transformation parameters to default
	 */
	void transformReset()
	{
		drawInfo.affine.sx = 1.0;
		drawInfo.affine.rx = 0.0;
		drawInfo.affine.ry = 0.0;
		drawInfo.affine.sy = 1.0;
		drawInfo.affine.tx = 0.0;
		drawInfo.affine.ty = 0.0;
	}

	/**
	 * Returns the product of two Affine matrices
	 * The AffineMatrix looks like this:
	 * -----------
	 * | sx rx 0 |
	 * | ry sy 0 |
	 * | tx ty 1 |
	 * -----------
	 */
	AffineMatrix multiplyMatrix(AffineMatrix a, AffineMatrix b)
	{
		AffineMatrix result;

		result.sx = a.sx * b.sx + a.rx * b.ry;
		result.rx = a.sx * b.rx + a.rx * b.sy;
		result.ry = a.ry * b.sx + a.sy * b.ry;
		result.sy = a.ry * b.rx + a.sy * b.sy;
		result.tx = a.tx * b.sx + a.ty * b.ry + b.tx;
		result.ty = a.tx * b.rx + a.ty * b.sy + b.ty;

		return result;
	}

	/**
	 * Control antialiasing of rendered Postscript
	 * and Postscript or TrueType fonts. The default is true.
	 */
	void antialias(bool antialias)
	{
		drawInfo.text_antialias = antialias;
	}
	///ditto
	bool antialias() const
	{
		return drawInfo.text_antialias == 1;
	}

	/**
	 * If set, causes the text to be drawn over a box of the specified color.
	 */
	void boxColor(string color)
	{
		boxColor = new Color(color);
	}
	///ditto
	void boxColor(Color color)
	{
		drawInfo.undercolor = color.pixelPacket;
	}
	///ditto
	Color boxColor() const
	{
		return new Color(drawInfo.undercolor);
	}

	/**
	 * Color to use when filling drawn objects.
	 * The default is "black".
	 */
	void fillColor(string color)
	{
		fillColor = new Color(color);
	}
	///ditto
	void fillColor(Color color)
	{
		drawInfo.fill = color.pixelPacket;
	}
	///ditto
	Color fillColor() const
	{
		return new Color(drawInfo.fill);
	}

	/**
	 * Pattern image to use when filling drawn objects.
	 */
	//TODO: investigate if we need to clone the image.
	void fillPattern(dmagick.Image.Image pattern)
	{
		if (drawInfo.fill_pattern)
			drawInfo.fill_pattern = DestroyImageList(drawInfo.fill_pattern);

		drawInfo.fill_pattern = ReferenceImage(pattern.imageRef);
	}
	///ditto
	const(dmagick.Image.Image) fillPattern() const
	{
		return new dmagick.Image.Image(ReferenceImage((cast(DrawInfo*)drawInfo).fill_pattern));
	}

	/**
	 * Rule to use when filling drawn objects.
	 */
	void fillRule(FillRule rule)
	{
		drawInfo.fill_rule = rule;
	}
	///ditto
	FillRule fillRule() const
	{
		return drawInfo.fill_rule;
	}

	/**
	 * Specify the font family, such as "arial" or "helvetica".
	 */
	void fontFamily(string type)
	{
		copyString(drawInfo.family, type);
	}
	///ditto
	string fontFamily() const
	{
		return to!(string)(drawInfo.family);
	}

	/**
	 * Specify the spacing between text characters.
	 */
	void fontStretch(StretchType type)
	{
		drawInfo.stretch = type;
	}
	///ditto
	StretchType fontStretch() const
	{
		return drawInfo.stretch;
	}

	/**
	 * Specify the font style, i.e. italic, oblique, or normal.
	 */
	void fontStyle(StyleType type)
	{
		drawInfo.style = type;
	}
	///ditto
	StyleType fontStyle() const
	{
		return drawInfo.style;
	}

	/**
	 * Specify the font weight.
	 */
	void fontWeight(size_t weight)
	{
		drawInfo.weight = type;
	}
	///ditto
	size_t fontWeight() const
	{
		return drawInfo.weight;
	}

	/**
	 * Enable or disable anti-aliasing when drawing object outlines.
	 */
	void strokeAntialias(bool antialias)
	{
		drawInfo.stroke_antialias = antialias;
	}
	///ditto
	bool strokeAntialias() const
	{
		return drawInfo.stroke_antialias == 1;
	}

	/**
	 * Color to use when drawing object outlines.
	 */
	void strokeColor(string color)
	{
		strokeColor = new Color(color);
	}
	///ditto
	void strokeColor(Color color)
	{
		drawInfo.stroke = color.pixelPacket;
	}
	///ditto
	Color strokeColor() const
	{
		return new Color(drawInfo.stroke);
	}

	/**
	 * The initial distance into the dash pattern. The units are pixels.
	 */
	void strokeDashOffset(double offset)
	{
		drawInfo.dash_offset = offset;
	}
	///ditto
	double strokeDashOffset() const
	{
		return drawInfo.dash_offset;
	}

	/**
	 * Describe a _pattern of dashes to be used when stroking paths.
	 * The arguments are a list of pixel widths of
	 * alternating dashes and gaps.
	 * All elements must be > 0.
	 */
	void strokeDashPattern(const(double)[] pattern)
	{
		if ( drawInfo.dash_pattern !is null )
			RelinquishMagickMemory(drawInfo.dash_pattern);

		if ( pattern is null )
			return;

		drawInfo.dash_pattern = cast(double*)AcquireMagickMemory((pattern.length+1) * double.sizeof);
		drawInfo.dash_pattern[0 .. pattern.length] = pattern;
		drawInfo.dash_pattern[pattern.length] = 0.0;
	}
	///ditto
	double[] strokeDashPattern() const
	{
		size_t x;
		for (x = 0; drawInfo.dash_pattern[x] == 0.0; x++ ) {}

		double[] pattern = new double[x];
		pattern[] = drawInfo.dash_pattern[0 .. x];

		return pattern;
	}

	/**
	 * Specify how the line ends should be drawn.
	 */
	void strokeLineCap(LineCap cap)
	{
		drawInfo.linecap = cap;
	}
	///ditto
	LineCap strokeLineCap() const
	{
		return drawInfo.linecap;
	}

	/**
	 * Specify how corners are drawn.
	 */
	void strokeLineJoin(LineJoin join)
	{
		drawInfo.linejoin = join;
	}
	///ditto
	LineJoin lineJoin() const
	{
		return drawInfo.linejoin;
	}

	/**
	 * Specify a constraint on the length of the "miter"
	 * formed by two lines meeting at an angle. If the angle
	 * if very sharp, the miter could be very long relative
	 * to the line thickness. The miter _limit is a _limit on
	 * the ratio of the miter length to the line width.
	 * The default is 4.
	 */
	void strokeMiterlimit(size_t limit)
	{
		drawInfo.miterlimit = limit;
	}
	///ditto
	size_t strokeMiterlimit() const
	{
		return drawInfo.miterlimit;
	}

	/**
	 * Pattern image to use while drawing object stroke
	 */
	//TODO: investigate if we need to clone the image.
	void strokePattern(dmagick.Image.Image pattern)
	{
		if (drawInfo.stroke_pattern)
			drawInfo.stroke_pattern = DestroyImageList(drawInfo.stroke_pattern);

		drawInfo.stroke_pattern = ReferenceImage(pattern.imageRef);
	}
	///ditto
	const(dmagick.Image.Image) strokePattern() const
	{
		return new dmagick.Image.Image(ReferenceImage((cast(DrawInfo*)drawInfo).stroke_pattern));
	}

	/**
	 * Stroke _width for use when drawing vector objects
	 */
	void strokeWidth(double width)
	{
		drawInfo.stroke_width = width;
	}
	///ditto
	double strokeWidth() const
	{
		return drawInfo.stroke_width;
	}

	/**
	 * The text density in the x and y directions. The default is "72x72".
	 */
	void textDensity(string str)
	{
		copyString(imageInfo.density, str);
	}
	///ditto
	void textDensity(Geometry geometry)
	{
		textDensity(geometry.toString);
	}
	///ditto
	Geometry textDensity() const
	{
		return Geometry( to!(string)(imageInfo.density) );
	}

	/**
	 * Specify the code set to use for text annotations.
	 * The only character encoding which may be specified at
	 * this time is "UTF-8" for representing Unicode as a
	 * sequence of bytes. Specify an empty string to use
	 * ASCII encoding. Successful text annotation using
	 * Unicode may require fonts designed to support Unicode.
	 * The default is "UTF-8"
	 */
	void textEncoding(string str)
	{
		copyString(drawInfo.encoding, str);
	}
	///ditto
	string textEncoding() const
	{
		return to!(string)(drawInfo.encoding);
	}

	//char* primitive,
	//char* geometry;
	//RectangleInfo viewbox;
	//GravityType gravity;
	//GradientInfo gradient;
	//MagickBooleanType tile,
	//DecorationType decorate;
	//CompositeOperator compose;
	//char* text;
	//size_t face;
	//char* metrics,
	//AlignType align;
	//char* clip_mask;
	//SegmentInfo bounds;
	//ClipPathUnits clip_units;
	//Quantum opacity;
	//MagickBooleanType render;
	//ElementReference element_reference;
	//MagickBooleanType ddebug;
	//size_t signature;
	//double kerning,
	//double interword_spacing,
	//double interline_spacing;
	//DirectionType direction;

	/+***************************************************************
	 * QuantizeInfo fields
	 ***************************************************************+/


	/**
	 * Preferred number of _colors in the image.
	 * The actual number of _colors in the image may be less
	 * than your request, but never more. Images with less
	 * unique _colors than specified with this option will have
	 * any duplicate or unused _colors removed.
	 */
	void quantizeColors(size_t colors)
	{
		quantizeInfo.number_colors = colors;
	}
	///ditto
	size_t quantizeColors() const
	{
		return quantizeInfo.number_colors;
	}

	/**
	 * Colorspace to quantize colors in.
	 * Empirical evidence suggests that distances in color spaces
	 * such as YUV or YIQ correspond to perceptual color differences
	 * more closely than do distances in RGB space. These color spaces
	 * may give better results when color reducing an image.
	 * The default is RGB
	 */
	void quantizeColorSpace(ColorspaceType type)
	{
		quantizeInfo.colorspace = type;
	}
	///ditto
	ColorspaceType quantizeColorSpace() const
	{
		return quantizeInfo.colorspace;
	}

	/**
	 * The basic strategy of dithering is to trade intensity resolution for
	 * spatial resolution by averaging the intensities of several neighboring
	 * pixels. Images which suffer from severe contouring when reducing
	 * colors can be improved with this option. 
	 */
	void quantizeDitherMethod(DitherMethod method)
	{
		quantizeInfo.dither_method = method;
	}
	///ditto
	DitherMethod quantizeDitherMethod() const
	{
		return quantizeInfo.dither_method;
	}

	/**
	 * Depth of the quantization color classification tree.
	 * Values of 0 or 1 allow selection of the optimal tree _depth
	 * for the color reduction algorithm. Values between 2 and 8
	 * may be used to manually adjust the tree _depth.
	 */
	void quantizeTreeDepth(size_t depth)
	{
		quantizeInfo.tree_depth = depth;
	}
	///ditto
	size_t quantizeTreeDepth() const
	{
		return quantizeInfo.tree_depth;
	}

	//MagickBooleanType measure_error;
	//size_t signature;
}
