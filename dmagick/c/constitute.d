module dmagick.c.constitute;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;

extern(C)
{
	/**
	 * The size of a pixel component.
	 */
	enum StorageType
	{
		UndefinedPixel, ///
		CharPixel,      /// ditto
		DoublePixel,    /// ditto
		FloatPixel,     /// ditto
		IntegerPixel,   /// ditto
		LongPixel,      /// ditto
		QuantumPixel,   /// ditto
		ShortPixel      /// ditto
	}

	Image* ConstituteImage(const size_t, const size_t, const(char)*, const StorageType, const(void)*, ExceptionInfo*);
	Image* PingImage(const(ImageInfo)*, ExceptionInfo*);
	Image* PingImages(const(ImageInfo)*, ExceptionInfo*);
	Image* ReadImage(const(ImageInfo)*, ExceptionInfo*);
	Image* ReadImages(const(ImageInfo)*, ExceptionInfo*);
	Image* ReadInlineImage(const(ImageInfo)*, const(char)*, ExceptionInfo*);


	static if ( MagickLibVersion < 0x689 )
	{
		MagickBooleanType ConstituteComponentGenesis();
	}
	MagickBooleanType WriteImage(const(ImageInfo)*, Image*);
	MagickBooleanType WriteImages(const(ImageInfo)*, Image*, const(char)*, ExceptionInfo*);

	static if ( MagickLibVersion < 0x689 )
	{
		void ConstituteComponentTerminus();
	}
}
