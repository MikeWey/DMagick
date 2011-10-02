module dmagick.c.layer;

import dmagick.c.composite;
import dmagick.c.exception;
import dmagick.c.image;

alias ptrdiff_t ssize_t;

extern(C)
{
	enum DisposeType
	{
		UnrecognizedDispose,
		UndefinedDispose = 0,
		NoneDispose = 1,
		BackgroundDispose = 2,
		PreviousDispose = 3
	}

	enum ImageLayerMethod
	{
		UndefinedLayer,
		CoalesceLayer,
		CompareAnyLayer,
		CompareClearLayer,
		CompareOverlayLayer,
		DisposeLayer,
		OptimizeLayer,
		OptimizeImageLayer,
		OptimizePlusLayer,
		OptimizeTransLayer,
		RemoveDupsLayer,
		RemoveZeroLayer,
		CompositeLayer,
		MergeLayer,
		FlattenLayer,
		MosaicLayer,
		TrimBoundsLayer
	}

	Image* CoalesceImages(const(Image)*, ExceptionInfo*);
	Image* DisposeImages(const(Image)*, ExceptionInfo*);
	Image* CompareImageLayers(const(Image)*, const ImageLayerMethod, ExceptionInfo*);
	Image* DeconstructImages(const(Image)*, ExceptionInfo*);
	Image* MergeImageLayers(Image*, const ImageLayerMethod, ExceptionInfo*);
	Image* OptimizeImageLayers(const(Image)*, ExceptionInfo*);
	Image* OptimizePlusImageLayers(const(Image)*, ExceptionInfo*);

	void CompositeLayers(Image*, const CompositeOperator, Image*, const ssize_t, const ssize_t, ExceptionInfo*);
	void OptimizeImageTransparency(const(Image)*, ExceptionInfo*);
	void RemoveDuplicateLayers(Image**, ExceptionInfo*);
	void RemoveZeroDelayLayers(Image**, ExceptionInfo*);
}
