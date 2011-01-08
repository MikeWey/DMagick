module dmagick.c.constitute;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	enum StorageType
	{
		UndefinedPixel,
		CharPixel,
		DoublePixel,
		FloatPixel,
		IntegerPixel,
		LongPixel,
		QuantumPixel,
		ShortPixel
	}

	Image* ConstituteImage(const size_t, const size_t, const char*, const StorageType, const void*, ExceptionInfo*);
	Image* PingImage(const ImageInfo*, ExceptionInfo*);
	Image* PingImages(const ImageInfo*, ExceptionInfo*);
	Image* ReadImage(const ImageInfo*, ExceptionInfo*);
	Image* ReadImages(const ImageInfo*, ExceptionInfo*);
	Image* ReadInlineImage(const ImageInfo*, const char*, ExceptionInfo*);

	MagickBooleanType ConstituteComponentGenesis();
	MagickBooleanType WriteImage(const ImageInfo*, Image*);
	MagickBooleanType WriteImages(const ImageInfo*, Image*, const char*, ExceptionInfo*);

	void ConstituteComponentTerminus();
}
