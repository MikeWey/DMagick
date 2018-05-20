module dmagick.c.magickVersion;

import core.stdc.config;
import core.stdc.stdio;

/// Defines the version of ImageMagick where these headers are based on.
enum MagickLibVersion = 0x707;
///ditto
enum MagickLibVersionText = "7.0.7";

/// The quantum depth used by MagickCore.
enum MagickQuantumDepth = 16;

/// Defines if HDRI is enabled.
enum MagickHDRISupport = true;

/*
 * With ImageMagick 6.6.3 long and unsinged long were changed to
 * ssize_t and size_t. This is only a problem for 64bits windows.
 */
static if (MagickLibVersion < 0x663 && c_ulong.sizeof != size_t.sizeof)
{
	static assert(0, "Only ImageMagick version 6.6.3 and up are supported on your platform");
}

extern(C)
{
	char* GetMagickHomeURL();

	const(char)* GetMagickCopyright();

	static if ( MagickLibVersion >= 0x681 )
	{
		const(char)* GetMagickDelegates();
	}

	const(char)* GetMagickFeatures();
	const(char)* GetMagickPackageName();
	const(char)* GetMagickQuantumDepth(size_t*);
	const(char)* GetMagickQuantumRange(size_t*);
	const(char)* GetMagickReleaseDate();
	const(char)* GetMagickVersion(size_t*);

	static if ( MagickLibVersion >= 0x681 )
	{
		void ListMagickVersion(FILE*);
	}
}
