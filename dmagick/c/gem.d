module dmagick.c.gem;

import dmagick.c.geometry;
import dmagick.c.magickType;
import dmagick.c.magickVersion;
import dmagick.c.fx;
import dmagick.c.random;

extern(C)
{
	double ExpandAffine(const(AffineMatrix)*);
	double GenerateDifferentialNoise(RandomInfo*, const Quantum, const NoiseType, const MagickRealType);

	size_t GetOptimalKernelWidth(const double, const double);
	size_t GetOptimalKernelWidth1D(const double, const double);
	size_t GetOptimalKernelWidth2D(const double, const double);

	static if (MagickLibVersion >= 0x679)
	{
		void ConvertHCLToRGB(const double, const double, const double, Quantum*, Quantum*, Quantum*);
	}

	static if (MagickLibVersion >= 0x686)
	{
		void ConvertHCLpToRGB(const double, const double, const double, Quantum*, Quantum*, Quantum*);
		void ConvertHSIToRGB(const double, const double, const double, Quantum*, Quantum*, Quantum*);
		void ConvertHSVToRGB(const double, const double, const double, Quantum*, Quantum*, Quantum*);
	}

	void ConvertHSBToRGB(const double, const double, const double, Quantum*, Quantum*, Quantum*);
	void ConvertHSLToRGB(const double, const double, const double, Quantum*, Quantum*, Quantum*);
	void ConvertHWBToRGB(const double, const double, const double, Quantum*, Quantum*, Quantum*);

	static if ( MagickLibVersion >= 0x685 )
	{
		void ConvertLCHabToRGB(const double, const double, const double, Quantum*, Quantum*, Quantum*);
		void ConvertLCHuvToRGB(const double, const double, const double, Quantum*, Quantum*, Quantum*);
	}

	static if (MagickLibVersion >= 0x679)
	{
		void ConvertRGBToHCL(const Quantum, const Quantum, const Quantum, double*, double*, double*);
	}

	static if (MagickLibVersion >= 0x686)
	{
		void ConvertRGBToHCLp( const Quantum, const Quantum, const Quantum, double*, double*, double*);
		void ConvertRGBToHSI( const Quantum, const Quantum, const Quantum, double*, double*, double*);
		void ConvertRGBToHSV( const Quantum, const Quantum, const Quantum, double*, double*, double*);
	}

	void ConvertRGBToHSB(const Quantum, const Quantum, const Quantum, double*, double*, double*);
	void ConvertRGBToHSL(const Quantum, const Quantum, const Quantum, double*, double*, double*);
	void ConvertRGBToHWB(const Quantum, const Quantum, const Quantum, double*, double*, double*);

	static if ( MagickLibVersion >= 0x685 )
	{
		void ConvertRGBToLCHab(const Quantum, const Quantum, const Quantum, double*, double*, double*);
		void ConvertRGBToLCHuv(const Quantum, const Quantum, const Quantum, double*, double*, double*);
	}
}
