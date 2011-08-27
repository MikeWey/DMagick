/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */

module dmagick.DrawingContext;

import dmagick.Image;

import dmagick.c.geometry;

class DrawingContext
{
	private void delegate(Image)[] actions;

	//Image property changes that need undoing.
	private void delegate(Image)[string] undo;

	/**
	 * Apply the drawing context to the image.
	 */
	void draw(Image image)
	{
		undo = null;

		foreach ( action; actions )
			action(image);

		foreach ( u; undo )
			u(image);
	}

	/**
	 * Specify a transformation matrix to adjust scaling, rotation, and
	 * translation (coordinate transformation) for subsequently drawn
	 * objects in the drawing context. 
	 */
	void affine(AffineMatrix affine)
	{
		AffineMatrix oldAffine;

		actions ~= (Image image)
		{
			if ( "affine" !in undo )
			{
				oldAffine = image.options.affine;

				undo["affine"] = (Image image)
				{
					image.options.affine = oldAffine;
				};
			}

			image.options.affine = affine;
		};
	}

	/**
	 * Transforms the image as specified by the affine matrix.
	 */
	void affineTransform(AffineMatrix affine)
	{
		actions ~= (Image image)
		{
			image.affineTransform(affine);
		};
	}
}
