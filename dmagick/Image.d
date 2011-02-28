/**
 * The image
 *
 * Copyright: Mike Wey 2011
 * License:   To be determined
 * Authors:   Mike Wey
 */

module dmagick.Image;

import dmagick.Exception;
import dmagick.Options;
import dmagick.Utils;

import dmagick.c.constitute;
import dmagick.c.exception;
import dmagick.c.image;


class Image
{
	alias dmagick.c.image.Image MagickCoreImage;
	alias RefCounted!( DestroyImage, MagickCoreImage ) ImageRef;

	ImageRef imageRef;
	Options options;

	this()
	{
		options = new Options();
		imageRef = ImageRef(AcquireImage(options.imageInfo));
	}

	this(MagickCoreImage* image)
	{
		options = new Options();
		imageRef = ImageRef(image);
	}

	this(string filename)
	{
		options = new Options();
		read(filename);
	}

	this(Geometry size, Color color)
	{
		options = new Options();
		options.size = size;

		//Use read to create a cnavas with the spacified color.
		read( "canvas:"~ color.toString() );
	}

	void read(string filename)
	{
		options.filename = filename;

		ExceptionInfo* exception = AcquireExceptionInfo();
		MagickCoreImage* image = ReadImage(options.imageInfo, exception);

		DMagickException.throwException(exception);

		imageRef = ImageRef(image);
		DestroyExceptionInfo(exception);
	}
}
