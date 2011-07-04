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
		UndefinedKernel,    /* equivelent to UnityKernel */
		UnityKernel,        /* The no-op or 'original image' kernel */
		GaussianKernel,     /* Convolution Kernels, Gaussian Based */
		DoGKernel,
		LoGKernel,
		BlurKernel,
		CometKernel,
		LaplacianKernel,    /* Convolution Kernels, by Name */
		SobelKernel,
		FreiChenKernel,
		RobertsKernel,
		PrewittKernel,
		CompassKernel,
		KirschKernel,
		DiamondKernel,      /* Shape Kernels */
		SquareKernel,
		RectangleKernel,
		OctagonKernel,
		DiskKernel,
		PlusKernel,
		CrossKernel,
		RingKernel,
		PeaksKernel,        /* Hit And Miss Kernels */
		EdgesKernel,
		CornersKernel,
		ThinDiagonalsKernel,
		LineEndsKernel,
		LineJunctionsKernel,
		RidgesKernel,
		ConvexHullKernel,
		SkeletonKernel,
		ChebyshevKernel,    /* Distance Measuring Kernels */
		ManhattanKernel,
		EuclideanKernel,
		UserDefinedKernel   /* User Specified Kernel Array */
	}

	enum MorphologyMethod
	{
		UndefinedMorphology,

		/* Convolve / Correlate weighted sums */
		ConvolveMorphology,          /* Weighted Sum with reflected kernel */
		CorrelateMorphology,         /* Weighted Sum using a sliding window */

		/* Low-level Morphology methods */
		ErodeMorphology,             /* Minimum Value in Neighbourhood */
		DilateMorphology,            /* Maximum Value in Neighbourhood */
		ErodeIntensityMorphology,    /* Pixel Pick using GreyScale Erode */
		DilateIntensityMorphology,   /* Pixel Pick using GreyScale Dialate */
		DistanceMorphology,          /* Add Kernel Value, take Minimum */

		/* Second-level Morphology methods */
		OpenMorphology,              /* Dilate then Erode */
		CloseMorphology,             /* Erode then Dilate */
		OpenIntensityMorphology,     /* Pixel Pick using GreyScale Open */
		CloseIntensityMorphology,    /* Pixel Pick using GreyScale Close */
		SmoothMorphology,            /* Open then Close */

		/* Difference Morphology methods */
		EdgeInMorphology,            /* Dilate difference from Original */
		EdgeOutMorphology,           /* Erode difference from Original */
		EdgeMorphology,              /* Dilate difference with Erode */
		TopHatMorphology,            /* Close difference from Original */
		BottomHatMorphology,         /* Open difference from Original */

		/* Recursive Morphology methods */
		HitAndMissMorphology,        /* Foreground/Background pattern matching */
		ThinningMorphology,          /* Remove matching pixels from image */
		ThickenMorphology,           /* Add matching pixels from image */

		/* Experimental Morphology methods */
		VoronoiMorphology
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
