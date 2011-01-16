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

	//ImageInfo fields

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

	void density(string str)
	{
		copyString(imageInfo.density, str);
	}
	string density()
	{
		return to!(string)(imageInfo.density);
	}

	void depth(size_t d)
	{
		imageInfo.depth = d;
	}
	size_t depth()
	{
		return imageInfo.depth;
	}

	void dither(bool d)
	{
		imageInfo.dither = d;
	}
	size_t dither()
	{
		return imageInfo.dither;
	}

	void endian(EndianType type)
	{
		imageInfo.endian = type;
	}
	EndianType endian()
	{
		return imageInfo.endian;
	}

	void file(FILE* f)
	{
		imageInfo.file = f;
	}
	FILE* file()
	{
		return imageInfo.file;
	}

	void filename(string str)
	{
		copyString(imageInfo.filename, str);
	}
	string filename()
	{
		return imageInfo.filename[0 .. strlen(imageInfo.filename.ptr)].idup;
	}

	void font(string str)
	{
		copyString(imageInfo.font, str);
		copyString(drawInfo.font, str);
	}
	string font()
	{
		return to!(string)(drawInfo.font);
	}

	void fuzz(double f)
	{
		imageInfo.fuzz = f;
	}
	double fuzz()
	{
		return imageInfo.fuzz;
	}

	void interlace(InterlaceType type)
	{
		imageInfo.interlace = type;
	}
	InterlaceType interlace()
	{
		return imageInfo.interlace;
	}

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

	void monochrome(bool m)
	{
		imageInfo.monochrome = m;
	}
	bool monochrome()
	{
		return imageInfo.monochrome;
	}

	void numberOfScenes(size_t num)
	{
		imageInfo.number_scenes = num;
	}
	size_t numberOfScenes()
	{
		return imageInfo.number_scenes;
	}

	void page(string str)
	{
		copyString(imageInfo.page, str);
	}
	string page()
	{
		return to!(string)(imageInfo.page);
	}

	void pointSize(double size)
	{
		imageInfo.pointsize = size;
		drawInfo.pointsize = size;
	}
	double pointSize()
	{
		return drawInfo.pointsize;
	}

	void quality(size_t q)
	{
		imageInfo.quality = q;
	}
	size_t quality()
	{
		return imageInfo.quality;
	}

	void resolutionUnits(ResolutionType type)
	{
		imageInfo.units = type;
	}
	ResolutionType resolutionUnits()
	{
		return imageInfo.units;
	}

	void samplingFactor(string str)
	{
		copyString(imageInfo.sampling_factor, str);
	}
	string samplingFactor()
	{
		return to!(string)(imageInfo.sampling_factor);
	}

	void scene(size_t num)
	{
		imageInfo.scene = num;
	}
	size_t scene()
	{
		return imageInfo.scene;
	}

	void size(string str)
	{
		copyString(imageInfo.size, str);
	}
	string size()
	{
		return to!(string)(imageInfo.size);
	}

	void type(ImageType t)
	{
		imageInfo.type = t;
	}
	ImageType type()
	{
		return imageInfo.type;
	}

	void verbose(bool v)
	{
		imageInfo.verbose = v;
	}
	bool verbose()
	{
		return imageInfo.verbose;
	}

	void view(string str)
	{
		copyString(imageInfo.view, str);
	}
	string view()
	{
		return to!(string)(imageInfo.view);
	}

	//TODO: Delegates?
	void virtualPixelMethod(VirtualPixelMethod method)
	{
		imageInfo.virtual_pixel_method = method;
	}
	VirtualPixelMethod virtualPixelMethod()
	{
		return imageInfo.virtual_pixel_method;
	}

	void x11Display(string str)
	{
		copyString(imageInfo.server_name, str);
	}
	string x11Display()
	{
		return to!(string)(imageInfo.server_name);
	}

	////OrientationType orientation;
	////MagickBooleanType temporary,
	////MagickBooleanType affirm,
	////MagickBooleanType antialias;
	////char* extract,
	////char* scenes;
	////size_t colors;
	////PreviewType preview_type;
	////ssize_t group;
	////MagickBooleanType ping,
	////char* authenticate;
	////ChannelType channel;
	////void* options;
	////MagickProgressMonitor progress_monitor;
	////void* client_data,
	////void* cache;
	////StreamHandler stream;
	////void* blob;
	////size_t length;
	////char[MaxTextExtent] unique,
	////char[MaxTextExtent] zero,
	////size_t signature;
	////PixelPacket transparent_color;
	////void* profile;
	////MagickBooleanType synchronize;

	private void copyString(ref char[MaxTextExtent] dest, string source)
	{
		if ( source.length < MaxTextExtent )
			throw new Exception("text is to long"); //TODO: a proper exception.

		dest[0 .. source.length] = str;
		dest[source.length] = '\0';
	}

	/**
	 * Using CloneString whould force us to append a \0
	 * to the end of the string which might relocate the sting,
	 * and that is wastefull if we are just going to copy it.
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
