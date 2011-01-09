module dmagick.c.geometry;

import core.sys.posix.sys.types;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	enum GeometryFlags
	{
		NoValue = 0x0000,

		XValue  = 0x0001,
		XiValue = 0x0001,

		YValue   = 0x0002,
		PsiValue = 0x0002,

		WidthValue = 0x0004,
		RhoValue   = 0x0004,

		HeightValue = 0x0008,
		SigmaValue  = 0x0008,
		ChiValue    = 0x0010,
		XiNegative  = 0x0020,

		XNegative   = 0x0020,
		PsiNegative = 0x0040,

		YNegative      = 0x0040,
		ChiNegative    = 0x0080,
		PercentValue   = 0x1000,
		AspectValue    = 0x2000,
		NormalizeValue = 0x2000,
		LessValue      = 0x4000,
		GreaterValue   = 0x8000,
		MinimumValue   = 0x10000,
		CorrelateNormalizeValue = 0x10000,
		AreaValue      = 0x20000,
		DecimalValue   = 0x40000,

		AllValues = 0x7fffffff
	}

	enum GravityType
	{
		UndefinedGravity,
		ForgetGravity    = 0,
		NorthWestGravity = 1,
		NorthGravity     = 2,
		NorthEastGravity = 3,
		WestGravity      = 4,
		CenterGravity    = 5,
		EastGravity      = 6,
		SouthWestGravity = 7,
		SouthGravity     = 8,
		SouthEastGravity = 9,
		StaticGravity    = 10
	}

	struct AffineMatrix
	{
		double
			sx,
			rx,
			ry,
			sy,
			tx,
			ty;
	}

	struct GeometryInfo
	{
		double
			rho,
			sigma,
			xi,
			psi,
			chi;
	}

	struct OffsetInfo
	{
		ssize_t
			x,
			y;
	}

	struct RectangleInfo
	{
		size_t
			width,
			height;

		ssize_t
			x,
			y;
	}

	char* GetPageGeometry(const(char)*);

	MagickBooleanType IsGeometry(const(char)*);
	MagickBooleanType IsSceneGeometry(const(char)*, const MagickBooleanType);

	MagickStatusType GetGeometry(const(char)*, ssize_t*, ssize_t*, size_t*, size_t*);
	MagickStatusType ParseAbsoluteGeometry(const(char)*, RectangleInfo*);
	MagickStatusType ParseAffineGeometry(const(char)*, AffineMatrix*, ExceptionInfo*);
	MagickStatusType ParseGeometry(const(char)*, GeometryInfo*);
	MagickStatusType ParseGravityGeometry(const(Image)*, const(char)*, RectangleInfo*, ExceptionInfo*);
	MagickStatusType ParseMetaGeometry(const(char)*, ssize_t*, ssize_t*, size_t*, size_t*);
	MagickStatusType ParsePageGeometry(const(Image)*, const(char)*, RectangleInfo*, ExceptionInfo*);
	MagickStatusType ParseRegionGeometry(const(Image)*, const(char)*, RectangleInfo*, ExceptionInfo*);

	void GravityAdjustGeometry(const size_t, const size_t, const GravityType, RectangleInfo*);
	void SetGeometry(const(Image)*, RectangleInfo*);
	void SetGeometryInfo(GeometryInfo*);
}
