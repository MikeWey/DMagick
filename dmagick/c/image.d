module dmagick.c.image;

import core.stdc.stdio;

import dmagick.c.cacheView;
import dmagick.c.color;
import dmagick.c.colorspace;
import dmagick.c.composite;
import dmagick.c.compress;
import dmagick.c.compress;
import dmagick.c.effect;
import dmagick.c.exception;
import dmagick.c.geometry;
import dmagick.c.layer;
import dmagick.c.magickType;
import dmagick.c.magickVersion;
import dmagick.c.monitor;
import dmagick.c.pixel;
import dmagick.c.profile;
import dmagick.c.quantum;
import dmagick.c.resample;
import dmagick.c.semaphore;
import dmagick.c.stream;
import dmagick.c.timer;

alias ptrdiff_t ssize_t;

extern(C)
{
	enum AlphaChannelType
	{
		UndefinedAlphaChannel,
		ActivateAlphaChannel,
		BackgroundAlphaChannel,
		CopyAlphaChannel,
		DeactivateAlphaChannel,
		ExtractAlphaChannel,
		OpaqueAlphaChannel,
		ResetAlphaChannel,
		SetAlphaChannel,
		ShapeAlphaChannel,
		TransparentAlphaChannel
	}

	enum ImageType
	{
		UndefinedType,
		BilevelType,
		GrayscaleType,
		GrayscaleMatteType,
		PaletteType,
		PaletteMatteType,
		TrueColorType,
		TrueColorMatteType,
		ColorSeparationType,
		ColorSeparationMatteType,
		OptimizeType,
		PaletteBilevelMatteType
	}

	enum InterlaceType
	{
		UndefinedInterlace,
		NoInterlace,
		LineInterlace,
		PlaneInterlace,
		PartitionInterlace,
		GIFInterlace,
		JPEGInterlace,
		PNGInterlace
	}

	enum OrientationType
	{
		UndefinedOrientation,
		TopLeftOrientation,
		TopRightOrientation,
		BottomRightOrientation,
		BottomLeftOrientation,
		LeftTopOrientation,
		RightTopOrientation,
		RightBottomOrientation,
		LeftBottomOrientation
	}

	enum ResolutionType
	{
		UndefinedResolution,
		PixelsPerInchResolution,
		PixelsPerCentimeterResolution
	}

	struct PrimaryInfo
	{
		double
			x,
			y,
			z;
	}

	struct SegmentInfo
	{
		double
			x1,
			y1,
			x2,
			y2;
	}

	enum TransmitType
	{
		UndefinedTransmitType,
		FileTransmitType,
		BlobTransmitType,
		StreamTransmitType,
		ImageTransmitType
	}

	struct ChromaticityInfo
	{
		PrimaryInfo
			red_primary,
			green_primary,
			blue_primary,
			white_point;
	}

	struct Image
	{
		ClassType
			storage_class;

		ColorspaceType
			colorspace;      /* colorspace of image data */

		CompressionType
			compression;     /* compression of image when read/write */

		size_t
			quality;         /* compression quality setting, meaning varies */

		OrientationType
			orientation;     /* photo orientation of image */

		MagickBooleanType
			taint,           /* has image been modified since reading */
			matte;           /* is transparency channel defined and active */

		size_t
			columns,         /* physical size of image */
			rows,
			depth,           /* depth of image on read/write */
			colors;          /* size of color table on read */

		PixelPacket*
			colormap;

		PixelPacket
			background_color, /* current background color attribute */
			border_color,     /* current bordercolor attribute */
			matte_color;      /* current mattecolor attribute */

		double
			gamma;

		ChromaticityInfo
			chromaticity;

		RenderingIntent
			rendering_intent;

		void*
			profiles;

		ResolutionType
			units;           /* resolution/density  ppi or ppc */

		char*
			montage,
			directory,
			geometry;

		ssize_t
			offset;

		double
			x_resolution,    /* image resolution/density */
			y_resolution;

		RectangleInfo
			page,            /* virtual canvas size and offset of image */
			extract_info,
			tile_info;       /* deprecated */

		double
			bias,
			blur,            /* deprecated */
			fuzz;            /* current color fuzz attribute */

		FilterTypes
			filter;          /* resize/distort filter to apply */

		InterlaceType
			interlace;

		EndianType
			endian;          /* raw data integer ordering on read/write */

		GravityType
			gravity;         /* Gravity attribute for positioning in image */

		CompositeOperator
			compose;         /* alpha composition method for layered images */

		DisposeType
			dispose;         /* GIF animation disposal method */

		Image*
			clip_mask;

		size_t
			scene,           /* index of image in multi-image file */
			delay;           /* Animation delay time */

		ssize_t
			ticks_per_second;  /* units for delay time, default 100 for GIF */

		size_t
			iterations,
			total_colors;

		ssize_t
			start_loop;

		ErrorInfo
			error;

		TimerInfo
			timer;

		MagickProgressMonitor
			progress_monitor;

		void*
			client_data,
			cache,
			attributes;      /* deprecated */

		Ascii85Info*
			ascii85;

		BlobInfo*
			blob;

		char[MaxTextExtent]
			filename,        /* images input filename */
			magick_filename,
			magick;

		size_t
			magick_columns,
			magick_rows;

		ExceptionInfo
			exception;       /* Error handling report */

		MagickBooleanType
			ddebug;          /* debug output attribute */

		ssize_t
			reference_count;

		SemaphoreInfo*
			semaphore;

		ProfileInfo
			color_profile,
			iptc_profile;

		ProfileInfo*
			generic_profile;

		size_t
			generic_profiles;

		size_t
			signature;

		Image*
			previous,        /* Image sequence list links */
			list,
			next;

		InterpolatePixelMethod
			interpolate;     /* Interpolation of color for between pixel lookups */

		MagickBooleanType
			black_point_compensation;

		PixelPacket
			transparent_color; /* color for 'transparent' color index in GIF */

		Image*
			mask;

		RectangleInfo
			tile_offset;

		void*
			properties,      /* per image properities */
			artifacts;       /* per image sequence image artifacts */

		ImageType
			type;

		MagickBooleanType
			dither;          /* dithering method during color reduction */

		MagickSizeType
			extent;

		static if ( MagickLibVersion >= 0x662 )
		{
			MagickBooleanType
				ping;
		}

		static if ( MagickLibVersion >= 0x670 )
		{
			size_t
				channels;
		}
	}

	struct ImageInfo
	{
		CompressionType
			compression;

		OrientationType
			orientation;

		MagickBooleanType
			temporary,
			adjoin,
			affirm,
			antialias;

		char*
			size,
			extract,
			page,
			scenes;

		size_t
			scene,
			number_scenes,
			depth;

		InterlaceType
			interlace;

		EndianType
			endian;

		ResolutionType
			units;

		size_t
			quality;

		char*
			sampling_factor,
			server_name,
			font,
			texture,
			density;

		double
			pointsize,
			fuzz;

		PixelPacket
			background_color,
			border_color,
			matte_color;

		MagickBooleanType
			dither,
			monochrome;

		size_t
			colors;

		ColorspaceType
			colorspace;

		ImageType
			type;

		PreviewType
			preview_type;

		ssize_t
			group;

		MagickBooleanType
			ping,
			verbose;

		char*
			view,
			authenticate;

		ChannelType
			channel;

		Image*
			attributes;

		void*
			options;

		MagickProgressMonitor
			progress_monitor;

		void*
			client_data,
			cache;

		StreamHandler
			stream;

		FILE*
			file;

		void*
			blob;

		size_t
			length;

		char[MaxTextExtent]
			magick,
			unique,
			zero,
			filename;

		MagickBooleanType
			ddebug;

		char*
			tile;

		size_t
			subimage,
			subrange;

		PixelPacket
			pen;

		size_t
			signature;

		VirtualPixelMethod
			virtual_pixel_method;

		PixelPacket
			transparent_color;

		void*
			profile;

		MagickBooleanType
			synchronize;
	}

	ExceptionType CatchImageException(Image*);

	FILE* GetImageInfoFile(const(ImageInfo)*);

	Image* AcquireImage(const(ImageInfo)*);
	Image* AppendImages(const(Image)*, const MagickBooleanType, ExceptionInfo*);
	Image* CloneImage(const(Image)*, const size_t, const size_t, const MagickBooleanType, ExceptionInfo*);
	Image* CombineImages(const(Image)*, const ChannelType, ExceptionInfo*);
	Image* DestroyImage(Image*);
	Image* GetImageClipMask(const(Image)*, ExceptionInfo*);
	Image* GetImageMask(const(Image)*, ExceptionInfo*);
	Image* NewMagickImage(const(ImageInfo)*, const size_t, const size_t, const(MagickPixelPacket)*);
	Image* ReferenceImage(Image*);
	Image* SeparateImages(const(Image)*, const ChannelType, ExceptionInfo*);

	static if ( MagickLibVersion >= 0x668 )
	{
		Image* SmushImages(const(Image)*, const MagickBooleanType, const ssize_t, ExceptionInfo*);
	}

	ImageInfo* AcquireImageInfo();
	ImageInfo* CloneImageInfo(const(ImageInfo)*);
	ImageInfo* DestroyImageInfo(ImageInfo*);

	static if (MagickLibVersion < 0x662)
	{
		MagickBooleanType AcquireImageColormap(Image*, const size_t);
	}

	MagickBooleanType ClipImage(Image*);
	MagickBooleanType ClipImagePath(Image*, const(char)*, const MagickBooleanType);
	MagickBooleanType GetImageAlphaChannel(const(Image)*);
	MagickBooleanType IsTaintImage(const(Image)*);
	MagickBooleanType IsMagickConflict(const(char)*);
	MagickBooleanType IsHighDynamicRangeImage(const(Image)*, ExceptionInfo*);
	MagickBooleanType IsImageObject(const(Image)*);
	MagickBooleanType ListMagickInfo(FILE*, ExceptionInfo*);
	MagickBooleanType ModifyImage(Image**, ExceptionInfo*);
	MagickBooleanType ResetImagePage(Image*, const(char)*);
	MagickBooleanType SeparateImageChannel(Image*, const ChannelType);
	MagickBooleanType SetImageAlphaChannel(Image*, const AlphaChannelType);
	MagickBooleanType SetImageBackgroundColor(Image*);
	MagickBooleanType SetImageClipMask(Image*, const(Image)*);

	static if (MagickLibVersion >= 0x662)
	{
		MagickBooleanType SetImageColor(Image*, const(MagickPixelPacket)*);
	}

	MagickBooleanType SetImageColor(Image*, const(MagickPixelPacket)*);
	MagickBooleanType SetImageExtent(Image*, const size_t, const size_t);
	MagickBooleanType SetImageInfo(ImageInfo*, const uint, ExceptionInfo*);
	MagickBooleanType SetImageMask(Image*, const(Image)*);
	MagickBooleanType SetImageOpacity(Image*, const Quantum);

	static if ( MagickLibVersion >= 0x670 )
	{
		MagickBooleanType SetImageChannels(Image*, const size_t);
	}

	MagickBooleanType SetImageStorageClass(Image*, const ClassType);
	MagickBooleanType SetImageType(Image*, const ImageType);
	MagickBooleanType StripImage(Image*);
	MagickBooleanType SyncImage(Image*);
	MagickBooleanType SyncImageSettings(const(ImageInfo)*, Image*);
	MagickBooleanType SyncImagesSettings(ImageInfo*, Image*);

	size_t InterpretImageFilename(const(ImageInfo)*, Image*, const(char)*, int, char*);

	ssize_t GetImageReferenceCount(Image*);

	static if ( MagickLibVersion >= 0x670 )
	{
		size_t GetImageChannels(Image*);
	}

	VirtualPixelMethod GetImageVirtualPixelMethod(const(Image)*);
	VirtualPixelMethod SetImageVirtualPixelMethod(const(Image)*, const VirtualPixelMethod);

	void AcquireNextImage(const(ImageInfo)*, Image*);
	void DestroyImagePixels(Image*);
	void DisassociateImageStream(Image*);
	void GetImageException(Image*, ExceptionInfo*);
	void GetImageInfo(ImageInfo*);
	void SetImageInfoBlob(ImageInfo*, const(void)*, const size_t);
	void SetImageInfoFile(ImageInfo*, FILE*);
}
