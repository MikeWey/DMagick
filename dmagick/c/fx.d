module dmagick.c.fx;

import dmagick.c.draw;
import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;
import dmagick.c.morphology;
import dmagick.c.pixel;

alias ptrdiff_t ssize_t;

extern(C)
{
	/**
	 * Select the type of noise to be added to the image.
	 */
	enum NoiseType
	{
		UndefinedNoise,              ///
		UniformNoise,                /// ditto
		GaussianNoise,               /// ditto
		MultiplicativeGaussianNoise, /// ditto
		ImpulseNoise,                /// ditto
		LaplacianNoise,              /// ditto
		PoissonNoise,                /// ditto
		RandomNoise                  /// ditto
	}

	Image* AddNoiseImage(const(Image)*, const NoiseType, ExceptionInfo*);
	Image* AddNoiseImageChannel(const(Image)*, const ChannelType, const NoiseType, ExceptionInfo*);
	Image* BlueShiftImage(const(Image)*, const double, ExceptionInfo*);
	Image* CharcoalImage(const(Image)*, const double, const double, ExceptionInfo*);
	Image* ColorizeImage(const(Image)*, const(char)*, const PixelPacket, ExceptionInfo*);

	static if (MagickLibVersion >= 0x661)
	{
		Image* ColorMatrixImage(const(Image)*, const(KernelInfo)* kernel, ExceptionInfo*);
	}

	Image* FxImage(const(Image)*, const(char)*, ExceptionInfo*);
	Image* FxImageChannel(const(Image)*, const ChannelType, const(char)*, ExceptionInfo*);
	Image* ImplodeImage(const(Image)*, const double, ExceptionInfo*);
	Image* MorphImages(const(Image)*, const size_t, ExceptionInfo*);
	Image* PolaroidImage(const(Image)*, const(DrawInfo)*, const double, ExceptionInfo*);

	static if (MagickLibVersion < 0x661)
	{
		Image* RecolorImage(const(Image)*, const size_t, const(double)*, ExceptionInfo*);
	}

	Image* SepiaToneImage(const(Image)*, const double, ExceptionInfo*);
	Image* ShadowImage(const(Image)*, const double, const double, const ssize_t, const ssize_t, ExceptionInfo*);
	Image* SketchImage(const(Image)*, const double, const double, const double, ExceptionInfo*);
	Image* SteganoImage(const(Image)*, const(Image)*, ExceptionInfo*);
	Image* StereoImage(const(Image)*, const(Image)*, ExceptionInfo*);
	Image* StereoAnaglyphImage(const(Image)*, const(Image)*, const ssize_t, const ssize_t, ExceptionInfo*);
	Image* SwirlImage(const(Image)*, double, ExceptionInfo*);
	Image* TintImage(const(Image)*, const(char)*, const PixelPacket, ExceptionInfo*);
	Image* VignetteImage(const(Image)*, const double, const double, const ssize_t, const ssize_t, ExceptionInfo*);
	Image* WaveImage(const(Image)*, const double, const double, ExceptionInfo*);

	MagickBooleanType PlasmaImage(Image*, const(SegmentInfo)*, size_t, size_t);
	MagickBooleanType SolarizeImage(Image*, const double);

	static if (MagickLibVersion >= 0x680)
	{
		MagickBooleanType SolarizeImageChannel(Image*, const ChannelType, const double, ExceptionInfo*);
	}
}
