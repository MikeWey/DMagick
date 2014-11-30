/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 * 
 * This module contains functions that operate on a array or list of images.
 */

module dmagick.Array;

import std.string;
import core.time;

import dmagick.Exception;
import dmagick.Geometry;
import dmagick.Image;
import dmagick.Montage;
import dmagick.Options;

import dmagick.c.blob;
import dmagick.c.colorspace;
import dmagick.c.composite;
import dmagick.c.constitute;
import dmagick.c.display;
import dmagick.c.fx;
import dmagick.c.image : MagickCoreImage = Image;
import dmagick.c.layer;
import dmagick.c.magickType;
import dmagick.c.memory;
import dmagick.c.montage;
import dmagick.c.statistic;
import dmagick.c.quantize;

version(DMagick_No_Display)
{
}
else
{
	version(Windows) import dmagick.internal.Windows;
}

/// See_Also: $(CXREF layer, _ImageLayerMethod)
public alias dmagick.c.layer.ImageLayerMethod ImageLayerMethod;

alias ptrdiff_t ssize_t;

/**
 * Set the animationDelay for all images in the array.
 */
void animationDelay(Image[] images, Duration delay)
{
	size_t ticks = cast(size_t)(delay.total!"msecs"() * images[0].imageRef.ticks_per_second) / 1000;

	foreach ( image; images )
	{
		image.imageRef.delay = ticks;
	}
}

/**
 * Number of iterations to loop an animation.
 */
void animationIterations(Image[] images, size_t iterations)
{
	images[0].animationIterations = iterations;
}

/**
 * Averages all the images together. Each image in the image must have
 * the same width and height.
 */
Image average(Image[] images)
{
	linkImages(images);
	scope(exit) unlinkImages(images);

	static if ( is(typeof(EvaluateImages)) )
	{
		MagickCoreImage* image =
			EvaluateImages(images[0].imageRef, MagickEvaluateOperator.MeanEvaluateOperator, DMagickExceptionInfo());
	}
	else
	{
		MagickCoreImage* image = AverageImages(images[0].imageRef, DMagickExceptionInfo());
	}

	return new Image(image);
}

/**
 * Clone every image in the array.
 */
Image[] clone(const(Image)[] images)
{
	Image[] newImages = new Image[images.length];

	foreach ( i, image; images )
	{
		newImages[i] = image.clone();
	}

	return newImages;
}

/**
 * Merges all the images in the imagelist into a new imagelist. Each image
 * in the new imagelist is formed by flattening all the previous images.
 * 
 * The length of time between images in the new image is specified by the
 * delay attribute of the input image. The position of the image on the
 * merged images is specified by the page attribute of the input image.
 */
Image[] coalesce(Image[] images)
{
	linkImages(images);
	scope(exit) unlinkImages(images);

	MagickCoreImage* image = CoalesceImages(images[0].imageRef, DMagickExceptionInfo());

	return imageListToArray(image);
}

/**
 * Compares each image with the next in a sequence and returns the minimum
 * bounding region of all the pixel differences (of the ImageLayerMethod
 * specified) it discovers.
 * 
 * Images do NOT have to be the same size, though it is best that all the
 * images are 'coalesced' (images are all the same size, on a flattened
 * canvas, so as to represent exactly how an specific frame should look).
 * 
 * No GIF dispose methods are applied, so GIF animations must be coalesced
 * before applying this image operator to find differences to them.
 */
Image[] compareLayers(Image[] images, ImageLayerMethod method)
{
	linkImages(images);
	scope(exit) unlinkImages(images);

	MagickCoreImage* image =
		CompareImageLayers(images[0].imageRef, method, DMagickExceptionInfo());

	return imageListToArray(image);
}

/**
 * An image from source is composited over an image from destination until
 * one list is finished. Unlike a normal composite operation, the canvas
 * offset is also included to the composite positioning. If one of the
 * image lists only contains one image, that image is applied to all the
 * images in the other image list, regardless of which list it is. In this
 * case it is the image meta-data of the list which preserved.
 */
