module dmagick.c.composite;

import dmagick.c.image;
import dmagick.c.magickType;

alias ptrdiff_t ssize_t;

extern(C)
{
	/**
	 * Select the image composition algorithm used to compose a
	 * composite image with a image.
	 */
	enum CompositeOperator
	{
		/** */
		UndefinedCompositeOp,

		/**
		 * No composite operator has been specified.
		 */
		NoCompositeOp,
		
		/**
		 * The result of composite image + image,
		 * with overflow wrapping around (mod 256).
		 */
		ModulusAddCompositeOp,
		
		/**
		 * The result is the same shape as image, with composite image
		 * obscuring image where the image shapes overlap. Note that this
		 * differs from OverCompositeOp because the portion of composite
		 * image outside of image's shape does not appear in the result.
		 */
		AtopCompositeOp,
		
		/**
		 * Merges images together such that both images are treated
		 * equally (being just added together), according to the percentage
		 * arguments given.
		 */
		BlendCompositeOp,
		
		/**
		 * The result image shaded by composite image.
		 */
		BumpmapCompositeOp,
		
		/**
		 * Replace any destination pixel that is the similar to the source
		 * image's pixel (as defined by the current fuzz factor),
		 * with transparency.
		 */
		ChangeMaskCompositeOp,
		
		/**
		 * Make the target image transparent. The composite image is ignored.
		 */
		ClearCompositeOp,
		
		/**
		 * Darkens the destination color to reflect the source color.
		 * Painting with white produces no change.
		 */
		ColorBurnCompositeOp,
		
		/**
		 * Brightens the destination color to reflect the source color.
		 * Painting with black produces no change.
		 */
		ColorDodgeCompositeOp,
		
		/**
		 * Each pixel in the result image is the combination of the
		 * brightness of the target image and the saturation and hue of the
		 * composite image. This is the opposite of LuminizeCompositeOp.
		 */
		ColorizeCompositeOp,
		
		/**
		 * Copy the black channel from the composite image to the target image.
		 */
		CopyBlackCompositeOp,
		
		/**
		 * Copy the blue channel from the composite image to the target image.
		 */
		CopyBlueCompositeOp,
		
		/**
		 * Replace the target image with the composite image.
		 */
		CopyCompositeOp,
		
		/**
		 * Copy the cyan channel from the composite image to the target image.
		 */
		CopyCyanCompositeOp,
		
		/**
		 * Copy the green channel from the composite image to the target image.
		 */
		CopyGreenCompositeOp,
		
		/**
		 * Copy the magenta channel from the composite image to the target image.
		 */
		CopyMagentaCompositeOp,
		
		/**
		 * If the composite image's matte attribute is true, copy the
		 * opacity channel from the composite image to the target image.
		 * Otherwise, set the target image pixel's opacity to the intensity
		 * of the corresponding pixel in the composite image.
		 */
		CopyOpacityCompositeOp,
		
		/**
		 * Copy the red channel from the composite image to the target image.
		 */
		CopyRedCompositeOp,
		
		/**
		 * Copy the yellow channel from the composite image to the target image.
		 */
		CopyYellowCompositeOp,
		
		/**
		 * Replace target image pixels with darker
		 * pixels from the composite image.
		 */
		DarkenCompositeOp,
		
		/**
		 * The part of the destination lying inside of the source is
		 * composited over the source and replaces the destination.
		 */
		DstAtopCompositeOp,
		
		/**
		 * The destination is left untouched.
		 */
		DstCompositeOp,
		
		/**
		 * The part of the destination lying inside of
		 * the source replaces the destination.
		 */
		DstInCompositeOp,
		
		/**
		 * The part of the destination lying outside of
		 * the source replaces the destination.
		 */
		DstOutCompositeOp,
		
		/**
		 * The destination is composited over the source
		 * and the result replaces the destination.
		 */
		DstOverCompositeOp,
		
		/**
		 * The result of abs(composite image - image). This is useful
		 * for comparing two very similar images.
		 */
		DifferenceCompositeOp,
		
		/**
		 * Displace target image pixels as defined by a displacement map.
		 * The operator used by the displace method.
		 */
		DisplaceCompositeOp,
		
		/**
		 * The operator used in the dissolve method.
		 */
		DissolveCompositeOp,
		
		/**
		 * Produces an effect similar to that of 'difference', but appears
		 * as lower contrast. Painting with white inverts the destination
		 * color. Painting with black produces no change.
		 */
		ExclusionCompositeOp,
		
		/**
		 * Multiplies or screens the colors, dependent on the source color
		 * value. If the source color is lighter than 0.5, the destination
		 * is lightened as if it were screened. If the source color is darker
		 * than 0.5, the destination is darkened, as if it were multiplied.
		 * The degree of lightening or darkening is proportional to the
		 * difference between the source color and 0.5. If it is equal to
		 * 0.5 the destination is unchanged. Painting with pure black or
		 * white produces black or white.
		 */
		HardLightCompositeOp,
		
		/**
		 * Each pixel in the result image is the combination of the hue of
		 * the target image and the saturation and brightness of the
		 * composite image.
		 */
		HueCompositeOp,
		
		/**
		 * The result is simply composite image cut by the shape of image.
		 * None of the image data of image is included in the result.
		 */
		InCompositeOp,
		
		/**
		 * Replace target image pixels with lighter
		 * pixels from the composite image.
		 */
		LightenCompositeOp,
		
		/**
		 * Increase contrast slightly with an impact on the foreground's
		 * tonal values.
		 */
		LinearLightCompositeOp,
		
		/**
		 * Each pixel in the result image is the combination of the
		 * brightness of the composite image and the saturation and hue
		 * of the target image. This is the opposite of ColorizeCompositeOp.
		 */
		LuminizeCompositeOp,
		
		/**
		 * The result of composite image - image, with overflow cropped
		 * to zero. The matte chanel is ignored (set to 255, full coverage).
		 */
		MinusDstCompositeOp,
		
		/**
		 * Used by the watermark method.
		 */
		ModulateCompositeOp,
		
		/**
		 * Multiplies the color of each target image pixel by the color
		 * of the corresponding composite image pixel. The result color
		 * is always darker.
		 */
		MultiplyCompositeOp,
		
		/**
		 * The resulting image is composite image
		 * with the shape of image cut out.
		 */
		OutCompositeOp,
		
		/**
		 * The result is the union of the the two image shapes with composite
		 * image obscuring image in the region of overlap. The matte channel
		 * of the composite image is respected, so that if the composite
		 * pixel is part or all transparent, the corresponding image pixel
		 * will show through.
		 */
		OverCompositeOp,
		
		/**
		 * Multiplies or screens the colors, dependent on the destination
		 * color. Source colors overlay the destination whilst preserving
		 * its highlights and shadows. The destination color is not replaced,
		 * but is mixed with the source color to reflect the lightness or
		 * darkness of the destination.
		 */
		OverlayCompositeOp,
		
		/**
		 * The result is just the sum of the image data. Output values are
		 * cropped to 255 (no overflow). This operation is independent of
		 * the matte channels.
		 */
		PlusCompositeOp,
		
		/**
		 * The resulting image is image replaced with composite image.
		 * Here the matte information is ignored.
		 */
		ReplaceCompositeOp,
		
		/**
		 * Each pixel in the result image is the combination of the
		 * saturation of the target image and the hue and brightness
		 * of the composite image.
		 */
		SaturateCompositeOp,
		
		/**
		 * Multiplies the inverse of each image's color information.
		 */
		ScreenCompositeOp,
		
		/**
		 * Darkens or lightens the colors, dependent on the source color
		 * value. If the source color is lighter than 0.5, the destination
		 * is lightened. If the source color is darker than 0.5, the
		 * destination is darkened, as if it were burned in. The degree of
		 * darkening or lightening is proportional to the difference between
		 * the source color and 0.5. If it is equal to 0.5, the destination
		 * is unchanged. Painting with pure black or white produces a
		 * distinctly darker or lighter area, but does not result in pure
		 * black or white.
		 */
		SoftLightCompositeOp,
		
		/**
		 * The part of the source lying inside of the destination is
		 * composited onto the destination.
		 */
		SrcAtopCompositeOp,
		
		/**
		 * The source is copied to the destination.
		 * The destination is not used as input.
		 */
		SrcCompositeOp,
		
		/**
		 * The part of the source lying inside of the destination
		 * replaces the destination.
		 */
		SrcInCompositeOp,
		
		/**
		 * The part of the source lying outside of the destination
		 * replaces the destination.
		 */
		SrcOutCompositeOp,
		
		/**
		 * The source is composited over the destination.
		 */
		SrcOverCompositeOp,
		
		/**
		 * The result of composite image - image, with underflow wrapping
		 * around (mod 256). The add and subtract operators can be used to
		 * perform reversable transformations.
		 */
		ModulusSubtractCompositeOp,
		
		/** */
		ThresholdCompositeOp,
		
		/**
		 * The result is the image data from both composite image and image
		 * that is outside the overlap region. The overlap region will
		 * be blank.
		 */
		XorCompositeOp,

		/*
		 * These are new operators, added after the above was last sorted.
		 * The list should be re-sorted only when a new library version is
		 * created.
		 */
		
		/**
		 * The two images are divided from each other, Src / Dest.
		 */
		DivideDstCompositeOp,
		
		/**
		 * Distort an image, using the given method
		 * and its required arguments.
		 */
		DistortCompositeOp,
		
		/**
		 * Provides you with a method of replacing each individual pixel by
		 * a Elliptical Gaussian Average (a blur) of the neighbouring pixels,
		 * according to a mapping image.
		 */
		BlurCompositeOp,
		
		/**
		 * Almost equivalent to SoftLightCompositeOp, but using
		 * a continuious mathematical formula rather than two conditionally
		 * selected formulae.
		 */
		PegtopLightCompositeOp,
		
		/**
		 * A modified LinearLightCompositeOp designed to preserve very
		 * stong primary and secondary colors in the image.
		 */
		VividLightCompositeOp,
		
		/**
		 * Similar to HardLightCompositeOp, but using sharp linear shadings,
		 * to similate the effects of a strong 'pinhole' light source.
		 */
		PinLightCompositeOp,
		
		/**
		 * This is equivelent to PlusCompositeOp in that the color channels
		 * are simply added, however it does not "plus" the alpha channel,
		 * but uses the normal OverCompositeOp alpha blending, which
		 * transparencies are involved. Produces a sort of additive
		 * multiply-like result.
		 */
		LinearDodgeCompositeOp,
		
		/**
		 * Same as LinearDodgeCompositeOp, but also subtract one from the
		 * result. Sort of a additive 'Screen' of the images
		 */
		LinearBurnCompositeOp,
		
		/**
		 * This composite method takes 4 numerical values to allow the user
		 * to define many different Mathematical Compose Methods.
		 */
		MathematicsCompositeOp,
		
		/**
		 * The two images are divided from each other, Dest / Src.
		 */
		DivideSrcCompositeOp,
		
		/**
		 * The result of image - composite image, with overflow cropped
		 * to zero. The matte chanel is ignored (set to 255, full coverage).
		 */
		MinusSrcCompositeOp,
		
		/**
		 * Compare the source and destination image color values and
		 * take the darker value.
		 */
		DarkenIntensityCompositeOp,
		
		/**
		 * Compare the source and destination image color values and
		 * take the lighter value.
		 */
		LightenIntensityCompositeOp,

		/** */
		HardMixCompositeOp,

		/* Depreciated (renamed) Method Names for backward compatibility */
		AddCompositeOp      = ModulusAddCompositeOp,
		SubtractCompositeOp = ModulusSubtractCompositeOp,
		MinusCompositeOp    = MinusDstCompositeOp,
		DivideCompositeOp   = DivideDstCompositeOp		
	}

	MagickBooleanType CompositeImage(Image*, const CompositeOperator, const(Image)*, const ssize_t, const ssize_t);
	MagickBooleanType CompositeImageChannel(Image*, const ChannelType, const CompositeOperator, const(Image)*, const ssize_t, const ssize_t);
	MagickBooleanType TextureImage(Image*, const(Image)*);
}
