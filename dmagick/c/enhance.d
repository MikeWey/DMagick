module dmagick.c.enhance;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;
import dmagick.c.pixel;

extern(C)
{
	MagickBooleanType AutoGammaImage(Image*);
	MagickBooleanType AutoGammaImageChannel(Image*, const ChannelType);
	MagickBooleanType AutoLevelImage(Image*);
	MagickBooleanType AutoLevelImageChannel(Image*, const ChannelType);
	MagickBooleanType BrightnessContrastImage(Image*, const double, const double);
	MagickBooleanType BrightnessContrastImageChannel(Image*, const ChannelType, const double, const double);
	MagickBooleanType ClutImage(Image*, const(Image)*);
	MagickBooleanType ClutImageChannel(Image*, const ChannelType, const(Image)*);
	MagickBooleanType ColorDecisionListImage(Image*, const(char)*);
	MagickBooleanType ContrastImage(Image*, const MagickBooleanType);
	MagickBooleanType ContrastStretchImage(Image*, const(char)*);
	MagickBooleanType ContrastStretchImageChannel(Image*, const ChannelType, const double, const double);
	MagickBooleanType EqualizeImage(Image* image);
	MagickBooleanType EqualizeImageChannel(Image* image, const ChannelType);
	MagickBooleanType GammaImage(Image*, const(char)*);
	MagickBooleanType GammaImageChannel(Image*, const ChannelType, const double);

	static if ( MagickLibVersion >= 0x685 )
	{
		MagickBooleanType GrayscaleImage(Image*, const PixelIntensityMethod);
	}

	MagickBooleanType HaldClutImage(Image*, const(Image)*);
	MagickBooleanType HaldClutImageChannel(Image*, const ChannelType, const(Image)*);
	MagickBooleanType LevelImage(Image*, const(char)*);
	MagickBooleanType LevelImageChannel(Image*, const ChannelType, const double, const double, const double);
	MagickBooleanType LevelizeImage(Image*, const double, const double, const double);
	MagickBooleanType LevelizeImageChannel(Image*, const ChannelType, const double, const double, const double);
	MagickBooleanType LevelColorsImage(Image*, const(MagickPixelPacket)*, const(MagickPixelPacket)*, const MagickBooleanType);
	MagickBooleanType LevelColorsImageChannel(Image*, const ChannelType, const(MagickPixelPacket)*, const(MagickPixelPacket)*, const MagickBooleanType);
	MagickBooleanType LinearStretchImage(Image*, const double, const double);
	MagickBooleanType ModulateImage(Image*, const(char)*);
	MagickBooleanType NegateImage(Image*, const MagickBooleanType);
	MagickBooleanType NegateImageChannel(Image*, const ChannelType, const MagickBooleanType);
	MagickBooleanType NormalizeImage(Image*);
	MagickBooleanType NormalizeImageChannel(Image*, const ChannelType);
	MagickBooleanType SigmoidalContrastImage(Image*, const MagickBooleanType, const(char)*);
	MagickBooleanType SigmoidalContrastImageChannel(Image*, const ChannelType, const MagickBooleanType, const double, const double);

	Image* EnhanceImage(const(Image)*, ExceptionInfo*);
}
