module dmagick.c.image;

import core.stdc.stdio;
import core.stdc.time;

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
	/**
	 * Used to set a flag on an image indicating whether or not to use
	 * existing alpha channel data, to create an alpha channel, or to
	 * perform other operations on the alpha channel.
	 */
	enum AlphaChannelType
	{
		/** */
		UndefinedAlphaChannel,

		/**
		 * Enable the image's transparency channel. Note normally
		 * SetAlphaChannel should be used instead of this, unless you
		 * specifically need to preserve existing (but specifically turned
		 * Off) transparency channel.
		 */
		ActivateAlphaChannel,

		/**
		 * Set any fully-transparent pixel to the background color, while
		 * leaving it fully-transparent. This can make some image file
		 * formats, such as PNG, smaller as the RGB values of transparent
		 * pixels are more uniform, and thus can compress better.
		 */
		BackgroundAlphaChannel,

		/**
		 * Turns On the alpha/matte channel, then copies the gray-scale
		 * intensity of the image, into the alpha channel, converting a
		 * gray-scale mask into a transparent shaped mask ready to be
		 * colored appropriately. The color channels are not modified.
		 */
		CopyAlphaChannel,

		/**
		 * Disables the image's transparency channel. Does not delete or
		 * change the existing data, just turns off the use of that data.
		 */
		DeactivateAlphaChannel,

		/**
		 * Copies the alpha channel values into all the color channels and
		 * turns 'Off' the the image's transparency, so as to generate a
		 * gray-scale mask of the image's shape. The alpha channel data is
		 * left intact just deactivated. This is the inverse of
		 * CopyAlphaChannel.
		 */
		ExtractAlphaChannel,

		/**
		 * Enables the alpha/matte channel and forces it to be fully opaque.
		 */
		OpaqueAlphaChannel,

		/** */
		ResetAlphaChannel,

		/**
		 * Activates the alpha/matte channel. If it was previously turned
		 * off then it also resets the channel to opaque. If the image
		 * already had the alpha channel turned on, it will have no effect.
		 */
		SetAlphaChannel,

		/**
		 * As per CopyAlphaChannel but also colors the resulting shape mask
		 * with the current background color. That is the RGB color channels
		 * is replaced, with appropriate alpha shape.
		 */
		ShapeAlphaChannel,

		/**
		 * Activates the alpha/matte channel and forces it to be fully
		 * transparent. This effectively creates a fully transparent image
		 * the same size as the original and with all its original RGB data
		 * still intact, but fully transparent.
		 */
		TransparentAlphaChannel,

		/**
		 * Flatten image pixels over the background pixels.
		 * 
		 * Since: ImageMagick 6.7.6.
		 */
		FlattenAlphaChannel,

		/** ditto */
		RemoveAlphaChannel,

		/** */
		AssociateAlphaChannel,

		/** */
		DisassociateAlphaChannel
	}

	/**
	 * Indicate the type classification of the image.
	 */
	enum ImageType
	{
		UndefinedType,       /// No type has been specified.
		BilevelType,         /// Monochrome image.
		GrayscaleType,       /// Grayscale image.
		GrayscaleMatteType,  /// Grayscale image with opacity.
		PaletteType,         /// Indexed color (palette) image.
		PaletteMatteType,    /// Indexed color (palette) image with opacity.
		TrueColorType,       /// Truecolor image.
		TrueColorMatteType,  /// Truecolor image with opacity.
		ColorSeparationType, /// Cyan/Yellow/Magenta/Black (CYMK) image.
		ColorSeparationMatteType, /// Cyan/Yellow/Magenta/Black (CYMK) image with opacity.
		OptimizeType,        ///
		PaletteBilevelMatteType   ///
	}

	/**
	 * Specify the ordering of the red, green, and blue pixel information in
	 * the image. Interlacing is usually used to make image information
	 * available to the user faster by taking advantage of the space vs
	 * time tradeoff. For example, interlacing allows images on the Web to
	 * be recognizable sooner and satellite images to accumulate/render with
	 * image resolution increasing over time. Use LineInterlace or
	 * PlaneInterlace to create an interlaced GIF or progressive JPEG image.
	 */
	enum InterlaceType
	{
		/**
		 * No interlace type has been specified.
		 */
		UndefinedInterlace,

		/**
		 * Don't interlace image (RGBRGBRGBRGBRGBRGB...).
		 */
		NoInterlace,

		/**
		 * Use scanline interlacing (RRR...GGG...BBB...RRR...GGG...BBB...).
		 */
		LineInterlace,

		/**
		 * Use plane interlacing (RRRRRR...GGGGGG...BBBBBB...).
		 */
		PlaneInterlace,

		/**
		 * Similar to plane interlacing except that the different planes are
		 * saved to individual files (e.g. image.R, image.G, and image.B)
		 */
		PartitionInterlace,

		/** */
		GIFInterlace,

		/** */
		JPEGInterlace,

		/** */
		PNGInterlace
	}

	/**
	 * Specify the orientation of the image pixels.
	 */
	enum OrientationType
	{
		/**
		 * See_Also: $(LINK http://jpegclub.org/exif_orientation.html )
		 */
		UndefinedOrientation,
		TopLeftOrientation,      /// ditto
		TopRightOrientation,     /// ditto
		BottomRightOrientation,  /// ditto
		BottomLeftOrientation,   /// ditto
		LeftTopOrientation,      /// ditto
		RightTopOrientation,     /// ditto
		RightBottomOrientation,  /// ditto
		LeftBottomOrientation    /// ditto
	}

	/**
	 * By default, ImageMagick defines resolutions in pixels per inch.
	 * ResolutionType provides a means to adjust this.
	 */
	enum ResolutionType
	{
		/**
		 * No resolution has been specified.
		 */
		UndefinedResolution,

		/**
		 * Density specifications are specified in units
		 * of pixels per inch (English units).
		 */
		PixelsPerInchResolution,

		/**
		 * Density specifications are specified in units
		 * of pixels per centimeter (metric units).
		 */
		PixelsPerCentimeterResolution
	}

	/** */
	struct PrimaryInfo
	{
		double
			x, /// X ordinate.
			y, /// Y ordinate.
			z; /// Z ordinate. This attribute is always ignored.
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

	/**
	 * A Chromaticity object represents chromaticity values.
	 */
	struct ChromaticityInfo
	{
		PrimaryInfo
			red_primary,   /// Red primary point (e.g. red_primary.x=0.64, red_primary.y=0.33)
			green_primary, /// Green primary point (e.g. green_primary.x=0.3, green_primary.y=0.6)
			blue_primary,  /// Blue primary point (e.g. blue_primary.x=0.15, blue_primary.y=0.06)
			white_point;   /// White point (e.g. white_point.x=0.3127, white_point.y=0.329)
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
			magick_filename, /* ditto with coders, and read_mods */
			magick;          /* Coder used to decode image */

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
			previous,        /* Image list links */
			list,            /* Undo/Redo image processing list (for display) */
			next;            /* Image list links */

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

		static if ( MagickLibVersion >= 0x683 )
		{
			time_t
				timestamp;
		}

		static if ( MagickLibVersion >= 0x684 )
		{
			PixelIntensityMethod
				intensity;      /* method to generate an intensity value from a pixel */
		}

		static if ( MagickLibVersion >= 0x689 )
		{
			/** Total animation duration sum(delay*iterations) */
			size_t duration;
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
	Image* DestroyImage(Image*);
	Image* GetImageClipMask(const(Image)*, ExceptionInfo*);
	Image* GetImageMask(const(Image)*, ExceptionInfo*);
	Image* NewMagickImage(const(ImageInfo)*, const size_t, const size_t, const(MagickPixelPacket)*);
	Image* ReferenceImage(Image*);

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
	MagickBooleanType IsTaintImage(const(Image)*);
	MagickBooleanType IsMagickConflict(const(char)*);
	MagickBooleanType IsHighDynamicRangeImage(const(Image)*, ExceptionInfo*);
	MagickBooleanType IsImageObject(const(Image)*);
	MagickBooleanType ListMagickInfo(FILE*, ExceptionInfo*);
	MagickBooleanType ModifyImage(Image**, ExceptionInfo*);
	MagickBooleanType ResetImagePage(Image*, const(char)*);
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
