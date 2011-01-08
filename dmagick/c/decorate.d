module dmagick.c.decorate;

import core.sys.posix.sys.types;

import dmagick.c.exception;
import dmagick.c.geometry;
import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	struct FrameInfo
	{
		size_t
			width,
			height;

		ssize_t
			x,
			y,
			inner_bevel,
			outer_bevel;
	}

	Image* BorderImage(const Image*, const RectangleInfo*, ExceptionInfo*);
	Image* FrameImage(const Image*, const FrameInfo*, ExceptionInfo*);

	MagickBooleanType RaiseImage(Image*, const RectangleInfo*, const MagickBooleanType);
}
