module dmagick.c.montage;

import dmagick.c.exception;
import dmagick.c.geometry;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.pixel;

extern(C)
{
	enum MontageMode
	{
		UndefinedMode,
		FrameMode,
		UnframeMode,
		ConcatenateMode
	}

	struct MontageInfo
	{
		char*
			geometry,
			tile,
			title,
			frame,
			texture,
			font;

		double
			pointsize;

		size_t
			border_width;

		MagickBooleanType
			shadow;

		PixelPacket
			fill,
			stroke,
			background_color,
			border_color,
			matte_color;

		GravityType
			gravity;

		char[MaxTextExtent]
			filename;

		MagickBooleanType
			ddebug;

		size_t
			signature;
	}

	Image* MontageImages(const(Image)*, const(MontageInfo)*, ExceptionInfo*);
	Image* MontageImageList(const(ImageInfo)*, const(MontageInfo)*, const(Image)*, ExceptionInfo*);

	MontageInfo* CloneMontageInfo(const(ImageInfo)*, const(MontageInfo)*);
	MontageInfo* DestroyMontageInfo(MontageInfo*);

	void GetMontageInfo(const(ImageInfo)*, MontageInfo*);
}
