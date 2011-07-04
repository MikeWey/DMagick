module dmagick.c.cacheView;

import core.sys.posix.sys.types;

import dmagick.c.colorspace;
import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.pixel;

extern(C)
{
	enum VirtualPixelMethod
	{
		UndefinedVirtualPixelMethod,
		BackgroundVirtualPixelMethod,
		ConstantVirtualPixelMethod,
		DitherVirtualPixelMethod,
		EdgeVirtualPixelMethod,
		MirrorVirtualPixelMethod,
		RandomVirtualPixelMethod,
		TileVirtualPixelMethod,
		TransparentVirtualPixelMethod,
		MaskVirtualPixelMethod,
		BlackVirtualPixelMethod,
		GrayVirtualPixelMethod,
		WhiteVirtualPixelMethod,
		HorizontalTileVirtualPixelMethod,
		VerticalTileVirtualPixelMethod,
		HorizontalTileEdgeVirtualPixelMethod,
		VerticalTileEdgeVirtualPixelMethod,
		CheckerTileVirtualPixelMethod
	}

	struct CacheView {}

	CacheView* AcquireCacheView(const(Image)*);
	CacheView* CloneCacheView(const(CacheView)*);
	CacheView* DestroyCacheView(CacheView*);

	ClassType GetCacheViewStorageClass(const(CacheView)*);

	ColorspaceType GetCacheViewColorspace(const(CacheView)*);

	const(IndexPacket)* GetCacheViewVirtualIndexQueue(const(CacheView)*);

	const(PixelPacket)* GetCacheViewVirtualPixels(const(CacheView)*, const ssize_t, const ssize_t, const size_t, const size_t, ExceptionInfo*);
	const(PixelPacket)* GetCacheViewVirtualPixelQueue(const(CacheView)*);

	ExceptionInfo* GetCacheViewException(const(CacheView)*);

	IndexPacket* GetCacheViewAuthenticIndexQueue(CacheView*);

	MagickBooleanType GetOneCacheViewVirtualPixel(const(CacheView)*, const ssize_t, const ssize_t, PixelPacket*, ExceptionInfo*);
	MagickBooleanType GetOneCacheViewVirtualMethodPixel(const(CacheView)*, const VirtualPixelMethod, const ssize_t, const ssize_t, PixelPacket*, ExceptionInfo*);
	MagickBooleanType GetOneCacheViewAuthenticPixel(const(CacheView)*, const ssize_t, const ssize_t, PixelPacket*, ExceptionInfo*);
	MagickBooleanType SetCacheViewStorageClass(CacheView*, const ClassType);
	MagickBooleanType SetCacheViewVirtualPixelMethod(CacheView*, const VirtualPixelMethod);
	MagickBooleanType SyncCacheViewAuthenticPixels(CacheView*, ExceptionInfo*);

	MagickSizeType GetCacheViewExtent(const(CacheView)*);

	size_t GetCacheViewChannels(const(CacheView)*);

	PixelPacket* GetCacheViewAuthenticPixelQueue(CacheView*);
	PixelPacket* GetCacheViewAuthenticPixels(CacheView*, const ssize_t, const ssize_t, const size_t, const size_t, ExceptionInfo*);
	PixelPacket* QueueCacheViewAuthenticPixels(CacheView*, const ssize_t, const ssize_t, const size_t, const size_t, ExceptionInfo*);
}
