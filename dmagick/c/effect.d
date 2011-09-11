module dmagick.c.effect;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;
import dmagick.c.morphology;

extern(C)
{
	enum PreviewType
	{
		UndefinedPreview,
		RotatePreview,
		ShearPreview,
		RollPreview,
		HuePreview,
		SaturationPreview,
		BrightnessPreview,
		GammaPreview,
		SpiffPreview,
		DullPreview,
		GrayscalePreview,
		QuantizePreview,
		DespecklePreview,
		ReduceNoisePreview,
		AddNoisePreview,
		SharpenPreview,
		BlurPreview,
		ThresholdPreview,
		EdgeDetectPreview,
		SpreadPreview,
		SolarizePreview,
		ShadePreview,
		RaisePreview,
		SegmentPreview,
		SwirlPreview,
		ImplodePreview,
		WavePreview,
		OilPaintPreview,
		CharcoalDrawingPreview,
		JPEGPreview
	}

	mixin(
	{
		string types = "enum StatisticType
		{
			UndefinedStatistic,";

			static if ( MagickLibVersion >= 0x670 )
			{
				types ~= "GradientStatistic,";
			}

			types ~= "
			MaximumStatistic,
			MeanStatistic,
			MedianStatistic,
			MinimumStatistic,
			ModeStatistic,
			NonpeakStatistic,";

			static if ( MagickLibVersion >= 0x670 )
			{
				types ~= "StandardDeviationStatistic,";
			}

			types ~= "
		}";

		return types;
	}());

	Image* AdaptiveBlurImage(const(Image)*, const double, const double, ExceptionInfo*);
	Image* AdaptiveBlurImageChannel(const(Image)*, const ChannelType, const double, const double, ExceptionInfo*);
	Image* AdaptiveSharpenImage(const(Image)*, const double, const double, ExceptionInfo*);
	Image* AdaptiveSharpenImageChannel(const(Image)*, const ChannelType, const double, const double, ExceptionInfo*);
	Image* BlurImage(const(Image)*, const double, const double, ExceptionInfo*);
	Image* BlurImageChannel(const(Image)*, const ChannelType, const double, const double, ExceptionInfo*);
	Image* ConvolveImage(const(Image)*, const size_t, const(double)*, ExceptionInfo*);
	Image* ConvolveImageChannel(const(Image)*, const ChannelType, const size_t, const(double)*, ExceptionInfo*);
	Image* DespeckleImage(const(Image)*, ExceptionInfo*);
	Image* EdgeImage(const(Image)*, const double, ExceptionInfo*);
	Image* EmbossImage(const(Image)*, const double, const double, ExceptionInfo*);
	Image* FilterImage(const(Image)*, const(KernelInfo)*, ExceptionInfo*);
	Image* FilterImageChannel(const(Image)*, const ChannelType, const(KernelInfo)*, ExceptionInfo*);
	Image* GaussianBlurImage(const(Image)*, const double, const double, ExceptionInfo*);
	Image* GaussianBlurImageChannel(const(Image)*, const ChannelType, const double, const double, ExceptionInfo*);

	static if ( MagickLibVersion < 0x669 )
	{
		Image* MedianFilterImage(const(Image)*, const double, ExceptionInfo*);
	}

	static if ( MagickLibVersion == 0x668 )
	{
		Image* ModeImage(const(Image)*, const double, ExceptionInfo*);
	}

	Image* MotionBlurImage(const(Image)*, const double, const double, const double, ExceptionInfo*);
	Image* MotionBlurImageChannel(const(Image)*, const ChannelType, const double, const double, const double, ExceptionInfo*);
	Image* PreviewImage(const(Image)*, const PreviewType, ExceptionInfo*);
	Image* RadialBlurImage(const(Image)*, const double, ExceptionInfo*);
	Image* RadialBlurImageChannel(const(Image)*, const ChannelType, const double, ExceptionInfo*);

	static if ( MagickLibVersion < 0x669 )
	{
		Image* ReduceNoiseImage(const(Image)*, const double, ExceptionInfo*);
	}

	Image* SelectiveBlurImage(const(Image)*, const double, const double, const double, ExceptionInfo*);
	Image* SelectiveBlurImageChannel(const(Image)*, const ChannelType, const double, const double, const double, ExceptionInfo*);
	Image* ShadeImage(const(Image)*, const MagickBooleanType, const double, const double, ExceptionInfo*);
	Image* SharpenImage(const(Image)*, const double, const double, ExceptionInfo*);
	Image* SharpenImageChannel(const(Image)*, const ChannelType ,const double, const double, ExceptionInfo*);
	Image* SpreadImage(const(Image)*, const double, ExceptionInfo*);

	static if ( MagickLibVersion >= 0x669 )
	{
		Image* StatisticImage(const(Image)*, const StatisticType, const size_t, const size_t, ExceptionInfo*);
		Image* StatisticImageChannel(const(Image)*, const ChannelType, const StatisticType, const size_t, const size_t, ExceptionInfo*);
	}

	Image* UnsharpMaskImage(const(Image)*, const double, const double, const double, const double, ExceptionInfo*);
	Image* UnsharpMaskImageChannel(const(Image)*, const ChannelType, const double, const double, const double, const double, ExceptionInfo*);
}
