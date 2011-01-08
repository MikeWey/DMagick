module dmagick.c.sheer;

import dmagick.c.exception;
import dmagick.c.geometry;
import dmagick.c.image;

extern(C)
{
	Image* AffineTransformImage(const Image*, const AffineMatrix*, ExceptionInfo*);
	Image* DeskewImage(const Image*, const double, ExceptionInfo*);
	Image* RotateImage(const Image*, const double, ExceptionInfo*);
	Image* ShearImage(const Image*, const double, const double, ExceptionInfo*);
}
