module dmagick.c.colorspace;

import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	/**
	 * Specify the colorspace that quantization (color reduction and mapping)
	 * is done under or to specify the colorspace when encoding an output
	 * image. Colorspaces are ways of describing colors to fit the
	 * requirements of a particular application (e.g. Television, offset
	 * printing, color monitors).  Color reduction, by default, takes place
	 * in the RGBColorspace. Empirical evidence suggests that distances in
	 * color spaces such as YUVColorspace or YIQColorspace correspond to
	 * perceptual color differences more closely than do distances in RGB
	 * space. These color spaces may give better results when color reducing
	 * an image.
	 * 
	 * When encoding an output image, the colorspaces RGBColorspace,
	 * CMYKColorspace, and GRAYColorspace may be specified. The
	 * CMYKColorspace option is only applicable when writing TIFF, JPEG,
	 * and Adobe Photoshop bitmap (PSD) files.
	 */
	enum ColorspaceType
	{
		/**
		 * No colorspace has been specified.
		 */
		UndefinedColorspace,

		/**
		 * Red-Green-Blue colorspace
		 */
		RGBColorspace,
		
		/**
		 * Full-range grayscale
		 */
		GRAYColorspace,
		
		/**
		 * The Transparent color space behaves uniquely in that it preserves
		 * the matte channel of the image if it exists.
		 */
		TransparentColorspace,
		
		/**
		 * Red-Green-Blue colorspace
		 */
		OHTAColorspace,
		
		/**
		 * ditto
		 */
		LabColorspace,
		
		/**
		 * CIE XYZ
		 */
		XYZColorspace,
		
		/**
		 * Kodak PhotoCD PhotoYCC
		 */
		YCbCrColorspace,
		
		/**
		 * ditto
		 */
		YCCColorspace,
		
		/**
		 * Y-signal, U-signal, and V-signal colorspace. YUV is most widely
		 * used to encode color for use in television transmission.
		 */
		YIQColorspace,
		
		/**
		 * ditto
		 */
		YPbPrColorspace,
		
		/**
		 * ditto
		 */
		YUVColorspace,
		
		/**
		 * Cyan-Magenta-Yellow-Black colorspace. CYMK is a subtractive color
		 * system used by printers and photographers for the rendering of
		 * colors with ink or emulsion, normally on a white surface.
		 */
		CMYKColorspace,
		
		/**
		 * Kodak PhotoCD sRGB.
		 */
		sRGBColorspace,
		
		/**
		 * Hue, saturation, luminosity
		 */
		HSBColorspace,
		
		/**
		 * ditto
		 */
		HSLColorspace,
		
		/**
		 * Hue, whiteness, blackness
		 */
		HWBColorspace,
		
		/**
		 * Luma (Y) according to ITU-R 601
		 */
		Rec601LumaColorspace,
		
		/**
		 * YCbCr according to ITU-R 601
		 */
		Rec601YCbCrColorspace,
		
		/**
		 * Luma (Y) according to ITU-R 709
		 */
		Rec709LumaColorspace,
		
		/**
		 * YCbCr according to ITU-R 709
		 */
		Rec709YCbCrColorspace,
		
		/**
		 * Red-Green-Blue colorspace
		 */
		LogColorspace,
		
		/**
		 * Cyan-Magenta-Yellow-Black colorspace. CYMK is a subtractive color
		 * system used by printers and photographers for the rendering of
		 * colors with ink or emulsion, normally on a white surface.
		 */
		CMYColorspace,

		/**
		 * CIE 1976 (L*, u*, v*) color space.
		 */
		LuvColorspace,

		/**
		 * HCL is a color space that tries to combine the advantages of
		 * perceptual uniformity of Luv, and the simplicity of specification
		 * of HSV and HSL.
		 */
		HCLColorspace
	}

	MagickBooleanType RGBTransformImage(Image*, const ColorspaceType);
	MagickBooleanType SetImageColorspace(Image*, const ColorspaceType);
	MagickBooleanType TransformImageColorspace(Image*, const ColorspaceType);
	MagickBooleanType TransformRGBImage(Image*, const ColorspaceType);
}
