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

	enum RenderingIntent
	{
		UndefinedIntent,
		SaturationIntent,
		PerceptualIntent,
		AbsoluteIntent,
		RelativeIntent
	}

	char* GetNextImageProfile(const Image*);

	const(StringInfo) *GetImageProfile(const Image *,const char *);

	MagickBooleanType CloneImageProfiles(Image*, const Image*);
	MagickBooleanType DeleteImageProfile(Image*, const char*);
	MagickBooleanType ProfileImage(Image*, const char*, const void*, const size_t, const MagickBooleanType);
	MagickBooleanType SetImageProfile(Image*, const char*, const StringInfo*);
	MagickBooleanType SyncImageProfiles(Image*);

	StringInfo* RemoveImageProfile(Image*, const char*);

	void DestroyImageProfiles(Image*);
	void ResetImageProfileIterator(const Image*);
}
