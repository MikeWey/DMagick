module dmagick.c.property;

import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	char* GetNextImageProperty(const(Image)*);
	char* InterpretImageProperties(const(ImageInfo)*, Image*, const(char)*);
	char* RemoveImageProperty(Image*, const(char)*);

	const(char)* GetImageProperty(const(Image)*, const(char)*);
	const(char)* GetMagickProperty(const(ImageInfo)*, Image*, const(char)*);

	MagickBooleanType CloneImageProperties(Image*, const(Image)*);
	MagickBooleanType DefineImageProperty(Image*, const(char)*);
	MagickBooleanType DeleteImageProperty(Image*, const(char)*);
	MagickBooleanType FormatImageProperty(Image*, const(char)*, const(char)*, ...);
	MagickBooleanType SetImageProperty(Image*, const(char)*, const(char)*);

	void DestroyImageProperties(Image*);
	void ResetImagePropertyIterator(const(Image)*);
}
