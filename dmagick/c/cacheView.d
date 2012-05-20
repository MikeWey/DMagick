module dmagick.c.cacheView;

import dmagick.c.colorspace;
import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;
import dmagick.c.pixel;

alias ptrdiff_t ssize_t;

extern(C)
{
	/**
	 * Specify contents of virtual pixels.
	 */
	enum VirtualPixelMethod
	{
		/** */
		UndefinedVirtualPixelMethod,

		/**
		 * The area surrounding the image is the background color.
		 */
		BackgroundVirtualPixelMethod,
		
		/** */
		ConstantVirtualPixelMethod,
		
		/**
		 * Non-random 32x32 dithered pattern.
		 */
		DitherVirtualPixelMethod,
		
		/**
		 * Extend the edge pixel toward infinity.
		 */
		EdgeVirtualPixelMethod,
		
		/**
		 * Mirror tile the image.
		 */
		MirrorVirtualPixelMethod,
		
		/**
		 * Choose a random pixel from the image.
		 */
		RandomVirtualPixelMethod,
		
		/**
		 * Tile the image.
		 */
		TileVirtualPixelMethod,
		
		/**
		 * The area surrounding the image is transparent blackness.
		 */
		TransparentVirtualPixelMethod,
		
		/** */
		MaskVirtualPixelMethod,
		
		/**
		 * The area surrounding the image is black.
		 */
		BlackVirtualPixelMethod,
		
		/**
		 * The area surrounding the image is gray.
		 */
		GrayVirtualPixelMethod,
		
		/**
		 * The area surrounding the image is white.
		 */
		WhiteVirtualPixelMethod,
		
		/**
		 * Horizontally tile the image, background color above/below.
		 */
		HorizontalTileVirtualPixelMethod,
		
		/**
		 * Vertically tile the image, sides are background color.
		 */
		VerticalTileVirtualPixelMethod,
		
		/**
		 * Horizontally tile the image and replicate the side edge pixels.
		 */
		HorizontalTileEdgeVirtualPixelMethod,
		
		/**
		 * Vertically tile the image and replicate the side edge pixels.
		 */
		VerticalTileEdgeVirtualPixelMethod,
		
		/**
		 * Alternate squares with image and background color.
		 */
		CheckerTileVirtualPixelMethod
	}

	struct CacheView {}

	static if ( MagickLibVersion >= 0x677 )
	{
		CacheView* AcquireAuthenticCacheView(const(Image)*, ExceptionInfo*);
	}

	CacheView* AcquireCacheView(const(Image)*);

	static if ( MagickLibVersion >= 0x677 )
	{
		CacheView* AcquireVirtualCacheView(const(Image)*, ExceptionInfo*);
	}

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

	static if ( MagickLibVersion >= 0x670 )
	{
		size_t GetCacheViewChannels(const(CacheView)*);
	}

	PixelPacket* GetCacheViewAuthenticPixelQueue(CacheView*);
	PixelPacket* GetCacheViewAuthenticPixels(CacheView*, const ssize_t, const ssize_t, const size_t, const size_t, ExceptionInfo*);
	PixelPacket* QueueCacheViewAuthenticPixels(CacheView*, const ssize_t, const ssize_t, const size_t, const size_t, ExceptionInfo*);
}
