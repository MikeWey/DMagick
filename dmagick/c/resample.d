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
		/**
		 * Used to adjust the filter algorithm used when resizing images.
		 * Different filters experience varying degrees of success with
		 * various images and can take significantly different amounts of
		 * processing time. ImageMagick uses the LanczosFilter by default
		 * since this filter has been shown to provide the best results for
		 * most images in a reasonable amount of time. Other filter types
		 * (e.g. TriangleFilter) may execute much faster but may show
		 * artifacts when the image is re-sized or around diagonal lines.
		 * The only way to be sure is to test the filter with sample images.
		 * 
		 * See_Also: $(LINK2 http://www.imagemagick.org/Usage/resize/,
		 *     Resize Filters) in the Examples of ImageMagick Usage.
		 */
		enum FilterTypes
		{
			UndefinedFilter,     ///
			PointFilter,         /// ditto
			BoxFilter,           /// ditto
			TriangleFilter,      /// ditto
			HermiteFilter,       /// ditto
			HanningFilter,       /// ditto
			HammingFilter,       /// ditto
			BlackmanFilter,      /// ditto
			GaussianFilter,      /// ditto
			QuadraticFilter,     /// ditto
			CubicFilter,         /// ditto
			CatromFilter,        /// ditto
			MitchellFilter,      /// ditto
			JincFilter,          /// ditto
			SincFilter,          /// ditto
			SincFastFilter,      /// ditto
			KaiserFilter,        /// ditto
			WelshFilter,         /// ditto
			ParzenFilter,        /// ditto
			BohmanFilter,        /// ditto
			BartlettFilter,      /// ditto
			LagrangeFilter,      /// ditto
			LanczosFilter,       /// ditto
			LanczosSharpFilter,  /// ditto
			Lanczos2Filter,      /// ditto
			Lanczos2SharpFilter, /// ditto
			RobidouxFilter,      /// ditto
			RobidouxSharpFilter, /// ditto
			CosineFilter,        /// ditto
			SplineFilter,        /// ditto
			LanczosRadiusFilter, /// ditto
			SentinelFilter,      // a count of all the filters, not a real filter

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
			RobidouxSharpFilter,
			CosineFilter,
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
