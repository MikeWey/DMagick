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
	/**
	 * Specify text alignment.
	 */
	enum AlignType
	{
		UndefinedAlign, /// No alignment specified. Equivalent to LeftAlign.
		LeftAlign,      /// Align the leftmost part of the text to the starting point.
		CenterAlign,    /// Center the text around the starting point.
		RightAlign      /// Align the rightmost part of the text to the starting point.
	}

	/**
	 * Defines the coordinate system for the contents of a clip path.
	 */
	enum ClipPathUnits
	{
		/** */
		UndefinedPathUnits,

		/**
		 * The contents of the clipPath represent values in the current
		 * user coordinate system.
		 */
		UserSpace,

		/**
		 * The contents of the clipPath represent values in the current
		 * user coordinate system in place at the time when the clipPath
		 * element is referenced.
		 */
		UserSpaceOnUse,

		/**
		 * The user coordinate system for the contents of the clipPath
		 * element is established using the bounding box of the element to
		 * which the clipping path is applied.
		 */
		ObjectBoundingBox
	}

	/**
	 * Specify the text decoration.
	 */
	enum DecorationType
	{
		UndefinedDecoration,   ///
		NoDecoration,          /// Don't decorate the text.
		UnderlineDecoration,   /// Underline the text.
		OverlineDecoration,    /// Overline the text.
		LineThroughDecoration  /// Draw a horizontal line through the middle of the text.
	}

	static if (MagickLibVersion >= 0x662)
	{
		/**
		 * Defines the text direction.
		 */
		enum DirectionType
		{
			UndefinedDirection,    ///
			RightToLeftDirection,  /// ditto
			LeftToRightDirection   /// ditto
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

	/**
	 * FillRule indicates the algorithm which is to be used to determine
	 * what parts of the canvas are included inside the shape.
	 */
	enum FillRule
	{
		/** */
		UndefinedRule,

		/**
		 * This rule determines the "insideness" of a point on the canvas by
		 * drawing a ray from that point to infinity in any direction and
		 * counting the number of path segments from the given shape that
		 * the ray crosses. If this number is odd, the point is inside; if
		 * even, the point is outside.
		 */
		EvenOddRule,

		/**
		 * This rule determines the "insideness" of a point on the canvas by
		 * drawing a ray from that point to infinity in any direction and
		 * then examining the places where a segment of the shape crosses
		 * the ray. Starting with a count of zero, add one each time a path
		 * segment crosses the ray from left to right and subtract one each
		 * time a path segment crosses the ray from right to left. After
		 * counting the crossings, if the result is zero then the point is
		 * outside the path. Otherwise, it is inside.
		 */
		NonZeroRule
	}

	enum GradientType
	{
		UndefinedGradient,
		LinearGradient,
		RadialGradient
	}

	/**
	 * Specifies the shape to be used at the end of open subpaths when they
	 * are stroked.
	 * 
	 * See_Also: $(LINK2 http://www.w3.org/TR/SVG/painting.html#StrokeLinecapProperty,
	 *     the 'stroke-linecap' property) in the Scalable Vector Graphics (SVG)
	 *     1.1 Specification.
	 */
	enum LineCap
	{
		UndefinedCap, ///
		ButtCap,      /// ditto
		RoundCap,     /// ditto
		SquareCap     /// ditto
	}

	/**
	 * Specifies the shape to be used at the corners of paths or basic
	 * shapes when they are stroked.
	 * 
	 * See_Also: $(LINK2 http://www.w3.org/TR/SVG/painting.html#StrokeLinejoinProperty,
	 *     the 'stroke-linejoin' property) in the Scalable Vector Graphics (SVG)
	 *     1.1 Specification.
	 */
	enum LineJoin
	{
		UndefinedJoin, ///
		MiterJoin,     /// ditto
		RoundJoin,     /// ditto
		BevelJoin      /// ditto
	}

	/**
	 * Specify how pixel colors are to be replaced in the image.
	 */
	enum PaintMethod
	{
		/** */
		UndefinedMethod,

		/**
		 * Replace pixel color at point.
		 */
		PointMethod,

		/**
		 * Replace color for all image pixels matching color at point.
		 */
		ReplaceMethod,

		/**
		 * Replace color for pixels surrounding point until encountering
		 * pixel that fails to match color at point.
		 */
		FloodfillMethod,

		/**
		 * Replace color for pixels surrounding point until encountering
		 * pixels matching border color.
		 */
		FillToBorderMethod,

		/**
		 * Replace colors for all pixels in image with fill color.
		 */
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
