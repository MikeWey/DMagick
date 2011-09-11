module dmagick.c.distort;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;

extern(C)
{
	mixin(
	{
		string methods = "enum DistortImageMethod
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
			DePolarDistortion,";

			static if ( MagickLibVersion >= 0x671 )
			{
				methods ~= "Cylinder2PlaneDistortion,
				            Plane2CylinderDistortion,";
			}

			methods ~= "
			BarrelDistortion,
			BarrelInverseDistortion,
			ShepardsDistortion,";

			static if ( MagickLibVersion >= 0x670 )
			{
				methods ~= "ResizeDistortion,";
			}

			methods ~= "
			SentinelDistortion
		}";

		return methods;
	}());

	enum SparseColorMethod
	{
		UndefinedColorInterpolate =   DistortImageMethod.UndefinedDistortion,
		BarycentricColorInterpolate = DistortImageMethod.AffineDistortion,
		BilinearColorInterpolate =    DistortImageMethod.BilinearReverseDistortion,
		PolynomialColorInterpolate =  DistortImageMethod.PolynomialDistortion,
		ShepardsColorInterpolate =    DistortImageMethod.ShepardsDistortion,

		VoronoiColorInterpolate =     DistortImageMethod.SentinelDistortion,
		InverseColorInterpolate
	}

	Image* DistortImage(const(Image)*, const DistortImageMethod, const size_t, const(double)*, MagickBooleanType, ExceptionInfo* exception);

	static if ( MagickLibVersion >= 0x670 )
	{
		Image* DistortResizeImage(const(Image)*, const size_t, const size_t, ExceptionInfo*);
	}

	Image* SparseColorImage(const(Image)*, const ChannelType, const SparseColorMethod, const size_t, const(double)*, ExceptionInfo*);
}
