module dmagick.c.attribute;

import dmagick.c.image;
import dmagick.c.exception;
import dmagick.c.magickType;
import dmagick.c.geometry;

extern(C)
{
	ImageType GetImageType(const(Image)*, ExceptionInfo*);

	MagickBooleanType IsGrayImage(const(Image)*, ExceptionInfo*);
	MagickBooleanType IsMonochromeImage(const(Image)*, ExceptionInfo*);
	MagickBooleanType IsOpaqueImage(const(Image)*, ExceptionInfo*);
	MagickBooleanType SetImageChannelDepth(Image*, const ChannelType, const size_t);
	MagickBooleanType SetImageDepth(Image*, const size_t);
	MagickBooleanType SetImageType(Image*, const ImageType);

	RectangleInfo GetImageBoundingBox(const(Image)*, ExceptionInfo* exception);

	size_t GetImageChannelDepth(const(Image)*, const ChannelType, ExceptionInfo*);
	size_t GetImageDepth(const(Image)*, ExceptionInfo*);
	size_t GetImageQuantumDepth(const(Image)*, const MagickBooleanType);
}
