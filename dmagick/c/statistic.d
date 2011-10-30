module dmagick.c.statistic;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;

extern(C)
{
	struct ChannelStatistics
	{
		size_t
			depth;

		static if ( MagickLibVersion >= 0x664 )
		{
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
		else
		{
			double
				minima,
				maxima,
				mean,
				standard_deviation,
				kurtosis,
				skewness;
		}
	}

	/**
	 * Alter channel pixels by evaluating an arithmetic, relational,
	 * or logical expression.
	 */
	enum MagickEvaluateOperator
	{
		UndefinedEvaluateOperator,      ///
		AddEvaluateOperator,            /// Add value to pixels.
		AndEvaluateOperator,            /// Binary AND of pixels with value.
		DivideEvaluateOperator,         /// Divide pixels by value.
		LeftShiftEvaluateOperator,      /// Shift the pixel values left by value bits.
		MaxEvaluateOperator,            /// Clip pixels at lower bound value.
		MinEvaluateOperator,            /// Clip pixels at upper bound value.
		MultiplyEvaluateOperator,       /// Multiply pixels by value.
		OrEvaluateOperator,             /// Binary OR of pixels with value.
		RightShiftEvaluateOperator,     /// Shift the pixel values right by value bits.
		SetEvaluateOperator,            /// Set pixel equal to value.
		SubtractEvaluateOperator,       /// Subtract value from pixels.
		XorEvaluateOperator,            /// Binary XOR of pixels with value.
		PowEvaluateOperator,            /// Raise normalized pixels to the power value.
		LogEvaluateOperator,            /// Apply scaled logarithm to normalized pixels.
		ThresholdEvaluateOperator,      /// Threshold pixels larger than value.
		ThresholdBlackEvaluateOperator, /// Threshold pixels to zero values equal to or below value.
		ThresholdWhiteEvaluateOperator, /// Threshold pixels to maximum values above value.
		GaussianNoiseEvaluateOperator,       /// 
		ImpulseNoiseEvaluateOperator,        /// ditto
		LaplacianNoiseEvaluateOperator,      /// ditto
		MultiplicativeNoiseEvaluateOperator, /// ditto
		PoissonNoiseEvaluateOperator,        /// ditto
		UniformNoiseEvaluateOperator,        /// ditto
		CosineEvaluateOperator,      /// Apply cosine to pixels with frequency value with 50% bias added.
		SineEvaluateOperator,        /// Apply sine to pixels with frequency value with 50% bias added.
		AddModulusEvaluateOperator,  /// Add value to pixels modulo QuantumRange.
		MeanEvaluateOperator,        /// Add the value and divide by 2.
		AbsEvaluateOperator,         /// Add value to pixels and return absolute value.
		ExponentialEvaluateOperator, /// base-e exponential function.
		MedianEvaluateOperator       /// Choose the median value from an image sequence.
	}

	/**
	 * Apply a function to channel values.
	 * 
	 * See_Also: $(XREF Image, functionImage).
	 */
	enum MagickFunction
	{
		UndefinedFunction,  ///
		PolynomialFunction, /// ditto
		SinusoidFunction,   /// ditto
		ArcsinFunction,     /// ditto
		ArctanFunction      /// ditto
	}

	ChannelStatistics* GetImageChannelStatistics(const(Image)*, ExceptionInfo*);

	static if ( MagickLibVersion < 0x661 )
	{
		Image* AverageImages(const(Image)*, ExceptionInfo*);
	}

	static if ( MagickLibVersion >= 0x661 )
	{
		Image* EvaluateImages(const(Image)*, const MagickEvaluateOperator, ExceptionInfo*);
	}

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
