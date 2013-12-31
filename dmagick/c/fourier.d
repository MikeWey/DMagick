module dmagick.c.fourier;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;

static if ( MagickLibVersion >= 0x688 )
{
	enum ComplexOperator
	{
		UndefinedComplexOperator,
		AddComplexOperator,
		ConjugateComplexOperator,
		DivideComplexOperator,
		MagnitudePhaseComplexOperator,
		MultiplyComplexOperator,
		RealImaginaryComplexOperator,
		SubtractComplexOperator
	}
}

extern(C)
{
	static if ( MagickLibVersion >= 0x688 )
	{
		Image* ComplexImages(const(Image)*, const ComplexOperator, ExceptionInfo*);
	}

	Image* ForwardFourierTransformImage(const(Image)*, const MagickBooleanType, ExceptionInfo*);
	Image* InverseFourierTransformImage(const(Image)*, const(Image)*, const MagickBooleanType, ExceptionInfo*);
}
