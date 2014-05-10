module dmagick.c.compare;

import dmagick.c.exception;
import dmagick.c.geometry;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;

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
		RootMeanSquaredErrorMetric,
		NormalizedCrossCorrelationErrorMetric,
		FuzzErrorMetric,
		UndefinedErrorMetric = 0,
		PerceptualHashErrorMetric = 0xff
	}

	double* GetImageChannelDistortions(Image*, const(Image)*, const MetricType, ExceptionInfo*);

	Image* CompareImageChannels(Image*, const(Image)*, const ChannelType, const MetricType, double*, ExceptionInfo*);
	Image* CompareImages(Image*, const(Image)*, const MetricType, double*, ExceptionInfo*);
	Image* SimilarityImage(Image*, const(Image)*, RectangleInfo*, double*, ExceptionInfo*);

	static if ( MagickLibVersion >= 0x674 )
	{
		Image* SimilarityMetricImage(Image*, const(Image)*, const MetricType, RectangleInfo*, double*, ExceptionInfo*);
	}

	MagickBooleanType GetImageChannelDistortion(Image*, const(Image)*, const ChannelType, const MetricType, double*, ExceptionInfo*);
	MagickBooleanType GetImageDistortion(Image*, const(Image)*, const MetricType, double*, ExceptionInfo*);
	MagickBooleanType IsImagesEqual(Image*, const(Image)*);
}
