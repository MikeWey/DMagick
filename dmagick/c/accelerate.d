module dmagick.c.accelerate;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;
import dmagick.c.morphology;

extern(C)
{
	MagickBooleanType AccelerateConvolveImage(const(Image)*, const(KernelInfo)*, Image*, ExceptionInfo*);

	static if ( MagickLibVersion >= 0x687 )
	{
		Image* AccelerateConvolveImageChannel(const(Image)*, const ChannelType, const(KernelInfo)*, ExceptionInfo*);
	}
}
