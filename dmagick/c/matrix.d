module dmagick.c.matrix;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;

alias ptrdiff_t ssize_t;

extern(C)
{
	struct MatrixInfo;

	double** AcquireMagickMatrix(const size_t, const size_t);
	double** RelinquishMagickMatrix(double**, const size_t);

	static if ( MagickLibVersion >= 0x690 )
	{
		Image* MatrixToImage(const(MatrixInfo)*, ExceptionInfo*);
	}

	MagickBooleanType GaussJordanElimination(double**, double**, const size_t, const size_t);

	static if ( MagickLibVersion >= 0x669 )
	{
		MagickBooleanType GetMatrixElement(const(MatrixInfo)*, const ssize_t, const ssize_t, void*);
		MagickBooleanType NullMatrix(MatrixInfo*);
		MagickBooleanType SetMatrixElement(const(MatrixInfo)*, const ssize_t, const ssize_t, const(void)*);

		MatrixInfo* AcquireMatrixInfo(const size_t, const size_t, const size_t, ExceptionInfo*);
		MatrixInfo* DestroyMatrixInfo(MatrixInfo*);

		size_t GetMatrixColumns(const(MatrixInfo)*);
		size_t GetMatrixRows(const(MatrixInfo)*);
	}

	void LeastSquaresAddTerms(double**, double**, const(double)*, const(double)*, const size_t, const size_t);
}