void compositeLayers(
	ref Image[] destination,
	Image[] source,
	ssize_t xOffset,
	ssize_t yOffset,
	CompositeOperator operator = CompositeOperator.OverCompositeOp)
{
	linkImages(destination);
	linkImages(source);
	scope(exit) unlinkImages(source);
	scope(failure) unlinkImages(destination);

	CompositeLayers(destination[0].imageRef, operator, source[0].imageRef, xOffset, yOffset, DMagickExceptionInfo());

	destination = imageListToArray(destination[0].imageRef);
}

/**
 * Repeatedly displays an image sequence to a X window screen.
 */
void display(Image[] images)
{
	version(DMagick_No_Display)
	{
	}
	else
	{
		version(Windows)
		{
			Window win = new Window(images);
			win.display();
		}
		else
		{
			linkImages(images);
			scope(exit) unlinkImages(images);

			DisplayImages(images[0].options.imageInfo, images[0].imageRef);

			DMagickException.throwException(&(images[0].imageRef.exception));
		}
	}
}

/**
 * Applies a mathematical expression to the specified images.
 * 
 * See_Aso:
 *     $(LINK2 http://www.imagemagick.org/script/fx.php,
 *     FX, The Special Effects Image Operator) for a detailed
 *     discussion of this option.
 */
void fx(Image[] images, string expression, ChannelType channel = ChannelType.DefaultChannels)
{
	linkImages(images);
	scope(exit) unlinkImages(images);

	images[0].fx(expression, channel);
}

/**
 * Composes all the image layers from the current given image onward
 * to produce a single image of the merged layers.
 * 
 * The inital canvas's size depends on the given ImageLayerMethod, and is
 * initialized using the first images background color. The images are then
 * compositied onto that image in sequence using the given composition that
 * has been assigned to each individual image.
 * 
 * Params:
 *     layers = The images to merge.
 *     method = The method of selecting the size of the initial canvas.
 *              $(LIST
 *                  $(B MergeLayer:) Merge all layers onto a canvas just
 *                      large enough to hold all the actual images. The
 *                      virtual canvas of the first image is preserved but
 *                      otherwise ignored.,
 *                  $(B FlattenLayer:) Use the virtual canvas size of first
 *                      image. Images which fall outside this canvas is
 *                      clipped. This can be used to 'fill out' a given
 *                      virtual canvas.,
 *                  $(B MosaicLayer:) Start with the virtual canvas of the
 *                      first image enlarging left and right edges to
 *                      contain all images. Images with negative offsets
 *                      will be clipped.,
 *                  $(B TrimBoundsLayer:) Determine the overall bounds of
 *                      all the image layers just as in "MergeLayer". Then
 *                      adjust the the canvas and offsets to be relative to
 *                      those bounds. Without overlaying the images.
 * 
 *                      $(RED Warning:) a new image is not returned the
 *                      original image sequence page data is modified instead.
 *              )
 */
Image mergeLayers(Image[] layers, ImageLayerMethod method = ImageLayerMethod.FlattenLayer)
{
	linkImages(layers);
	scope(exit) unlinkImages(layers);

	MagickCoreImage* image =
		MergeImageLayers(layers[0].imageRef, method, DMagickExceptionInfo());

	return new Image(image);
}

/**
 * Creates a composite image by reducing the size of the input images and
 * arranging them in a grid on the background color or texture of your
 * choice. There are many configuration options. For example, you can
 * specify the number of columns and rows, the distance between images,
 * and include a label with each small image (called a tile).
 * 
 * To add labels to the tiles, assign a "Label" property to each image.
 */
Image[] montage(Image[] images, Montage montageInfo)
{
	linkImages(images);
	scope(exit) unlinkImages(images);

	MagickCoreImage* image =
		MontageImages(images[0].imageRef, montageInfo.montageInfoRef, DMagickExceptionInfo());

	return imageListToArray(image);
}

