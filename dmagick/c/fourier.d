module dmagick.c.fourier;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	Image* ForwardFourierTransformImage(const(Image)*, const MagickBooleanType, ExceptionInfo*);
	Image* InverseFourierTransformImage(const(Image)*, const(Image)*, const MagickBooleanType, ExceptionInfo*);
}
