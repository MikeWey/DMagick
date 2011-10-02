module dmagick.c.paint;

import dmagick.c.draw;
import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.pixel;

alias ptrdiff_t ssize_t;

extern(C)
{
	Image* OilPaintImage(const(Image)*, const double, ExceptionInfo*);

	MagickBooleanType FloodfillPaintImage(Image*, const ChannelType, const(DrawInfo)*, const(MagickPixelPacket)*, const ssize_t, const ssize_t, const MagickBooleanType);
	MagickBooleanType GradientImage(Image*, const GradientType, const SpreadMethod, const(PixelPacket)*, const(PixelPacket)*);
	MagickBooleanType OpaquePaintImage(Image*, const(MagickPixelPacket)*, const(MagickPixelPacket)*, const MagickBooleanType);
	MagickBooleanType OpaquePaintImageChannel(Image*, const ChannelType, const(MagickPixelPacket)*, const(MagickPixelPacket)*, const MagickBooleanType);
	MagickBooleanType TransparentPaintImage(Image*, const(MagickPixelPacket)*, const Quantum, const MagickBooleanType);
	MagickBooleanType TransparentPaintImageChroma(Image*, const(MagickPixelPacket)*, const(MagickPixelPacket)*, const Quantum, const MagickBooleanType);
}
