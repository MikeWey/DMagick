module dmagick.c.decorate;

import dmagick.c.exception;
import dmagick.c.geometry;
import dmagick.c.image;
import dmagick.c.magickType;

alias ptrdiff_t ssize_t;

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

	Image* BorderImage(const(Image)*, const(RectangleInfo)*, ExceptionInfo*);
	Image* FrameImage(const(Image)*, const(FrameInfo)*, ExceptionInfo*);

	MagickBooleanType RaiseImage(Image*, const(RectangleInfo)*, const MagickBooleanType);
}
