/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */

module dmagick.Image;

import std.conv;
import std.math;
import std.string;
import core.memory;
import core.runtime;
import core.stdc.string;
import core.sys.posix.sys.types;

import dmagick.Color;
import dmagick.Exception;
import dmagick.Geometry;
import dmagick.Options;
import dmagick.Utils;

import dmagick.c.artifact;
import dmagick.c.annotate;
import dmagick.c.attribute;
import dmagick.c.blob;
import dmagick.c.cacheView;
import dmagick.c.cipher;
import dmagick.c.constitute;
import dmagick.c.colormap;
import dmagick.c.colorspace;
import dmagick.c.compare;
import dmagick.c.composite;
import dmagick.c.compress;
import dmagick.c.decorate;
import dmagick.c.display;
import dmagick.c.distort;
import dmagick.c.draw;
import dmagick.c.effect;
import dmagick.c.enhance;
import dmagick.c.fx;
import dmagick.c.geometry;
import dmagick.c.histogram;
import dmagick.c.image;
import dmagick.c.layer;
import dmagick.c.magick;
import dmagick.c.magickString;
import dmagick.c.magickType;
import dmagick.c.memory;
import dmagick.c.morphology;
import dmagick.c.pixel;
import dmagick.c.profile;
import dmagick.c.quantize;
import dmagick.c.quantum;
import dmagick.c.resample;
import dmagick.c.resize;
import dmagick.c.resource;
import dmagick.c.shear;
import dmagick.c.transform;
import dmagick.c.threshold;

/**
 * The image
 */
class Image
{
	alias dmagick.c.image.Image MagickCoreImage;
	alias RefCounted!( DestroyImage, MagickCoreImage ) ImageRef;

