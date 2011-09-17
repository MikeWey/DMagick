/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 * 
 * This module contains functions that operate on a array or list of images.
 */

module dmagick.Array;

import dmagick.Exception;
import dmagick.Geometry;
import dmagick.Image;
import dmagick.Options;

import dmagick.c.blob;
import dmagick.c.constitute;
import dmagick.c.image : MagickCoreImage = Image;

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
 * Actual implementation for files.
 */
private Image[] readImages(Options options)
{
	Image[] images;

	MagickCoreImage* image = ReadImage(options.imageInfo, DMagickExceptionInfo());

	do
	{
		images ~= new Image(image);

		image = image.next;
	}
	while ( image !is null )

	return images;
}

/**
 * Actual implementation for blobs.
 */
private Image[] readImages(void[] blob, Options options)
{
	Image[] images;

	MagickCoreImage* image = 
		BlobToImage(options.imageInfo, blob.ptr, blob.length, DMagickExceptionInfo());

	do
	{
		images ~= new Image(image);

		image = image.next;
	}
	while ( image !is null )

	unlinkImages(images);

	return images;
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