/**
 * Transforms a image into another image by inserting n in-between images.
 * Requires at least two images. If more images are present, the 2nd image
 * is transformed into the 3rd, the 3rd to the 4th, etc.
 * 
 * Params:
 *     images = The images to use.
 *     frames = The number of frames to inster between the images.
 */
Image[] morph(Image[] images, size_t frames)
{
	linkImages(images);
	scope(exit) unlinkImages(images);

	MagickCoreImage* image =
		MorphImages(images[0].imageRef, frames, DMagickExceptionInfo());

	return imageListToArray(image);
}

/**
 * For each image compares the GIF disposed forms of the previous image in
 * the sequence. From this it attempts to select the smallest cropped image
 * to replace each frame, while preserving the results of the GIF animation.
 * 
 * See_Also: $(LINK2 http://www.imagemagick.org/Usage/anim_opt/,
 *     Examples of ImageMagick Usage)
 */
Image[] optimizeLayers(Image[] images)
{
	linkImages(images);
	scope(exit) unlinkImages(images);

	MagickCoreImage* image = OptimizeImageLayers(images[0].imageRef, DMagickExceptionInfo());

	return imageListToArray(image);
}

/**
 * Is exactly as optimizeLayers, but may also add or even remove extra
 * frames in the animation, if it improves the total number of pixels in
 * the resulting GIF animation.
 */
Image[] optimizePlusLayers(Image[] images)
{
	linkImages(images);
	scope(exit) unlinkImages(images);

	MagickCoreImage* image = OptimizePlusImageLayers(images[0].imageRef, DMagickExceptionInfo());

	return imageListToArray(image);
}

/**
 * Ping is similar to read except only enough of the image is read to
 * determine the image columns, rows, and filesize. The columns, rows,
 * and fileSize attributes are valid after invoking ping.
 * The image data is not valid after calling ping.
 */
Image[] ping(string filename)
{
	Options options = new Options();
	options.filename = filename;

	MagickCoreImage* image = PingImages(options.imageInfo, DMagickExceptionInfo());

	return imageListToArray(image);
}

///ditto
Image[] ping(void[] blob)
{
	return ping(blob, new Options());
}

///ditto
Image[] ping(void[] blob, Geometry size)
{
	Options options = new Options();
	options.size = size;

	return ping(blob, options);
}

///ditto
Image[] ping(void[] blob, Geometry size, size_t depth)
{
	Options options = new Options();
	options.size = size;
	options.depth = depth;

	return ping(blob, options);
}

///ditto
Image[] ping(void[] blob, Geometry size, size_t depth, string magick)
{
	Options options = new Options();
	options.size = size;
	options.depth = depth;
	options.magick = magick;
	//Also set the filename to the image format
	options.filename = magick ~":";

	return ping(blob, options);
}

///ditto
Image[] ping(void[] blob, Geometry size, string magick)
{
	Options options = new Options();
	options.size = size;
	options.magick = magick;
	//Also set the filename to the image format
	options.filename = magick ~":";

	return ping(blob, options);
}

/**
 * Analyzes the colors within a set of reference images and chooses a
 * fixed number of colors to represent the set. The goal of the algorithm
 * is to minimize the difference between the input and output images while
 * minimizing the processing time.
 * 
 * Params:
 *     images       = The images to quantize.
 *     measureError = Set to true to calculate quantization errors
 *                    when quantizing the image. These can be accessed
 *                    with: normalizedMeanError, normalizedMaxError
 *                    and meanErrorPerPixel.
 */
void quantize(Image[] images, bool measureError = false)
{
	linkImages(images);
	scope(exit) unlinkImages(images);

	bool originalmeasureError = images[0].options.quantizeInfo.measure_error != 0;
	images[0].options.quantizeInfo.measure_error = measureError;
	scope(exit) images[0].options.quantizeInfo.measure_error = originalmeasureError;

	QuantizeImages(images[0].options.quantizeInfo, images[0].imageRef);

	foreach ( image; images )
		DMagickException.throwException(&(image.imageRef.exception));
}