	ImageRef imageRef;
	Options options;  ///The options for this image.

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
	 */
	this(size_t columns, size_t rows, string map, StorageType storage, void[] pixels)
	{
		options = new Options();

		read(columns, rows, map, storage, pixels);
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
		ssize_t x, y;
		size_t width  = columns;
		size_t height = rows;

		ParseMetaGeometry(toStringz(size.toString), &x, &y, &width, &height);
		MagickCoreImage* image =
			AdaptiveResizeImage(imageRef, width, height, DMagickExceptionInfo());

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
	 *     channel = If no channels are specified, blurs all the channels.
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
	 *     boundingArea = 
	 *              The location/bounding area for the text,
	 *               if the height and width are 0 the height and
	 *               with of the image are used to calculate
	 *               the bounding area.
	 *     gravity = Placement gravity.
	 *     degrees = The angle of the Text.
	 */
	void annotate(
		string text,
		Geometry boundingArea = Geometry.init,
		GravityType gravity = GravityType.NorthWestGravity,
		double degrees = 0.0)
	{
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
	 * See_Also: $(LINK2 http://http://en.wikipedia.org/wiki/ASC_CDL,
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
	 *     overlay     = Image to use in to composite operation.
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
		DisplayImages(options.imageInfo, imageRef);

		DMagickException.throwException(&(imageRef.exception));
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
	 * Extracts the pixel data from the specified rectangle.
	 *
	 * Params:
	 *     width   = Width in pixels of the region to extract.
	 *     height  = Height in pixels of the region to extract.
	 *     xOffset = Horizontal ordinate of left-most coordinate
	 *               of region to extract.
	 *     yOffset = Vertical ordinate of top-most coordinate of
	 *               region to extract.
	 *     map     = This character string can be any combination
	 *               or order of R = red, G = green, B = blue, A = 
	 *               alpha, C = cyan, Y = yellow, M = magenta, and K = black.
	 *               The ordering reflects the order of the pixels in
	 *               the supplied pixel array.
	 * 
	 * Returns: An array of values containing the pixel components as
	 *          defined by the map parameter and the Type.
	 */
	T[] exportPixels(T)
		(size_t width, size_t height, ssize_t xOffset = 0, ssize_t yOffset = 0, string map = "RGBA") const
	{
		StorageType storage;
		void[] pixels = new T[width*height];

		static if ( is( T == byte) )
		{
			storage = CharPixel;
		}
		else static if ( is( T == short) )
		{
			storage = ShortPixel;
		}
		else static if ( is( T == int) )
		{
			storage = IntegerPixel;
		}
		else static if ( is( T == long) )
		{
			storage = LongPixel;
		}
		else static if ( is( T == float) )
		{
			storage = FloatPixel;
		}
		else static if ( is( T == double) )
		{
			storage = DoublePixel;
		}
		else
		{
			assert(false, "Unsupported type");
		}

		ExportImagePixels(imageRef, xOffset, yOffset, width, height, map, storage, pixels.ptr, DMagickExceptionInfo());

		return pixels;
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
	 * Read an Image by reading from the file or
	 * URL specified by filename.
	 */
	void read(string filename)
	{
		options.filename = filename;

		MagickCoreImage* image = ReadImage(options.imageInfo, DMagickExceptionInfo());

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
	void read(size_t width, size_t height, string map, StorageType storage, void[] pixels)
	{
		MagickCoreImage* image = 
			ConstituteImage(width, height, toStringz(map), storage, pixels.ptr, DMagickExceptionInfo());

		imageRef = ImageRef(image);
	}

	///ditto
	void readPixels(T)(size_t width, size_t height, string map, T[] pixels)
	{
		StorageType storage;

		static if ( is( T == byte) )
		{
			storage = CharPixel;
		}
		else static if ( is( T == short) )
		{
			storage = ShortPixel;
		}
		else static if ( is( T == int) )
		{
			storage = IntegerPixel;
		}
		else static if ( is( T == long) )
		{
			storage = LongPixel;
		}
		else static if ( is( T == float) )
		{
			storage = FloatPixel;
		}
		else static if ( is( T == double) )
		{
			storage = DoublePixel;
		}
		else
		{
			assert(false, "Unsupported type");
		}

		read(width, height, map, storage, pixels);
	}

	//TODO: set process monitor.

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

		AcquireMemoryHandler oldMalloc;
		ResizeMemoryHandler  oldRealloc;
		DestroyMemoryHandler oldFree;

		if ( magick !is null )
			this.magick = magick;
		if ( depth != 0 )
			this.depth = depth;

		//Use the D GC to accolate the blob.
		GetMagickMemoryMethods(&oldMalloc, &oldRealloc, &oldFree);
		SetMagickMemoryMethods(&GC.malloc, &GC.realloc, &GC.free);
		scope(exit) SetMagickMemoryMethods(oldMalloc, oldRealloc, oldFree);

		void* blob = ImageToBlob(options.imageInfo, imageRef, &length, DMagickExceptionInfo());

		return blob[0 .. length];	
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
		options.filename = filename;
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
	 * Number of ticks which must expire before displaying the
	 * next image in an animated sequence. The default number
	 * of ticks is 0. By default there are 100 ticks per second.
	 */
	void animationDelay(ushort delay)
	{
		imageRef.delay = delay;
	}
	///ditto
	ushort annimationDelay() const
	{
		return cast(ushort)imageRef.delay;
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
			//TODO: implement quantize function.
			//quantize();
			assert(false);
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
	 * GammaImage() gamma-corrects a particular image channel.
	 * The same image viewed on different devices will have perceptual
	 * differences in the way the image's intensities are represented
	 * on the screen.  Specify individual gamma levels for the red,
	 * green, and blue channels, or adjust all three with the gamma
	 * parameter.  Values typically range from 0.8 to 2.3.
	 * 
	 * You can also reduce the influence of a particular channel
	 * with a gamma value of 0.
	 */
	void gamma(double value)
	{
		GammaImageChannel(imageRef,
			( ChannelType.RedChannel | ChannelType.GreenChannel | ChannelType.BlueChannel ),
			value);
	}
	///ditto
	void gamma(double red, double green, double blue)
	{
		GammaImageChannel(imageRef, ChannelType.RedChannel, red);
		GammaImageChannel(imageRef, ChannelType.GreenChannel, green);
		GammaImageChannel(imageRef, ChannelType.BlueChannel, blue);
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
		if ( imageRef.magick !is null )
			return imageRef.magick[0 .. strlen(imageRef.magick.ptr)].idup;

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
	void quality(size_t )
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

	//TODO: Statistics ?

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

	//Image properties - set via SetImageProperties
	//Should we implement these as actual properties?
	//attribute
	//comment
	//label
	//signature

	//Other unimplemented porperties
	//pixelColor
}


/*
 * Initialize ImageMagick, only needed on Windows.
 */
version (Windows)
{
	static this()
	{
			MagickCoreGenesis(toStringz(Runtime.args[0]) , false);
	}

	static ~this()
	{
			MagickCoreTerminus();
	}
}
