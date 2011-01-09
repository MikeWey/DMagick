module dmagick.c.xwindow;

import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	struct XImportInfo
	{
	  MagickBooleanType
		frame,
		borders,
		screen,
		descend,
		silent;
	}

	Image* XImportImage(const(ImageInfo)*, XImportInfo*);

	void XGetImportInfo(XImportInfo*);
}