/**
 * Preferred number of _colors in the image.
 * The actual number of _colors in the image may be less
 * than your request, but never more. Images with less
 * unique _colors than specified with this option will have
 * any duplicate or unused _colors removed.
 */
void quantizeColors(Image[] images, size_t colors)
{
	images[0].options.quantizeColors = colors;
}
///ditto
size_t quantizeColors(const(Image)[] images)
{
	return images[0].options.quantizeColors;
}

/**
 * Colorspace to quantize colors in.
 * Empirical evidence suggests that distances in color spaces
 * such as YUV or YIQ correspond to perceptual color differences
 * more closely than do distances in RGB space. These color spaces
 * may give better results when color reducing an image.
 * The default is RGB
 */
void quantizeColorSpace(Image[] images, ColorspaceType type)
{
	images[0].options.quantizeColorSpace = type;
}
///ditto
ColorspaceType quantizeColorSpace(const(Image)[] images)
{
	return images[0].options.quantizeColorSpace;
}

/**
 * The basic strategy of dithering is to trade intensity resolution for
 * spatial resolution by averaging the intensities of several neighboring
 * pixels. Images which suffer from severe contouring when reducing
 * colors can be improved with this option. 
 */
void quantizeDitherMethod(Image[] images, DitherMethod method)
{
	images[0].options.quantizeDitherMethod = method;
}
///ditto
DitherMethod quantizeDitherMethod(const(Image)[] images)
{
	return images[0].options.quantizeDitherMethod;
}

/**
 * Depth of the quantization color classification tree.
 * Values of 0 or 1 allow selection of the optimal tree _depth
 * for the color reduction algorithm. Values between 2 and 8
 * may be used to manually adjust the tree _depth.
 */
void quantizeTreeDepth(Image[] images, size_t depth)
{
	images[0].options.quantizeTreeDepth = depth;
}
///ditto
size_t quantizeTreeDepth(const(Image)[] images)
{
	return images[0].options.quantizeTreeDepth;
}

/**
 * Read a multi frame Image by reading from the file or
 * URL specified by filename.
 */
Image[] readImages(string filename)
{
	Options options = new Options();
	options.filename = filename;

	return readImages(options);
}

///ditto
Image[] readImages(string filename, Geometry size)
{
	Options options = new Options();
	options.filename = filename;
	options.size = size;

	return readImages(options);
}

/**
 * Reads a multi frame Image from an in-memory blob.
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
Image[] readImages(void[] blob)
{
	return readImages(blob, new Options());
}

///ditto
Image[] readImages(void[] blob, Geometry size)
{
	Options options = new Options();
	options.size = size;

	return readImages(blob, options);
}

///ditto
Image[] readImages(void[] blob, Geometry size, size_t depth)
{
	Options options = new Options();
	options.size = size;
	options.depth = depth;

	return readImages(blob, options);
}

///ditto
Image[] readImages(void[] blob, Geometry size, size_t depth, string magick)
{
	Options options = new Options();
	options.size = size;
	options.depth = depth;
	options.magick = magick;
	//Also set the filename to the image format
	options.filename = magick ~":";

	return readImages(blob, options);
}

///ditto
Image[] readImages(void[] blob, Geometry size, string magick)
{
	Options options = new Options();
	options.size = size;
	options.magick = magick;
	//Also set the filename to the image format
	options.filename = magick ~":";

	return readImages(blob, options);
}

/**
 * Reduce the colors used in the imagelist to the set of colors in
 * reference image.
 */
