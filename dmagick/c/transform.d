module dmagick.c.transform;

import dmagick.c.exception;
import dmagick.c.geometry;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;

alias ptrdiff_t ssize_t;

extern(C)
{
	static if ( MagickLibVersion >= 0x682 )
	{
		Image* AutoOrientImage(const(Image)*, const OrientationType, ExceptionInfo*);
	}

	Image* ChopImage(const(Image)*, const(RectangleInfo)*, ExceptionInfo*);
	Image* ConsolidateCMYKImages(const(Image)*, ExceptionInfo*);
	Image* CropImage(const(Image)*, const(RectangleInfo)*, ExceptionInfo*);

	static if ( MagickLibVersion >= 0x669 )
	{
		Image* CropImageToTiles(const(Image)*, const(char)*, ExceptionInfo*);
	}

	Image* ExcerptImage(const(Image)*, const(RectangleInfo)*, ExceptionInfo*);
	Image* ExtentImage(const(Image)*, const(RectangleInfo)*, ExceptionInfo*);
	Image* FlipImage(const(Image)*, ExceptionInfo*);
	Image* FlopImage(const(Image)*, ExceptionInfo*);
	Image* RollImage(const(Image)*, const ssize_t, const ssize_t, ExceptionInfo*);
	Image* ShaveImage(const(Image)*, const(RectangleInfo)*, ExceptionInfo*);
	Image* SpliceImage(const(Image)*, const(RectangleInfo)*, ExceptionInfo*);
	Image* TransposeImage(const(Image)*, ExceptionInfo*);
	Image* TransverseImage(const(Image)*, ExceptionInfo*);
	Image* TrimImage(const(Image)*, ExceptionInfo*);

	MagickBooleanType TransformImage(Image**, const(char)*, const(char)*);
	MagickBooleanType TransformImages(Image**, const(char)*, const(char)*);
}
