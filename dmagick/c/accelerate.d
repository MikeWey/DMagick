module dmagick.c.accelerate;

import dmagick.c.colorspace;
import dmagick.c.exception;
import dmagick.c.fx;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;
import dmagick.c.morphology;
import dmagick.c.statistic;

extern(C)
{
	MagickBooleanType AccelerateConvolveImage(const(Image)*, const(KernelInfo)*, Image*, ExceptionInfo*);

	static if ( MagickLibVersion >= 0x688 )
	{
		MagickBooleanType AccelerateContrastImage(Image*, const MagickBooleanType, ExceptionInfo*);
		MagickBooleanType AccelerateEqualizeImage(Image*, const ChannelType, ExceptionInfo*);
		MagickBooleanType AccelerateFunctionImage(Image*, const ChannelType, const MagickFunction, const size_t, const(double)*, ExceptionInfo*);
		MagickBooleanType AccelerateModulateImage(Image*, double, double, double, ColorspaceType, ExceptionInfo*);
	}

	static if ( MagickLibVersion >= 0x688 )
	{
		Image* AccelerateAddNoiseImage(const(Image)*, const ChannelType, const NoiseType, ExceptionInfo*);
		Image* AccelerateBlurImage(const(Image)*, const ChannelType, const double, const double, ExceptionInfo*);
	}

	static if ( MagickLibVersion >= 0x687 )
	{
		Image* AccelerateConvolveImageChannel(const(Image)*, const ChannelType, const(KernelInfo)*, ExceptionInfo*);
	}
}
