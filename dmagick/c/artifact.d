module dmagick.c.artifact;

import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	char* GetNextImageArtifact(const(Image)*);
	char* RemoveImageArtifact(Image*, const(char)*);

	const(char)* GetImageArtifact(const(Image)*, const(char)*);

	MagickBooleanType CloneImageArtifacts(Image*, const(Image)*);
	MagickBooleanType DefineImageArtifact(Image*, const(char)*);
	MagickBooleanType DeleteImageArtifact(Image*, const(char)*);
	MagickBooleanType SetImageArtifact(Image*, const(char)*, const(char)*);

	void DestroyImageArtifacts(Image*);
	void ResetImageArtifactIterator(const(Image)*);
}
