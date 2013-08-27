module dmagick.c.quantum;

import dmagick.c.cacheView;
import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;

extern(C)
{
	/**
	 * The endianess of the image when reading the image file.
	 */
	enum EndianType
	{
		UndefinedEndian, /// Not defined (default).
		LSBEndian,       /// Little Endian.
		MSBEndian        /// Big Endian.
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
		version(MagickCore_HDRI)
		{
			return value;
		}
		else
		{
			if (value <= 0.0)
				return(cast(Quantum) 0);
			if (value >= cast(MagickRealType) QuantumRange)
				return(cast(Quantum) QuantumRange);
			return(cast(Quantum) (value+0.5));
		}
	}

	static pure nothrow ubyte ScaleQuantumToChar(const Quantum quantum)
	{
		version(MagickCore_HDRI)
		{
			if ( quantum <= 0 )
				return 0;
			static if ( MagickQuantumDepth == 8 )
			{
				if ( quantum >= 255 )
					return 255;
				return cast(ubyte)(quantum+0.5);
			}
			else static if ( MagickQuantumDepth == 16 )
			{
				if ( quantum/257 >= 255)
					return 255;
				return cast(ubyte)(quantum/257+0.5);
			}
			else static if ( MagickQuantumDepth == 32 )
			{
				if ( quantum/16843009 >= 255)
					return 255;
				return cast(ubyte)(quantum/16843009+0.5);
			}
			else
			{
				if ( quantum/72340172838076673 >= 255)
					return 255;
				return cast(ubyte)(quantum/72340172838076673+0.5);
			}
		}
		else
		{
			static if ( MagickQuantumDepth == 8 )
				return quantum;
			else static if ( MagickQuantumDepth == 16 )
				return cast(ubyte) (((quantum+128UL)-((quantum+128UL) >> 8)) >> 8);
			else static if ( MagickQuantumDepth == 32 )
				return cast(ubyte) (quantum+8421504UL/16843009UL );
			else
				return cast(ubyte) (quantum/72340172838076673.0+0.5);
		}
	}

	static pure nothrow Quantum ScaleCharToQuantum(ubyte value)
	{
		enum Quantum factor = QuantumRange/255;

		return cast(Quantum)(factor*value);
	}

	static if ( MagickLibVersion >= 0x681 )
	{
		EndianType GetQuantumEndian(const(QuantumInfo)*);
	}

	MagickBooleanType SetQuantumDepth(const(Image)*, QuantumInfo*, const size_t);

	static if ( MagickLibVersion >= 0x681 )
	{
		MagickBooleanType SetQuantumEndian(const(Image)*, QuantumInfo*, const EndianType);
	}

	MagickBooleanType SetQuantumFormat(const(Image)*, QuantumInfo*, const QuantumFormatType);
	MagickBooleanType SetQuantumPad(const(Image)*, QuantumInfo*, const size_t);

	static if ( MagickLibVersion >= 0x674 )
	{
		QuantumFormatType GetQuantumFormat(const(QuantumInfo)*);
	}

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
