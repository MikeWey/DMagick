module dmagick.c.color;

import core.stdc.stdio;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;
import dmagick.c.pixel;

alias ptrdiff_t ssize_t;

extern(C)
{
	enum ComplianceType
	{
		UndefinedCompliance,
		NoCompliance  = 0x0000,
		SVGCompliance = 0x0001,
		X11Compliance = 0x0002,
		XPMCompliance = 0x0004,
		AllCompliance = 0x7fffffff
	}

	struct ColorInfo
	{
		char*
			path,
			name;

		ComplianceType
			compliance;

		MagickPixelPacket
			color;

		MagickBooleanType
			exempt,
			stealth;

		ColorInfo*
			previous,
			next;

		size_t
			signature;
	}

	struct ErrorInfo
	{
		double
			mean_error_per_pixel,
			normalized_mean_error,
			normalized_maximum_error;
	}

	char** GetColorList(const(char)*, size_t*, ExceptionInfo*);

	const(ColorInfo)*  GetColorInfo(const(char)*, ExceptionInfo*);
	const(ColorInfo)** GetColorInfoList(const(char)*, size_t*, ExceptionInfo*);

	MagickBooleanType ColorComponentGenesis();
	MagickBooleanType IsColorSimilar(const(Image)*, const(PixelPacket)*, const(PixelPacket)*);
	MagickBooleanType IsGrayImage(const(Image)*, ExceptionInfo*);
	MagickBooleanType IsImageSimilar(const(Image)*, const(Image)*, ssize_t* x,ssize_t* y, ExceptionInfo*);
	MagickBooleanType IsMagickColorSimilar(const(MagickPixelPacket)*, const(MagickPixelPacket)*);
	MagickBooleanType IsMonochromeImage(const(Image)*, ExceptionInfo*);
	MagickBooleanType IsOpacitySimilar(const(Image)*, const(PixelPacket)*, const(PixelPacket)*);
	MagickBooleanType IsOpaqueImage(const(Image)*, ExceptionInfo*);
	MagickBooleanType ListColorInfo(FILE*, ExceptionInfo*);

	static if ( MagickLibVersion >= 0x664 )
	{
		MagickBooleanType QueryColorCompliance(const(char)*, const ComplianceType, PixelPacket*, ExceptionInfo*);
	}

	MagickBooleanType QueryColorDatabase(const(char)*, PixelPacket*, ExceptionInfo*);
	MagickBooleanType QueryColorname(const(Image)*, const(PixelPacket)*, const ComplianceType, char*, ExceptionInfo*);

	static if ( MagickLibVersion >= 0x664 )
	{
		MagickBooleanType QueryMagickColorCompliance(const(char)*, const ComplianceType, MagickPixelPacket*, ExceptionInfo*);
	}

	MagickBooleanType QueryMagickColor(const(char)*, MagickPixelPacket*, ExceptionInfo*);
	MagickBooleanType QueryMagickColorname(const(Image)*, const(MagickPixelPacket)*, const ComplianceType, char*, ExceptionInfo*);

	void ColorComponentTerminus();
	void ConcatenateColorComponent(const(MagickPixelPacket)*, const ChannelType, const ComplianceType, char*);
	void GetColorTuple(const(MagickPixelPacket)*, const MagickBooleanType, char*);
}
