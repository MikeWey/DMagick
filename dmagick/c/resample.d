module dmagick.c.resample;

import dmagick.c.cacheView;
import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;
import dmagick.c.pixel;

//A mixin with static if has problems with circular imports. (dmagick.c.image)
version(MagickCore_660) {} else
version(MagickCore_661) {} else
version(MagickCore_662) {} else
version(MagickCore_663) {} else
version(MagickCore_664) {} else
version(MagickCore_665) {} else
{
	version = MagickCore_666_and_up;
}

extern(C)
{
	version ( MagickCore_666_and_up )
	{
		enum FilterTypes
		{
			UndefinedFilter,
			PointFilter,
			BoxFilter,
			TriangleFilter,
			HermiteFilter,
			HanningFilter,
			HammingFilter,
			BlackmanFilter,
			GaussianFilter,
			QuadraticFilter,
			CubicFilter,
			CatromFilter,
			MitchellFilter,
			JincFilter,
			SincFilter,
			SincFastFilter,
			KaiserFilter,
			WelshFilter,
			ParzenFilter,
			BohmanFilter,
			BartlettFilter,
			LagrangeFilter,
			LanczosFilter,
			LanczosSharpFilter,
			Lanczos2Filter,
			Lanczos2SharpFilter,
			RobidouxFilter,
			SentinelFilter,  /* a count of all the filters, not a real filter */

			BesselFilter         = JincFilter,
			Lanczos2DFilter      = Lanczos2Filter,
			Lanczos2DSharpFilter = Lanczos2SharpFilter
		}
	}
	else
	{
		enum FilterTypes
		{
			UndefinedFilter,
			PointFilter,
			BoxFilter,
			TriangleFilter,
			HermiteFilter,
			HanningFilter,
			HammingFilter,
			BlackmanFilter,
			GaussianFilter,
			QuadraticFilter,
			CubicFilter,
			CatromFilter,
			MitchellFilter,
			LanczosFilter,
			JincFilter,
			SincFilter,
			KaiserFilter,
			WelshFilter,
			ParzenFilter,
			LagrangeFilter,
			BohmanFilter,
			BartlettFilter,
			SincFastFilter,
			Lanczos2DFilter,
			Lanczos2DSharpFilter,
			RobidouxFilter,
			SentinelFilter,  /* a count of all the filters, not a real filter */

			BesselFilter         = JincFilter
		}
	}

	struct ResampleFilter {}

	MagickBooleanType ResamplePixelColor(ResampleFilter*, const double, const double, MagickPixelPacket*);
	MagickBooleanType SetResampleFilterInterpolateMethod(ResampleFilter*, const InterpolatePixelMethod);
	MagickBooleanType SetResampleFilterVirtualPixelMethod(ResampleFilter*, const VirtualPixelMethod);

	ResampleFilter* AcquireResampleFilter(const(Image)*, ExceptionInfo*);
	ResampleFilter* DestroyResampleFilter(ResampleFilter*);

	void ScaleResampleFilter(ResampleFilter*, const double, const double, const double, const double);
	void SetResampleFilter(ResampleFilter*, const FilterTypes, const double);
}
