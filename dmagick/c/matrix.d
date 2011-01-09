module dmagick.c.matrix;

import dmagick.c.magickType;

extern(C)
{
	double** AcquireMagickMatrix(const size_t, const size_t);
	double** RelinquishMagickMatrix(double**, const size_t);

	MagickBooleanType GaussJordanElimination(double**, double**, const size_t, const size_t);

	void LeastSquaresAddTerms(double**, double**, const(double)*, const(double)*, const size_t, const size_t);
}
