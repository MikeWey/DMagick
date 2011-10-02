module dmagick.c.composite;

import dmagick.c.image;
import dmagick.c.magickType;

alias ptrdiff_t ssize_t;

extern(C)
{
	enum CompositeOperator
	{
		UndefinedCompositeOp,
		NoCompositeOp,
		ModulusAddCompositeOp,
		AtopCompositeOp,
		BlendCompositeOp,
		BumpmapCompositeOp,
		ChangeMaskCompositeOp,
		ClearCompositeOp,
		ColorBurnCompositeOp,
		ColorDodgeCompositeOp,
		ColorizeCompositeOp,
		CopyBlackCompositeOp,
		CopyBlueCompositeOp,
		CopyCompositeOp,
		CopyCyanCompositeOp,
		CopyGreenCompositeOp,
		CopyMagentaCompositeOp,
		CopyOpacityCompositeOp,
		CopyRedCompositeOp,
		CopyYellowCompositeOp,
		DarkenCompositeOp,
		DstAtopCompositeOp,
		DstCompositeOp,
		DstInCompositeOp,
		DstOutCompositeOp,
		DstOverCompositeOp,
		DifferenceCompositeOp,
		DisplaceCompositeOp,
		DissolveCompositeOp,
		ExclusionCompositeOp,
		HardLightCompositeOp,
		HueCompositeOp,
		InCompositeOp,
		LightenCompositeOp,
		LinearLightCompositeOp,
		LuminizeCompositeOp,
		MinusDstCompositeOp,
		ModulateCompositeOp,
		MultiplyCompositeOp,
		OutCompositeOp,
		OverCompositeOp,
		OverlayCompositeOp,
		PlusCompositeOp,
		ReplaceCompositeOp,
		SaturateCompositeOp,
		ScreenCompositeOp,
		SoftLightCompositeOp,
		SrcAtopCompositeOp,
		SrcCompositeOp,
		SrcInCompositeOp,
		SrcOutCompositeOp,
		SrcOverCompositeOp,
		ModulusSubtractCompositeOp,
		ThresholdCompositeOp,
		XorCompositeOp,
		/*
		 * These are new operators, added after the above was last sorted.
		 * The list should be re-sorted only when a new library version is
		 * created.
		 */
		DivideDstCompositeOp,
		DistortCompositeOp,
		BlurCompositeOp,
		PegtopLightCompositeOp,
		VividLightCompositeOp,
		PinLightCompositeOp,
		LinearDodgeCompositeOp,
		LinearBurnCompositeOp,
		MathematicsCompositeOp,
		DivideSrcCompositeOp,
		MinusSrcCompositeOp,
		DarkenIntensityCompositeOp,
		LightenIntensityCompositeOp,

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
