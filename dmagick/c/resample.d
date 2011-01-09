module dmagick.c.resample;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.pixel;
import dmagick.c.cacheView;

extern(C)
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
		RobidouxFilter,
		SentinelFilter
	}

	enum InterpolatePixelMethod
	{
		UndefinedInterpolatePixel,
		AverageInterpolatePixel,
		BicubicInterpolatePixel,
		BilinearInterpolatePixel,
		FilterInterpolatePixel,
		IntegerInterpolatePixel,
		MeshInterpolatePixel,
		NearestNeighborInterpolatePixel,
		SplineInterpolatePixel
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
