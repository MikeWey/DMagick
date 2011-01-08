module dmagick.c.gem;

import dmagick.c.geometry;
import dmagick.c.magickType;
import dmagick.c.fx;
import dmagick.c.random;

extern(C)
{
	double ExpandAffine(const AffineMatrix*);
	double GenerateDifferentialNoise(RandomInfo*, const Quantum, const NoiseType, const MagickRealType);

	size_t GetOptimalKernelWidth(const double, const double);
	size_t GetOptimalKernelWidth1D(const double, const double);
	size_t GetOptimalKernelWidth2D(const double, const double);

	void ConvertHSBToRGB(const double, const double, const double, Quantum*, Quantum*, Quantum*);
	void ConvertHSLToRGB(const double, const double, const double, Quantum*, Quantum*, Quantum*);
	void ConvertHWBToRGB(const double, const double, const double, Quantum*, Quantum *,Quantum*);
	void ConvertRGBToHSB(const Quantum, const Quantum, const Quantum, double*, double*, double*);
	void ConvertRGBToHSL(const Quantum, const Quantum, const Quantum, double*, double*, double*);
	void ConvertRGBToHWB(const Quantum, const Quantum, const Quantum, double*, double*, double*);
}
