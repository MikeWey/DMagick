module dmagick.c.pixel;

import core.sys.posix.sys.types;

import dmagick.c.cacheView;
import dmagick.c.colorspace;
import dmagick.c.constitute;
import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;

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
	MagickBooleanType InterpolateMagickPixelPacket(const Image*, const CacheView*, const InterpolatePixelMethod, const double, const double, MagickPixelPacket*, ExceptionInfo*);

	void GetMagickPixelPacket(const(Image)*, MagickPixelPacket*);
}
