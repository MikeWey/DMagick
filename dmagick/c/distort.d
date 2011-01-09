module dmagick.c.distort;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	enum DistortImageMethod
	{
		UndefinedDistortion,
		AffineDistortion,
		AffineProjectionDistortion,
		ScaleRotateTranslateDistortion,
		PerspectiveDistortion,
		PerspectiveProjectionDistortion,
		BilinearForwardDistortion,
		BilinearDistortion = BilinearForwardDistortion,
		BilinearReverseDistortion,
		PolynomialDistortion,
		ArcDistortion,
		PolarDistortion,
		DePolarDistortion,
		BarrelDistortion,
		BarrelInverseDistortion,
		ShepardsDistortion,
		SentinelDistortion
	}

	enum SparseColorMethod
	{
		UndefinedColorInterpolate =   DistortImageMethod.UndefinedDistortion,
		BarycentricColorInterpolate = DistortImageMethod.AffineDistortion,
		BilinearColorInterpolate =    DistortImageMethod.BilinearReverseDistortion,
		PolynomialColorInterpolate =  DistortImageMethod.PolynomialDistortion,
		ShepardsColorInterpolate =    DistortImageMethod.ShepardsDistortion,

		VoronoiColorInterpolate =     DistortImageMethod.SentinelDistortion
	}

	Image* DistortImage(const(Image)*, const DistortImageMethod, const size_t, const(double)*, MagickBooleanType, ExceptionInfo* exception);
	Image* SparseColorImage(const(Image)*, const ChannelType, const SparseColorMethod, const size_t, const(double)*, ExceptionInfo*);
}
