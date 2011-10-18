module dmagick.c.annotate;

import dmagick.c.draw;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;

alias ptrdiff_t ssize_t;

extern(C)
{
	static if ( MagickLibVersion >= 0x668 )
	{
		MagickBooleanType AnnotateComponentGenesis();
	}

	MagickBooleanType AnnotateImage(Image*, const(DrawInfo)*);
	MagickBooleanType GetMultilineTypeMetrics(Image*, const(DrawInfo)*, TypeMetric*);
	MagickBooleanType GetTypeMetrics(Image*, const(DrawInfo)*, TypeMetric*);

	static if ( MagickLibVersion >= 0x665 )
	{
		ssize_t FormatMagickCaption(Image*, DrawInfo*, const MagickBooleanType, TypeMetric*, char**);
	}
	else
	{
		ssize_t FormatMagickCaption(Image*, DrawInfo*, TypeMetric*, char**);
	}

	static if ( MagickLibVersion >= 0x668 )
	{
		void AnnotateComponentTerminus();
	}
}
