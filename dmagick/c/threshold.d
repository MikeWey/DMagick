module dmagick.c.threshold;

import core.stdc.stdio;
import core.sys.posix.sys.types;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	struct ThresholdMap {}

	Image* AdaptiveThresholdImage(const Image*, const size_t, const size_t, const ssize_t, ExceptionInfo*);

	ThresholdMap* DestroyThresholdMap(ThresholdMap*);
	ThresholdMap* GetThresholdMap(const char*, ExceptionInfo*);

	MagickBooleanType BilevelImage(Image*, const double);
	MagickBooleanType BilevelImageChannel(Image*, const ChannelType, const double);
	MagickBooleanType BlackThresholdImage(Image*, const char*);
	MagickBooleanType BlackThresholdImageChannel(Image*, const ChannelType, const char*, ExceptionInfo*);
	MagickBooleanType ClampImage(Image*);
	MagickBooleanType ClampImageChannel(Image*, const ChannelType);
	MagickBooleanType ListThresholdMaps(FILE*, ExceptionInfo*);
	MagickBooleanType OrderedDitherImage(Image*);
	MagickBooleanType OrderedDitherImageChannel(Image*, const ChannelType, ExceptionInfo*);
	MagickBooleanType OrderedPosterizeImage(Image*, const char*, ExceptionInfo*);
	MagickBooleanType OrderedPosterizeImageChannel(Image*, const ChannelType, const char*, ExceptionInfo*);
	MagickBooleanType RandomThresholdImage(Image*, const char*, ExceptionInfo*);
	MagickBooleanType RandomThresholdImageChannel(Image*, const ChannelType, const char*, ExceptionInfo*);
	MagickBooleanType WhiteThresholdImage(Image*, const char*);
	MagickBooleanType WhiteThresholdImageChannel(Image *,const ChannelType,const char *,ExceptionInfo *);
}
