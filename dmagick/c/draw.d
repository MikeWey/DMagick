module dmagick.c.draw;

import dmagick.c.composite;
import dmagick.c.geometry;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.pixel;
import dmagick.c.type;

extern(C)
{
	enum AlignType
	{
		UndefinedAlign,
		LeftAlign,
		CenterAlign,
		RightAlign
	}

	enum ClipPathUnits
	{
		UndefinedPathUnits,
		UserSpace,
		UserSpaceOnUse,
		ObjectBoundingBox
	}

	enum DecorationType
	{
		UndefinedDecoration,
		NoDecoration,
		UnderlineDecoration,
		OverlineDecoration,
		LineThroughDecoration
	}

	enum DirectionType
	{
		UndefinedDirection,
		RightToLeftDirection,
		LeftToRightDirection
	}

	enum FillRule
	{
		UndefinedRule,

		EvenOddRule,
		NonZeroRule
	}

	enum GradientType
	{
		UndefinedGradient,
		LinearGradient,
		RadialGradient
	}

	enum LineCap
	{
		UndefinedCap,
		ButtCap,
		RoundCap,
		SquareCap
	}

	enum LineJoin
	{
		UndefinedJoin,
		MiterJoin,
		RoundJoin,
		BevelJoin
	}

	enum PaintMethod
	{
		UndefinedMethod,
		PointMethod,
		ReplaceMethod,
		FloodfillMethod,
		FillToBorderMethod,
		ResetMethod
	}

	enum PrimitiveType
	{
		UndefinedPrimitive,
		PointPrimitive,
		LinePrimitive,
		RectanglePrimitive,
		RoundRectanglePrimitive,
		ArcPrimitive,
		EllipsePrimitive,
		CirclePrimitive,
		PolylinePrimitive,
		PolygonPrimitive,
		BezierPrimitive,
		ColorPrimitive,
		MattePrimitive,
		TextPrimitive,
		ImagePrimitive,
		PathPrimitive
	}

	enum ReferenceType
	{
		UndefinedReference,
		GradientReference
	}

	enum SpreadMethod
	{
		UndefinedSpread,
		PadSpread,
		ReflectSpread,
		RepeatSpread
	}

	struct PointInfo
	{
		double
			x,
			y;
	}

	struct StopInfo
	{
		MagickPixelPacket
			color;

		MagickRealType
			offset;
	}

	struct GradientInfo
	{
		GradientType
			type;

		RectangleInfo
			bounding_box;

		SegmentInfo
			gradient_vector;

		StopInfo*
			stops;

		size_t
			number_stops;

		SpreadMethod
			spread;

		MagickBooleanType
			ddebug;

		size_t
			signature;

		PointInfo
			center;

		MagickRealType
			radius;
	}

	struct ElementReference
	{
		char*
			id;

		ReferenceType
			type;

		GradientInfo
			gradient;

		size_t
			signature;

		ElementReference*
			previous,
			next;
	}

	struct DrawInfo
	{
		char*
			primitive,
			geometry;

		RectangleInfo
			viewbox;

		AffineMatrix
			affine;

		GravityType
			gravity;

		PixelPacket
			fill,
			stroke;

		double
			stroke_width;

		GradientInfo
			gradient;

		Image*
			fill_pattern,
			tile,
			stroke_pattern;

		MagickBooleanType
			stroke_antialias,
			text_antialias;

		FillRule
			fill_rule;

		LineCap
			linecap;

		LineJoin
			linejoin;

		size_t
			miterlimit;

		double
			dash_offset;

		DecorationType
			decorate;

		CompositeOperator
			compose;

		char*
			text;

		size_t
			face;

		char*
			font,
			metrics,
			family;

		StyleType
			style;

		StretchType
			stretch;

		size_t
			weight;

		char*
			encoding;

		double
			pointsize;

		char*
			density;

		AlignType
			aalign;

		PixelPacket
			undercolor,
			border_color;

		char*
			server_name;

		double*
			dash_pattern;

		char*
			clip_mask;

		SegmentInfo
			bounds;

		ClipPathUnits
			clip_units;

		Quantum
			opacity;

		MagickBooleanType
			render;

		ElementReference
			element_reference;

		MagickBooleanType
			ddebug;

		size_t
			signature;

		double
			kerning,
			interword_spacing,
			interline_spacing;

		DirectionType
			direction;
	}

	struct PrimitiveInfo
	{
		PointInfo
			point;

		size_t
			coordinates;

		PrimitiveType
			primitive;

		PaintMethod
			method;

		char*
			text;
	}

	struct TypeMetric
	{
		PointInfo
			pixels_per_em;

		double
			ascent,
			descent,
			width,
			height,
			max_advance,
			underline_position,
			underline_thickness;

		SegmentInfo
			bounds;

		PointInfo
			origin;
	}

	DrawInfo* AcquireDrawInfo();
	DrawInfo* CloneDrawInfo(const(ImageInfo)*, const(DrawInfo)*);
	DrawInfo* DestroyDrawInfo(DrawInfo*);

	MagickBooleanType DrawAffineImage(Image*, const(Image)*, const(AffineMatrix)*);
	MagickBooleanType DrawClipPath(Image*, const(DrawInfo)*, const(char)*);
	MagickBooleanType DrawGradientImage(Image*, const(DrawInfo)*);
	MagickBooleanType DrawImage(Image*, const(DrawInfo)*);
	MagickBooleanType DrawPatternPath(Image*, const(DrawInfo)*, const(char)*, Image**);
	MagickBooleanType DrawPrimitive(Image*, const(DrawInfo)*, const(PrimitiveInfo)*);

	void GetAffineMatrix(AffineMatrix*);
	void GetDrawInfo(const(ImageInfo)*, DrawInfo*);
}
