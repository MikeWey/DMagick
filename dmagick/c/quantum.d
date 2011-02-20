module dmagick.c.quantum;

import dmagick.c.cacheView;
import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	enum EndianType
	{
		UndefinedEndian,
		LSBEndian,
		MSBEndian
	}

	enum QuantumAlphaType
	{
		UndefinedQuantumAlpha,
		AssociatedQuantumAlpha,
		DisassociatedQuantumAlpha
	}

	enum QuantumFormatType
	{
		UndefinedQuantumFormat,
		FloatingPointQuantumFormat,
		SignedQuantumFormat,
		UnsignedQuantumFormat
	}

	enum QuantumType
	{
		UndefinedQuantum,
		AlphaQuantum,
		BlackQuantum,
		BlueQuantum,
		CMYKAQuantum,
		CMYKQuantum,
		CyanQuantum,
		GrayAlphaQuantum,
		GrayQuantum,
		GreenQuantum,
		IndexAlphaQuantum,
		IndexQuantum,
		MagentaQuantum,
		OpacityQuantum,
		RedQuantum,
		RGBAQuantum,
		BGRAQuantum,
		RGBOQuantum,
		RGBQuantum,
		YellowQuantum,
		GrayPadQuantum,
		RGBPadQuantum,
		CbYCrYQuantum,
		CbYCrQuantum,
		CbYCrAQuantum,
		CMYKOQuantum,
		BGRQuantum,
		BGROQuantum
	}

	struct QuantumInfo {}

	alias ClampToQuantum RoundToQuantum;
	static pure nothrow Quantum ClampToQuantum(const MagickRealType value)
	{
		if (value <= 0.0)
			return(cast(Quantum) 0);
		if (value >= cast(MagickRealType) 65535UL)
			return(cast(Quantum) 65535UL);
		return(cast(Quantum) (value+0.5));
	}

	static pure nothrow ubyte ScaleQuantumToChar(const Quantum quantum)
	{
		return(cast(ubyte) (((quantum+128UL)-((quantum+128UL) >> 8)) >> 8));
	}

	static pure nothrow Quantum ScaleCharToQuantum(ubyte value)
	{
		enum Quantum factor = QuantumRange/255;

		return cast(Quantum)(factor*value);
	}

	MagickBooleanType SetQuantumDepth(const(Image)*, QuantumInfo*, const size_t);
	MagickBooleanType SetQuantumFormat(const(Image)*, QuantumInfo*, const QuantumFormatType);
	MagickBooleanType SetQuantumPad(const(Image)*, QuantumInfo*, const size_t);

	QuantumInfo* AcquireQuantumInfo(const(ImageInfo)*, Image*);
	QuantumInfo* DestroyQuantumInfo(QuantumInfo*);

	QuantumType GetQuantumType(Image*, ExceptionInfo*);

	size_t ExportQuantumPixels(const(Image)*, const(CacheView)*, const(QuantumInfo)*, const QuantumType, ubyte*, ExceptionInfo*);
	size_t GetQuantumExtent(const(Image)*, const(QuantumInfo)*, const QuantumType);
	size_t ImportQuantumPixels(Image*, CacheView*, const(QuantumInfo)*, const QuantumType, const(ubyte)*, ExceptionInfo*);

	ubyte* GetQuantumPixels(const(QuantumInfo)*);

	void GetQuantumInfo(const(ImageInfo)*, QuantumInfo*);
	void SetQuantumAlphaType(QuantumInfo*, const QuantumAlphaType);
	void SetQuantumImageType(Image*, const QuantumType);
	void SetQuantumMinIsWhite(QuantumInfo*, const MagickBooleanType);
	void SetQuantumPack(QuantumInfo*, const MagickBooleanType);
	void SetQuantumQuantum(QuantumInfo*, const size_t);
	void SetQuantumScale(QuantumInfo*, const double);
}
