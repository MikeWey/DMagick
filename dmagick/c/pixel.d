module dmagick.c.pixel;

import dmagick.c.cacheView;
import dmagick.c.colorspace;
import dmagick.c.constitute;
import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;

alias ptrdiff_t ssize_t;

extern(C)
{
	/**
	 * The pixel color interpolation method.
	 */
	enum InterpolatePixelMethod
	{
		UndefinedInterpolatePixel,       ///
		AverageInterpolatePixel,         /// The average color of the surrounding four pixels.
		BicubicInterpolatePixel,         /// Fitted bicubic-spines of surrounding 16 pixels.
		BilinearInterpolatePixel,        /// A double linear interpolation of pixels (the default).
		FilterInterpolatePixel,          /// Use resize filter settings.
		IntegerInterpolatePixel,         /// The color of the top-left pixel (floor function).
		MeshInterpolatePixel,            /// Divide area into two flat triangular interpolations.
		NearestNeighborInterpolatePixel, /// The nearest pixel to the lookup point (rounded function).
		SplineInterpolatePixel,          /// Direct spline curves (colors are blurred).
		Average9InterpolatePixel,        /// Average 9 nearest neighbours.
		Average16InterpolatePixel,       /// Average 16 nearest neighbours.
		BlendInterpolatePixel,           /// blend of nearest 1, 2 or 4 pixels.
		BackgroundInterpolatePixel,      /// just return background color.
		CatromInterpolatePixel           /// Catmull-Rom interpolation.
	}


	static if ( MagickLibVersion >= 0x671 )
	{
		enum PixelComponent
		{
			PixelRed = 0,
			PixelCyan = 0,
			PixelGray = 0,
			PixelY = 0,
			PixelGreen = 1,
			PixelMagenta = 1,
			PixelCb = 1,
			PixelBlue = 2,
			PixelYellow = 2,
			PixelCr = 2,
			PixelAlpha = 3,
			PixelBlack = 4,
			PixelIndex = 4,
		}
	}
	else
	{
		enum PixelComponent
		{
			RedPixelComponent = 0,
			CyanPixelComponent = 0,
			GrayPixelComponent = 0,
			YPixelComponent = 0,
			GreenPixelComponent = 1,
			MagentaPixelComponent = 1,
			CbPixelComponent = 1,
			BluePixelComponent = 2,
			YellowPixelComponent = 2,
			CrPixelComponent = 2,
			AlphaPixelComponent = 3,
			BlackPixelComponent = 4,
			IndexPixelComponent = 4,
			MaskPixelComponent = 5
		}
	}

	enum PixelIntensityMethod
	{
		UndefinedPixelIntensityMethod = 0,
		AveragePixelIntensityMethod,
		BrightnessPixelIntensityMethod,
		LightnessPixelIntensityMethod,
		Rec601LumaPixelIntensityMethod,
		Rec601LuminancePixelIntensityMethod,
		Rec709LumaPixelIntensityMethod,
		Rec709LuminancePixelIntensityMethod,
		RMSPixelIntensityMethod,
		MSPixelIntensityMethod
	}

	struct DoublePixelPacket
	{
		double
			red,
			green,
			blue,
			opacity,
			index;
	}

	struct LongPixelPacket
	{
		uint
			red,
			green,
			blue,
			opacity,
			index;
	} 

	struct MagickPixelPacket
	{
		ClassType
			storage_class;

		ColorspaceType
			colorspace;

		MagickBooleanType
			matte;

		double
			fuzz;

		size_t
			depth;

		MagickRealType
			red,
			green,
			blue,
			opacity,
			index;
	}

	alias Quantum IndexPacket;

	struct PixelPacket
	{
		Quantum
			blue,
			green,
			red,
			opacity;
	}

	static if ( MagickLibVersion >= 0x680 )
	{
		struct QuantumPixelPacket
		{
			Quantum
				red,
				green,
				blue,
				opacity,
				index;
		}
	}

	MagickBooleanType ExportImagePixels(const(Image)*, const ssize_t, const ssize_t, const size_t, const size_t, const(char)*, const StorageType, void*, ExceptionInfo*);
	MagickBooleanType ImportImagePixels(Image*, const ssize_t, const ssize_t, const size_t, const size_t, const(char)*, const StorageType, const(void)*);

	static if ( MagickLibVersion >= 0x669 )
	{
		MagickBooleanType InterpolateMagickPixelPacket(const(Image)*, const(CacheView)*, const InterpolatePixelMethod, const double, const double, MagickPixelPacket*, ExceptionInfo*);
	}

	static if ( MagickLibVersion >= 0x678 )
	{
		MagickPixelPacket* CloneMagickPixelPacket(const(MagickPixelPacket)*);
	}

	static if ( MagickLibVersion >= 0x682 )
	{
		MagickRealType DecodePixelGamma(const MagickRealType);
		MagickRealType EncodePixelGamma(const MagickRealType);
	}

	static if ( MagickLibVersion >= 0x684 )
	{
		MagickRealType GetPixelIntensity(const(Image)* image, const(PixelPacket)* restrict);
	}

	static if ( MagickLibVersion >= 0x690 )
	{
		void ConformMagickPixelPacket(Image*, const(MagickPixelPacket)*, MagickPixelPacket*, ExceptionInfo*);
	}

	void GetMagickPixelPacket(const(Image)*, MagickPixelPacket*);
}
