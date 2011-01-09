module dmagick.c.blob;

import core.stdc.stdio;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.stream;

extern(C)
{
	enum MapMode
	{
		ReadMode,
		WriteMode,
		IOMode
	}

	FILE* GetBlobFileHandle(const(Image)*);

	Image* BlobToImage(const(ImageInfo)*, const(void)*, const size_t, ExceptionInfo*);
	Image* PingBlob(const(ImageInfo)*, const(void)*, const size_t, ExceptionInfo*);

	MagickBooleanType BlobToFile(char*, const(void)*, const size_t, ExceptionInfo*);
	MagickBooleanType FileToImage(Image*, const(char)*);
	MagickBooleanType GetBlobError(const(Image)*);
	MagickBooleanType ImageToFile(Image*, char*, ExceptionInfo*);
	MagickBooleanType InjectImageBlob(const(ImageInfo)*, Image*, Image*, const(char)*, ExceptionInfo*);
	MagickBooleanType IsBlobExempt(const(Image)*);
	MagickBooleanType IsBlobSeekable(const(Image)*);
	MagickBooleanType IsBlobTemporary(const(Image)*);

	MagickSizeType GetBlobSize(const(Image)*);

	StreamHandler GetBlobStreamHandler(const(Image)*);

	ubyte* FileToBlob(const(char)*, const size_t, size_t*, ExceptionInfo*);
	ubyte* GetBlobStreamData(const(Image)*);
	ubyte* ImageToBlob(const(ImageInfo)*, Image*, size_t*, ExceptionInfo*);
	ubyte* ImagesToBlob(const(ImageInfo)*, Image*, size_t*, ExceptionInfo*);

	void DestroyBlob(Image*);
	void DuplicateBlob(Image*, const(Image)*);
	void SetBlobExempt(Image*, const MagickBooleanType);
}
