/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */

module dmagick.Image;

import std.algorithm : min;
import std.array;
import std.conv;
import std.math;
import std.string;
import std.typecons : Tuple;
import std.uni;
import core.memory;
import core.runtime;
import core.time;
import core.stdc.string;

import dmagick.Color;
import dmagick.Exception;
import dmagick.Geometry;
import dmagick.ImageView;
import dmagick.Options;
import dmagick.Utils;

version(Windows) import dmagick.internal.Windows;

//Import all translated c headers.
import dmagick.c.MagickCore;

/// See_Also: $(CXREF geometry, _AffineMatrix)
public alias dmagick.c.geometry.AffineMatrix AffineMatrix;
/// See_Also: $(CXREF image, _AlphaChannelType)
public alias dmagick.c.image.AlphaChannelType AlphaChannelType;
/// See_Also: $(CXREF magickType, _ChannelType)
public alias dmagick.c.magickType.ChannelType ChannelType;
/// See_Also: $(CXREF image, _ChromaticityInfo)
public alias dmagick.c.image.ChromaticityInfo ChromaticityInfo;
/// See_Also: $(CXREF magickType, _ClassType)
public alias dmagick.c.magickType.ClassType ClassType;
/// See_Also: $(CXREF colorspace, _ColorspaceType)
public alias dmagick.c.colorspace.ColorspaceType ColorspaceType;
/// See_Also: $(CXREF composite, _CompositeOperator)
public alias dmagick.c.composite.CompositeOperator CompositeOperator;
/// See_Also: $(CXREF compress, _CompressionType)
public alias dmagick.c.compress.CompressionType CompressionType;
/// See_Also: $(CXREF layer, _DisposeType)
public alias dmagick.c.layer.DisposeType DisposeType;
/// See_Also: $(CXREF distort, _DistortImageMethod)
public alias dmagick.c.distort.DistortImageMethod DistortImageMethod;
/// See_Also: $(CXREF quantum, _EndianType)
public alias dmagick.c.quantum.EndianType EndianType;
/// See_Also: $(CXREF resample, _FilterTypes)
public alias dmagick.c.resample.FilterTypes FilterTypes;
/// See_Also: $(CXREF geometry, _GravityType)
public alias dmagick.c.geometry.GravityType GravityType;
/// See_Also: $(CXREF image, _ImageType)
public alias dmagick.c.image.ImageType ImageType;
/// See_Also: $(CXREF image, _InterlaceType)
public alias dmagick.c.image.InterlaceType InterlaceType;
/// See_Also: $(CXREF pixel, _InterpolatePixelMethod)
public alias dmagick.c.pixel.InterpolatePixelMethod InterpolatePixelMethod;
/// See_Also: $(CXREF statistic, _MagickEvaluateOperator)
public alias dmagick.c.statistic.MagickEvaluateOperator MagickEvaluateOperator;
/// See_Also: $(CXREF statistic, _MagickFunction)
public alias dmagick.c.statistic.MagickFunction MagickFunction;
/// See_Also: $(CXREF fx, _NoiseType)
public alias dmagick.c.fx.NoiseType NoiseType;
/// See_Also: $(CXREF image, _OrientationType)
public alias dmagick.c.image.OrientationType OrientationType;
/// See_Also: $(CXREF effect, _PreviewType)
public alias dmagick.c.effect.PreviewType PreviewType;
/// See_Also: $(CXREF magickType, _Quantum)
public alias dmagick.c.magickType.Quantum Quantum;
/// See_Also: $(CXREF profile, _RenderingIntent)
public alias dmagick.c.profile.RenderingIntent RenderingIntent;
/// See_Also: $(CXREF image, _ResolutionType)
public alias dmagick.c.image.ResolutionType ResolutionType;
/// See_Also: $(CXREF distort, _SparseColorMethod)
public alias dmagick.c.distort.SparseColorMethod SparseColorMethod;
/// See_Also: $(CXREF effect, _StatisticType)
public alias dmagick.c.statistic.StatisticType StatisticType;
/// See_Also: $(CXREF constitute, _StorageType)
public alias dmagick.c.constitute.StorageType StorageType;
/// See_Also: $(CXREF draw, _TypeMetric)
public alias dmagick.c.draw.TypeMetric TypeMetric;
/// See_Also: $(CXREF cacheView, _VirtualPixelMethod)
public alias dmagick.c.cacheView.VirtualPixelMethod VirtualPixelMethod;

alias ptrdiff_t ssize_t;

/**
 * The image
 */
class Image
{
	alias dmagick.c.image.Image MagickCoreImage;
	alias RefCounted!( DestroyImage, MagickCoreImage ) ImageRef;

	ImageRef imageRef;
	Options options;  ///The options for this image.

	private bool delegate(string, long, ulong) progressMonitor;
	
	///
	this()
	{
		options = new Options();
		imageRef = ImageRef(AcquireImage(options.imageInfo));
	}

	this(MagickCoreImage* image, Options options = null)
	{
		this(ImageRef(image), options);
	}

	this(ImageRef image, Options options = null)
	{
		if ( options is null )
			this.options = new Options();
		else
			this.options = options;

		imageRef = image;
	}

	/**
	 * Construct an Image by reading from the file or
	 * URL specified by filename.
	 */
	this(string filename)
	{
		options = new Options();
		read(filename);
	}

	/**
	 * Construct a blank image with the specified color.
	 */
	this(Geometry size, Color color)
	{
		options = new Options();
		options.size = size;

		//Use read to create a cnavas with the spacified color.
		read( "canvas:"~ color.toString() );
	}

	/**
	 * Construct an image from an in-memory blob.
	 * The Blob size, depth and magick format may also be specified.
	 *
	 * Some image formats require size to be specified,
	 * the default depth Imagemagick uses is the Quantum size
	 * it's compiled with. If it doesn't match the depth of the image
	 * it may need to be specified.
	 *
	 * Imagemagick can usualy detect the image format, when the
	 * format can't be detected a magick format must be specified.
	 */
	this(void[] blob)
	{
		options = new Options();

		read(blob);
	}

	///ditto
	this(void[] blob, Geometry size)
	{
		options = new Options();

		read(blob, size);
	}

	///ditto
	this(void[] blob, Geometry size, size_t depth)
	{
		options = new Options();

		read(blob, size, depth);
	}

	///ditto
	this(void[] blob, Geometry size, size_t depth, string magick)
	{
		options = new Options();

		read(blob, size, depth, magick);
	}
	
	///ditto
	this(void[] blob, Geometry size, string magick)
	{
		options = new Options();

		read(blob, size, magick);
	}

