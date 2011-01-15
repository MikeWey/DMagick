module dmagick.c.image;

import core.stdc.stdio;
import core.sys.posix.sys.types;

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
import dmagick.c.monitor;
import dmagick.c.pixel;
import dmagick.c.profile;
import dmagick.c.quantum;
import dmagick.c.resample;
import dmagick.c.semaphore;
import dmagick.c.stream;
import dmagick.c.timer;

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
			colorspace;

		CompressionType
			compression;

		size_t
			quality;

		OrientationType
			orientation;

		MagickBooleanType
			taint,
			matte;

		size_t
			columns,
			rows,
			depth,
			colors;

		PixelPacket*
			colormap;

		PixelPacket
			background_color,
			border_color,
			matte_color;

		double
			gamma;

		ChromaticityInfo
			chromaticity;

		RenderingIntent
			rendering_intent;

		void*
			profiles;

		ResolutionType
			units;

		char*
			montage,
			directory,
			geometry;

		ssize_t
			offset;

		double
			x_resolution,
			y_resolution;

		RectangleInfo
			page,
			extract_info,
			tile_info;

		double
			bias,
			blur,
			fuzz;

		FilterTypes
			filter;

		InterlaceType
			interlace;

		EndianType
			endian;

		GravityType
			gravity;

		CompositeOperator
			compose;

		DisposeType
			dispose;

		Image*
			clip_mask;

		size_t
			scene,
			delay;

		ssize_t
			ticks_per_second;

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
			attributes;

		Ascii85Info*
			ascii85;

		BlobInfo*
			blob;

		char[MaxTextExtent]
			filename,
			magick_filename,
			magick;

		size_t
			magick_columns,
			magick_rows;

		ExceptionInfo
			exception;

		MagickBooleanType
			ddebug;

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
			previous,
			list,
			next;

		InterpolatePixelMethod
			interpolate;

		MagickBooleanType
			black_point_compensation;

		PixelPacket
			transparent_color;

		Image*
			mask;

		RectangleInfo
			tile_offset;

		void*
			properties,
			artifacts;

		ImageType
			type;

		MagickBooleanType
			dither;

		MagickSizeType
			extent;

		MagickBooleanType
			ping;
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

	ImageInfo* AcquireImageInfo();
	ImageInfo* CloneImageInfo(const(ImageInfo)*);
	ImageInfo* DestroyImageInfo(ImageInfo*);

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
	MagickBooleanType SetImageColor(Image*, const(MagickPixelPacket)*);
	MagickBooleanType SetImageExtent(Image*, const size_t, const size_t);
	MagickBooleanType SetImageInfo(ImageInfo*, const uint, ExceptionInfo*);
	MagickBooleanType SetImageMask(Image*, const(Image)*);
	MagickBooleanType SetImageOpacity(Image*, const Quantum);
	MagickBooleanType SetImageStorageClass(Image*, const ClassType);
	MagickBooleanType SetImageType(Image*, const ImageType);
	MagickBooleanType StripImage(Image*);
	MagickBooleanType SyncImage(Image*);
	MagickBooleanType SyncImageSettings(const(ImageInfo)*, Image*);
	MagickBooleanType SyncImagesSettings(ImageInfo*, Image*);

	size_t InterpretImageFilename(const(ImageInfo)*, Image*, const(char)*, int, char*);

	ssize_t GetImageReferenceCount(Image*);

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
