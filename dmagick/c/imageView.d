module dmagick.c.imageView;

import dmagick.c.exception;
import dmagick.c.geometry;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;
import dmagick.c.pixel;

alias ptrdiff_t ssize_t;

extern(C)
{
	struct ImageView {}

	alias MagickBooleanType function(const(ImageView)*, const(ImageView)*, ImageView*, const ssize_t, const int, void*) DuplexTransferImageViewMethod;
	alias MagickBooleanType function(const(ImageView)*, const ssize_t, const int, void*) GetImageViewMethod;
	alias MagickBooleanType function(ImageView*, const ssize_t, const int, void*) SetImageViewMethod;
	alias MagickBooleanType function(const(ImageView)*, ImageView*, const ssize_t, const int, void*) TransferImageViewMethod;
	alias MagickBooleanType function(ImageView*, const ssize_t, const int, void*) UpdateImageViewMethod;

	char* GetImageViewException(const(ImageView)*, ExceptionType*);

	const(IndexPacket)* GetImageViewVirtualIndexes(const(ImageView)*);

	const(PixelPacket)* GetImageViewVirtualPixels(const(ImageView)*);

	Image* GetImageViewImage(const(ImageView)*);

	ImageView* CloneImageView(const(ImageView)*);
	ImageView* DestroyImageView(ImageView*);
	ImageView* NewImageView(Image*);
	ImageView* NewImageViewRegion(Image*, const ssize_t, const ssize_t, const size_t, const size_t);

	IndexPacket* GetImageViewAuthenticIndexes(const(ImageView)*);

	MagickBooleanType DuplexTransferImageViewIterator(ImageView*, ImageView*, ImageView*, DuplexTransferImageViewMethod, void*);
	MagickBooleanType GetImageViewIterator(ImageView*, GetImageViewMethod, void*);
	MagickBooleanType IsImageView(const(ImageView)*);
	MagickBooleanType SetImageViewIterator(ImageView*, SetImageViewMethod, void*);
	MagickBooleanType TransferImageViewIterator(ImageView*, ImageView*, TransferImageViewMethod, void*);
	MagickBooleanType UpdateImageViewIterator(ImageView*, UpdateImageViewMethod, void*);

	PixelPacket* GetImageViewAuthenticPixels(const(ImageView)*);

	RectangleInfo GetImageViewExtent(const(ImageView)*);

	void SetImageViewDescription(ImageView*, const(char)*);

	static if ( MagickLibVersion >= 0x665 )
	{
		void SetImageViewThreads(ImageView*, const size_t);
	}
}
