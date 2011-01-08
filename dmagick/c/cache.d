module dmagick.c.cache;

import core.sys.posix.sys.types;

import dmagick.c.image;
import dmagick.c.pixel;
import dmagick.c.exception;
import dmagick.c.magickType;
import dmagick.c.cacheView;

extern(C)
{
	const(IndexPacket*) GetVirtualIndexQueue(const Image*);

	const(PixelPacket*) GetVirtualPixels(const Image*, const ssize_t, const ssize_t, const size_t, const size_t, ExceptionInfo*);
	const(PixelPacket*) GetVirtualPixelQueue(const Image*);

	const(void*) AcquirePixelCachePixels(const Image*, MagickSizeType*, ExceptionInfo*);

	IndexPacket* GetAuthenticIndexQueue(const Image*);

	MagickBooleanType CacheComponentGenesis();
	MagickBooleanType GetOneVirtualMagickPixel(const Image*, const ssize_t, const ssize_t, MagickPixelPacket*, ExceptionInfo*);
	MagickBooleanType GetOneVirtualPixel(const Image*, const ssize_t, const ssize_t, PixelPacket*, ExceptionInfo*);
	MagickBooleanType GetOneVirtualMethodPixel(const Image*, const VirtualPixelMethod, const ssize_t, const ssize_t, PixelPacket*, ExceptionInfo*);
	MagickBooleanType GetOneAuthenticPixel(Image*, const ssize_t, const ssize_t, PixelPacket*, ExceptionInfo*);
	MagickBooleanType PersistPixelCache(Image*, const char*, const MagickBooleanType, MagickOffsetType*, ExceptionInfo*);
	MagickBooleanType SyncAuthenticPixels(Image*, ExceptionInfo*);

	MagickSizeType GetImageExtent(const Image*);

	PixelPacket* GetAuthenticPixels(Image*, const ssize_t, const ssize_t, const size_t, const size_t, ExceptionInfo*);
	PixelPacket* GetAuthenticPixelQueue(const Image*);
	PixelPacket* QueueAuthenticPixels(Image*, const ssize_t, const ssize_t, const size_t, const size_t, ExceptionInfo*);

	VirtualPixelMethod GetPixelCacheVirtualMethod(const Image*);
	VirtualPixelMethod SetPixelCacheVirtualMethod(const Image*, const VirtualPixelMethod);

	void  CacheComponentTerminus();
	void* GetPixelCachePixels(Image*, MagickSizeType*, ExceptionInfo*);
}
