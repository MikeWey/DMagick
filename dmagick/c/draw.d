module dmagick.c.draw;

import dmagick.c.composite;
import dmagick.c.geometry;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;
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

	static if (MagickLibVersion >= 0x662)
	{
		enum DirectionType
		{
			UndefinedDirection,
			RightToLeftDirection,
			LeftToRightDirection
		}
	}
	else
	{
		enum DirectionType
		{
			UndefinedDirection,
			LeftToRightDirection,
			RightToLeftDirection
		}
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

		static if (MagickLibVersion >= 0x662)
		{
			DirectionType
				direction;
		}
		else static if (MagickLibVersion == 0x661)
		{
			double
				direction;
		}
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

	/**
	 * This is used to reprecent text/font mesurements.
	 */
	struct TypeMetric
	{
		/**
		 * Horizontal (x) and vertical (y) pixels per em.
		 */
		PointInfo pixels_per_em;

		/**
		 * The distance in pixels from the text baseline to the
		 * highest/upper grid coordinate used to place an outline point.
		 * Always a positive value.
		 */
		double ascent;

		/**
		 * The distance in pixels from the baseline to the lowest grid
		 * coordinate used to place an outline point.
		 * Always a negative value.
		 */
		double descent;

		/**
		 * Text width in pixels.
		 */
		double width;

		/**
		 * Text height in pixels.
		 */
		double height;

		/**
		 * The maximum horizontal advance (advance from the beginning
		 * of a character to the beginning of the next character) in
		 * pixels.
		 */
		double max_advance;

		double underline_position;  ///
		double underline_thickness; ///

		/**
		 * This is an imaginary box that encloses all glyphs from the font,
		 * usually as tightly as possible.
		 */
		SegmentInfo bounds;

		/**
		 * A virtual point, located on the baseline, used to locate glyphs.
		 */
		PointInfo origin;
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
