module dmagick.c.feature;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickVersion;

extern(C)
{
	struct ChannelFeatures
	{
		double[4]
			angular_second_moment,
			contrast,
			correlation,
			variance_sum_of_squares,
			inverse_difference_moment,
			sum_average,
			sum_variance,
			sum_entropy,
			entropy,
			difference_variance,
			difference_entropy,
			measure_of_correlation_1,
			measure_of_correlation_2,
			maximum_correlation_coefficient;
	}

	ChannelFeatures* GetImageChannelFeatures(const(Image)*, const size_t, ExceptionInfo*);

	static if ( MagickLibVersion >= 0x689 )
	{
		Image* CannyEdgeImage(const(Image)*, const double, const double, const double, const double, ExceptionInfo*);
	}
	static if ( MagickLibVersion >= 0x690 )
	{
		Image* HoughLineImage(const(Image)*, const size_t, const size_t, const size_t, ExceptionInfo*);
		Image* MeanShiftImage(const(Image)*, const size_t, const size_t, const double, ExceptionInfo*);
	}
}
