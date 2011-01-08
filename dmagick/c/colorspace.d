module dmagick.c.colorspace;

import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	enum ColorspaceType
	{
		UndefinedColorspace,
		RGBColorspace,
		GRAYColorspace,
		TransparentColorspace,
		OHTAColorspace,
		LabColorspace,
		XYZColorspace,
		YCbCrColorspace,
		YCCColorspace,
		YIQColorspace,
		YPbPrColorspace,
		YUVColorspace,
		CMYKColorspace,
		sRGBColorspace,
		HSBColorspace,
		HSLColorspace,
		HWBColorspace,
		Rec601LumaColorspace,
		Rec601YCbCrColorspace,
		Rec709LumaColorspace,
		Rec709YCbCrColorspace,
		LogColorspace,
		CMYColorspace
	}

	MagickBooleanType RGBTransformImage(Image*, const ColorspaceType);
	MagickBooleanType SetImageColorspace(Image*, const ColorspaceType);
	MagickBooleanType TransformImageColorspace(Image*, const ColorspaceType);
	MagickBooleanType TransformRGBImage(Image*, const ColorspaceType);
}
