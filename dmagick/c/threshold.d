module dmagick.c.threshold;

import core.stdc.stdio;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;

alias ptrdiff_t ssize_t;

extern(C)
{
	struct ThresholdMap {}

	Image* AdaptiveThresholdImage(const(Image)*, const size_t, const size_t, const ssize_t, ExceptionInfo*);

	ThresholdMap* DestroyThresholdMap(ThresholdMap*);
	ThresholdMap* GetThresholdMap(const(char)*, ExceptionInfo*);

	MagickBooleanType BilevelImage(Image*, const double);
	MagickBooleanType BilevelImageChannel(Image*, const ChannelType, const double);
	MagickBooleanType BlackThresholdImage(Image*, const(char)*);
	MagickBooleanType BlackThresholdImageChannel(Image*, const ChannelType, const(char)*, ExceptionInfo*);
	MagickBooleanType ClampImage(Image*);
	MagickBooleanType ClampImageChannel(Image*, const ChannelType);
	MagickBooleanType ListThresholdMaps(FILE*, ExceptionInfo*);
	MagickBooleanType OrderedDitherImage(Image*);
	MagickBooleanType OrderedDitherImageChannel(Image*, const ChannelType, ExceptionInfo*);
	MagickBooleanType OrderedPosterizeImage(Image*, const(char)*, ExceptionInfo*);
	MagickBooleanType OrderedPosterizeImageChannel(Image*, const ChannelType, const(char)*, ExceptionInfo*);

	static if ( MagickLibVersion >= 0x681 )
	{
		MagickBooleanType PerceptibleImage(Image*, const double);
		MagickBooleanType PerceptibleImageChannel(Image*, const ChannelType, const double);
	}

	MagickBooleanType RandomThresholdImage(Image*, const(char)*, ExceptionInfo*);
	MagickBooleanType RandomThresholdImageChannel(Image*, const ChannelType, const(char)*, ExceptionInfo*);
	MagickBooleanType WhiteThresholdImage(Image*, const(char)*);
	MagickBooleanType WhiteThresholdImageChannel(Image*, const ChannelType, const(char)*, ExceptionInfo *);
}
