module dmagick.c.deprecate;

import core.vararg;
import core.stdc.stdio;

import dmagick.c.cacheView;
import dmagick.c.colorspace;
import dmagick.c.constitute;
import dmagick.c.draw;
import dmagick.c.exception;
import dmagick.c.geometry;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;
import dmagick.c.pixel;
import dmagick.c.quantize;
import dmagick.c.quantum;
import dmagick.c.registry;
import dmagick.c.resample;
import dmagick.c.semaphore;

alias ptrdiff_t ssize_t;

deprecated extern(C)
{
	enum MagickLayerMethod
	{
		UndefinedMagickLayerMethod
	}

	alias MagickOffsetType ExtendedSignedIntegralType;
	alias MagickSizeType   ExtendedUnsignedIntegralType;
	alias MagickRealType   ExtendedRationalType;
	/// The Quantum depth ImageMagick / DMagick is compiled with.
	alias MagickQuantumDepth MAGICKCORE_QUANTUM_DEPTH;

	static if ( MagickLibVersion >= 0x689 )
	{
		enum MagickRealType MagickHuge    = 3.4e+38;
	}

	struct ViewInfo {}

	alias MagickBooleanType function(const(char)*, const MagickOffsetType, const MagickSizeType, ExceptionInfo*) MonitorHandler;

	struct ImageAttribute
	{
		char*
			key,
			value;

		MagickBooleanType
			compression;

		ImageAttribute*
			previous,
			next;
	}

	CacheView* CloseCacheView(CacheView*);
	CacheView* OpenCacheView(const(Image)*);

	char* AllocateString(const(char)*);
	char* InterpretImageAttributes(const(ImageInfo)*, Image*, const(char)*);
	char* PostscriptGeometry(const(char)*);
	char* TranslateText(const(ImageInfo)*, Image*, const(char)*);

	const(ImageAttribute)* GetImageAttribute(const(Image)*, const(char)*);
	const(ImageAttribute)* GetImageClippingPathAttribute(Image*);
	const(ImageAttribute)* GetNextImageAttribute(const(Image)*);

	const(IndexPacket)* AcquireCacheViewIndexes(const(CacheView)*);
	const(IndexPacket)* AcquireIndexes(const(Image)*);

	const(PixelPacket)* AcquirePixels(const(Image)*);
	const(PixelPacket)* AcquireCacheViewPixels(const(CacheView)*, const ssize_t, const ssize_t, const size_t, const size_t, ExceptionInfo*);
	const(PixelPacket)* AcquireImagePixels(const(Image)*, const ssize_t, const ssize_t, const size_t, const size_t, ExceptionInfo*);

	static if ( MagickLibVersion >= 0x673 )
	{
		FILE* OpenMagickStream(const(char)*, const(char)*);
	}

	Image* AllocateImage(const(ImageInfo)*);

	static if ( MagickLibVersion >= 0x661 )
	{
		Image* AverageImages(const(Image)*, ExceptionInfo*);
	}

	Image* ExtractSubimageFromImage(Image*, const(Image)*, ExceptionInfo*);
	Image* GetImageFromMagickRegistry(const(char)*, ssize_t* id, ExceptionInfo*);
	Image* GetImageList(const(Image)*, const ssize_t, ExceptionInfo*);
	Image* GetNextImage(const(Image)*);
	Image* GetPreviousImage(const(Image)*);
	Image* FlattenImages(Image*, ExceptionInfo*);

	static if ( MagickLibVersion >= 0x661 )
	{
		Image* MaximumImages(const(Image)*, ExceptionInfo*);
	}

	static if ( MagickLibVersion >= 0x669 )
	{
		Image* MedianFilterImage(const Image*, const double, ExceptionInfo*);
		Image* ModeImage(const(Image)*, const double, ExceptionInfo*);
	}

	static if ( MagickLibVersion >= 0x661 )
	{
		Image* MinimumImages(const(Image)*, ExceptionInfo*);
	}

	Image* MosaicImages(Image*, ExceptionInfo*);
	Image* PopImageList(Image**);

	static if ( MagickLibVersion >= 0x689 )
	{
		Image* RadialBlurImage(const(Image)*, const double, ExceptionInfo*);
		Image* RadialBlurImageChannel(const(Image)*, const ChannelType, const double, ExceptionInfo*);
	}

	static if ( MagickLibVersion >= 0x661 )
	{
		Image* RecolorImage(const(Image)*, const size_t, const(double)*, ExceptionInfo*);
	}

	static if ( MagickLibVersion >= 0x669 )
	{
		Image* ReduceNoiseImage(const(Image)*, const double, ExceptionInfo*);
	}

	Image* ShiftImageList(Image**);
	Image* SpliceImageList(Image*, const ssize_t, const size_t, const(Image)*, ExceptionInfo*);

	static if ( MagickLibVersion >= 0x665 )
	{
		Image* ZoomImage(const(Image)*, const size_t, const size_t, ExceptionInfo*);
	}

	IndexPacket* GetCacheViewIndexes(CacheView*);
	IndexPacket* GetIndexes(const(Image)*);
	IndexPacket  ValidateColormapIndex(Image*, const size_t);

	int GetImageGeometry(Image*, const(char)*, const uint, RectangleInfo*);
	int ParseImageGeometry(const(char)*, ssize_t*, ssize_t*, size_t*, size_t*);

	static if ( MagickLibVersion >= 0x690 )
	{
		int SystemCommand(const MagickBooleanType, const MagickBooleanType, const(char)*, ExceptionInfo*);
	}

	MagickBooleanType AcquireOneCacheViewPixel(const(CacheView)*, const ssize_t, const ssize_t, PixelPacket*, ExceptionInfo*);
	MagickBooleanType AcquireOneCacheViewVirtualPixel(const(CacheView)*, const VirtualPixelMethod, const ssize_t, const ssize_t, PixelPacket*, ExceptionInfo*);
	MagickBooleanType AffinityImage(const(QuantizeInfo)*, Image*, const(Image)*);
	MagickBooleanType AffinityImages(const(QuantizeInfo)*, Image*, const(Image)*);
	MagickBooleanType AllocateImageColormap(Image*, const size_t);
	MagickBooleanType ClipPathImage(Image*, const(char)*, const MagickBooleanType);
	MagickBooleanType CloneImageAttributes(Image*, const(Image)*);
	MagickBooleanType ColorFloodfillImage(Image*, const(DrawInfo)*, const PixelPacket, const ssize_t, const ssize_t, const PaintMethod);

	static if ( MagickLibVersion >= 0x689 )
	{
		MagickBooleanType ConstituteComponentGenesis();
	}

	MagickBooleanType DeleteImageAttribute(Image*, const(char)*);
	MagickBooleanType DeleteMagickRegistry(const ssize_t);
	MagickBooleanType DescribeImage(Image*, FILE*, const MagickBooleanType);
	MagickBooleanType FormatImageAttribute(Image*, const(char)*, const(char)*, ...);
	MagickBooleanType FormatImageAttributeList(Image*, const(char)*, const(char)*, va_list);

	static if ( MagickLibVersion >= 0x670 )
	{
		MagickBooleanType FormatImagePropertyList(Image*, const(char)*, const(char)*, va_list);
	}

	MagickBooleanType FuzzyColorCompare(const(Image)*, const(PixelPacket)*, const(PixelPacket)*);
	MagickBooleanType FuzzyOpacityCompare(const(Image)*, const(PixelPacket)*, const(PixelPacket)*);

	static if (MagickLibVersion >= 0x689)
	{
		MagickBooleanType InitializeModuleList(ExceptionInfo*);
		MagickBooleanType IsMagickInstantiated();
	}

	MagickBooleanType LevelImageColors(Image*, const ChannelType, const(MagickPixelPacket)*, const(MagickPixelPacket)*, const MagickBooleanType);

	static if ( MagickLibVersion >= 0x689 )
	{
		MagickBooleanType LoadMimeLists(const(char)*, ExceptionInfo*);
	}

	MagickBooleanType MagickMonitor(const(char)*, const MagickOffsetType, const MagickSizeType, void*);
	MagickBooleanType MapImage(Image*, const(Image)*, const MagickBooleanType);
	MagickBooleanType MapImages(Image*, const(Image)*, const MagickBooleanType);
	MagickBooleanType MatteFloodfillImage(Image*, const PixelPacket, const Quantum, const ssize_t, const ssize_t, const PaintMethod);
	MagickBooleanType OpaqueImage(Image*, const PixelPacket, const PixelPacket);
	MagickBooleanType PaintFloodfillImage(Image*, const ChannelType, const(MagickPixelPacket)*, const ssize_t, const ssize_t, const(DrawInfo)*, const PaintMethod);
	MagickBooleanType PaintOpaqueImage(Image*, const(MagickPixelPacket)*, const(MagickPixelPacket)*);
	MagickBooleanType PaintOpaqueImageChannel(Image*, const ChannelType, const(MagickPixelPacket)*, const(MagickPixelPacket)*);
	MagickBooleanType PaintTransparentImage(Image*, const(MagickPixelPacket)*, const Quantum);
	MagickBooleanType SetExceptionInfo(ExceptionInfo*, ExceptionType);
	MagickBooleanType SetImageAttribute(Image*, const(char)*, const(char)*);
	MagickBooleanType SyncCacheViewPixels(CacheView*);
	MagickBooleanType SyncImagePixels(Image*);
	MagickBooleanType TransparentImage(Image*, const PixelPacket, const Quantum);

	MagickPixelPacket AcquireOneMagickPixel(const(Image)*, const ssize_t, const ssize_t, ExceptionInfo*);

	MonitorHandler GetMonitorHandler();
	MonitorHandler SetMonitorHandler(MonitorHandler);

	MagickOffsetType SizeBlob(Image* image);

	MagickPixelPacket InterpolatePixelColor(const(Image)*, CacheView*, const InterpolatePixelMethod, const double, const double, ExceptionInfo*);

	MagickStatusType ParseSizeGeometry(const(Image)*, const(char)*, RectangleInfo*);

	PixelPacket  AcquireOnePixel(const(Image)*, const ssize_t, const ssize_t, ExceptionInfo*);
	PixelPacket  AcquireOneVirtualPixel(const(Image)*, const VirtualPixelMethod, const ssize_t, const ssize_t, ExceptionInfo*);
	PixelPacket* GetCacheView(CacheView*, const ssize_t, const ssize_t, const size_t, const size_t);
	PixelPacket* GetCacheViewPixels(CacheView*, const ssize_t, const ssize_t, const size_t, const size_t);
	PixelPacket* GetImagePixels(Image*, const ssize_t, const ssize_t, const size_t, const size_t);
	PixelPacket  GetOnePixel(Image*, const ssize_t, const ssize_t);
	PixelPacket* GetPixels(const(Image)*);
	PixelPacket* SetCacheViewPixels(CacheView*, const ssize_t, const ssize_t, const size_t, const size_t);
	PixelPacket* SetImagePixels(Image*, const ssize_t, const ssize_t, const size_t, const size_t);

	size_t GetImageListSize(const(Image)*);
	size_t PopImagePixels(Image*, const QuantumType, ubyte*);
	size_t PushImagePixels(Image*, const QuantumType, const(byte)*);

	static if ( MagickLibVersion >= 0x670 )
	{
		ssize_t FormatMagickString(char*, const size_t, const(char)*, ...);
		ssize_t FormatMagickStringList(char*, const size_t, const(char)*, va_list);
	}

	ssize_t GetImageListIndex(const(Image)*);
	ssize_t SetMagickRegistry(const RegistryType, const(void)*, const size_t, ExceptionInfo*);

	uint ChannelImage(Image*, const ChannelType);
	uint ChannelThresholdImage(Image*, const(char)*);
	uint DispatchImage(const(Image)*, const ssize_t, const ssize_t, const size_t, const size_t, const(char)*, const StorageType, void*, ExceptionInfo*);
	uint FuzzyColorMatch(const(PixelPacket)*, const(PixelPacket)*, const double);
	uint GetNumberScenes(const(Image)*);
	uint GetMagickGeometry(const(char)*, ssize_t*, ssize_t*, size_t*, size_t*);
	uint IsSubimage(const(char)*, const uint);
	uint PushImageList(Image**, const(Image)*, ExceptionInfo*);
	uint QuantizationError(Image*);
	uint RandomChannelThresholdImage(Image*, const(char)*, const(char)*, ExceptionInfo*);
	uint SetImageList(Image**, const(Image)*, const ssize_t, ExceptionInfo*);
	uint TransformColorspace(Image*, const ColorspaceType);
	uint ThresholdImage(Image*, const double);
	uint ThresholdImageChannel(Image*, const(char)*);
	uint UnshiftImageList(Image**, const(Image)*, ExceptionInfo*);

	void* AcquireMemory(const size_t);

	static if ( MagickLibVersion >= 0x689 )
	{
		void AcquireSemaphoreInfo(SemaphoreInfo**);
	}

	void  AllocateNextImage(const(ImageInfo)*, Image*);

	static if ( MagickLibVersion >= 0x689 )
	{
		void ConstituteComponentTerminus();
	}

	void* CloneMemory(void*, const(void)*, const size_t);

	static if ( MagickLibVersion >= 0x655 )
	{
		void DestroyConstitute();
	}

	void  DestroyImageAttributes(Image*);
	void  DestroyImages(Image*);
	void  DestroyMagick();
	void  DestroyMagickRegistry();
	void* GetConfigureBlob(const(char)*, char*, size_t*, ExceptionInfo*);

	static if ( MagickLibVersion >= 0x689 )
	{
		void GetExceptionInfo(ExceptionInfo*);
	}

	void* GetMagickRegistry(const ssize_t, RegistryType*, size_t*, ExceptionInfo*);
	void  IdentityAffine(AffineMatrix*);
	void  LiberateMemory(void**);
	void  LiberateSemaphoreInfo(SemaphoreInfo**);
	void  FormatString(char*, const(char)*, ...);
	void  FormatStringList(char*, const(char)*, va_list);
	void  HSLTransform(const double, const double, const double, Quantum*, Quantum*, Quantum*);
	void  InitializeMagick(const(char)*);
	void  MagickIncarnate(const(char)*);
	void  ReacquireMemory(void**, const size_t);

	static if ( MagickLibVersion >= 0x689 )
	{
		void RelinquishSemaphoreInfo(SemaphoreInfo*);
	}

	void  ResetImageAttributeIterator(const(Image)*);
	void  SetCacheThreshold(const size_t);
	void  SetImage(Image*, const Quantum);
	void  Strip(char*);
	void  TemporaryFilename(char*);
	void  TransformHSL(const Quantum, const Quantum, const Quantum, double*, double*, double*);
}
