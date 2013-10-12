module dmagick.c.distort;

import dmagick.c.exception;
import dmagick.c.geometry;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;

extern(C)
{
	version(D_Ddoc)
	{
		/**
		 * The distortion method to use when distorting an image.
		 */
		enum DistortImageMethod
		{
			/** */
			UndefinedDistortion,

			/**
			 * Distort the image linearly by moving a list of at least 3 or
			 * more sets of control points (as defined below). Ideally 3 sets
			 * or 12 floating point values are given allowing the image to
			 * be linearly scaled, rotated, sheared, and translated, according
			 * to those three points. See also the related AffineProjection
			 * and ScaleRotateTranslateDistortion distortions. 
			 * 
			 * More than 3 sets given control point pairs (12 numbers) is least
			 * squares fitted to best match a lineary affine distortion. If only
			 * 2 control point pairs (8 numbers) are given a two point image
			 * translation rotation and scaling is performed, without any possible
			 * shearing, flipping or changes in aspect ratio to the resulting image.
			 * If only one control point pair is provides the image is only
			 * translated, (which may be a floating point non-integer translation). 
			 * 
			 * This distortion does not include any form of perspective distortion.
			 */
			AffineDistortion,

			/**
			 * Linearly distort an image using the given Affine Matrix of 6 pre-calculated
			 * coefficients forming a set of Affine Equations to map the source
			 * image to the destination image.
			 * 
			 * Sx,Rx,Ry,Sy,Tx,Ty
			 */
			AffineProjectionDistortion,

			/**
			 * Distort image by first scaling and rotating about a given
			 * 'center', before translating that 'center' to the new location,
			 * in that order. It is an alternative method of specifying a
			 * 'Affine' type of distortion, but without shearing effects. It
			 * also provides a good way of rotating and displacing a smaller
			 * image for tiling onto a larger background (IE 2-dimensional
			 * animations).
			 * 
			 * The number of arguments determine the specific meaning of each
			 * argument for the scales, rotation, and translation operations. 
			 * $(TABLE
			 *     $(HEADERS #, arguments meaning )
			 *     $(ROW 1:, $(COMMA Angle_of_Rotation ))
			 *     $(ROW 2:, $(COMMA Scale Angle ))
			 *     $(ROW 3:, $(COMMA X,Y Angle ))
			 *     $(ROW 4:, $(COMMA X,Y Scale Angle ))
			 *     $(ROW 5:, $(COMMA X,Y ScaleX,ScaleY Angle ))
			 *     $(ROW 6:, $(COMMA X,Y Scale Angle NewX,NewY ))
			 *     $(ROW 7:, $(COMMA X,Y ScaleX,ScaleY Angle NewX,NewY ))
			 * )
			 * 
			 * This is actually an alternative way of specifying a 2 dimensional
			 * linear 'Affine' or 'AffineProjection' distortion.
			 */
			ScaleRotateTranslateDistortion,
			
			/**
			 * Perspective distort the images, using a list of 4 or more sets of
			 * control points (as defined below). More that 4 sets (16 numbers) of
			 * control points provide least squares fitting for more accurate
			 * distortions (for the purposes of image registration and panarama
			 * effects). Less than 4 sets will fall back to a 'Affine' linear distortion.
			 * 
			 * Perspective Distorted images ensures that straight lines remain straight,
			 * but the scale of the distorted image will vary. The horizon is
			 * anti-aliased, and the 'sky' color may be set using the -mattecolor setting.
			 */
			PerspectiveDistortion,
			
			/**
			 * Do a Perspective distortion biased on a set of 8 pre-calculated coefficients.
			 * If the last two perspective scaling coefficients are zero, the remaining
			 * 6 represents a transposed 'Affine Matrix'.
			 */
			PerspectiveProjectionDistortion,
			
			/**
			 * Bilinear Distortion, given a minimum of 4 sets of coordinate pairs,
			 * or 16 values (see below). Not that lines may not appear straight
			 * after distortion, though the distance between coordinates will
			 * remain consistent.
			 * 
			 * The BilinearForward is used to map rectangles to any quadrilateral,
			 * while the BilinearReverse form maps any quadrilateral to a rectangle,
			 * while preserving the straigth line edges in each case.
			 * 
			 * Note that BilinearForward can generate invalid pixels which will be
			 * colored using the -mattecolor color setting. Also if the quadraterial
			 * becomes 'flipped' the image may dissappear.
			 * 
			 * There are future plans to produce a true Bilinear distortion that will
			 * attempt to map any quadrilateral to any other quadrilateral,
			 * while preserving edges (and edge distance ratios).
			 */
			BilinearForwardDistortion,
			
			/**
			 * ditto
			 */
			BilinearDistortion = BilinearForwardDistortion,
			
			/**
			 * ditto
			 */
			BilinearReverseDistortion,
			
			/**
			 * 
			 */
			PolynomialDistortion,
			
			/**
			 * Arc the image (variation of polar mapping) over the angle given around a circle.
			 * $(TABLE
			 *     $(HEADERS Argument,  Meaning)
			 *     $(ROW arc_angle,     The angle over which to arc the image side-to-side)
			 *     $(ROW rotate_angle,  Angle to rotate resulting image from vertical center)
			 *     $(ROW top_radius,    Set top edge of source image at this radius)
			 *     $(ROW bottom_radius, Set bottom edge to this radius (radial scaling))
			 * )
			 * 
			 * The resulting image is always resized to best fit the resulting image, while
			 * attempting to preserve scale and aspect ratio of the original image as much
			 * as possible with the arguments given by the user. All four arguments will be
			 * needed to change the overall aspect ratio of an 'Arc'ed image. 
			 * 
			 * This a variation of a polar distortion designed to try to preserve the aspect
			 * ratio of the image rather than direct Cartesian to Polar conversion.
			 */
			ArcDistortion,
			
			/**
			 * Like ArcDistortion but do a complete Cartesian to Polar mapping of the image.
			 * that is the height of the input image is mapped to the radius limits, while
			 * the width is wrapped around between the angle limits.
			 * 
			 * Arguments : Rmax,Rmin CenterX,CenterY, start,end_angle
			 * 
			 * All arguments are optional. With Rmin defaulting to zero, the center to the
			 * center of the image, and the angles going from -180 (top) to +180 (top). If
			 * Rmax is given the special value of '0', the the distance from the center to
			 * the nearest edge is used for the radius of the output image, which will ensure
			 * the whole image is visible (though scaled smaller). However a special value of
			 * '-1' will use the distance from the center to the furthest corner, This may
			 * 'clip' the corners from the input rectangular image, but will generate the
			 * exact reverse of a 'DePolar' with the same arguments.
			 */
			PolarDistortion,
			
			/**
			 * Uses the same arguments and meanings as a Polar distortion but generates the 
			 * reverse Polar to Cartesian distortion. 
			 * 
			 * The special Rmax setting of '0' may however clip the corners of the input image.
			 * However using the special Rmax setting of '-1' (maximum center to corner distance)
			 * will ensure the whole distorted image is preserved in the generated result, so that
			 * the same argument to 'Polar' will reverse the distortion re-producing the original.
			 * Note that as this distortion requires the area resampling of a circular arc, which
			 * can not be handled by the builtin EWA resampling function. As such the normal EWA
			 * filters are turned off. It is recommended some form of 'super-sampling' image
			 * processing technique be used to produce a high quality result.
			 */
			DePolarDistortion,
			
			/** */
			Cylinder2PlaneDistortion,
			
			/** */
			Plane2CylinderDistortion,
			
			/**
			 * Given the four coefficients (A,B,C,D) as defined by Helmut Dersch, perform a barrell or
			 * pin-cushion distortion appropriate to correct radial lens distortions. That is in
			 * photographs, make straight lines straight again.
			 * 
			 * Arguments : A B C [D [X,Y]] $(BR)
			 * or Ax Bx Cx Dx  Ay By Cy Dy [X,Y] $(BR)
			 * So that it forms the function $(BR)
			 * Rsrc = r * ( A*r³ + B*r² + C*r + D )
			 * 
			 * Where X,Y is the optional center of the distortion (defaulting to the center of the image).
			 * The second form is typically used to distort images, rather than correct lens distortions.
			 */
			BarrelDistortion,
			
			/**
			 * This is very simular to BarrelDistortion with the same set of arguments, and argument handling.
			 * However it uses the inverse of the radial polynomial, so that it forms the function 
			 * 
			 * Rsrc = r / ( A*r³ + B*r² + C*r + D )
			 * 
			 * Note that this is not the reverse of the Barrel distortion,
			 * just a different barrel-like radial distortion method.
			 */
			BarrelInverseDistortion,
			
			/**
			 * Distort the given list control points (any number) using an Inverse Squared Distance
			 * Interpolation Method (Shepards Method). The control points in effect do 'localized'
			 * displacement of the image around the given control point (preserving the look and the
			 * rotation of the area near the control points. For best results extra control points
			 * should be added to 'lock' the positions of the corners, edges and other unchanging
			 * parts of the image, to prevent their movement.
			 * 
			 * The distortion has been likened to 'taffy pulling' using nails, or pins' stuck in a
			 * block of 'jelly' which is then moved to the new position, distorting te surface of the jelly. 
			 */
			ShepardsDistortion,
			
			/** */
			ResizeDistortion,

			/* Not a real distortion, ImageMagick uses this to get the amount of Distortions supported */
			SentinelDistortion
		}
	}
	else
	{
		mixin(
		{
			string methods = "enum DistortImageMethod
			{
				UndefinedDistortion,
				AffineDistortion,
				AffineProjectionDistortion,
				ScaleRotateTranslateDistortion,
				PerspectiveDistortion,
				PerspectiveProjectionDistortion,
				BilinearForwardDistortion,
				BilinearDistortion = BilinearForwardDistortion,
				BilinearReverseDistortion,
				PolynomialDistortion,
				ArcDistortion,
				PolarDistortion,
				DePolarDistortion,";

				static if ( MagickLibVersion >= 0x671 )
				{
					methods ~= "Cylinder2PlaneDistortion,
						        Plane2CylinderDistortion,";
				}

				methods ~= "
				BarrelDistortion,
				BarrelInverseDistortion,
				ShepardsDistortion,";

				static if ( MagickLibVersion >= 0x670 )
				{
					methods ~= "ResizeDistortion,";
				}

				methods ~= "
				SentinelDistortion
			}";

			return methods;
		}());
	}

	/**
	 * Determines how to fill intervening colors.
	 */
	enum SparseColorMethod
	{
		/** */
		UndefinedColorInterpolate =   cast(int)DistortImageMethod.UndefinedDistortion,

		/**
		 * three point triangle of color given 3 points. Giving only 2 points
		 * will form a linear gradient between those points. The gradient
		 * generated extends beyond the triangle created by those 3 points.
		 */
		BarycentricColorInterpolate = cast(int)DistortImageMethod.AffineDistortion,

		/**
		 * Like barycentric but for 4 points. Less than 4 points fall back
		 * to barycentric.
		 */
		BilinearColorInterpolate =    cast(int)DistortImageMethod.BilinearReverseDistortion,

		/** */
		PolynomialColorInterpolate =  cast(int)DistortImageMethod.PolynomialDistortion,

		/**
		 * Colors points biased on the ratio of inverse distance squared.
		 * Generating spots of color in a sea of the average of colors.
		 */
		ShepardsColorInterpolate =    cast(int)DistortImageMethod.ShepardsDistortion,

		/**
		 * Simply map each pixel to the to nearest color point given.
		 * The result are polygonal cells of solid color.
		 */
		VoronoiColorInterpolate =     cast(int)DistortImageMethod.SentinelDistortion,

		/**
		 * Colors points biased on the ratio of inverse distance.
		 * This generates sharper points of color rather than rounded spots
		 * of ShepardsColorInterpolate Generating spots of color in a sea
		 * of the average of colors.
		 */
		InverseColorInterpolate
	}

	Image* AffineTransformImage(const(Image)*, const(AffineMatrix)*, ExceptionInfo*);
	Image* DistortImage(const(Image)*, const DistortImageMethod, const size_t, const(double)*, MagickBooleanType, ExceptionInfo* exception);

	static if ( MagickLibVersion >= 0x670 )
	{
		Image* DistortResizeImage(const(Image)*, const size_t, const size_t, ExceptionInfo*);
	}

	Image* RotateImage(const(Image)*, const double, ExceptionInfo*);
	Image* SparseColorImage(const(Image)*, const ChannelType, const SparseColorMethod, const size_t, const(double)*, ExceptionInfo*);
}
