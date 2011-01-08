module dmagick.c.pixel;

import core.sys.posix.sys.types;

import dmagick.c.magickType;
import dmagick.c.colorspace;
import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.constitute;

extern(C)
{
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

	MagickBooleanType ExportImagePixels(const Image*, const ssize_t, const ssize_t, const size_t, const size_t, const char*, const StorageType, void*, ExceptionInfo*);
	MagickBooleanType ImportImagePixels(Image*, const ssize_t, const ssize_t, const size_t, const size_t, const char*, const StorageType, const void*);

	void GetMagickPixelPacket(const Image*, MagickPixelPacket*);
}