void remap(Image[] images, Image referenceImage)
{
	linkImages(images);
	scope(exit) unlinkImages(images);

	RemapImages(images[0].options.quantizeInfo, images[0].imageRef, referenceImage.imageRef);

	foreach ( image; images )
		DMagickException.throwException(&(image.imageRef.exception));
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
 * Note, some image formats do not permit multiple images to the same
 * image stream (e.g. JPEG). in this instance, just the first image of
 * the sequence is returned as a blob.
 * 
 * Params:
 *     images = Images to write.
 *     magick = Specifies the image format to write.
 *     depth  = Specifies the image depth.
 *     adjoin = Join images into a single multi-image file.
 */
void[] toBlob(Image[] images, string magick = null, size_t depth = 0, bool adjoin = true)
{
	size_t length;

	if ( magick !is null )
		images[0].magick = magick;
	if ( depth != 0 )
		images[0].depth = depth;

	string originalFilename = images[0].filename;
	images[0].filename = images[0].magick ~ ":";
	scope(exit) images[0].filename = originalFilename;

	bool originalAdjoin = images[0].options.imageInfo.adjoin != 0;
	images[0].options.imageInfo.adjoin = adjoin;
	scope(exit) images[0].options.imageInfo.adjoin = originalAdjoin;

	linkImages(images);
	scope(exit) unlinkImages(images);

	void* blob = ImagesToBlob(images[0].options.imageInfo, images[0].imageRef, &length, DMagickExceptionInfo());

	void[] dBlob = blob[0 .. length].dup;
	RelinquishMagickMemory(blob);

	return dBlob;	
}

/**
 * Writes the image to the specified file. ImageMagick
 * determines image format from the prefix or extension.
 * 
 * WriteImages generates multiple output files if necessary
 * (or when requested). When adjoin is set to false, the filename is
 * expected to include a printf-style formatting string for the frame
 * number (e.g. "image%02d.png").
 * 
 * If an image format is selected which is capable of supporting
 * fewer colors than the original image or quantization has been
 * requested, the original image will be quantized to fewer colors.
 * Use a copy of the original if this is a problem.
 * 
 * Params:
 *     images   = Images to write.
 *     filename = The file name to write to.
 *     adjoin   = Join images into a single multi-image file.
 */
void writeImages(Image[] images, string filename, bool adjoin = true)
{
	linkImages(images);
	scope(exit) unlinkImages(images);

	images[0].options.adjoin = adjoin;

	WriteImages(images[0].options.imageInfo, images[0].imageRef, toStringz(filename), DMagickExceptionInfo());
}

/**
 * Turn an ImageMagick image list into a D array.
 */
private Image[] imageListToArray(MagickCoreImage* imageList)
{
	Image[] images;

	do
	{
		images ~= new Image(imageList);

		imageList = imageList.next;
	}
	while ( imageList !is null );

	unlinkImages(images);

	return images;
}

/**
 * Create an ImageMagick ImageList.
 */
private void linkImages(Image[] images)
{
	for ( int i = 0; i < images.length; i++ )
	{
		if ( i > 0 )
			images[i].imageRef.previous = images[i-1].imageRef;

		if ( i < images.length-1 )
			images[i].imageRef.next = images[i+1].imageRef;
	}
}


/**
 * Actual implementation for ping.
 */
private Image[] ping(void[] blob, Options options)
{
	MagickCoreImage* image = 
		PingBlob(options.imageInfo, blob.ptr, blob.length, DMagickExceptionInfo());

	return imageListToArray(image);
}

/**
 * Actual implementation for files.
 */
private Image[] readImages(Options options)
{
	MagickCoreImage* image = ReadImage(options.imageInfo, DMagickExceptionInfo());

	return imageListToArray(image);
}

/**
 * Actual implementation for blobs.
 */
private Image[] readImages(void[] blob, Options options)
{
	MagickCoreImage* image = 
		BlobToImage(options.imageInfo, blob.ptr, blob.length, DMagickExceptionInfo());

	return imageListToArray(image);
}

/**
 * Destroy the ImageMagick ImageList.
 */
private void unlinkImages(Image[] images)
{
	foreach ( image; images )
	{
		image.imageRef.next = null;
		image.imageRef.previous = null;
	}
}
