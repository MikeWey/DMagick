module dmagick.Options;

import dmagick.c.draw;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.memory;
import dmagick.c.quantize;

class Options
{
	ImageInfo*    imageInfo;
	QuantizeInfo* quantizeInfo;
	DrawInfo*     drawInfo;

	this()
	{
		imageInfo = cast(ImageInfo*)AcquireMagickMemory(ImageInfo.sizeof);
		quantizeInfo = cast(QuantizeInfo*)AcquireMagickMemory(QuantizeInfo.sizeof);
		drawInfo = cast(DrawInfo*)AcquireMagickMemory(DrawInfo.sizeof);

	}

	this(const(ImageInfo)* imageInfo, const(QuantizeInfo)* quantizeInfo, const(DrawInfo)* drawInfo)
	{
		this.imageInfo = CloneImageInfo(imageInfo);
		this.quantizeInfo = CloneQuantizeInfo(quantizeInfo);
		this.drawInfo = CloneDrawInfo(imageInfo, drawInfo);
	}

	~this()
	{
		imageInfo = DestroyImageInfo(imageInfo);
		quantizeInfo = DestroyQuantizeInfo(quantizeInfo);
		drawInfo = DestroyDrawInfo(drawInfo);
	}

	private void copyString(ref char[MaxTextExtent] field, string str)
	{
		if ( str.length >= MaxTextExtent )
			throw new Exception("text is to long"); //TODO: a proper exception.

		field[0 .. str.length] = str;
		field[str.length] = '\0';
	}
}
