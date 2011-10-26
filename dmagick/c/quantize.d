module dmagick.c.quantize;

import dmagick.c.colorspace;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;

extern(C)
{
	/**
	 * Determines the dithering method to use.
	 */
	enum DitherMethod
	{
		UndefinedDitherMethod,      ///
		NoDitherMethod,             /// ditto
		RiemersmaDitherMethod,      /// ditto
		FloydSteinbergDitherMethod  /// ditto
	}

	struct QuantizeInfo
	{
		size_t
			number_colors;

		size_t
			tree_depth;

		MagickBooleanType
			dither;

		ColorspaceType
			colorspace;

		MagickBooleanType
			measure_error;

		size_t
			signature;

		DitherMethod
			dither_method;
	}

	MagickBooleanType CompressImageColormap(Image*);
	MagickBooleanType GetImageQuantizeError(Image*);
	MagickBooleanType PosterizeImage(Image*, const size_t, const MagickBooleanType);

	static if ( MagickLibVersion >= 0x668 )
	{
		MagickBooleanType PosterizeImageChannel(Image*, const ChannelType, const size_t, const MagickBooleanType);
	}

	MagickBooleanType QuantizeImage(const(QuantizeInfo)*, Image*);
	MagickBooleanType QuantizeImages(const(QuantizeInfo)*, Image*);
	MagickBooleanType RemapImage(const(QuantizeInfo)*, Image*, const(Image)*);
	MagickBooleanType RemapImages(const(QuantizeInfo)*, Image*, const(Image)*);

	QuantizeInfo* AcquireQuantizeInfo(const(ImageInfo)*);
	QuantizeInfo* CloneQuantizeInfo(const(QuantizeInfo)*);
	QuantizeInfo* DestroyQuantizeInfo(QuantizeInfo*);

	void GetQuantizeInfo(QuantizeInfo*);
}
