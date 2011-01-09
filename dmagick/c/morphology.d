module dmagick.c.morphology;

import core.sys.posix.sys.types;

import dmagick.c.exception;
import dmagick.c.geometry;
import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	enum KernelInfoType
	{
		UndefinedKernel,
		UnityKernel,
		GaussianKernel,
		DoGKernel,
		LoGKernel,
		BlurKernel,
		CometKernel,
		LaplacianKernel,
		SobelKernel,
		FreiChenKernel,
		RobertsKernel,
		PrewittKernel,
		CompassKernel,
		KirschKernel,
		DiamondKernel,
		SquareKernel,
		RectangleKernel,
		DiskKernel,
		PlusKernel,
		CrossKernel,
		RingKernel,
		PeaksKernel,
		EdgesKernel,
		CornersKernel,
		ThinDiagonalsKernel,
		LineEndsKernel,
		LineJunctionsKernel,
		RidgesKernel,
		ConvexHullKernel,
		SkeletonKernel,
		ChebyshevKernel,
		ManhattanKernel,
		EuclideanKernel,
		UserDefinedKernel
	}

	enum MorphologyMethod
	{
		UndefinedMorphology,

		ConvolveMorphology,
		CorrelateMorphology,

		ErodeMorphology,
		DilateMorphology,
		ErodeIntensityMorphology,
		DilateIntensityMorphology,
		DistanceMorphology,

		OpenMorphology,
		CloseMorphology,
		OpenIntensityMorphology,
		CloseIntensityMorphology,
		SmoothMorphology,

		EdgeInMorphology,
		EdgeOutMorphology,
		EdgeMorphology,
		TopHatMorphology,
		BottomHatMorphology,

		HitAndMissMorphology,
		ThinningMorphology,
		ThickenMorphology
	}

	struct KernelInfo
	{
		KernelInfoType
			type;

		size_t
			width,
			height;

		ssize_t
			x,
			y;

		double* values;

		double
			minimum,
			maximum,
			negative_range,
			positive_range,
			angle;

		KernelInfo*
			next;

		size_t
			signature;
	}


	KernelInfo* AcquireKernelInfo(const(char)*);
	KernelInfo* AcquireKernelBuiltIn(const KernelInfoType, const(GeometryInfo)*);
	KernelInfo* CloneKernelInfo(const(KernelInfo)*);
	KernelInfo* DestroyKernelInfo(KernelInfo*);

	Image* MorphologyImage(const(Image)*, const MorphologyMethod, const ssize_t, const(KernelInfo)*, ExceptionInfo*);
	Image* MorphologyImageChannel(const(Image)*, const ChannelType, const MorphologyMethod, const ssize_t, const(KernelInfo)*, ExceptionInfo*);

	void ScaleGeometryKernelInfo(KernelInfo*, const(char)*);
	void ShowKernelInfo(KernelInfo*);
}
