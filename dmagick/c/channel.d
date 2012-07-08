module dmagick.c.channel;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;

extern(C)
{
	Image* CombineImages(const(Image)*, const ChannelType, ExceptionInfo*);

	static if ( MagickLibVersion >= 0x678 )
	{
		Image* SeparateImage(const(Image)*, const ChannelType, ExceptionInfo*);
	}

	Image* SeparateImages(const(Image)*, const ChannelType, ExceptionInfo*);

	MagickBooleanType GetImageAlphaChannel(const(Image)*);
	MagickBooleanType SeparateImageChannel(Image*, const ChannelType);
	MagickBooleanType SetImageAlphaChannel(Image*, const AlphaChannelType);
}
