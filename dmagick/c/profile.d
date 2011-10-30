module dmagick.c.profile;

import dmagick.c.magickString;
import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	struct ProfileInfo
	{
		char*
			name;

		size_t
			length;

		ubyte*
			info;

		size_t
			signature;
	}

	/**
	 * Rendering intent is a concept defined by ICC Spec ICC.1:1998-09,
	 * "File Format for Color Profiles". ImageMagick uses RenderingIntent in
	 * order to support ICC Color Profiles.
	 * 
	 * From the specification: "Rendering intent specifies the style of
	 * reproduction to be used during the evaluation of this profile in a
	 * sequence of profiles. It applies specifically to that profile in the
	 * sequence and not to the entire sequence. Typically, the user or
	 * application will set the rendering intent dynamically at runtime or
	 * embedding time."
	 */
	enum RenderingIntent
	{
		/**
		 * No intent has been specified.
		 */
		UndefinedIntent,

		/**
		 * A rendering intent that specifies the saturation of the pixels in
		 * the image is preserved perhaps at the expense of accuracy in hue
		 * and lightness.
		 */
		SaturationIntent,

		/**
		 * A rendering intent that specifies the full gamut of the image is
		 * compressed or expanded to fill the gamut of the destination
		 * device. Gray balance is preserved but colorimetric accuracy might
		 * not be preserved.
		 */
		PerceptualIntent,

		/**
		 * Absolute colorimetric.
		 */
		AbsoluteIntent,

		/**
		 * Relative colorimetric.
		 */
		RelativeIntent
	}

	char* GetNextImageProfile(const(Image)*);

	const(StringInfo)* GetImageProfile(const(Image)*, const(char)*);

	MagickBooleanType CloneImageProfiles(Image*, const(Image)*);
	MagickBooleanType DeleteImageProfile(Image*, const(char)*);
	MagickBooleanType ProfileImage(Image*, const(char)*, const(void)*, const size_t, const MagickBooleanType);
	MagickBooleanType SetImageProfile(Image*, const(char)*, const(StringInfo)*);
	MagickBooleanType SyncImageProfiles(Image*);

	StringInfo* RemoveImageProfile(Image*, const(char)*);

	void DestroyImageProfiles(Image*);
	void ResetImageProfileIterator(const(Image)*);
}
