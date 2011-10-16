module dmagick.c.statistic;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	struct ChannelStatistics
	{
		size_t
			depth;

		double
			minima,
			maxima,
			sum,
			sum_squared,
			sum_cubed,
			sum_fourth_power,
			mean,
			variance,
			standard_deviation,
			kurtosis,
			skewness;
	}

	enum MagickEvaluateOperator
	{
		UndefinedEvaluateOperator,
		AddEvaluateOperator,
		AndEvaluateOperator,
		DivideEvaluateOperator,
		LeftShiftEvaluateOperator,
		MaxEvaluateOperator,
		MinEvaluateOperator,
		MultiplyEvaluateOperator,
		OrEvaluateOperator,
		RightShiftEvaluateOperator,
		SetEvaluateOperator,
		SubtractEvaluateOperator,
		XorEvaluateOperator,
		PowEvaluateOperator,
		LogEvaluateOperator,
		ThresholdEvaluateOperator,
		ThresholdBlackEvaluateOperator,
		ThresholdWhiteEvaluateOperator,
		GaussianNoiseEvaluateOperator,
		ImpulseNoiseEvaluateOperator,
		LaplacianNoiseEvaluateOperator,
		MultiplicativeNoiseEvaluateOperator,
		PoissonNoiseEvaluateOperator,
		UniformNoiseEvaluateOperator,
		CosineEvaluateOperator,
		SineEvaluateOperator,
		AddModulusEvaluateOperator,
		MeanEvaluateOperator,
		AbsEvaluateOperator,
		ExponentialEvaluateOperator,
		MedianEvaluateOperator
	}

	enum MagickFunction
	{
		UndefinedFunction,
		PolynomialFunction,
		SinusoidFunction,
		ArcsinFunction,
		ArctanFunction
	}

	ChannelStatistics* GetImageChannelStatistics(const(Image)*, ExceptionInfo*);

	Image* EvaluateImages(const(Image)*, const MagickEvaluateOperator, ExceptionInfo*);

	MagickBooleanType EvaluateImage(Image*, const MagickEvaluateOperator, const double, ExceptionInfo*);
	MagickBooleanType EvaluateImageChannel(Image*, const ChannelType, const MagickEvaluateOperator, const double, ExceptionInfo*);
	MagickBooleanType FunctionImage(Image*, const MagickFunction, const size_t, const(double)*, ExceptionInfo*);
	MagickBooleanType FunctionImageChannel(Image*, const ChannelType, const MagickFunction, const size_t, const(double)*, ExceptionInfo*);
	MagickBooleanType GetImageChannelExtrema(const(Image)*, const ChannelType, size_t*, size_t*, ExceptionInfo*);
	MagickBooleanType GetImageChannelMean(const(Image)*, const ChannelType, double*, double*, ExceptionInfo*);
	MagickBooleanType GetImageChannelKurtosis(const(Image)*, const ChannelType, double*, double*, ExceptionInfo*);
	MagickBooleanType GetImageChannelRange(const(Image)*, const ChannelType, double*, double*, ExceptionInfo*);
	MagickBooleanType GetImageExtrema(const(Image)*, size_t*, size_t*, ExceptionInfo*);
	MagickBooleanType GetImageRange(const(Image)*, double*, double*, ExceptionInfo*);
	MagickBooleanType GetImageMean(const(Image)*, double*, double*, ExceptionInfo*);
	MagickBooleanType GetImageKurtosis(const(Image)*, double*, double*, ExceptionInfo*);
}
