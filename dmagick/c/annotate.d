module dmagick.c.annotate;

import core.sys.posix.sys.types;

import dmagick.c.draw;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;

extern(C)
{
	static if ( MagickLibVersion >= 0x668 )
	{
		MagickBooleanType AnnotateComponentGenesis();
	}

	MagickBooleanType AnnotateImage(Image*, const(DrawInfo)*);
	MagickBooleanType GetMultilineTypeMetrics(Image*, const(DrawInfo)*, TypeMetric*);
	MagickBooleanType GetTypeMetrics(Image*, const(DrawInfo)*, TypeMetric*);

	ssize_t FormatMagickCaption(Image*, DrawInfo*, const MagickBooleanType, TypeMetric*, char**);

	static if ( MagickLibVersion >= 0x668 )
	{
		void AnnotateComponentTerminus();
	}
}
