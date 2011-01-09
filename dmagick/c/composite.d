module dmagick.c.composite;

import core.sys.posix.sys.types;

import dmagick.c.image;
import dmagick.c.magickType;

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
		MinusCompositeOp,
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
		DivideCompositeOp,
		DistortCompositeOp,
		BlurCompositeOp,
		PegtopLightCompositeOp,
		VividLightCompositeOp,
		PinLightCompositeOp,
		LinearDodgeCompositeOp,
		LinearBurnCompositeOp,
		MathematicsCompositeOp
	}

	MagickBooleanType CompositeImage(Image*, const CompositeOperator, const(Image)*, const ssize_t, const ssize_t);
	MagickBooleanType CompositeImageChannel(Image*, const ChannelType, const CompositeOperator, const(Image)*, const ssize_t, const ssize_t);
	MagickBooleanType TextureImage(Image*, const(Image)*);
}