	/**
	 * Constructs an image from an array of pixels.
	 *
	 * Params:
	 *     columns =  The number of columns in the image.
	 *     rows    =  The number of rows in the image.
	 *     map     =  A string describing the expected ordering
	 *                of the pixel array. It can be any combination
	 *                or order of R = red, G = green, B = blue, A = alpha
	 *                , C = cyan, Y = yellow, M = magenta, K = black,
	 *                or I = intensity (for grayscale).
	 *     storage  = The pixel Staroage type (CharPixel,
	 *                ShortPixel, IntegerPixel, FloatPixel, or DoublePixel).
	 *     pixels   = The pixel data.
	 */
	this(size_t columns, size_t rows, string map, StorageType storage, void[] pixels)
	{
		options = new Options();

		MagickCoreImage* image = 
			ConstituteImage(columns, rows, toStringz(map), storage, pixels.ptr, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Constructs a description of the image as a string.
	 * The string contains some or all of the following fields:
	 * $(LIST
	 *     $(B filename) The current filename.,
	 *     $(B [scene]) The scene number if the image is part of a secuence.,
	 *     $(B format) The image format.,
	 *     $(B width x height),
	 *     $(B page width x height + xOffset + yOffset),
	 *     $(B classType) DirectClass or PseudoClass,
	 *     $(B N-bit) bit depth.,
	 *     $(B blob size) if present.
	 * )
	 */
	override string toString()
	{
		string result;

		result ~= to!(string)(imageRef.filename);

		//Scene number.
		ssize_t index = GetImageIndexInList(imageRef);
		if ( index > 0 )
		{
			result ~= std.string.format("[%s]", index);
		}

		result ~= std.string.format(" %s ", format);
		result ~= std.string.format("%sx%s ", columns, rows);

		//Page size
		if ( imageRef.page.width > 0 || imageRef.page.height > 0 
			|| imageRef.page.x != 0 || imageRef.page.y != 0 )
		{
			result ~= std.string.format("%sx%s%+s%+s ",
				imageRef.page.width, imageRef.page.height,
				imageRef.page.x,     imageRef.page.y);
		}

		if ( classType == ClassType.DirectClass )
			result ~= "DirectClass ";
		else
			result ~= "PseudoClass ";

		result = std.string.format("%s-bit ", GetImageQuantumDepth(imageRef, true));

		//Size of the image.
		MagickSizeType size = GetBlobSize(imageRef);
		if ( size > 0 )
		{
			if ( size > 2*1024*1024 )
				result ~= std.string.format("%s MiB", size/1024/1024);
			else if ( size > 2*1024 )
				result ~= std.string.format("%s KiB", size/1024);
			else
				result ~= std.string.format("%s bytes", size);
		}

		return result;
	}

	/**
	 * Adaptively blurs the image by blurring more intensely near
	 * image edges and less intensely far from edges.
	 * The adaptiveBlur method blurs the image with a Gaussian operator
	 * of the given radius and standard deviation (sigma).
	 * For reasonable results, radius should be larger than sigma.
	 * Use a radius of 0 and adaptiveBlur selects a suitable radius for you.
	 *
	 * Params:
	 *     radius  = The radius of the Gaussian in pixels,
	 *               not counting the center pixel.
	 *     sigma   = The standard deviation of the Laplacian, in pixels.
	 *     channel = The channels to blur.
	 */
	void adaptiveBlur(double radius = 0, double sigma = 1, ChannelType channel = ChannelType.DefaultChannels)
	{
		MagickCoreImage* image =
			AdaptiveBlurImageChannel(imageRef, channel, radius, sigma, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * adaptiveResize uses the special Mesh Interpolation method
	 * to resize images. Basically adaptiveResize avoids the excessive
	 * blurring that resize can produce with sharp color changes.
	 * This works well for slight image size adjustments and in
	 * particularly for magnification, And especially with images
	 * with sharp color changes. But when images are enlarged or reduced
	 * by more than 50% it will start to produce aliasing,
	 * and Moiré effects in the results.
	 */
	void adaptiveResize(Geometry size)
	{
		size = size.toAbsolute(columns, rows);

		MagickCoreImage* image =
			AdaptiveResizeImage(imageRef, size.width, size.height, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Adaptively sharpens the image by sharpening more intensely near
	 * image edges and less intensely far from edges. The adaptiveSharpen
	 * method sharpens the image with a Gaussian operator of the given
	 * radius and standard deviation (sigma). For reasonable results,
	 * radius should be larger than sigma. Use a radius of 0 and
	 * adaptiveSharpen selects a suitable radius for you.
	 *
	 * Params:
	 *     radius  = The radius of the Gaussian in pixels,
	 *               not counting the center pixel.
	 *     sigma   = The standard deviation of the Laplacian, in pixels.
	 *     channel = If no channels are specified, sharpens all the channels.
	 */
	void adaptiveSharpen(double radius = 0, double sigma = 1, ChannelType channel = ChannelType.DefaultChannels)
	{
		MagickCoreImage* image =
			AdaptiveSharpenImageChannel(imageRef, channel, radius, sigma, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Selects an individual threshold for each pixel based on the range
	 * of intensity values in its local neighborhood. This allows for
	 * thresholding of an image whose global intensity histogram doesn't
	 * contain distinctive peaks.
	 *
	 * Params:
	 *     width  = define the width of the local neighborhood.
	 *     heigth = define the height of the local neighborhood.
	 *     offset = constant to subtract from pixel neighborhood mean.
	 */
	void adaptiveThreshold(size_t width = 3, size_t height = 3, ssize_t offset = 0)
	{
		MagickCoreImage* image =
			AdaptiveThresholdImage(imageRef, width, height, offset, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Adds random noise to the specified channel or channels in the image.
	 * The amount of time addNoise requires depends on the NoiseType argument.
	 *
	 * Params:
	 *     type    = A NoiseType value.
	 *     channel = 0 or more ChannelType arguments. If no channels are
	 *               specified, adds noise to all the channels
	 */
	void addNoise(NoiseType type, ChannelType channel = ChannelType.DefaultChannels)
	{
		MagickCoreImage* image =
			AddNoiseImageChannel(imageRef, channel, type, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Transforms the image as specified by the affine matrix.
	 */
	void affineTransform(AffineMatrix affine)
	{
		MagickCoreImage* image =
			AffineTransformImage(imageRef, &affine, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Annotates an image with text.  Optionally you can include any 
	 * of the following bits of information about the image by embedding
	 * the appropriate special characters:
	 * --------------------
	 *     %b   file size in bytes.
	 *     %c   comment.
	 *     %d   directory in which the image resides.
	 *     %e   extension of the image file.
	 *     %f   original filename of the image.
	 *     %h   height of image.
	 *     %i   filename of the image.
	 *     %k   number of unique colors.
	 *     %l   image label.
	 *     %m   image file format.
	 *     %n   number of images in a image sequence.
	 *     %o   output image filename.
	 *     %p   page number of the image.
	 *     %q   image depth (8 or 16).
	 *     %q   image depth (8 or 16).
	 *     %s   image scene number.
	 *     %t   image filename without any extension.
	 *     %u   a unique temporary filename.
	 *     %w   image width.
	 *     %x   x resolution of the image.
	 *     %y   y resolution of the image.
	 *--------------------
	 * Params:
	 *     text    = The text.
	 *     xOffset = The x coordinate.
	 *     yOffset = The y coordinate.
	 *     gravity = Placement gravity.
	 *     degrees = The angle of the Text.
	 */
	void annotate(
		string text,
		size_t xOffset,
		size_t yOffset,
		GravityType gravity = GravityType.NorthWestGravity,
		double degrees = 0.0)
	{
		annotate(text, Geometry(size_t.max, size_t.max, xOffset, yOffset), gravity, degrees);
	}

	/**
	 * Ditto, but word wraps the text so it stays withing the
	 * boundingArea. if the height and width are 0 the height and
	 * with of the image are used to calculate the bounding area.
	 */
	void annotate(
		string text,
		Geometry boundingArea = Geometry.init,
		GravityType gravity = GravityType.NorthWestGravity,
		double degrees = 0.0)
	{
		if ( boundingArea.width == 0 )
			boundingArea.width = columns;

		if ( boundingArea.height == 0 )
			boundingArea.height = rows;

		if ( boundingArea.width > 0 )
			text = wordWrap(text, boundingArea);

		DrawInfo* drawInfo = options.drawInfo;
		AffineMatrix oldAffine = options.affine;

		copyString(drawInfo.text, text);
		copyString(drawInfo.geometry, boundingArea.toString());

		drawInfo.gravity = gravity;
		options.transformRotation(degrees);

		scope(exit)
		{
			copyString(drawInfo.text, null);
			copyString(drawInfo.geometry, null);

			drawInfo.gravity = GravityType.NorthWestGravity;
			options.affine = oldAffine;
		}

		AnnotateImage(imageRef, drawInfo);

		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * extract the 'mean' from the image and adjust the image
	 * to try make set its gamma appropriatally.
	 * 
	 * Params:
	 *     channel = One or more channels to adjust.
	 */
	void autoGamma(ChannelType channel = ChannelType.DefaultChannels)
	{
		AutoGammaImageChannel(imageRef, channel);

		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * adjusts the levels of a particular image channel by scaling
	 * the minimum and maximum values to the full quantum range.
	 * 
	 * Params:
	 *     channel = One or more channels to adjust.
	 */
	void autoLevel(ChannelType channel = ChannelType.DefaultChannels)
	{
		AutoLevelImageChannel(imageRef, channel);

		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Changes the value of individual pixels based on the intensity
	 * of each pixel channel. The result is a high-contrast image.
	 *
	 * More precisely each channel value of the image is 'thresholded'
	 * so that if it is equal to or less than the given value it is set
	 * to zero, while any value greater than that give is set to it
	 * maximum or QuantumRange.
	 * 
	 * Params:
	 *     threshold = The threshold value.
	 *     channel   = One or more channels to adjust.
	 */
	void bilevel(Quantum threshold, ChannelType channel = ChannelType.DefaultChannels)
	{
		BilevelImageChannel(imageRef, channel, threshold);

		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Forces all pixels below the threshold into black while leaving
	 * all pixels above the threshold unchanged.
	 * 
	 * Params:
	 *     threshold = The threshold value for red green and blue.
	 *     channel   = One or more channels to adjust.
	 */
	void blackThreshold(Quantum threshold, ChannelType channel = ChannelType.DefaultChannels)
	{
		blackThreshold(threshold, threshold, threshold, 0, channel);
	}

	///ditto
	void blackThreshold(
		Quantum red,
		Quantum green,
		Quantum blue,
		Quantum opacity = 0,
		ChannelType channel = ChannelType.DefaultChannels)
	{
		string thresholds = std.string.format("%s,%s,%s,%s", red, green, blue, opacity);

		BlackThresholdImageChannel(
			imageRef, channel, toStringz(thresholds), DMagickExceptionInfo()
		);
	}

	/**
	 * Adds the overlay image to the target image according to
	 * srcPercent and dstPercent.
	 * 
	 * This method corresponds to the -blend option of ImageMagick's
	 * composite command.
	 * 
	 * Params:
	 *     overlay       = The source image for the composite operation.
	 *     srcPercentage = Percentage for the source image.
	 *     dstPercentage = Percentage for this image.
	 *     xOffset       = The x offset to use for the overlay.
	 *     yOffset       = The y offset to use for the overlay.
	 *     gravity       = The gravity to use for the overlay.
	 */
	void blend(
		const(Image) overlay,
		int srcPercentage,
		int dstPercentage,
		ssize_t xOffset,
		ssize_t yOffset)
	{
		SetImageArtifact(imageRef, "compose:args",
			toStringz(std.string.format("%s,%s", srcPercentage, dstPercentage)));
		scope(exit) RemoveImageArtifact(imageRef, "compose:args");

		composite(overlay, CompositeOperator.BlendCompositeOp, xOffset, yOffset);
	}

	///ditto
	void blend(
		const(Image) overlay,
		int srcPercentage,
		int dstPercentage,
		GravityType gravity = GravityType.NorthWestGravity)
	{
		RectangleInfo geometry;

		SetGeometry(overlay.imageRef, &geometry);
		GravityAdjustGeometry(columns, rows, gravity, &geometry);

		blend(overlay, srcPercentage, dstPercentage, geometry.x, geometry.y);
	}

	/**
	 * mutes the colors of the image to simulate a scene at
	 * nighttime in the moonlight.
	 * 
	 * Params:
	 *     factor = The shift factor, larger values increase the effect.
	 */
	void blueShift(double factor = 1.5)
	{
		MagickCoreImage* image =
			BlueShiftImage(imageRef, factor, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Blurs the specified channel. We convolve the image with a Gaussian
	 * operator of the given radius and standard deviation (sigma).
	 * The blur method differs from gaussianBlur in that it uses a
	 * separable kernel which is faster but mathematically equivalent
	 * to the non-separable kernel.
	 *
	 * Params:
	 *     radius  = The radius of the Gaussian in pixels,
	 *               not counting the center pixel.
	 *     sigma   = The standard deviation of the Laplacian, in pixels.
	 *     channel = The channels to blur.
	 */
	void blur(double radius = 0, double sigma = 1, ChannelType channel = ChannelType.DefaultChannels)
	{
		MagickCoreImage* image =
			BlurImageChannel(imageRef, channel, radius, sigma, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Surrounds the image with a border of the color defined
	 * by the borderColor property.
	 *
	 * Params:
	 *     width  = Border width in pixels.
	 *     height = Border height in pixels.
	 */
	void border(size_t width, size_t height)
	{
		RectangleInfo borderInfo = RectangleInfo(width, height);

		MagickCoreImage* image =
			BorderImage(imageRef, &borderInfo, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Extract channel from image. Use this option to extract a
	 * particular channel from the image. ChannelType.MatteChannel for
	 * example, is useful for extracting the opacity values from an image.
	 */
	Image channel(ChannelType channel) const
	{
		MagickCoreImage* image =
			SeparateImages(imageRef, channel, DMagickExceptionInfo());

		return new Image(image);
	}

	/**
	 * Adds a "charcoal" effect to the image. You can alter the
	 * intensity of the effect by changing the radius and sigma arguments.
	 *
	 * Params:
	 *     radius = The radius of the pixel neighborhood.
	 *     sigma  = The standard deviation of the Gaussian, in pixels.
	 */
	void charcoal(double radius = 0, double sigma = 1)
	{
		MagickCoreImage* image =
			CharcoalImage(imageRef, radius, sigma, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Removes the specified rectangle and collapses the rest of
	 * the image to fill the removed portion.
	 *
	 * Params:
	 *     geometry = The horizontal and/or vertical subregion to remove.
	 */
	void chop(Geometry geometry)
	{
		RectangleInfo rectangle = geometry.rectangleInfo;

		MagickCoreImage* image =
			ChopImage(imageRef, &rectangle, DMagickExceptionInfo());

		imageRef = ImageRef(image);		
	}

	/**
	 * Returns a copy of the image.
	 */
	Image clone() const
	{
		MagickCoreImage* image =
			CloneImage(imageRef, 0, 0, true, DMagickExceptionInfo());

		return new Image(image, options.clone());
	}

	/**
	 * replaces each color value in the given image, by using it as an
	 * index to lookup a replacement color value in a Color Look UP Table
	 * in the form of an image.  The values are extracted along a diagonal
	 * of the CLUT image so either a horizontal or vertial gradient image
	 * can be used.
	 * 
	 * Typically this is used to either re-color a gray-scale image
	 * according to a color gradient in the CLUT image, or to perform a
	 * freeform histogram (level) adjustment according to the (typically
	 * gray-scale) gradient in the CLUT image.
	 * 
	 * When the 'channel' mask includes the matte/alpha transparency
	 * channel but one image has no such channel it is assumed that that
	 * image is a simple gray-scale image that will effect the alpha channel
	 * values, either for gray-scale coloring (with transparent or
	 * semi-transparent colors), or a histogram adjustment of existing alpha
	 * channel values. If both images have matte channels, direct and normal
	 * indexing is applied, which is rarely used.
	 *
	 * Params:
	 *     clutImage = the color lookup table image for replacement
	 *                 color values.
	 *     channel   = One or more channels to adjust.
	 */
	void clut(Image clutImage, ChannelType channel = ChannelType.DefaultChannels)
	{
		ClutImageChannel(imageRef, channel, clutImage.imageRef);

		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Applies a lightweight Color Correction Collection (CCC) file
	 * to the image. The file solely contains one or more color corrections.
	 * Here is a sample:
	 * --------------------
	 * <ColorCorrectionCollection xmlns="urn:ASC:CDL:v1.2">
	 *     <ColorCorrection id="cc03345">
	 *         <SOPNode>
	 *             <Slope> 0.9 1.2 0.5 </Slope>
	 *             <Offset> 0.4 -0.5 0.6 </Offset>
	 *             <Power> 1.0 0.8 1.5 </Power>
	 *         </SOPNode>
	 *         <SATNode>
	 *             <Saturation> 0.85 </Saturation>
	 *         </SATNode>
	 *     </ColorCorrection>
	 * </ColorCorrectionCollection>
	 * --------------------
	 * which includes the slop, offset, and power for each of
	 * the RGB channels as well as the saturation.
	 * 
	 * See_Also: $(LINK2 http://en.wikipedia.org/wiki/ASC_CDL,
	 *         Wikipedia ASC CDL).
	 */
	void colorDecisionList(string colorCorrectionCollection)
	{
		ColorDecisionListImage(imageRef, toStringz(colorCorrectionCollection));

		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Blend the fill color with the image pixels. The opacityRed,
	 * opacityGreen, opacityBlue and opacityAlpha arguments are the
	 * percentage to blend with the red, green, blue and alpha channels.
	 */
	void colorize(Color fill, uint opacityRed, uint opacityGreen, uint opacityBlue, uint opacityAlpha = 0)
	{
		string opacity = std.string.format("%s/%s/%s/%s",
			opacityRed, opacityGreen, opacityBlue, opacityAlpha);

		MagickCoreImage* image =
			ColorizeImage(imageRef, toStringz(opacity), fill.pixelPacket, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Applies color transformation to an image. This method permits
	 * saturation changes, hue rotation, luminance to alpha, and various
	 * other effects.  Although variable-sized transformation matrices can
	 * be used, typically one uses a 5x5 matrix for an RGBA image and a 6x6
	 * for CMYKA (or RGBA with offsets).  The matrix is similar to those
	 * used by Adobe Flash except offsets are in column 6 rather than 5
	 * (in support of CMYKA images) and offsets are normalized
	 * (divide Flash offset by 255)
	 *
	 * Params:
	 *     matrix = A tranformation matrix, with a maximum size of 6x6.
	 */
	void colorMatrix(double[][] matrix)
	{
		if ( matrix.length > 6 || matrix[0].length > 6 )
			throw new DMagickException("Matrix must be 6x6 or smaller.");

		static if ( is(typeof(ColorMatrixImage)) )
		{
			KernelInfo* kernelInfo = AcquireKernelInfo("1");
			scope(exit) DestroyKernelInfo(kernelInfo);

			kernelInfo.width = matrix[0].length;
			kernelInfo.height = matrix.length;
			kernelInfo.values = cast(double*)AcquireQuantumMemory(kernelInfo.width*kernelInfo.height, double.sizeof);
			scope(exit) kernelInfo.values = cast(double*)RelinquishMagickMemory(kernelInfo.values);

			foreach ( i, row; matrix )
			{
				size_t offset = i * row.length;

				kernelInfo.values[offset .. offset+row.length] = row;
			}

			MagickCoreImage* image =
				ColorMatrixImage(imageRef, kernelInfo, DMagickExceptionInfo());
		}
		else
		{
			double[] values;

			foreach ( i, row; matrix )
			{
				size_t offset = i * row.length;

				values[offset .. offset+row.length] = row;
			}

			MagickCoreImage* image =
				RecolorImage(imageRef, matrix.length, values.ptr, DMagickExceptionInfo());
		}

		imageRef = ImageRef(image);
	}

	/**
	 * Compare current image with another image. Sets meanErrorPerPixel,
	 * normalizedMaxError , and normalizedMeanError in the current image.
	 * false is returned if the images are identical. An ErrorOption
	 * exception is thrown if the reference image columns, rows, colorspace,
	 * or matte differ from the current image.
	 */
	bool compare(const(Image) referenceImage)
	{
		bool isEqual = IsImagesEqual(imageRef, referenceImage.imageRef) == 1;
		DMagickException.throwException(&(imageRef.exception));

		return isEqual;
	}

	/**
	 * Composites dest onto this image using the specified composite operator.
	 *
	 * Params:
	 *     overlay     = Image to use in the composite operation.
	 *     compositeOp = The composite operation to use.
	 *     xOffset     = The x-offset of the composited image,
	 *                   measured from the upper-left corner
	 *                   of the image.
	 *     yOffset     = The y-offset of the composited image,
	 *                   measured from the upper-left corner
	 *                   of the image.
	 *     gravity     = The gravity that defines the location of the
	 *                   location of overlay.
	 *     channel     = One or more channels to compose.
	 */
	void composite(
		const(Image) overlay,
		CompositeOperator compositeOp,
		ssize_t xOffset,
		ssize_t yOffset,
		ChannelType channel = ChannelType.DefaultChannels)
	{
		CompositeImageChannel(imageRef, channel, compositeOp, overlay.imageRef, xOffset, yOffset);

		DMagickException.throwException(&(imageRef.exception));
	}

	///ditto
	void composite(
		const(Image) overlay,
		CompositeOperator compositeOp,
		GravityType gravity = GravityType.NorthWestGravity,
		ChannelType channel = ChannelType.DefaultChannels)
	{
		RectangleInfo geometry;

		SetGeometry(overlay.imageRef, &geometry);
		GravityAdjustGeometry(columns, rows, gravity, &geometry);

		composite(overlay, compositeOp, geometry.x, geometry.y, channel);
	}

	/**
	 * Merge the source and destination images according to the
	 * formula a*Sc*Dc + b*Sc + c*Dc + d where Sc is the source
	 * pixel and Dc is the destination pixel.
	 *
	 * Params:
	 *     overlay = Image to use in to composite operation.
	 *     xOffset = The x-offset of the composited image,
	 *               measured from the upper-left corner
	 *               of the image.
	 *     yOffset = The y-offset of the composited image,
	 *               measured from the upper-left corner
	 *               of the image.
	 *     gravity = The gravity that defines the location of the
	 *               location of overlay.
	 *     channel = One or more channels to compose.
	 */
	void composite(
		const(Image) overlay,
		double a,
		double b,
		double c,
		double d,
		ssize_t xOffset,
		ssize_t yOffset,
		ChannelType channel = ChannelType.DefaultChannels)
	{
		SetImageArtifact(imageRef, "compose:args",
			toStringz(std.string.format("%s,%s,%s,%s", a, b, c, d)));
		scope(exit) RemoveImageArtifact(imageRef, "compose:args");

		composite(overlay, CompositeOperator.MathematicsCompositeOp, xOffset, yOffset, channel);
	}

	///ditto
	void composite(
		const(Image) overlay,
		double a,
		double b,
		double c,
		double d,
		GravityType gravity = GravityType.NorthWestGravity,
		ChannelType channel = ChannelType.DefaultChannels)
	{
		RectangleInfo geometry;

		SetGeometry(overlay.imageRef, &geometry);
		GravityAdjustGeometry(columns, rows, gravity, &geometry);

		composite(overlay, a, b, c, d, geometry.x, geometry.y, channel);
	}

	/**
	 * Composites multiple copies of the source image across and down
	 * the image, producing the same results as ImageMagick's composite
	 * command with the -tile option.
	 *
	 * Params:
	 *     overlay     = Image to use in to composite operation.
	 *     compositeOp = The composite operation to use.
	 *     channel     = One or more channels to compose.
	 */
	void compositeTiled(
		const(Image) overlay,
		CompositeOperator compositeOp,
		ChannelType channel = ChannelType.DefaultChannels)
	{
		SetImageArtifact(imageRef, "compose:outside-overlay", "false");
		scope(exit) RemoveImageArtifact(imageRef, "compose:outside-overlay");

		for ( size_t y = 0; y < rows; y += overlay.rows )
			for ( size_t x = 0; x < columns; x += overlay.columns )
				composite(overlay, compositeOp, x, y, channel);
	}

	/**
	 * enhances the intensity differences between the lighter and
	 * darker elements of the image.
	 *
	 * Params:
	 *     sharpen = If true increases the image contrast otherwise
	 *               the contrast is reduced.
	 */
	void contrast(bool sharpen = false)
	{
		ContrastImage(imageRef, sharpen);
		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * This is a simple image enhancement technique that attempts to
	 * improve the contrast in an image by `stretching' the range of
	 * intensity values it contains to span a desired range of values.
	 * It differs from the more sophisticated histogram equalization in
	 * that it can only apply a linear scaling function to the image pixel
	 * values. As a result the `enhancement' is less harsh.
	 *
	 * Params:
	 *     blackPoint = Black out at most this many pixels.
	 *                  Specify an apsulute number of pixels or an
	 *                  percentage by passing a value between 1 and 0
	 *     whitePoint = Burn at most this many pixels.
	 *                  Specify an apsulute number of pixels or an
	 *                  percentage by passing a value between 1 and 0
	 *     channel    = One or more channels to adjust.
	 */
	void contrastStretch(double blackPoint, double whitePoint, ChannelType channel = ChannelType.DefaultChannels)
	{
		if ( blackPoint < 1 )
			blackPoint *= QuantumRange;
		if ( whitePoint < 1 )
			whitePoint *= QuantumRange;

		ContrastStretchImageChannel(imageRef, channel, blackPoint, whitePoint);
		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Applies a custom convolution kernel to the image.
	 * See_Also: $(LINK2 http://www.dai.ed.ac.uk/HIPR2/convolve.htm,
	 *        Convolution in the Hypermedia Image Processing Reference).
	 */
	void convolve(double[][] matrix, ChannelType channel = ChannelType.DefaultChannels)
	{
		double[] kernel = new double[matrix.length * matrix[0].length];

		foreach ( i, row; matrix )
		{
			size_t offset = i * row.length;

			kernel[offset .. offset+row.length] = row;
		}

		MagickCoreImage* image =
			ConvolveImageChannel(imageRef, channel, matrix.length, kernel.ptr,  DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Extract a region of the image starting at the offset defined by
	 * geometry.  Region must be fully defined, and no special handling
	 * of geometry flags is performed.
	 */
	void crop(Geometry geometry)
	{
		RectangleInfo rectangle = geometry.rectangleInfo;

		MagickCoreImage* image =
			CropImage(imageRef, &rectangle, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * displaces an image's colormap by a given number of positions.
	 * If you cycle the colormap a number of times you can produce
	 * a psychodelic effect.
	 */
	void cycleColormap(ssize_t amount)
	{
		CycleColormapImage(imageRef, amount);
		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Decipher an enciphered image.
	 */
	void decipher(string passphrase)
	{
		DecipherImage(imageRef, toStringz(passphrase), DMagickExceptionInfo());
	}

	/**
	 * Straightens an image. A threshold of 40% works for most images.
	 * 
	 * Skew is an artifact that occurs in scanned images because of the
	 * camera being misaligned, imperfections in the scanning or surface,
	 * or simply because the paper was not placed completely flat when
	 * scanned.
	 * 
	 * Params:
	 *     threshold     = Specify an apsulute number of pixels or an
	 *                     percentage by passing a value between 1 and 0.
	 *     autoCropWidth = Specify a value for this argument to cause the
	 *                     deskewed image to be auto-cropped.
	 *                     The argument is the pixel width of the
	 *                     image background (e.g. 40).
	 *                     A width of 0 disables auto cropping.
	 */
	void deskew(double threshold = 0.4, size_t autoCropWidth = 0)
	{
		if ( autoCropWidth > 0 )
		{
			SetImageArtifact(imageRef, "deskew:auto-crop", toStringz(to!(string)(autoCropWidth)) );
			scope(exit) RemoveImageArtifact(imageRef, "deskew:auto-crop");
		}

		if ( threshold < 1 )
			threshold *= QuantumRange;

		MagickCoreImage* image =
			DeskewImage(imageRef, threshold, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Reduces the speckle noise in an image while perserving
	 * the edges of the original image.
	 */
	void despeckle()
	{
		MagickCoreImage* image =
			DespeckleImage(imageRef, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Uses displacementMap to move color from img to the output image.
	 * 
	 * This method corresponds to the -displace option of ImageMagick's
	 * composite command.
	 * 
	 * Params:
	 *     displacementMap = 
	 *                  The source image for the composite operation.
	 *     xAmplitude = The maximum displacement on the x-axis.
	 *     yAmplitude = The maximum displacement on the y-axis.
	 *     xOffset    = The x offset to use.
	 *     yOffset    = The y offset to use.
	 *     gravity    = The gravity to use.
	 */
	void displace(
		const(Image) displacementMap,
		int xAmplitude,
		int yAmplitude,
		ssize_t xOffset,
		ssize_t yOffset)
	{
		SetImageArtifact(imageRef, "compose:args",
			toStringz(std.string.format("%s,%s", xAmplitude, yAmplitude)));
		scope(exit) RemoveImageArtifact(imageRef, "compose:args");

		composite(displacementMap, CompositeOperator.DisplaceCompositeOp, xOffset, yOffset);
	}

	///ditto
	void displace(
		const(Image) overlay,
		int srcPercentage,
		int dstPercentage,
		GravityType gravity = GravityType.NorthWestGravity)
	{
		RectangleInfo geometry;

		SetGeometry(overlay.imageRef, &geometry);
		GravityAdjustGeometry(columns, rows, gravity, &geometry);

		displace(overlay, srcPercentage, dstPercentage, geometry.x, geometry.y);
	}	

	/**
	 * Display image on screen.
	 * 
	 * $(RED Caution:) if an image format is is not compatible with
	 * the display visual (e.g. JPEG on a colormapped display)
	 * then the original image will be altered. Use a copy of the
	 * original if this is a problem.
	 */
	void display()
	{
		version(Windows)
		{
			Window win = new Window(this);
			win.display();
		}
		else
		{
			DisplayImages(options.imageInfo, imageRef);

			DMagickException.throwException(&(imageRef.exception));
		}
	}

	/**
	 * Composites the overlay image onto this image. The opacity
	 * of this image is multiplied by dstPercentage and opacity of
	 * overlay is multiplied by srcPercentage.
	 * 
	 * This method corresponds to the -dissolve option
	 * of ImageMagick's composite command.
	 * 
	 * Params:
	 *     overlay       = The source image for the composite operation.
	 *     srcPercentage = Percentage for the source image.
	 *     dstPercentage = Percentage for this image.
	 *     xOffset       = The x offset to use for the overlay.
	 *     yOffset       = The y offset to use for the overlay.
	 *     gravity       = The gravity to use for the overlay.
	 */
	void dissolve(
		const(Image) overlay,
		int srcPercentage,
		int dstPercentage,
		ssize_t xOffset,
		ssize_t yOffset)
	{
		SetImageArtifact(imageRef, "compose:args",
			toStringz(std.string.format("%s,%s", srcPercentage, dstPercentage)));
		scope(exit) RemoveImageArtifact(imageRef, "compose:args");

		composite(overlay, CompositeOperator.DissolveCompositeOp, xOffset, yOffset);
	}

	///ditto
	void dissolve(
		const(Image) overlay,
		int srcPercentage,
		int dstPercentage,
		GravityType gravity = GravityType.NorthWestGravity)
	{
		RectangleInfo geometry;

		SetGeometry(overlay.imageRef, &geometry);
		GravityAdjustGeometry(columns, rows, gravity, &geometry);

		dissolve(overlay, srcPercentage, dstPercentage, geometry.x, geometry.y);
	}	

	/**
	 * Distort an image using the specified distortion type and its
	 * required arguments. This method is equivalent to ImageMagick's
	 * -distort option.
	 * 
	 * Params:
	 *     method    = Distortion method to use.
	 *     arguments = An array of numbers. The size of the array
	 *                 depends on the distortion type.
	 *     bestfit   = If enabled, and the distortion allows it,
	 *                 the destination image is adjusted to ensure 
	 *                 the whole source image will just fit within
	 *                 the final destination image, which will be
	 *                 sized and offset accordingly.
	 */
	void distort(DistortImageMethod method, double[] arguments, bool bestfit = false)
	{
		MagickCoreImage* image =
			DistortImage(imageRef, method, arguments.length, arguments.ptr, bestfit, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Finds edges in an image.
	 * 
	 * Params:
	 *     radius = the radius of the convolution filter.
	 *              If 0 a suitable default is selected.
	 */
	void edge(double radius = 0)
	{
		MagickCoreImage* image =
			EdgeImage(imageRef, radius, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Emboss image (hilight edges with 3D effect).
	 * 
	 * Params:
	 *     radius = The radius of the Gaussian, in pixels,
	 *              not counting the center pixel.
	 *     sigma  = The standard deviation of the Laplacian, in pixels.
	 */
	void emboss(double radius = 0, double sigma = 1)
	{
		MagickCoreImage* image =
			EmbossImage(imageRef, radius, sigma, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Encipher an image.
	 */
	void encipher(string passphrase)
	{
		EncipherImage(imageRef, toStringz(passphrase), DMagickExceptionInfo());
	}

	/**
	 * Applies a digital filter that improves the quality of a noisy image.
	 */
	void enhance()
	{
		MagickCoreImage* image =
			EnhanceImage(imageRef, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Applies a histogram equalization to the image.
	 */
	void equalize(ChannelType channel = ChannelType.DefaultChannels)
	{
		EqualizeImageChannel(imageRef, channel);

		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Initializes the image pixels to the image background color.
	 */
	void erase()
	{
		SetImageBackgroundColor(imageRef);

		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Applies a value to the image with an arithmetic, relational, or
	 * logical operator to an image. Use these operations to lighten or
	 * darken an image, to increase or decrease contrast in an image, or
	 * to produce the "negative" of an image.
	 *
	 * See_Also: $(LINK2 http://www.imagemagick.org/script/command-line-options.php#evaluate,
	 *     ImageMagick's -_evaluate option).
	 */
	void evaluate(MagickEvaluateOperator op, double value, ChannelType channel = ChannelType.DefaultChannels)
	{
		EvaluateImageChannel(imageRef, channel, op, value,  DMagickExceptionInfo());
	}

	/**
	 * This method is very similar to crop. It extracts the rectangle
	 * specified by its arguments from the image and returns it as a new
	 * image. However, excerpt does not respect the virtual page offset and
	 * does not update the page offset and is more efficient than cropping.
	 * 
	 * It is the caller's responsibility to ensure that the rectangle lies
	 * entirely within the original image.
	 */
	void excerpt(Geometry geometry)
	{
		RectangleInfo rectangle = geometry.rectangleInfo;

		MagickCoreImage* image =
			ExcerptImage(imageRef, &rectangle, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Extracts the pixel data from the specified rectangle.
	 *
	 * Params:
	 *     area = Area to extract.
	 *     map  = This character string can be any combination
	 *            or order of R = red, G = green, B = blue, A = 
	 *            alpha, C = cyan, Y = yellow, M = magenta, and K = black.
	 *            The ordering reflects the order of the pixels in
	 *            the supplied pixel array.
	 * 
	 * Returns: An array of values containing the pixel components as
	 *          defined by the map parameter and the Type.
	 */
	T[] exportPixels(T)(Geometry area, string map = "RGBA") const
	{
		T[] pixels = new T[(area.width * area.height) * map.length];

		exportPixels(area, pixels, map);

		return pixels;
	}

	/**
	 * Ditto, but takes an existing pixel buffer.
	 *
	 * Throws: An ImageException if the buffer length is insufficient.
	 */
	void exportPixels(T)(Geometry area, T[] pixels, string map = "RGBA") const
	{
		if ( pixels.length < (area.width * area.height) * map.length )
			throw new ImageException(std.string.format("Pixel buffer needs more storage for %s channels.", map));

		StorageType storage = getStorageType!(T);

		ExportImagePixels(
			imageRef,
			area.xOffset, 
			area.yOffset,
			area.width,   
			area.height,
			toStringz(map), 
			storage, 
			pixels.ptr, 
			DMagickExceptionInfo());
	}

	unittest
	{
		Image image = new Image(Geometry(100, 100), new Color("red"));
		byte[] bytes = image.exportPixels!(byte)(Geometry(10,10,10,10));

		assert(bytes.length == 10 * 10 * 4);
	}

	/**
	 * If the Geometry is larger than this Image, extends the image to
	 * the specified geometry. And the new pixels are set to the
	 * background color. If the Geometry is smaller than this image
	 * crops the image.
	 * 
	 * The new image is composed over the background using
	 * the composite operator specified by the compose property.
	 */
	void extent(Geometry geometry)
	{
		RectangleInfo rectangle = geometry.rectangleInfo;

		MagickCoreImage* image =
			ExtentImage(imageRef, &rectangle, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * This interesting method searches for a rectangle in the image that
	 * is similar to the target. For the rectangle to be similar each pixel
	 * in the rectangle must match the corresponding pixel in the target
	 * image within the range specified by the fuzz property of this image
	 * and the target image.
	 *
	 * Params:
	 *     target  = An image that forms the target of the search.
	 *     xOffset = The starting x position to search for a match.
	 *     yOffset = The starting y position to search for a match.
	 * 
	 * Returns: The size and location of the match.
	 */
	Geometry findSimilarRegion(Image target, ssize_t xOffset, ssize_t yOffset)
	{
		IsImageSimilar(imageRef, target.imageRef, &xOffset, &yOffset, DMagickExceptionInfo());

		return Geometry(target.columns, target.rows, xOffset, yOffset);
	}

	/**
	 * creates a vertical mirror image by reflecting the pixels
	 * around the central x-axis.
	 */
	void flip()
	{
		FlipImage(imageRef, DMagickExceptionInfo());
	}

	/**
	 * Changes the color value of any pixel that matches target and is an
	 * immediate neighbor. To the fillColor or fillPattern set for this
	 * image. If fillToBorder is true, the color value is changed
	 * for any neighbor pixel that does not match the borderColor.
	 * 
	 * By default target must match a particular pixel color exactly.
	 * However, in many cases two colors may differ by a small amount.
	 * The fuzz property of image defines how much tolerance is acceptable
	 * to consider two colors as the same. For example, set fuzz to 10 and
	 * the color red at intensities of 100 and 102 respectively are now
	 * interpreted as the same color for the purposes of the floodfill.
	 * 
	 * Params:
	 *     xOffset      = Starting x location for the operation.
	 *     xOffset      = Starting y location for the operation.
	 *     fillToBorder = If true fill untill the borderColor, else only
	 *                    the target color if affected.
	 *     channel      = The affected channels.
	 */
	void floodFill(
		ssize_t xOffset,
		ssize_t yOffset,
		bool fillToBorder = false,
		ChannelType channel = ChannelType.DefaultChannels)
	{
		MagickPixelPacket target;

		GetMagickPixelPacket(imageRef, &target);

		if ( fillToBorder )
		{
			setMagickPixelPacket(&target, borderColor);
		}
		else
		{
			PixelPacket packet;
			GetOneAuthenticPixel(imageRef, xOffset, yOffset, &packet, DMagickExceptionInfo());

			setMagickPixelPacket(&target, new Color(packet));
		}

		FloodfillPaintImage(imageRef, channel, options.drawInfo, &target, xOffset, yOffset, fillToBorder);

		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Fill the image like floodFill but use the specified colors.
	 *
	 * Params:
	 *     xOffset     = Starting x location for the operation.
	 *     xOffset     = Starting y location for the operation.
	 *     fillColor   = Fill color to use.
	 *     borderColor = borderColor to use.
	 *     channel     = The affected channels.
	 */
	void floodFillColor(
		ssize_t xOffset,
		ssize_t yOffset,
		Color fillColor,
		Color borderColor = null,
		ChannelType channel = ChannelType.DefaultChannels)
	{
		Color oldFillColor = options.fillColor;
		options.fillColor = fillColor;
		scope(exit) options.fillColor = oldFillColor;

		floodFillPattern(xOffset, yOffset, null, borderColor, channel);
	}

	/**
	 * Fill the image like floodFill but use the specified
	 * pattern an borderColor.
	 *
	 * Params:
	 *     xOffset     = Starting x location for the operation.
	 *     xOffset     = Starting y location for the operation.
	 *     fillPattern = Fill pattern to use.
	 *     borderColor = borderColor to use.
	 *     channel     = The affected channels.
	 */
	void floodFillPattern(
		ssize_t xOffset,
		ssize_t yOffset,
		Image fillPattern,
		Color borderColor = null,
		ChannelType channel = ChannelType.DefaultChannels)
	{
		// Cast away const, so we can temporarily hold
		// The image and asign it back to the fillPattern. 
		Image oldFillPattern = cast(Image)options.fillPattern;
		options.fillPattern = fillPattern;
		scope(exit) options.fillPattern = oldFillPattern;

		Color oldBorderColor = this.borderColor;
		this.borderColor = borderColor;
		scope(exit) this.borderColor = oldBorderColor;

		// If the borderColor !is null, set fillToBorder to true.
		floodFill(xOffset, yOffset, borderColor !is null, channel);
	}

	/**
	 * creates a horizontal mirror image by reflecting the pixels
	 * around the central y-axis.
	 */
	void flop()
	{
		FlopImage(imageRef, DMagickExceptionInfo());
	}

	/**
	 * Adds a simulated 3D border.
	 * The matteColor is used to draw the frame.
	 * 
	 * Params:
	 *     geometry = The size portion indicates the width and height of
	 *                the frame. If no offsets are given then the border
	 *                added is a solid color. Offsets x and y, if present,
	 *                specify that the width and height of the border is
	 *                partitioned to form an outer bevel of thickness x
	 *                pixels and an inner bevel of thickness y pixels.
	 *                Negative offsets make no sense as frame arguments.
	 */
	void frame(Geometry geometry)
	{
		FrameInfo frameInfo;

		frameInfo.width       = columns + ( 2 * geometry.width  );
		frameInfo.height      = rows    + ( 2 * geometry.height );
		frameInfo.x           = geometry.width;
		frameInfo.y           = geometry.height;
		frameInfo.inner_bevel = geometry.yOffset;
		frameInfo.outer_bevel = geometry.xOffset;

		MagickCoreImage* image =
			FrameImage(imageRef, &frameInfo, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Applies a value to the image with an arithmetic, relational, or
	 * logical operator to an image. Use these operations to lighten or
	 * darken an image, to increase or decrease contrast in an image, or
	 * to produce the "negative" of an image.
	 *
	 * This method is equivalent to the 
	 * $(LINK2 http://www.imagemagick.org/script/command-line-options.php#function,
	 *       convert -function) option.
	 *
	 * Params:
	 *     function = The MagickFunction to use.
	 *     params   = 
	 *         An array of values to be used by the function.
	 *         $(LIST $(COMMA $(B PolynomialFunction:)
	 *             The Polynomial function takes an arbitrary number of
	 *             parameters, these being the coefficients of a polynomial,
	 *             in decreasing order of degree. That is, entering
	 *             [aₙ, aₙ₋₁, ... a₁, a₀] will invoke a polynomial function
	 *             given by: aₙ uⁿ + aₙ₋₁ uⁿ⁻¹ + ··· a₁ u + a₀, where where
	 *             u is pixel's original normalized channel value.),
	 *         $(COMMA $(B SinusoidFunction:)
	 *             These values are given as one to four parameters, as
	 *             follows, [freq, phase, amp, bias] if omitted the default
	 *             values will be used: [1.0, 0.0, 0.5, 0.5].),
	 *         $(COMMA $(B ArcsinFunction:)
	 *             These values are given as one to four parameters, as
	 *             follows, [width, center, range, bias] if omitted the
	 *             default values will be used: [1.0, 0.5, 1.0, 0.5].),
	 *         $(COMMA $(B ArctanFunction:)
	 *             These values are given as one to four parameters, as
	 *             follows, [slope, center, range, bias] if omitted the
	 *             default values will be used: [1.0, 0.5, 1.0, 0.5].))
	 *     channel  = The channels this funtion aplies to.
	 */
	void functionImage(MagickFunction funct, double[] params, ChannelType channel = ChannelType.DefaultChannels)
	{
		FunctionImageChannel(imageRef, channel, funct, params.length, params.ptr, DMagickExceptionInfo());
	}

	/**
	 * Applies a mathematical expression to the specified image.
	 * 
	 * See_Aso:
	 *     $(LINK2 http://www.imagemagick.org/script/fx.php,
	 *     FX, The Special Effects Image Operator) for a detailed
	 *     discussion of this option.
	 */
	void fx(string expression, ChannelType channel = ChannelType.DefaultChannels)
	{
		MagickCoreImage* image =
			FxImageChannel(imageRef, channel, toStringz(expression), DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * gamma gamma-corrects a particular image channel.
	 * The same image viewed on different devices will have perceptual
	 * differences in the way the image's intensities are represented
	 * on the screen.  Specify individual gamma levels for the red,
	 * green, and blue channels, or adjust all three with the gamma
	 * function. Values typically range from 0.8 to 2.3.
	 * 
	 * You can also reduce the influence of a particular channel
	 * with a gamma value of 0.
	 */
	void gamma(double value, ChannelType channel = ChannelType.DefaultChannels)
	{
		GammaImageChannel(imageRef, channel, value);

		DMagickException.throwException(&(imageRef.exception));
	}

	///ditto
	void gamma(double red, double green, double blue)
	{
		GammaImageChannel(imageRef, ChannelType.RedChannel, red);
		GammaImageChannel(imageRef, ChannelType.GreenChannel, green);
		GammaImageChannel(imageRef, ChannelType.BlueChannel, blue);

		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Blurs an image. We convolve the image with a Gaussian operator
	 * of the given radius and standard deviation (sigma).
	 * For reasonable results, the radius should be larger than sigma.
	 * 
	 * Params:
	 *     radius  = The radius of the Gaussian, in pixels,
	 *               not counting the center pixel.
	 *     sigma   = the standard deviation of the Gaussian, in pixels.
	 *     channel = The channels to blur.
	 */
	void gaussianBlur(double radius = 0, double sigma = 1, ChannelType channel = ChannelType.DefaultChannels)
	{
		MagickCoreImage* image =
			GaussianBlurImageChannel(imageRef, channel, radius, sigma, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Returns the TypeMetric class witch provides the information
	 * regarding font metrics such as ascent, descent, text width,
	 * text height, and maximum horizontal advance. The units of
	 * these font metrics are in pixels, and that the metrics are
	 * dependent on the current Image font (default Ghostscript's
	 * "Helvetica"), pointsize (default 12 points), and x/y resolution
	 * (default 72 DPI) settings.
	 * 
	 * The pixel units may be converted to points (the standard
	 * resolution-independent measure used by the typesetting industry)
	 * via the following equation:
	 * ----------------------------------
	 * sizePoints = (sizePixels * 72)/resolution
	 * ----------------------------------
	 * where resolution is in dots-per-inch (DPI). This means that at the
	 * default image resolution, there is one pixel per point.
	 * See_Also:
	 *     $(LINK2 http://freetype.sourceforge.net/freetype2/docs/glyphs/index.html,
	 *         FreeType Glyph Conventions) for a detailed description of
	 *     font metrics related issues.
	 */
	TypeMetric getTypeMetrics(string text)
	{
		TypeMetric metric;
		DrawInfo* drawInfo = options.drawInfo;

		copyString(drawInfo.text, text);
		scope(exit) copyString(drawInfo.text, null);

		GetMultilineTypeMetrics(imageRef, drawInfo, &metric);
		DMagickException.throwException(&(imageRef.exception));

		return metric;
	}

	/**
	 * applies a Hald color lookup table to the image. A Hald color lookup
	 * table is a 3-dimensional color cube mapped to 2 dimensions. Create
	 * it with the HALD coder. You can apply any color transformation to
	 * the Hald image and then use this method to apply the transform to
	 * the image.
	 * 
	 * Params:
	 *     haldImage = The image, which is replaced by indexed CLUT values.
	 *     channel   = The channels to aply the CLUT to.
	 * 
	 * See_Also:
	 *     $(XREF Image, clut) which provides color value replacement of
	 *     the individual color channels, usally involving a simplier
	 *     gray-scale image. E.g: gray-scale to color replacement, or
	 *     modification by a histogram mapping.
	 */
	void haldClut(Image haldImage, ChannelType channel = ChannelType.DefaultChannels)
	{
		HaldClutImageChannel(imageRef, channel, haldImage.imageRef);

		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * A funhouse mirror effect.
	 * 
	 * Params:
	 *     amount = Defines the extend of the effect.
	 *              The value may be positive for implosion,
	 *              or negative for explosion.
	 */
	void implode(double amount = 0.5)
	{
		MagickCoreImage* image =
			ImplodeImage(imageRef, amount, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Replaces the pixels in the specified area with pixel data
	 * from the supplied array.
	 * 
	 * Params:
	 *     area   = Location in the image to store the pixels. 
	 *     pixels = An array of pixels defined by map.
	 *     map    = This character string can be any combination
	 *              or order of R = red, G = green, B = blue, A = 
	 *              alpha, C = cyan, Y = yellow, M = magenta, and K = black.
	 *              The ordering reflects the order of the pixels in
	 *              the supplied pixel array.
	 */
	void importPixels(T)(Geometry area, T[] pixels, string map = "RGBA")
	{
		StorageType storage = getStorageType!(T);

		ImportImagePixels(imageRef,
			area.xOffset, area.yOffset,
			area.width,   area.height,
			toStringz(map), storage, pixels.ptr);

		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Adjusts the levels of an image by scaling the colors falling between
	 * specified white and black points to the full available quantum range.
	 * The parameters provided represent the black, mid, and white points.
	 * Colors darker than the black point are set to zero. Colors brighter
	 * than the white point are set to the maximum quantum value.
	 * 
	 * It is typically used to improve image contrast, or to provide a
	 * controlled linear threshold for the image. If the black and white
	 * points are set to the minimum and maximum values found in the image,
	 * the image can be normalized. or by swapping black and white values,
	 * negate the image.
	 * 
	 * Params: 
	 *     blackPoint = Specifies the darkest color in the image.
	 *     whitePoint = Specifies the lightest color in the image.
	 *     gamma      = Specifies the gamma correction to apply to the image.
	 *     channel    = The channels to level.
	 */
	void level(
		Quantum blackPoint = 0,
		Quantum whitePoint = QuantumRange,
		double gamma = 1,
		ChannelType channel = ChannelType.DefaultChannels)
	{
		LevelImageChannel(imageRef, channel, blackPoint, whitePoint, gamma);

		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * applies the reversed level operation to just the channels specified.
	 * It compresses the full range of color values, so that they lie between
	 * the given black and white points. Gamma is applied before the values
	 * are mapped.
	 * 
	 * It can be used for example de-contrast a greyscale image to the exact
	 * levels specified. Or by using specific levels for each channel of an
	 * image you can convert a gray-scale image to any linear color gradient,
	 * according to those levels.
	 * 
	 * Params: 
	 *     blackPoint = Specifies the darkest color in the image.
	 *     whitePoint = Specifies the lightest color in the image.
	 *     gamma      = Specifies the gamma correction to apply to the image.
	 *     channel    = The channels to level.
	 */
	void levelize(
		Quantum blackPoint = 0,
		Quantum whitePoint = QuantumRange,
		double gamma = 1,
		ChannelType channel = ChannelType.DefaultChannels)
	{
		LevelizeImageChannel(imageRef, channel, blackPoint, whitePoint, gamma);

		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Discards any pixels below the black point and above the white
	 * point and levels the remaining pixels.
	 * 
	 * Params: 
	 *     blackPoint = Specifies the darkest color in the image.
	 *     whitePoint = Specifies the lightest color in the image.
	 */
	void linearStretch(Quantum blackPoint, Quantum whitePoint)
	{
		LinearStretchImage(imageRef, blackPoint, whitePoint);

		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Rescale image with seam carving. To use this method, you must
	 * have installed and configured ImageMagick to use the
	 * $(LINK2 http://liblqr.wikidot.com/, Liquid Rescale Library).
	 *
	 * Params:
	 *     columns  = The desired width.
	 *     rows     = The desired height.
	 *     deltaX   = Maximum seam transversal step (0 means straight seams).
	 *     rigidity = Introduce a bias for non-straight seams (typically 0).
	 */
	void liquidRescale(Geometry size, size_t rows, double deltaX = 0, double rigidity = 0)
	{
		size = size.toAbsolute(columns, rows);

		MagickCoreImage* image =
			LiquidRescaleImage(imageRef, size.width, size.height, deltaX, rigidity, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * A convenience method that scales an image proportionally to
	 * twice its size.
	 */
	void magnify()
	{
		MagickCoreImage* image = MagnifyImage(imageRef, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Applies a digital filter that improves the quality of a noisy image.
	 * Each pixel is replaced by the median in a set of neighboring pixels
	 * as defined by radius.
	 * 
	 * Params:
	 *     radius = The filter radius. Values larger than 8 or 9 may take
	 *              longer than you want to wait, and will not have
	 *              significantly better results than much smaller values.
	 */
	void medianFilter(size_t radius = 0)
	{
		static if ( is(typeof(StatisticImage)) )
		{
			MagickCoreImage* image = 
				StatisticImage(imageRef, StatisticType.MedianStatistic, radius, radius, DMagickExceptionInfo());
		}
		else
		{
			MagickCoreImage* image = 
				MedianFilterImage(imageRef, radius, DMagickExceptionInfo());
		}

		imageRef = ImageRef(image);
	}

	/**
	 * A convenience method that scales an image proportionally to 
	 * half its size.
	 */
	void minify()
	{
		MagickCoreImage* image = MinifyImage(imageRef, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Modulate percent hue, saturation, and brightness of an image.
	 * Modulation of saturation and brightness is as a ratio of the current
	 * value (1 ( == 100% ) for no change).
	 * 
	 * Params:
	 *     brightness = The percentage of change in the brightness.
	 *     saturation = The percentage of change in the saturation.
	 *     hue        = The percentage of change in the hue.
	 */
	void modulate(double brightness = 1, double saturation = 1, double hue = 1)
	{
		string args = std.string.format("%s,%s,%s", brightness*100, saturation*100, hue*100);
		ModulateImage(imageRef, toStringz(args));

		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Simulates motion blur. We convolve the image with a Gaussian operator
	 * of the given radius and standard deviation (sigma). Use a radius of 0
	 * and motion_blur selects a suitable radius for you. Angle gives the
	 * angle of the blurring motion.
	 * 
	 * Params:
	 *     radius  = The radius of the Gaussian operator.
	 *     sigma   = The standard deviation of the Gaussian operator.
	 *               Must be non-0.
	 *     angle   = The angle (in degrees) of the blurring motion.
	 *     channel = The affected channels.
	 */
	void motionBlur(
		double radius = 0,
		double sigma = 1,
		double angle = 0,
		ChannelType channel = ChannelType.DefaultChannels)
	{
		MagickCoreImage* image = 
			MotionBlurImageChannel(imageRef, channel, radius, sigma, angle, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Negates the colors in the reference image.
	 * 
	 * Params:
	 *     grayscale = If true, only negate grayscale pixels
	 *                 within the image.
	 *     channel   = The affected channels.
	 */
	void negate(bool grayscale = false, ChannelType channel = ChannelType.DefaultChannels)
	{
		NegateImageChannel(imageRef, channel, grayscale);

		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Enhances the contrast of a color image by adjusting the pixel
	 * color to span the entire range of colors available.
	 */
	void normalize(ChannelType channel = ChannelType.DefaultChannels)
	{
		NormalizeImageChannel(imageRef, channel);

		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Applies a special effect filter that simulates an oil painting.
	 * Each pixel is replaced by the most frequent color occurring in a
	 * circular region defined by radius.
	 */
	void oilPaint(double radius = 3)
	{
		MagickCoreImage* image = 
			OilPaintImage(imageRef, radius, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Set or attenuate the opacity channel in the image.
	 * If the image pixels are opaque then they are set to the specified
	 * opacity value, otherwise they are blended with the supplied opacity
	 * value.
	 */
	void opacity(Quantum value)
	{
		SetImageOpacity(imageRef, value);

		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Changes all pixels having the target color to the fill color.
	 * 
	 * Params:
	 *     target  = The color to be replaced.
	 *     fill    = The replacement color.
	 *     invert  = If true, the target pixels are all the pixels
	 *               that are not the target color.
	 *     channel = The affected channels.
	 */
	void opaque(Color target, Color fill, bool invert = false, ChannelType channel = ChannelType.CompositeChannels)
	{
		MagickPixelPacket magickTarget;
		MagickPixelPacket magickFill;
		
		GetMagickPixelPacket(imageRef, &magickTarget);
		GetMagickPixelPacket(imageRef, &magickFill);

		setMagickPixelPacket(&magickTarget, target);
		setMagickPixelPacket(&magickFill, fill);

		OpaquePaintImageChannel(imageRef, channel, &magickTarget, &magickFill, invert);
		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Dithers the image to a predefined pattern.
	 * 
	 * Params:
	 *     map = The map argument can be any of the strings
	 *           listed by this command:
	 *           --------------------
	 *           convert -list Threshold
	 *           --------------------
	 * See_Also: $(LINK2 http://www.imagemagick.org/script/command-line-options.php#ordered-dither,
	 *     ImageMagick's -ordered-dither option).
	 */
	void orderedDither(string map)
	{
		OrderedPosterizeImage(imageRef, toStringz(map), DMagickExceptionInfo());
	}

	/**
	 * Ping is similar to read except only enough of the image is read to
	 * determine the image columns, rows, and filesize. The columns, rows,
	 * and fileSize attributes are valid after invoking ping.
	 * The image data is not valid after calling ping.
	 */
	void ping(string filename)
	{
		options.filename = filename;

		MagickCoreImage* image = PingImages(options.imageInfo, DMagickExceptionInfo());

		//Make sure a single image (frame) is read.
		if ( image.next !is null )
		{
			MagickCoreImage* nextImage;

			nextImage = image.next;
			image.next = null;
			nextImage.previous = null;

			DestroyImageList(nextImage);
		}

		imageRef = ImageRef(image);
	}

	///ditto
	void ping(void[] blob)
	{
		MagickCoreImage* image = 
			PingBlob(options.imageInfo, blob.ptr, blob.length, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Produce an image that looks like a Polaroid® instant picture.
	 * If the image has a "Caption" property, the value is used as a caption.
	 * 
	 * Params:
	 *     angle = The resulting image is rotated by this amount,
	 *             measured in degrees.
	 */
	void polaroid(double angle)
	{
		MagickCoreImage* image = 
			PolaroidImage(imageRef, options.drawInfo, angle, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Reduces the image to a limited number of colors for a "poster" effect.
	 * 
	 * Params:
	 *     levels = Number of color levels allowed in each channel.
	 *              Very low values (2, 3, or 4) have the most
	 *              visible effect.
	 *     dither = If true, dither the image.
	 */
	void posterize(size_t levels = 4, bool dither = false)
	{
		PosterizeImage(imageRef, levels, dither);
		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Creates an image that contains 9 small versions of the receiver
	 * image. The center image is the unchanged receiver. The other 8
	 * images are variations created by transforming the receiver according
	 * to the specified preview type with varying parameters.
	 *
	 * A preview image is an easy way to "try out" a transformation method.
	 */
	Image preview(PreviewType preview)
	{
		MagickCoreImage* image = 
			PreviewImage(imageRef, preview, DMagickExceptionInfo());

		return new Image(image, options.clone());
	}

	/**
	 * Execute the named process module, passing any arguments arguments.
	 * An exception is thrown if the requested process module does not exist,
	 * fails to load, or fails during execution.
	 * 
	 * Params:
	 *     name      = The name of a module.
	 *     arguments = The arguments to pass to the module.
	 */
	void process(string name, string[] arguments)
	{
		MagickCoreImage* image = imageRef;
		const(char)*[] args = new const(char)*[arguments.length];

		foreach( i, arg; arguments )
			args[i] = toStringz(arg);

		InvokeDynamicImageFilter(toStringz(name), &image, cast(int)args.length, args.ptr, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Analyzes the colors within a reference image and chooses a fixed
	 * number of colors to represent the image. The goal of the algorithm
	 * is to minimize the difference between the input and output image
	 * while minimizing the processing time.
	 * 
	 * Params:
	 *     measureError = Set to true to calculate quantization errors
	 *                    when quantizing the image. These can be accessed
	 *                    with: normalizedMeanError, normalizedMaxError
	 *                    and meanErrorPerPixel.
	 */
	void quantize(bool measureError = false)
	{
		options.quantizeInfo.measure_error = measureError;

		QuantizeImage(options.quantizeInfo, imageRef);
		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Applies a radial blur to the image.
	 * 
	 * Params:
	 *     angle   = The angle of the radial blur, in degrees.
	 *     channel = If no channels are specified, blurs all the channels.
	 */
	void radialBlur(double angle, ChannelType channel = ChannelType.DefaultChannels)
	{
		MagickCoreImage* image = 
			RadialBlurImageChannel(imageRef, channel, angle, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Creates a simulated three-dimensional button-like effect by
	 * lightening and darkening the edges of the image.
	 * 
	 * Params:
	 *     width  = The width of the raised edge in pixels.
	 *     height = The height of the raised edge in pixels.
	 *     raised = If true, the image is raised, otherwise lowered.
	 */
	void raise(size_t width, size_t height, bool raised = true)
	{
		RectangleInfo raiseInfo;

		raiseInfo.width  = width;
		raiseInfo.height = height;

		RaiseImage(imageRef, &raiseInfo, raised);
		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Changes the value of individual pixels based on the intensity of
	 * each pixel compared to a random threshold. The result is a
	 * low-contrast, two color image.
	 * 
	 * Params:
	 *     thresholds = A geometry string containing LOWxHIGH thresholds.
	 *                  The string is in the form `XxY'. The Y value may be
	 *                  omitted, in which case it is assigned the value
	 *                  QuantumRange-X. If an % appears in the string then
	 *                  the values are assumed to be percentages of
	 *                  QuantumRange. If the string contains 2x2, 3x3, or
	 *                  4x4, then an ordered dither of order 2, 3, or 4
	 *                  will be performed instead.
	 *     channel    = The affected channels.
	 */
	void randomThreshold(Geometry thresholds, ChannelType channel = ChannelType.DefaultChannels)
	{
		RandomThresholdImageChannel(imageRef, channel, toStringz(thresholds.toString()), DMagickExceptionInfo());
	}

	/**
	 * Read an Image by reading from the file or
	 * URL specified by filename.
	 */
	void read(string filename)
	{
		options.filename = filename;

		MagickCoreImage* image = ReadImage(options.imageInfo, DMagickExceptionInfo());

		//Make sure a single image (frame) is read.
		if ( image.next !is null )
		{
			MagickCoreImage* nextImage;

			nextImage = image.next;
			image.next = null;
			nextImage.previous = null;

			DestroyImageList(nextImage);
		}

		imageRef = ImageRef(image);
	}

	/**
	 * Read an Image by reading from the file or
	 * URL specified by filename with the specified size.
	 * Usefull for images that don't specify their size.
	 */
	void read(string filename, Geometry size)
	{
		options.size = size;
		read(filename);
	}

	/**
	 * Reads an image from an in-memory blob.
	 * The Blob size, depth and magick format may also be specified.
	 *
	 * Some image formats require size to be specified,
	 * the default depth Imagemagick uses is the Quantum size
	 * it's compiled with. If it doesn't match the depth of the image
	 * it may need to be specified.
	 *
	 * Imagemagick can usualy detect the image format, when the
	 * format can't be detected a magick format must be specified.
	 */
	void read(void[] blob)
	{
		MagickCoreImage* image = 
			BlobToImage(options.imageInfo, blob.ptr, blob.length, DMagickExceptionInfo());

		//Make sure a single image (frame) is read.
		if ( image.next !is null )
		{
			MagickCoreImage* nextImage;

			nextImage = image.next;
			image.next = null;
			nextImage.previous = null;

			DestroyImageList(nextImage);
		}

		imageRef = ImageRef(image);
	}

	///ditto
	void read(void[] blob, Geometry size)
	{
		options.size = size;

		read(blob);
	}

	///ditto
	void read(void[] blob, Geometry size, size_t depth)
	{
		options.size = size;
		options.depth = depth;

		read(blob);
	}

	///ditto
	void read(void[] blob, Geometry size, size_t depth, string magick)
	{
		options.size = size;
		options.depth = depth;
		options.magick = magick;
		//Also set the filename to the image format
		options.filename = magick ~":";

		read(blob);
	}

	///ditto
	void read(void[] blob, Geometry size, string magick)
	{
		options.size = size;
		options.magick = magick;
		//Also set the filename to the image format
		options.filename = magick ~":";

		read(blob);
	}

	/**
	 * Reads an image from an array of pixels.
	 *
	 * Params:
	 *     width  =  The number of columns in the image.
	 *     height =  The number of rows in the image.
	 *     map    =  A string describing the expected ordering
	 *               of the pixel array. It can be any combination
	 *               or order of R = red, G = green, B = blue, A = alpha
	 *               , C = cyan, Y = yellow, M = magenta, K = black,
	 *               or I = intensity (for grayscale).
	 *     storage = The pixel Staroage type (CharPixel,
	 *               ShortPixel, IntegerPixel, FloatPixel, or DoublePixel).
	 *     pixels  = The pixel data.
	 * Bugs: DMD bug 2972 prevents readpixels from being named just read.
	 */
	void readPixels(T)(size_t width, size_t height, string map, T[] pixels)
	{
		StorageType storage = getStorageType!(T);

		MagickCoreImage* image = 
			ConstituteImage(width, height, toStringz(map), storage, pixels.ptr, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Smooths the contours of an image while still preserving edge
	 * information. The algorithm works by replacing each pixel with its
	 * neighbor closest in value.
	 * 
	 * Params:
	 *     radius = A neighbor is defined by radius. Use a radius of 0
	 *              and reduceNoise selects a suitable radius for you.
	 */
	void reduceNoise(size_t radius = 0)
	{
		static if ( is(typeof(StatisticImage)) )
		{
			MagickCoreImage* image = 
				StatisticImage(imageRef, StatisticType.NonpeakStatistic, radius, radius, DMagickExceptionInfo());
		}
		else
		{
			MagickCoreImage* image = 
				ReduceNoiseImage(imageRef, radius, DMagickExceptionInfo());
		}

		imageRef = ImageRef(image);
	}

	/**
	 * Reduce the number of colors in img to the colors used by reference.
	 * If a dither method is set then the given colors are dithered over
	 * the image as necessary, otherwise the closest color
	 * (in RGB colorspace) is selected to replace that pixel in the image.
	 */
	void remap(Image reference)
	{
		RemapImage(options.quantizeInfo, imageRef, reference.imageRef);

		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Resize image in terms of its pixel size, so that when displayed at
	 * the given resolution it will be the same size in terms of real world
	 * units as the original image at the original resolution.
	 * 
	 * Params:
	 *     xResolution = the target horizontal resolution
	 *     yResolution = the target vertical resolution
	 *     filter      = The filter to use when resizing.
	 *     blur        = Values > 1 increase the blurriness.
	 *                   Values < 1 increase the sharpness.
	 */
	void resample(
		double xResolution,
		double yResolution,
		FilterTypes filter = FilterTypes.LanczosFilter,
		double blur = 1)
	{
		MagickCoreImage* image = 
			ResampleImage(imageRef, xResolution, yResolution, filter, blur, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * scales an image to the desired dimensions, using the given filter.
	 * 
	 * Params:
	 *     size   = The desired width and height.
	 *     filter = The filter to use when resizing.
	 *     blur   = Values > 1 increase the blurriness.
	 *              Values < 1 increase the sharpness.
	 */
	void resize(Geometry size, FilterTypes filter = FilterTypes.LanczosFilter, double blur = 1)
	{
		size = size.toAbsolute(columns, rows);

		MagickCoreImage* image = 
			ResizeImage(imageRef, size.width, size.height, filter, blur, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Offsets an image as defined by xOffset and yOffset.
	 */
	void roll(ssize_t xOffset, ssize_t yOffset)
	{
		MagickCoreImage* image = 
			RollImage(imageRef, xOffset, yOffset, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Rotate the image by specified number of degrees. Rotated images are
	 * usually larger than the originals and have 'empty' triangular corners.
	 * Empty triangles left over from shearing the image are filled with the
	 * background color defined by the 'backgroundColor' property
	 * of the image.
	 * 
	 * Params:
	 *     degrees = The number of degrees to rotate the image. Positive
	 *               angles rotate counter-clockwise (right-hand rule),
	 *               while negative angles rotate clockwise.
	 */
	void rotate(double degrees)
	{
		MagickCoreImage* image = 
			RotateImage(imageRef, degrees, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * scales an image to the desired dimensions with pixel sampling.
	 * Unlike other scaling methods, this method does not introduce any
	 * additional color into the scaled image.
	 */
	void sample(Geometry size)
	{
		size = size.toAbsolute(columns, rows);

		MagickCoreImage* image = 
			SampleImage(imageRef, size.width, size.height, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Resize image by using simple ratio algorithm.
	 */
	void scale(Geometry size)
	{
		size = size.toAbsolute(columns, rows);

		MagickCoreImage* image = 
			ScaleImage(imageRef, size.width, size.height, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Segments an image by analyzing the histograms of the color
	 * components and identifying units that are homogeneous with the
	 * fuzzy c-means technique. Also uses quantizeColorSpace and
	 * verbose image properties. 
	 * 
	 * Params:
	 *     clusterThreshold   = 
	 *          The number of pixels in each cluster must exceed the
	 *          the cluster threshold to be considered valid.
	 *     smoothingThreshold = 
	 *          The smoothing threshold eliminates noise in the second
	 *          derivative of the histogram. As the value is increased,
	 *          you can expect a smoother second derivative.
	 */
	void segment(double clusterThreshold = 1, double smoothingThreshold = 1.5)
	{
		SegmentImage(imageRef, options.quantizeColorSpace, options.verbose, clusterThreshold, smoothingThreshold);
		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Selectively blur pixels within a contrast threshold.
	 * 
	 * Params:
	 *     radius    = The radius of the Gaussian in pixels,
	 *                 not counting the center pixel.
	 *     sigma     = The standard deviation of the Laplacian, in pixels.
	 *     threshold = Threshold level represented as a percentage
	 *                 of the quantum range.
	 *     channel   = The channels to blur.
	 */
	void selectiveBlur(
		double radius,
		double sigma,
		double threshold,
		ChannelType channel = ChannelType.DefaultChannels)
	{
		MagickCoreImage* image = 
			SelectiveBlurImageChannel(imageRef, channel, radius, sigma, threshold, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * applies a special effect to the image, similar to the effect achieved
	 * in a photo darkroom by sepia toning. A threshold of 80% is a good
	 * starting point for a reasonable tone.
	 * 
	 * Params:
	 *     threshold = Threshold ranges from 0 to QuantumRange and is
	 *                 a measure of the extent of the sepia toning.
	 *                 A value lower than 1 is treated as a percentage.
	 */
	void sepiatone(double threshold = QuantumRange)
	{
		if ( threshold < 1 )
			threshold *= QuantumRange;

		MagickCoreImage* image = 
			SepiaToneImage(imageRef, threshold, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * shines a distant light on an image to create a three-dimensional
	 * effect. You control the positioning of the light with azimuth and
	 * elevation.
	 * 
	 * Params:
	 *     azimuth   = The amount of degrees off the X axis.
	 *     elevation = The amount of pixels above the Z axis.
	 *     shading   = If true, shade shades the intensity of each pixel.
	 */
	void shade(double azimuth = 30, double elevation = 30, bool shading = false)
	{
		MagickCoreImage* image = 
			ShadeImage(imageRef, shading, azimuth, elevation, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Simulates a shadow from the specified image and returns it.
	 * This method only works when the image has opaque parts and
	 * transparent parts. Note that the resulting image is just the shadow.
	 * 
	 * Params:
	 *     xOffset = The shadow x offset.
	 *     yOffset = The shadow y offset.
	 *     sigma   = The standard deviation of the Gaussian operator used
	 *               to produce the shadow. The higher the number, the
	 *               "blurrier" the shadow, but the longer it takes to
	 *               produce the shadow.
	 *     opacity = The percent opacity of the shadow.
	 *               A number between 0.1 and 1.0
	 * Returns: The shadows for this image.
	 */
	Image shadowImage(ssize_t xOffset, ssize_t yOffset, double sigma = 4, double opacity = 1)
	{
		MagickCoreImage* image = 
			ShadowImage(imageRef, opacity, sigma, xOffset, yOffset, DMagickExceptionInfo());

		return new Image(image);
	}

	/**
	 * Sharpens an image. We convolve the image with a Gaussian operator
	 * of the given radius and standard deviation (sigma). For reasonable
	 * results, radius should be larger than sigma. Use a radius of 0 and
	 * sharpen selects a suitable radius for you.
	 * 
	 * Params:
	 *     radius  = The radius of the Gaussian in pixels,
	 *               not counting the center pixel.
	 *     sigma   = The standard deviation of the Laplacian, in pixels.
	 *     channel = If no channels are specified, sharpens all the channels.
	 */
	void sharpen(double radius = 0, double sigma = 1, ChannelType channel = ChannelType.DefaultChannels)
	{
		MagickCoreImage* image = 
			SharpenImageChannel(imageRef, channel, radius, sigma, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Removes pixels from the edges of the image,
	 * leaving the center rectangle.
	 * 
	 * Params:
	 *     geometry = The region of the image to crop.
	 */
	void shave(Geometry geometry)
	{
		RectangleInfo rectangle = geometry.rectangleInfo;
		MagickCoreImage* image = ShaveImage(imageRef, &rectangle, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Shearing slides one edge of an image along the X or Y axis, creating
	 * a parallelogram. An X direction shear slides an edge along the X axis,
	 * while a Y direction shear slides an edge along the Y axis. The amount
	 * of the shear is controlled by a shear angle. For X direction shears,
	 * xShearAngle is measured relative to the Y axis, and similarly, for Y
	 * direction shears yShearAngle is measured relative to the X axis.
	 * Empty triangles left over from shearing the image are filled with
	 * the background color.
	 */
	void shear(double xShearAngle, double yShearAngle)
	{
		MagickCoreImage* image = 
			ShearImage(imageRef, xShearAngle, yShearAngle, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Adjusts the contrast of an image channel with a non-linear sigmoidal
	 * contrast algorithm. Increases the contrast of the image using a
	 * sigmoidal transfer function without saturating highlights or shadows.
	 * 
	 * Params:
	 *     contrast = indicates how much to increase the contrast
	 *                (0 is none; 3 is typical; 20 is pushing it)
	 *     midpoint = indicates where midtones fall in the resultant
	 *                image (0 is white; 50% is middle-gray; 100% is black).
	 *                Specify an apsulute number of pixels or an
	 *                percentage by passing a value between 1 and 0
	 *     sharpen  = Increase or decrease image contrast.
	 *     channel  = The channels to adjust.
	 */
	void sigmoidalContrast(
		double contrast = 3,
		double midpoint = 50,
		bool sharpen = false,
		ChannelType channel = ChannelType.DefaultChannels)
	{
		if ( midpoint < 1 )
			midpoint *= QuantumRange;

		SigmoidalContrastImageChannel(imageRef, channel, sharpen, contrast, midpoint);
		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Simulates a pencil sketch. For best results start with
	 * a grayscale image.
	 * 
	 * Params:
	 *     radius = The radius of the Gaussian, in pixels, not counting
	 *              the center pixel.
	 *     sigma  = The standard deviation of the Gaussian, in pixels.
	 *     angle  = The angle toward which the image is sketched.
	 */
	void sketch(double radius = 0, double sigma = 1, double angle = 0)
	{
		MagickCoreImage* image = 
			SketchImage(imageRef, radius, sigma, angle, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Fills the image with the specified color or colors, starting at
	 * the x,y coordinates associated with the color and using the specified
	 * interpolation method.
	 * 
	 * Params:
	 *     method = The method to fill in the gradient between the
	 *              control points.
	 *     args   = A series of control points, and there Color.
	 * 
	 * See_Also: $(LINK2 http://www.imagemagick.org/Usage/canvas/#sparse-color,
	 *     Sparse Points of Color) at Examples of ImageMagick Usage.
	 */
	void sparseColor(SparseColorMethod method, Tuple!(size_t, "x", size_t, "y", Color, "color")[] args ...)
	{
		double[] argv = new double[args.length * 6];

		foreach( i, arg; args )
		{
			double[] values = argv[i*6 .. i*6+6];

			values[0] = arg.x;
			values[1] = arg.y;

			values[2] = arg.color.redQuantum / QuantumRange;
			values[3] = arg.color.greenQuantum / QuantumRange;
			values[4] = arg.color.blueQuantum / QuantumRange;
			values[5] = arg.color.opacityQuantum / QuantumRange;
		}

		MagickCoreImage* image = 
			SparseColorImage(imageRef,
				ChannelType.DefaultChannels,
				method,   argv.length,
				argv.ptr, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Splice the background color into the image as defined by the geometry.
	 * This method is the opposite of chop.
	 */
	void splice(Geometry geometry)
	{
		RectangleInfo rectangle = geometry.rectangleInfo;
		MagickCoreImage* image = SpliceImage(imageRef, &rectangle, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Randomly displaces each pixel in a block defined by the
	 * radius parameter.
	 */
	void spread(double radius = 3)
	{
		MagickCoreImage* image =
			SpreadImage(imageRef, radius, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Makes each pixel the min / max / median / mode / etc. of the
	 * neighborhood of the specified width and height.
	 * 
	 * Params:
	 *     type   = The type pf statistic to apply.
	 *     width  = The width of the pixel neighborhood.
	 *     height = The height of the pixel neighborhood.
	 */
	void statistic()(StatisticType type, size_t width, size_t height)
	{
		static if ( is(typeof(StatisticImage)) )
		{
			MagickCoreImage* image =
				StatisticImage(imageRef, type, width, height, DMagickExceptionInfo());

			imageRef = ImageRef(image);
		}
		else
		{
			static assert(0, "dmagick.Image.Image.statistic requires MagickCore version >= 6.6.9");
		}
	}

	/**
	 * Hides a digital watermark in the receiver. You can retrieve the
	 * watermark by reading the file with the stegano: prefix, thereby
	 * proving the authenticity of the file.
	 * 
	 * The watermarked image must be saved in a lossless RGB format such
	 * as MIFF, or PNG. You cannot save a watermarked image in a lossy
	 * format such as JPEG or a pseudocolor format such as GIF. Once
	 * written, the file must not be modified or processed in any way.
	 * 
	 * Params:
	 *     watermark = An image or imagelist to be used as the watermark.
	 *                 The watermark must be grayscale and should be
	 *                 substantially smaller than the receiver. The recovery
	 *                 time is proportional to the size of the watermark.
	 *     offset    = The starting position within the receiver at which
	 *                 the watermark will be hidden. When you retrieve the
	 *                 watermark from the file, you must supply this value,
	 *                 along with the width and height of the watermark, in
	 *                 the size optional parameter to the read method.
	 */
	void stegano(Image watermark, ssize_t offset)
	{
		imageRef.offset = offset;

		MagickCoreImage* image =
			SteganoImage(imageRef, watermark.imageRef, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Combines two images and produces a single image that is the composite
	 * of a left and right image of a stereo pair. Special red-green stereo
	 * glasses are required to view this effect.
	 */
	void stereo(Image rightImage)
	{
		MagickCoreImage* image =
			StereoImage(imageRef, rightImage.imageRef, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Strips an image of all profiles and comments.
	 */
	void strip()
	{
		StripImage(imageRef);
		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * synchronizes image properties with the image profiles. Currently
	 * we only support updating the EXIF resolution and orientation.
	 */
	void syncProfiles()
	{
		SyncImageProfiles(imageRef);
		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Swirls the pixels about the center of the image, where degrees
	 * indicates the sweep of the arc through which each pixel is moved.
	 * You get a more dramatic effect as the degrees move from 1 to 360.
	 */
	void swirl(double degrees)
	{
		MagickCoreImage* image =
			SwirlImage(imageRef, degrees, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Changes the value of individual pixels based on the intensity of
	 * each pixel compared to threshold. The result is a high-contrast,
	 * two color image.
	 * 
	 * See_Also: $(XREF Image, bilevel).
	 */
	//TODO: deprecated ?
	void threshold(Quantum value)
	{
		bilevel(value);
	}

	/**
	 * changes the size of an image to the given dimensions and removes
	 * any associated profiles. The goal is to produce small low cost
	 * thumbnail images suited for display on the Web.
	 */
	void thumbnail(Geometry size)
	{
		size = size.toAbsolute(columns, rows);

		MagickCoreImage* image =
			ThumbnailImage(imageRef, size.width, size.height, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Creates a Binary Large OBject, a direct-to-memory
	 * version of the image.
	 *
	 * if an image format is selected which is capable of supporting
	 * fewer colors than the original image or quantization has been
	 * requested, the original image will be quantized to fewer colors.
	 * Use a copy of the original if this is a problem.
	 * 
	 * Params:
	 *     magick = specifies the image format to write.
	 *     depth  = specifies the image depth.
	 */
	void[] toBlob(string magick = null, size_t depth = 0)
	{
		size_t length;
		ExceptionInfo* exceptionInfo = AcquireExceptionInfo();

		if ( magick !is null )
			this.magick = magick;
		if ( depth != 0 )
			this.depth = depth;

		string originalFilename = filename;
		filename = this.magick ~ ":";
		scope(exit) filename = originalFilename;

		void* blob = ImageToBlob(options.imageInfo, imageRef, &length, exceptionInfo);

		DMagickException.throwException(exceptionInfo);

		void[] dBlob = blob[0 .. length].dup;
		RelinquishMagickMemory(blob);

		return dBlob;	
	}

	unittest
	{
		Image example = new Image(Geometry(100, 100), new Color("green"));
		example.toBlob("jpg");
	}

	/**
	 * Changes the opacity value of all the pixels that match color to
	 * the value specified by opacity. By default the pixel must match
	 * exactly, but you can specify a tolerance level by setting the fuzz
	 * attribute on the image.
	 * 
	 * Params:
	 *     target  = The target color.
	 *     opacity = The desired opacity.
	 *     invert  = If true, all pixels outside the range
	 *               are set to opacity.
	 */
	void transparent(Color color, Quantum opacity = TransparentOpacity, bool invert = false)
	{
		MagickPixelPacket target;

		GetMagickPixelPacket(imageRef, &target);
		setMagickPixelPacket(&target, color);

		TransparentPaintImage(imageRef, &target, opacity, invert);
		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Changes the opacity value associated with any pixel between low and
	 * high to the value defined by opacity.
	 * 
	 * As there is one fuzz value for the all the channels, the transparent
	 * method is not suitable for the operations like chroma, where the
	 * tolerance for similarity of two color components (RGB) can be
	 * different, Thus we define this method take two target pixels (one
	 * low and one high) and all the pixels of an image which are lying
	 * between these two pixels are made transparent.
	 * 
	 * Params:
	 *     low     = The low end of the pixel range.
	 *     high    = The high end of the pixel range.
	 *     opacity = The desired opacity.
	 *     invert  = If true, all pixels outside the range
	 *               are set to opacity.
	 */
	void transparentChroma(Color low, Color high, Quantum opacity = TransparentOpacity, bool invert = false)
	{
		MagickPixelPacket lowTarget;
		MagickPixelPacket highTarget;

		GetMagickPixelPacket(imageRef, &lowTarget);
		setMagickPixelPacket(&lowTarget, low);

		GetMagickPixelPacket(imageRef, &highTarget);
		setMagickPixelPacket(&highTarget, high);

		TransparentPaintImageChroma(imageRef, &lowTarget, &highTarget, opacity, invert);
		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Creates a horizontal mirror image by reflecting the pixels around
	 * the central y-axis while rotating them by 90 degrees.
	 */
	void transpose()
	{
		MagickCoreImage* image = TransposeImage(imageRef, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Creates a vertical mirror image by reflecting the pixels around
	 * the central x-axis while rotating them by 270 degrees
	 */
	void transverse()
	{
		MagickCoreImage* image = TransverseImage(imageRef, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Removes the edges that are exactly the same color as the corner
	 * pixels. Use the fuzz property to make trim remove edges that are
	 * nearly the same color as the corner pixels.
	 */
	void trim()
	{
		MagickCoreImage* image = TrimImage(imageRef, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Constructs a new image with one pixel for each unique color in the
	 * image. The new image has 1 row. The row has 1 column for each unique
	 * pixel in the image.
	 */
	Image uniqueColors()
	{
		MagickCoreImage* image = UniqueImageColors(imageRef, DMagickExceptionInfo());

		return new Image(image);
	}

	/**
	 * Sharpens an image. We convolve the image with a Gaussian operator
	 * of the given radius and standard deviation (sigma). For reasonable
	 * results, radius should be larger than sigma. Use a radius of 0 and
	 * unsharpMask selects a suitable radius for you.
	 * 
	 * Params:
	 *     radius    = The radius of the Gaussian operator.
	 *     sigma     = The standard deviation of the Gaussian operator.
	 *     amount    = The percentage of the blurred image to be added
	 *                 to the receiver, specified as a fraction between 0
	 *                 and 1.0. A good starting value is 1.0
	 *     threshold = The threshold needed to apply the amount, specified
	 *                 as a fraction between 0 and 1.0.
	 *     channel   = The channels to sharpen.
	 */
	void unsharpMask(
		double radius = 0,
		double sigma = 1,
		double amount = 1,
		double threshold = 0.05,
		ChannelType channel = ChannelType.DefaultChannels)
	{
		MagickCoreImage* image =
			UnsharpMaskImageChannel(imageRef, channel, radius, sigma, amount, threshold, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Get a view into the image. The ImageView can be used to modify
	 * individual pixels of the image.
	 * 
	 * Params:
	 *     area = The area accessible through the view. 
	 */
	dmagick.ImageView.ImageView view(Geometry area = Geometry.init )
	{
		if ( area == Geometry.init )
		{
			area.width = columns;
			area.height = rows;
		}

		return new dmagick.ImageView.ImageView(this, area);
	}

	/**
	 * Gradually shades the edges of the image by transforming the pixels
	 * into the background color.
	 * 
	 * Larger values of sigma increase the blurring at the expense of
	 * increased execution time. In general, radius should be larger than
	 * sigma, although if radius is 0 then ImageMagick will choose a suitable
	 * value. Sigma must be non-zero. Choose a very small value for sigma to
	 * produce a "hard" edge.
	 * 
	 * Params:
	 *     xOffset = Influences the amount of background color in the
	 *               horizontal dimension.
	 *     yOffset = Influences the amount of background color in the
	 *               vertical dimension.
	 *     radius  = The radius of the pixel neighborhood.
	 *     sigma   = The standard deviation of the Gaussian, in pixels.
	 */
	void vignette(ssize_t xOffset, ssize_t yOffset, double radius = 0, double sigma = 10)
	{
		MagickCoreImage* image =
			VignetteImage(imageRef, radius, sigma, xOffset, yOffset, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Creates a "ripple" effect in the image by shifting the pixels
	 * vertically along a sine wave whose amplitude and wavelength is
	 * specified by the given parameters.Creates a "ripple" effect in the
	 * image by shifting the pixels vertically along a sine wave whose
	 * amplitude and wavelength is specified by the given parameters.
	 */
	void wave(double amplitude = 25, double wavelength = 150)
	{
		MagickCoreImage* image =
			WaveImage(imageRef, amplitude, wavelength, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	/**
	 * Forces all pixels above the threshold into white while leaving
	 * all pixels below the threshold unchanged.
	 * 
	 * Params:
	 *     threshold = The threshold value for red green and blue.
	 *     channel   = One or more channels to adjust.
	 */
	void whiteThreshold(Quantum threshold, ChannelType channel = ChannelType.DefaultChannels)
	{
		whiteThreshold(threshold, threshold, threshold, 0, channel);
	}

	///ditto
	void whiteThreshold(
		Quantum red,
		Quantum green,
		Quantum blue,
		Quantum opacity = 0,
		ChannelType channel = ChannelType.DefaultChannels)
	{
		string thresholds = std.string.format("%s,%s,%s,%s", red, green, blue, opacity);

		WhiteThresholdImageChannel(
			imageRef, channel, toStringz(thresholds), DMagickExceptionInfo()
		);
	}

	/**
	 * Writes the image to the specified file. ImageMagick
	 * determines image format from the prefix or extension.
	 * 
	 * if an image format is selected which is capable of supporting
	 * fewer colors than the original image or quantization has been
	 * requested, the original image will be quantized to fewer colors.
	 * Use a copy of the original if this is a problem.
	 */
	void write(string filename)
	{
		this.filename = filename;
		WriteImage(options.imageInfo, imageRef);

		DMagickException.throwException(&(imageRef.exception));
	}

	/**
	 * Set a flag to indicate whether or not to use alpha channel data.
	 */
	void alpha(AlphaChannelType type)
	{
		SetImageAlphaChannel(imageRef, type);
	}
	///ditto
	bool alpha() const
	{
		return GetImageAlphaChannel(imageRef) != 0;
	}

	/**
	 * Number time which must expire before displaying the
	 * next image in an animated sequence.
	 */
	void animationDelay(Duration delay)
	{
		imageRef.delay = cast(size_t)(delay.total!"msecs"() * imageRef.ticks_per_second) / 1000;
	}
	///ditto
	Duration animationDelay() const
	{
		return dur!"msecs"((imageRef.delay * 1000) / imageRef.ticks_per_second);
	}

	/**
	 * Number of iterations to loop an animation.
	 */
	void animationIterations(size_t iterations)
	{
		imageRef.iterations = iterations;
	}
	///ditto
	size_t animationIterations() const
	{
		return imageRef.iterations;
	}

	/**
	 * Set the image background color. The default is "white".
	 */
	void backgroundColor(string color)
	{
		backgroundColor = new Color(color);
	}
	///ditto	
	void backgroundColor(Color color)
	{
		options.backgroundColor(color);

		imageRef.background_color = color.pixelPacket;
	}
	///ditto
	Color backgroundColor() const
	{
		return options.backgroundColor;
	}

	/**
	 * Set the image border color. The default is "#dfdfdf".
	 */
	void borderColor(string color)
	{
		borderColor = new Color(color);
	}
	///ditto
	void borderColor(Color color)
	{
		options.borderColor = color;

		imageRef.border_color = color.pixelPacket;
	}
	///ditto
	Color borderColor() const
	{
		return options.borderColor;
	}

	/**
	 * Return smallest bounding box enclosing non-border pixels.
	 * The current fuzz value is used when discriminating between pixels.
	 */
	Geometry boundingBox() const
	{
		RectangleInfo box = GetImageBoundingBox(imageRef, DMagickExceptionInfo());

		return Geometry(box);
	}

	/**
	 * Pixel cache threshold in megabytes. Once this threshold is exceeded,
	 * all subsequent pixels cache operations are to/from disk.
	 * This is a static method and the attribute it sets is shared
	 * by all Image objects
	 */
	static void cacheThreshold(size_t threshold)
	{
		SetMagickResourceLimit(ResourceType.MemoryResource, threshold);
	}

	/**
	 * returns true if any pixel in the image has been altered
	 * since it was first constituted.
	 */
	bool changed() const
	{
		return IsTaintImage(imageRef) != 0;
	}

	/**
	 * Channel modulus depth. The channel modulus depth represents
	 * the minimum number of bits required to support the channel without loss.
	 * Setting the channel's modulus depth modifies the channel (i.e. discards
	 * resolution) if the requested modulus depth is less than the current
	 * modulus depth, otherwise the channel is not altered. There is no
	 * attribute associated with the modulus depth so the current modulus
	 * depth is obtained by inspecting the pixels. As a result, the depth
	 * returned may be less than the most recently set channel depth.
	 * Subsequent image processing may result in increasing the channel depth.
	 */
	//TODO: Is this a property?
	void channelDepth(ChannelType channel, size_t depth)
	{
		SetImageChannelDepth(imageRef, channel, depth);
	}
	///ditto
	size_t channelDepth(ChannelType channel) const
	{
		size_t depth = GetImageChannelDepth(imageRef, channel, DMagickExceptionInfo());

		return depth;
	}

	/**
	 * The red, green, blue, and white-point chromaticity values.
	 */
	void chromaticity(ChromaticityInfo chroma)
	{
		imageRef.chromaticity = chroma;
	}
	///ditto
	ChromaticityInfo chromaticity() const
	{
		return imageRef.chromaticity;
	}

	/**
	 * The image's storage class. If DirectClass then the pixels
	 * contain valid RGB or CMYK colors. If PseudoClass then the
	 * image has a colormap referenced by the pixel's index member.
	 */
	void classType(ClassType type)
	{
		if ( imageRef.storage_class == ClassType.PseudoClass && type == ClassType.DirectClass )
		{
			SyncImage(imageRef);
			colormap() = null;
		}
		else if ( imageRef.storage_class == ClassType.DirectClass && type == ClassType.PseudoClass )
		{
			options.quantizeColors = MaxColormapSize;
			quantize();
		}

		imageRef.storage_class = type;
	}
	///ditto
	ClassType classType() const
	{
		return imageRef.storage_class;
	}

	/**
	 * Associate a clip mask image with the current image.
	 * The clip mask image must have the same dimensions as the current
	 * image or an exception is thrown. Clipping occurs wherever pixels are
	 * transparent in the clip mask image. Clipping Pass an invalid image
	 * to unset an existing clip mask.
	 */
	void clipMask(const(Image) image)
	{
		if ( image is null )
		{
			SetImageClipMask(imageRef, null);
			return;
		}

		//Throw a chatchable exception when the size differs.
		if ( image.columns != columns || image.rows != rows )
			throw new ImageException("image size differs");

		SetImageClipMask(imageRef, image.imageRef);
	}
	///ditto
	Image clipMask() const
	{
		MagickCoreImage* image = CloneImage(imageRef.clip_mask, 0, 0, true, DMagickExceptionInfo());

		return new Image(image);
	}

	/**
	 * Access the image color map.
	 * Only ClassType.PsseudoClass images have a colormap.
	 * ----------------------------------
	 * Color color = image.colormap[2];
	 * image.colormap()[2] = color;
	 * ----------------------------------
	 * To asign the complete colormap at once:
	 * ----------------------------------
	 * Color[] colors = new Colors[255];
	 * image.colormap() = colors;
	 * //Or
	 * image.colormap.size = 255;
	 * foreach(i, color; colors)
	 *     image.colormap()[i] = color;
	 * ----------------------------------
	 * Bugs: because of dmd bug 2152 the parentheses are needed when assigning;
	 */
	auto colormap()
	{
		struct Colormap
		{
			Image img;

			this(Image img)
			{
				this.img = img;
			}

			Color opIndex(uint index)
			{
				if ( index >= img.colormapSize )
					throw new Exception("Index out of bounds");

				return new Color(img.imageRef.colormap[index]);
			}

			void opIndexAssign(Color value, size_t index)
			{
				if ( index >= img.colormapSize )
					throw new Exception("Index out of bounds");

				img.imageRef.colormap[index] = value.pixelPacket;
			}

			void opAssign(Color[] colors)
			{
				img.colormapSize = colors.length;

				if ( colors.length == 0 )
					return;

				foreach(i, color; colors)
					this[i] = color;
			}

			void opOpAssign(string op)(Color color) if ( op == "~" )
			{
				img.colormapSize = img.colormapSize + 1;

				this[img.colormapSize] = color;
			}

			void opOpAssign(string op)(Color[] colors) if ( op == "~" )
			{
				uint oldSize = img.colormapSize;

				img.colormapSize = oldSize + colors.length;

				foreach ( i; oldSize..img.colormapSize)
					this[i] = colors[i];
			}

			/**
			 * compresses the colormap by removing any
			 * duplicate or unused color entries.
			 */
			void compress()
			{
				CompressImageColormap(img.imageRef);
				DMagickException.throwException(&(img.imageRef.exception));
			}

			size_t size()
			{
				return img.colormapSize;
			}
			void size(size_t s)
			{
				img.colormapSize = s;
			}
		}

		return Colormap(this);
	}

	/**
	 * The number of colors in the colormap. Only meaningful for PseudoClass images.
	 * 
	 * Setting the colormap size may extend or truncate the colormap.
	 * The maximum number of supported entries is specified by the
	 * MaxColormapSize constant, and is dependent on the value of
	 * QuantumDepth when ImageMagick is compiled. An exception is thrown
	 * if more entries are requested than may be supported.
	 * Care should be taken when truncating the colormap to ensure that
	 * the image colormap indexes reference valid colormap entries.
	 */
	void colormapSize(size_t size)
	{
		if ( size > MaxColormapSize )
			throw new OptionException(
				"the size of the colormap can't exceed MaxColormapSize");

		if ( size == 0 && imageRef.colors > 0 )
		{
			imageRef.colormap = cast(PixelPacket*)RelinquishMagickMemory( imageRef.colormap );
			imageRef.colors = 0;

			return;
		}

		if ( imageRef.colormap is null )
		{
			AcquireImageColormap(imageRef, size);
			imageRef.colors = 0;
		}
		else
		{
			imageRef.colormap = cast(PixelPacket*)
				ResizeMagickMemory(imageRef.colormap, size * PixelPacket.sizeof);
		}

		//Initialize the colors as black.
		foreach ( i; imageRef.colors .. size )
		{
			imageRef.colormap[i].blue    = 0;
			imageRef.colormap[i].green   = 0;
			imageRef.colormap[i].red     = 0;
			imageRef.colormap[i].opacity = 0;
		}

		imageRef.colors = size;
	}
	///ditto
	size_t colormapSize() const
	{
		return imageRef.colors;
	}

	/**
	 * The colorspace used to represent the image pixel colors.
	 * Image pixels are always stored as RGB(A) except for the case of CMY(K).
	 */
	void colorspace(ColorspaceType type)
	{
		TransformImageColorspace(imageRef, type);

		options.colorspace = type;
	}
	///ditto
	ColorspaceType colorspace() const
	{
		return imageRef.colorspace;
	}

	/**
	 * The width of the image in pixels.
	 */
	size_t columns() const
	{
		return imageRef.columns;
	}

	/**
	 * Composition operator to be used when composition is
	 * implicitly used (such as for image flattening).
	 */
	void compose(CompositeOperator op)
	{
		imageRef.compose = op;
	}
	///ditto
	CompositeOperator compose() const
	{
		return imageRef.compose;
	}

	/**
	 * The image compression type. The default is the
	 * compression type of the specified image file.
	 */
	void compression(CompressionType type)
	{
		imageRef.compression = type;
		options.compression = type;
	}
	///ditto
	CompressionType compression() const
	{
		return imageRef.compression;
	}

	/**
	 * The vertical and horizontal resolution in pixels of the image.
	 * This option specifies an image density when decoding
	 * a Postscript or Portable Document page.
	 * 
	 * The default is "72x72".
	 */
	void density(Geometry value)
	{
		options.density = value;

		imageRef.x_resolution = value.width;
		imageRef.y_resolution = ( value.width != 0 ) ? value.width : value.height;
	}
	///ditto
	Geometry density() const
	{
		ssize_t width  = cast(ssize_t)rndtol(imageRef.x_resolution);
		ssize_t height = cast(ssize_t)rndtol(imageRef.y_resolution);

		return Geometry(width, height);
	}

	/**
	 * Image depth. Used to specify the bit depth when reading or writing
	 * raw images or when the output format supports multiple depths.
	 * Defaults to the quantum depth that ImageMagick is compiled with.
	 */
	void depth(size_t value)
	{
		if ( value > MagickQuantumDepth)
			value = MagickQuantumDepth;

		imageRef.depth = value;
		options.depth = value;
	}
	///ditto
	size_t depth() const
	{
		return imageRef.depth;
	}

	/**
	 * Tile names from within an image montage.
	 * Only valid after calling montage or reading a MIFF file
	 * which contains a directory.
	 */
	string directory() const
	{
		return to!(string)(imageRef.directory);
	}

	/**
	 * Specify (or obtain) endian option for formats which support it.
	 */
	void endian(EndianType type)
	{
		imageRef.endian = type;
		options.endian = type;
	}
	///ditto
	EndianType endian() const
	{
		return imageRef.endian;
	}

	/**
	 * The EXIF profile.
	 */
	void exifProfile(void[] blob)
	{
		StringInfo* profile = AcquireStringInfo(blob.length);
		SetStringInfoDatum(profile, cast(ubyte*)blob.ptr);

		SetImageProfile(imageRef, "exif", profile);

		DestroyStringInfo(profile);		
	}
	///ditto
	void[] exifProfile() const
	{
		const(StringInfo)* profile = GetImageProfile(imageRef, "exif");

		if ( profile is null )
			return null;

		return GetStringInfoDatum(profile)[0 .. GetStringInfoLength(profile)].dup;
	}

	/**
	 * The image filename.
	 */
	void filename(string str)
	{
		copyString(imageRef.filename, str);
		options.filename = str;
	}
	///ditto
	string filename() const
	{
		return imageRef.magick[0 .. strlen(imageRef.magick.ptr)].idup;
	}

	/**
	 * The image filesize in bytes.
	 */
	MagickSizeType fileSize() const
	{
		return GetBlobSize(imageRef);
	}

	/**
	 * Filter to use when resizing image. The reduction filter employed
	 * has a significant effect on the time required to resize an image
	 * and the resulting quality. The default filter is Lanczos which has
	 * been shown to produce high quality results when reducing most images.
	 */
	void filter(FilterTypes type)
	{
		imageRef.filter = type;
	}
	///ditto
	FilterTypes filter() const
	{
		return imageRef.filter;
	}

	/**
	 * The image encoding format. For example, "GIF" or "PNG".
	 */
	string format() const
	{
		const(MagickInfo)* info = GetMagickInfo(imageRef.magick.ptr, DMagickExceptionInfo());

		return to!(string)( info.description );
	}

	/**
	 * Colors within this distance are considered equal. 
	 * A number of algorithms search for a target  color.
	 * By default the color must be exact. Use this option to match
	 * colors that are close to the target color in RGB space.
	 */
	void fuzz(double f)
	{
		options.fuzz = f;
		imageRef.fuzz = f;
	}
	///ditto
	double fuzz() const
	{
		return options.fuzz;
	}

	/**
	 * Gamma level of the image. The same color image displayed on
	 * two different workstations may look different due to differences
	 * in the display monitor. Use gamma correction to adjust for this
	 * color difference.
	 */
	double gamma() const
	{
		return imageRef.gamma;
	}

	/**
	 * Preferred size of the image when encoding.
	 */
	void geometry(string str)
	{
		copyString(imageRef.geometry, str);
	}
	///ditto
	void geometry(Geometry value)
	{
		geometry(value.toString());
	}
	///ditto
	Geometry geometry() const
	{
		return Geometry( to!(string)(imageRef.geometry) );
	}

	/**
	 * GIF disposal method. This attribute is used to control how
	 * successive images are rendered (how the preceding image
	 * is disposed of) when creating a GIF animation.
	 */
	void gifDisposeMethod(DisposeType type)
	{
		imageRef.dispose = type;
	}
	///ditto
	DisposeType gifDisposeMethod() const
	{
		return imageRef.dispose;
	}

	/**
	 * Returns true if all the pixels in the image have the same red,
	 * green, and blue intensities.
	 */
	bool gray()
	{
		return dmagick.c.attribute.IsGrayImage(imageRef, DMagickExceptionInfo()) == 1;
	}

	/**
	 * Computes the number of times each unique color appears in the image.
	 * You may want to quantize the image before using this property.
	 * 
	 * Returns: A associative array. Each key reprecents a color in the Image.
	 *     The value is the number of times the color apears in the image.
	 */
	MagickSizeType[Color] histogram() const
	{
		size_t count;
		MagickSizeType[Color] hashMap;
		ColorPacket* colorPackets;

		colorPackets = GetImageHistogram(imageRef, &count, DMagickExceptionInfo());

		foreach ( packet; colorPackets[0 .. count] )
		{
			hashMap[new Color(packet.pixel)] = packet.count;
		}

		RelinquishMagickMemory(colorPackets);

		return hashMap;
	}

	/**
	 * ICC color profile.
	 */
	void iccColorProfile(void[] blob)
	{
		profile("icm", blob);
	}
	///ditto
	void[] iccColorProfile() const
	{
		return profile("icm");
	}

	/**
	 * Specify the _type of interlacing scheme for raw image formats
	 * such as RGB or YUV. NoInterlace means do not _interlace,
	 * LineInterlace uses scanline interlacing, and PlaneInterlace
	 * uses plane interlacing. PartitionInterlace is like PlaneInterlace
	 * except the different planes are saved to individual files
	 * (e.g. image.R, image.G, and image.B). Use LineInterlace or
	 * PlaneInterlace to create an interlaced GIF or
	 * progressive JPEG image. The default is NoInterlace.
	 */
	void interlace(InterlaceType type)
	{
		imageRef.interlace = type;
		options.interlace = type;
	}
	///ditto
	InterlaceType interlace() const
	{
		return imageRef.interlace;
	}

	/**
	 * The International Press Telecommunications Council profile.
	 */
	void iptcProfile(void[] blob)
	{
		profile("iptc", blob);
	}
	///ditto
	void[] iptcProfile() const
	{
		return profile("iptc");
	}

	/**
	 * Image format (e.g. "GIF")
	 */
	void magick(string str)
	{
		copyString(imageRef.magick, str);
		options.magick = str;
	}
	///ditto
	string magick() const
	{
		if ( imageRef.magick[0] !is '\0' )
		{
			return imageRef.magick[0 .. strlen(imageRef.magick.ptr)].idup;
		}
		return options.magick;
	}

	/**
	 * Set the image transparent color. The default is "#bdbdbd".
	 */
	void matteColor(string color)
	{
		matteColor = new Color(color);
	}
	///ditto
	void matteColor(Color color)
	{
		imageRef.matte_color = color.pixelPacket;
		options.matteColor = color;
	}
	///ditto
	Color matteColor() const
	{
		return new Color(imageRef.matte_color);
	}

	/**
	 * The mean error per pixel computed when an image is color reduced.
	 * This parameter is only valid if verbose is set to true and the
	 * image has just been quantized.
	 */
	double meanErrorPerPixel() const
	{
		return imageRef.error.mean_error_per_pixel;
	}

	/**
	 * Image modulus depth (minimum number of bits required to
	 * support red/green/blue components without loss of accuracy).
	 * The pixel modulus depth may be decreased by supplying a value
	 * which is less than the current value, updating the pixels
	 * (reducing accuracy) to the new depth. The pixel modulus depth
	 * can not be increased over the current value using this method.
	 */
	void modulusDepth(size_t depth)
	{
		SetImageDepth(imageRef, depth);
		options.depth = depth;
	}
	///ditto
	size_t modulusDepth() const
	{
		size_t depth = GetImageDepth(imageRef, DMagickExceptionInfo());

		return depth;
	}

	/**
	 * Establish a progress monitor. Most Image and ImageList methods
	 * will periodically call the monitor with arguments indicating the
	 * progress of the method.
	 *
	 * The delegate receves the folowing $(B parameters): $(BR)
	 * $(TABLE 
	 *     $(ROW string $(I methodName), The name of the monitored method.)
	 *     $(ROW long   $(I offset    ), A number between 0 and extent that
	 *          identifies how much of the operation has been completed
	 *          (or, in some cases, remains to be completed).)
	 *     $(ROW ulong  $(I extent    ), The number of quanta needed to
	 *                                   complete the operation.)
	 * )
	 */
	void monitor(bool delegate(string methodName, long offset, ulong extent) progressMonitor)
	{
		if ( this.progressMonitor is null )
			SetImageProgressMonitor(imageRef, cast(MagickProgressMonitor)&ImageProgressMonitor, cast(void*)this);

		this.progressMonitor = progressMonitor;

		if ( progressMonitor is null )
			SetImageProgressMonitor(imageRef, null, null);		
	}
	///ditto
	bool delegate(string, long, ulong) monitor()
	{
		return progressMonitor;
	}

	static extern(C) MagickBooleanType ImageProgressMonitor(
		const(char)* methodName,
		MagickOffsetType offset,
		MagickSizeType extend,
		Image image)
	{
		return image.progressMonitor(to!(string)(methodName), offset, extend);
	}

	/**
	 * Tile size and offset within an image montage.
	 * Only valid for images produced by montage.
	 */
	Geometry montageGeometry() const
	{
		return Geometry( to!(string)(imageRef.geometry) );
	}

	/**
	 * The normalized max error per pixel computed when
	 * an image is color reduced. This parameter is only
	 * valid if verbose is set to true and the image
	 * has just been quantized.
	 */
	double normalizedMaxError() const
	{
		return imageRef.error.normalized_maximum_error;
	}

	/**
	 * The normalized mean error per pixel computed when
	 * an image is color reduced. This parameter is only
	 * valid if verbose is set to true and the image
	 * has just been quantized.
	 */
	double normalizedMeanError() const
	{
		return imageRef.error.normalized_mean_error;
	}

	/**
	 * Sets the value of the image property. An image may have any number
	 * of properties. ImageMagick predefines some properties, including
	 * attribute, label, caption, comment, signature, and in some cases EXIF.
	 */
	void opDispatch(string property)(string value)
		 if ( property != "popFront" )
	{
		SetImageProperty(imageRef, toStringz(property), toStringz(value));

		return;
	}

	/**
	 * Returns the value of the image property.
	 */
	auto opDispatch(string property)()
		 if ( property != "popFront" )
	{
		return to!(string)(GetImageProperty(imageRef, toStringz(property)));
	}

	unittest
	{
		Image image = new Image();

		image.comment = "unittest";
		assert(image.comment == "unittest");
	}

	/**
	 * Image orientation.  Supported by some file formats
	 * such as DPX and TIFF. Useful for turning the right way up.
	 */
	void orientation(OrientationType orientation)
	{
		imageRef.orientation = orientation;
	}
	///ditto
	OrientationType orientation() const
	{
		return imageRef.orientation;
	}

	/**
	 * When compositing, this attribute describes the position
	 * of this image with respect to the underlying image.
	 * 
	 * Use this option to specify the dimensions and position of
	 * the Postscript page in dots per inch or a TEXT page in pixels.
	 * This option is typically used in concert with density.
	 * 
	 * Page may also be used to position a GIF image
	 * (such as for a scene in an animation).
	 */
	void page(Geometry geometry)
	{
		options.page = geometry;
		imageRef.page = geometry.rectangleInfo;
	}
	///ditto
	Geometry page() const
	{
		return Geometry(imageRef.page);
	}

	/**
	 * The pixel color interpolation method. Some methods (such
	 * as wave, swirl, implode, and composite) use the pixel color
	 * interpolation method to determine how to blend adjacent pixels.
	 */
	void pixelInterpolationMethod(InterpolatePixelMethod method)
	{
		imageRef.interpolate = method;
	}
	///ditto
	InterpolatePixelMethod pixelInterpolationMethod() const
	{
		return imageRef.interpolate;
	}

	/**
	 * Get/set/remove a named profile. Valid names include "*",
	 * "8BIM", "ICM", "IPTC", or a user/format-defined profile name. 
	 */
	void profile(string name, void[] blob)
	{
		ProfileImage(imageRef, toStringz(name), blob.ptr, blob.length, false);
	}
	///ditto
	void[] profile(string name) const
	{
		const(StringInfo)* profile = GetImageProfile(imageRef, toStringz(name));

		if ( profile is null )
			return null;

		return GetStringInfoDatum(profile)[0 .. GetStringInfoLength(profile)].dup;
	}

	/**
	 * JPEG/MIFF/PNG compression level (default 75).
	 */
	void quality(size_t quality)
	{
		imageRef.quality = quality;
		options.quality = quality;
	}
	///ditto
	size_t quality() const
	{
		return imageRef.quality;
	}

	/**
	 * The type of rendering intent.
	 * See_Also: 
	 * $(LINK http://www.cambridgeincolour.com/tutorials/color-space-conversion.htm)
	 */
	void renderingIntent(RenderingIntent intent)
	{
		imageRef.rendering_intent = intent;
	}
	///ditto
	RenderingIntent renderingIntent() const
	{
		return imageRef.rendering_intent;
	}

	/**
	 * Units of image resolution
	 */
	void resolutionUnits(ResolutionType type)
	{
		imageRef.units = type;
		options.resolutionUnits = type;
	}
	///ditto
	ResolutionType resolutionUnits() const
	{
		return options.resolutionUnits;
	}

	/**
	 * The scene number assigned to the image the last
	 * time the image was written to a multi-image image file.
	 */
	void scene(size_t value)
	{
		imageRef.scene = value;
	}
	///ditto
	size_t scene() const
	{
		return imageRef.scene;
	}

	/**
	 * The height of the image in pixels.
	 */
	size_t rows() const
	{
		return imageRef.rows;
	}

	/**
	 * Width and height of a image.
	 */
	Geometry size() const
	{
		return Geometry(imageRef.columns, imageRef.rows);
	}

	/**
	 * Number of colors in the image.
	 */
	size_t totalColors() const
	{
		size_t colors = GetNumberColors(imageRef, null, DMagickExceptionInfo());

		return colors;
	}

	/**
	 * Image type.
	 */
	void type(ImageType imageType)
	{
		options.type = imageType;
		SetImageType(imageRef, imageType);
	}
	///ditto
	ImageType type() const
	{
		if (options.type != ImageType.UndefinedType )
			return options.type;

		ImageType imageType = GetImageType(imageRef, DMagickExceptionInfo());

		return imageType;
	}

	/**
	 * Specify how "virtual pixels" behave. Virtual pixels are
	 * pixels that are outside the boundaries of the image.
	 * Methods such as blurImage, sharpen, and wave use virtual pixels.
	 */
	void virtualPixelMethod(VirtualPixelMethod method)
	{
		options.virtualPixelMethod = method;
		SetImageVirtualPixelMethod(imageRef, method);
	}
	///ditto
	VirtualPixelMethod virtualPixelMethod() const
	{
		return GetImageVirtualPixelMethod(imageRef);
	}

	/**
	 * Horizontal resolution of the image.
	 */
	double xResolution() const
	{
		return imageRef.x_resolution;
	}

	/**
	 * Vertical resolution of the image.
	 */
	double yResolution() const
	{
		return imageRef.y_resolution;
	}

	private void setMagickPixelPacket(MagickPixelPacket* magick, Color color)
	{
		magick.red     = color.redQuantum;
		magick.green   = color.greenQuantum;
		magick.blue    = color.blueQuantum;
		magick.opacity = color.opacityQuantum;
	}

	private string wordWrap(string text, Geometry boundingBox)
	{
		size_t pos;
		string[] lines;

		if ( text.empty )
			return text;

		double lineHeight = getTypeMetrics([text[0]]).height;
		size_t maxLines = cast(size_t)(boundingBox.height / lineHeight);

		while ( !text.empty )
		{
			for ( size_t i; i < text.length; i++ )
			{
				if ( isWhite(text[i]) || i == text.length-1 )
				{
					TypeMetric metric = getTypeMetrics(text[0..i]);

					if ( metric.width >  boundingBox.width )
					{
						if ( pos == 0 )
							pos = i;

						break;
					}

					pos = i;

					if ( text[i] == '\n' )
						break;

					if ( i == text.length-1 )
						pos++;
				}
			}

			lines ~= text[0 .. pos].strip();
			text = text[min(pos+1, text.length) .. $];
			pos = 0;

			if ( lines.length == maxLines )
				break;
		}

		return join(lines, "\n");	
	}

	unittest
	{
		Image img = new Image(Geometry(200, 200), new Color());
		string wraped = img.wordWrap("Lorem ipsum dolor sit amet.", Geometry(100, 200));

		assert(wraped == "Lorem ipsum\ndolor sit amet.");
	}

	private template getStorageType(T)
	{
		static if ( is( T == byte) )
		{
			enum getStorageType = StorageType.CharPixel;
		}
		else static if ( is( T == short) )
		{
			enum getStorageType  = StorageType.ShortPixel;
		}
		else static if ( is( T == int) )
		{
			enum getStorageType = StorageType.IntegerPixel;
		}
		else static if ( is( T == long) )
		{
			enum getStorageType = StorageType.LongPixel;
		}
		else static if ( is( T == float) )
		{
			enum getStorageType = StorageType.FloatPixel;
		}
		else static if ( is( T == double) )
		{
			enum getStorageType = StorageType.DoublePixel;
		}
		else
		{
			static assert(false, "Unsupported type");
		}
	}

	unittest
	{
		StorageType storage = getStorageType!(int);

		assert( storage == StorageType.IntegerPixel );
	}
}
