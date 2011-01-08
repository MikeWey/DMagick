module dmagick.c.utility;

import core.stdc.stdio;
import core.sys.posix.sys.types;

import dmagick.c.exception;
import dmagick.c.magickType;

extern(C)
{
	enum PathType
	{
		UndefinedPath,
		MagickPath,
		RootPath,
		HeadPath,
		TailPath,
		BasePath,
		ExtensionPath,
		SubimagePath,
		CanonicalPath
	}

	char*  Base64Encode(const ubyte*, const size_t, size_t*);
	char** GetPathComponents(const char*, size_t*);
	char** ListFiles(const char*, const char*, size_t*);

	FILE* OpenMagickStream(const char*, const char*);

	int SystemCommand(const MagickBooleanType, const MagickBooleanType, const char*, ExceptionInfo*);

	MagickBooleanType AcquireUniqueFilename(char*);
	MagickBooleanType AcquireUniqueSymbolicLink(const char*, char*);
	MagickBooleanType ExpandFilenames(int*, char***);
	MagickBooleanType GetPathAttributes(const char*, void*);
	MagickBooleanType GetExecutionPath(char*, const size_t);
	MagickBooleanType IsMagickTrue(const char*);
	MagickBooleanType IsPathAccessible(const char*);

	size_t MultilineCensus(const char*);

	ssize_t GetMagickPageSize();

	ubyte* Base64Decode(const char*, size_t*);

	void AppendImageFormat(const char*, char*);
	void ChopPathComponents(char*, const size_t);
	void ExpandFilename(char*);
	void GetPathComponent(const char*, PathType, char*);
	void MagickDelay(const MagickSizeType);
}
