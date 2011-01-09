module dmagick.c.magickVersion;

extern(C)
{
	char* GetMagickHomeURL();

	const(char)* GetMagickCopyright();
	const(char)* GetMagickFeatures();
	const(char)* GetMagickPackageName();
	const(char)* GetMagickQuantumDepth(size_t*);
	const(char)* GetMagickQuantumRange(size_t*);
	const(char)* GetMagickReleaseDate();
	const(char)* GetMagickVersion(size_t*);
}
