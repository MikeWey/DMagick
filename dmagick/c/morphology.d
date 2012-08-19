module dmagick.c.morphology;

import dmagick.c.exception;
import dmagick.c.geometry;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;

alias ptrdiff_t ssize_t;

extern(C)
{
	mixin(
	{
		string info = "enum KernelInfoType
		{
			UndefinedKernel,    /* equivelent to UnityKernel */";

			static if ( MagickLibVersion >= 0x662 )
			{
				info ~= "UnityKernel,        /* The no-op or 'original image' kernel */";
			}

			info ~= "GaussianKernel,     /* Convolution Kernels, Gaussian Based */";

			static if ( MagickLibVersion >= 0x662 )
			{
				info ~= "DoGKernel,
				         LoGKernel,";
			}

			info ~= "BlurKernel,";

			static if ( MagickLibVersion == 0x662 )
			{
				info ~= "DOBKernel,";
			}

			info ~= "CometKernel,
			         LaplacianKernel,    /* Convolution Kernels, by Name */";

			static if ( MagickLibVersion < 0x662 )
			{
				info ~= "DoGKernel,
				         LoGKernel,
				         RectangleKernel      /* Shape Kernels */,
				         SquareKernel,
				         DiamondKernel,";
			}

			static if ( MagickLibVersion >= 0x662 )
			{
				info ~= "SobelKernel,
				         FreiChenKernel,
				         RobertsKernel,
				         PrewittKernel,
				         CompassKernel,
				         KirschKernel,
				         DiamondKernel,     /* Shape Kernels */
				         SquareKernel,
				         RectangleKernel,";
			}

			static if ( MagickLibVersion >= 0x670 )
			{
				info ~= "OctagonKernel,";
			}

			info ~= "DiskKernel,
			         PlusKernel,";

			static if ( MagickLibVersion >= 0x662 )
			{
				info ~= "CrossKernel,
				         RingKernel,
				         PeaksKernel,      /* Hit And Miss Kernels */
				         EdgesKernel,
				         CornersKernel,";
			}

			static if ( MagickLibVersion < 0x663 )
			{
				info ~= "RidgesKernel";
			}
			static if ( MagickLibVersion >= 0x663 )
			{
				info ~= "ThinDiagonalsKernel,";
			}

			static if ( MagickLibVersion >= 0x662 )
			{
				info ~= "LineEndsKernel,
				         LineJunctionsKernel,";
			}

			static if ( MagickLibVersion >= 0x663 )
			{
				info ~= "RidgesKernel,";
			}

			static if ( MagickLibVersion >= 0x662 )
			{
				info ~= "ConvexHullKernel,
				         SkeletonKernel,";
			}

			info ~= "ChebyshevKernel,    /* Distance Measuring Kernels */
			         ManhattanKernel,
			         EuclideanKernel,
			         UserDefinedKernel,   /* User Specified Kernel Array */";

			static if ( MagickLibVersion >= 0x679 )
			{
				info ~= "BinomialKernel";
			}		
		info ~= "}";

		return info;
	}());

	mixin(
	{
		string method = "enum MorphologyMethod
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
			CloseIntensityMorphology,    /* Pixel Pick using GreyScale Close */";

			static if ( MagickLibVersion >= 0x662 )
			{
				method ~= "SmoothMorphology, /* Open then Close */";
			}

			method ~= "
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
			VoronoiMorphology,           /* distance matte channel copy nearest color */
			IterativeDistanceMorphology  /* Add Kernel Value, take Minimum */
		}";

		return method;
	}());

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
			positive_range;

		static if ( MagickLibVersion >= 0x662 )
		{
			double
				angle;

			KernelInfo*
				next;
		}

		size_t
			signature;
	}


	KernelInfo* AcquireKernelInfo(const(char)*);
	KernelInfo* AcquireKernelBuiltIn(const KernelInfoType, const(GeometryInfo)*);

	static if ( MagickLibVersion >= 0x661 )
	{
		KernelInfo* CloneKernelInfo(const(KernelInfo)*);
	}

	KernelInfo* DestroyKernelInfo(KernelInfo*);

	Image* MorphologyImage(const(Image)*, const MorphologyMethod, const ssize_t, const(KernelInfo)*, ExceptionInfo*);
	Image* MorphologyImageChannel(const(Image)*, const ChannelType, const MorphologyMethod, const ssize_t, const(KernelInfo)*, ExceptionInfo*);

	static if ( MagickLibVersion >= 0x662 )
	{
		void ScaleGeometryKernelInfo(KernelInfo*, const(char)*);
	}
	else static if ( MagickLibVersion == 0x661 )
	{
		void ScaleKernelInfo(KernelInfo*, const double, const GeometryFlags);
	}

	void ShowKernelInfo(const(KernelInfo)*);
}
