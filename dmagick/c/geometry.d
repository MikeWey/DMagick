module dmagick.c.geometry;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;

alias ptrdiff_t ssize_t;

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
		PercentValue   = 0x1000,  /* '%'  percentage of something */
		AspectValue    = 0x2000,  /* '!'  resize no-aspect - special use flag */
		NormalizeValue = 0x2000,  /* '!'  ScaleKernelValue() in morphology.c */
		LessValue      = 0x4000,  /* '<'  resize smaller - special use flag */
		GreaterValue   = 0x8000,  /* '>'  resize larger - spacial use flag */
		MinimumValue   = 0x10000, /* '^'  special handling needed */
		CorrelateNormalizeValue = 0x10000, /* '^' see ScaleKernelValue() */
		AreaValue      = 0x20000, /* '@'  resize to area - special use flag */
		DecimalValue   = 0x40000, /* '.'  floating point numbers found */
		SeparatorValue = 0x80000, /* 'x'  separator found  */

		AllValues = 0x7fffffff
	}

	/**
	 * Specify positioning of an object (e.g. text, image) within a
	 * bounding region (e.g. an image). Gravity provides a convenient way to
	 * locate objects irrespective of the size of the bounding region, in
	 * other words, you don't need to provide absolute coordinates in order
	 * to position an object.
	 * A common default for gravity is NorthWestGravity.
	 */
	enum GravityType
	{
		UndefinedGravity,      ///
		ForgetGravity    = 0,  /// Don't use gravity.
		NorthWestGravity = 1,  /// Position object at top-left of region.
		NorthGravity     = 2,  /// Position object at top-center of region.
		NorthEastGravity = 3,  /// Position object at top-right of region.
		WestGravity      = 4,  /// Position object at left-center of region.
		CenterGravity    = 5,  /// Position object at center of region.
		EastGravity      = 6,  /// Position object at right-center of region.
		SouthWestGravity = 7,  /// Position object at left-bottom of region.
		SouthGravity     = 8,  /// Position object at bottom-center of region.
		SouthEastGravity = 9,  /// Position object at bottom-right of region.
		StaticGravity    = 10  ///
	}

	/**
	 * An AffineMatrix object describes a coordinate transformation.
	 */
	struct AffineMatrix
	{
		double
			sx,  /// The amount of scaling on the x-axis.
			rx,  /// The amount of rotation on the x-axis, in radians.
			ry,  /// The amount of rotation on the y-axis, in radians.
			sy,  /// The amount of scaling on the y-axis.
			tx,  /// The amount of translation on the x-axis, in pixels.
			ty;  /// The amount of translation on the x-axis, in pixels.
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
