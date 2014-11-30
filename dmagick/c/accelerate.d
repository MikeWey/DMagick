module dmagick.c.accelerate;

import dmagick.c.colorspace;
import dmagick.c.composite;
import dmagick.c.exception;
import dmagick.c.fx;
import dmagick.c.geometry;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;
import dmagick.c.morphology;
import dmagick.c.pixel;
import dmagick.c.statistic;

extern(C)
{
	static if ( MagickLibVersion >= 0x689 )
	{
		MagickBooleanType AccelerateCompositeImage(Image*, const ChannelType, const CompositeOperator, const(Image)*, const ssize_t, const ssize_t, const float, const float, ExceptionInfo*);
		MagickBooleanType AccelerateContrastStretchImageChannel(Image*, const ChannelType, const double, const double, ExceptionInfo*);
		MagickBooleanType AccelerateGrayscaleImage(Image*, const PixelIntensityMethod, ExceptionInfo*);
		MagickBooleanType AccelerateRandomImage(Image*, ExceptionInfo*);
	}

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

	static if ( MagickLibVersion >= 0x689 )
	{
		Image* AccelerateMotionBlurImage(const Image*, const ChannelType, const(double)*, const size_t, const(OffsetInfo)*, ExceptionInfo*);
	}

	/* legacy, do not use */
	MagickBooleanType AccelerateConvolveImage(const(Image)*, const(KernelInfo)*, Image*, ExceptionInfo*);
	static if ( MagickLibVersion >= 0x689 )
	{
		MagickBooleanType AccelerateNegateImageChannel(Image*, const ChannelType, const MagickBooleanType, ExceptionInfo*);
	}
}
