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
	enum InterpolatePixelMethod
	{
		UndefinedInterpolatePixel,
		AverageInterpolatePixel,
		BicubicInterpolatePixel,
		BilinearInterpolatePixel,
		FilterInterpolatePixel,
		IntegerInterpolatePixel,
		MeshInterpolatePixel,
		NearestNeighborInterpolatePixel,
		SplineInterpolatePixel
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

	MagickBooleanType ExportImagePixels(const(Image)*, const ssize_t, const ssize_t, const size_t, const size_t, const(char)*, const StorageType, void*, ExceptionInfo*);
	MagickBooleanType ImportImagePixels(Image*, const ssize_t, const ssize_t, const size_t, const size_t, const(char)*, const StorageType, const(void)*);

	static if ( MagickLibVersion >= 0x669 )
	{
		MagickBooleanType InterpolateMagickPixelPacket(const Image*, const CacheView*, const InterpolatePixelMethod, const double, const double, MagickPixelPacket*, ExceptionInfo*);
	}

	void GetMagickPixelPacket(const(Image)*, MagickPixelPacket*);
}
