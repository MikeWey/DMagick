module dmagick.c.magickVersion;

extern(C)
{
	version(MagickCore_665)
	{
		/// Defines the version of ImageMagick where these headers are based on.
		enum MagickLibVersion = 0x665;
		///ditto
		enum MagickLibVersionText = "6.6.5";
	}
	version(MagickCore_666)
	{
		/// Defines the version of ImageMagick where these headers are based on.
		enum MagickLibVersion = 0x666;
		///ditto
		enum MagickLibVersionText = "6.6.6";
	}
	else version(MagickCore_667)
	{
		/// Defines the version of ImageMagick where these headers are based on.
		enum MagickLibVersion = 0x667;
		///ditto
		enum MagickLibVersionText = "6.6.7";
	}
	else version(MagickCore_668)
	{
		/// Defines the version of ImageMagick where these headers are based on.
		enum MagickLibVersion = 0x668;
		///ditto
		enum MagickLibVersionText = "6.6.8";
	}
	else version(MagickCore_669)
	{
		/// Defines the version of ImageMagick where these headers are based on.
		enum MagickLibVersion = 0x669;
		///ditto
		enum MagickLibVersionText = "6.6.9";
	}
	else version(MagickCore_670)
	{
		/// Defines the version of ImageMagick where these headers are based on.
		enum MagickLibVersion = 0x670;
		///ditto
		enum MagickLibVersionText = "6.7.0";
	}
	else version(MagickCore_671)
	{
		/// Defines the version of ImageMagick where these headers are based on.
		enum MagickLibVersion = 0x671;
		///ditto
		enum MagickLibVersionText = "6.7.1";
	}
	else version(MagickCore_672)
	{
		/// Defines the version of ImageMagick where these headers are based on.
		enum MagickLibVersion = 0x672;
		///ditto
		enum MagickLibVersionText = "6.7.2";
	}
	else
	{
		/// Defines the version of ImageMagick where these headers are based on.
		enum MagickLibVersion = 0x673;
		///ditto
		enum MagickLibVersionText = "6.7.3";
	}

	char* GetMagickHomeURL();

	const(char)* GetMagickCopyright();
	const(char)* GetMagickFeatures();
	const(char)* GetMagickPackageName();
	const(char)* GetMagickQuantumDepth(size_t*);
	const(char)* GetMagickQuantumRange(size_t*);
	const(char)* GetMagickReleaseDate();
	const(char)* GetMagickVersion(size_t*);
}
