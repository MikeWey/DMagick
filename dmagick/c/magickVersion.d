module dmagick.c.magickVersion;

import core.stdc.config;

extern(C)
{
	version(MagickCore_660)
	{
		/// Defines the version of ImageMagick where these headers are based on.
		enum MagickLibVersion = 0x660;
		///ditto
		enum MagickLibVersionText = "6.6.0";
	}
	else version(MagickCore_661)
	{
		/// Defines the version of ImageMagick where these headers are based on.
		enum MagickLibVersion = 0x661;
		///ditto
		enum MagickLibVersionText = "6.6.1";
	}
	else version(MagickCore_662)
	{
		/// Defines the version of ImageMagick where these headers are based on.
		enum MagickLibVersion = 0x662;
		///ditto
		enum MagickLibVersionText = "6.6.2";
	}
	else version(MagickCore_663)
	{
		/// Defines the version of ImageMagick where these headers are based on.
		enum MagickLibVersion = 0x663;
		///ditto
		enum MagickLibVersionText = "6.6.3";
	}
	else version(MagickCore_664)
	{
		/// Defines the version of ImageMagick where these headers are based on.
		enum MagickLibVersion = 0x664;
		///ditto
		enum MagickLibVersionText = "6.6.4";
	}
	else version(MagickCore_665)
	{
		/// Defines the version of ImageMagick where these headers are based on.
		enum MagickLibVersion = 0x665;
		///ditto
		enum MagickLibVersionText = "6.6.5";
	}
	else version(MagickCore_666)
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
	else version(MagickCore_673)
	{
		/// Defines the version of ImageMagick where these headers are based on.
		enum MagickLibVersion = 0x673;
		///ditto
		enum MagickLibVersionText = "6.7.3";
	}
	else version(MagickCore_674)
	{
		/// Defines the version of ImageMagick where these headers are based on.
		enum MagickLibVersion = 0x674;
		///ditto
		enum MagickLibVersionText = "6.7.4";
	}
	else version(MagickCore_675)
	{
		/// Defines the version of ImageMagick where these headers are based on.
		enum MagickLibVersion = 0x675;
		///ditto
		enum MagickLibVersionText = "6.7.5";
	}
	else
	{
		/// Defines the version of ImageMagick where these headers are based on.
		enum MagickLibVersion = 0x676;
		///ditto
		enum MagickLibVersionText = "6.7.6";
	}

	/*
	 * With ImageMagick 6.6.3 long and unsinged long were changed to
	 * ssize_t and size_t. This is only a problem for 64bits windows.
	 */
	static if (MagickLibVersion < 0x663 && c_ulong.sizeof != size_t.sizeof)
	{
		static assert(0, "Only ImageMagick version 6.6.3 and up are supported on your platform");
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
