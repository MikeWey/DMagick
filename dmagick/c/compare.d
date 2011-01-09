module dmagick.c.compare;

import dmagick.c.exception;
import dmagick.c.geometry;
import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	enum MetricType
	{
		UndefinedMetric,
		AbsoluteErrorMetric,
		MeanAbsoluteErrorMetric,
		MeanErrorPerPixelMetric,
		MeanSquaredErrorMetric,
		PeakAbsoluteErrorMetric,
		PeakSignalToNoiseRatioMetric,
		RootMeanSquaredErrorMetric
	}

	double* GetImageChannelDistortions(Image*, const(Image)*, const MetricType, ExceptionInfo*);

	Image* CompareImageChannels(Image*, const(Image)*, const ChannelType, const MetricType, double*, ExceptionInfo*);
	Image* CompareImages(Image*, const(Image)*, const MetricType, double*, ExceptionInfo*);
	Image* SimilarityImage(Image*, const(Image)*, RectangleInfo*, double*, ExceptionInfo*);

	MagickBooleanType GetImageChannelDistortion(Image*, const(Image)*, const ChannelType, const MetricType, double*, ExceptionInfo*);
	MagickBooleanType GetImageDistortion(Image*, const(Image)*, const MetricType, double*, ExceptionInfo*);
	MagickBooleanType IsImagesEqual(Image*, const(Image)*);
}
