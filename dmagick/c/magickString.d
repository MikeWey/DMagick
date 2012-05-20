module dmagick.c.magickString;

import core.stdc.stdio;
import core.stdc.time;
import core.vararg;

import dmagick.c.exception;
import dmagick.c.magickType;
import dmagick.c.magickVersion;

alias ptrdiff_t ssize_t;

extern(C)
{
	struct StringInfo
	{
		char[MaxTextExtent]
			path;

		ubyte*
			datum;

		size_t
			length,
			signature;
	}

	char*  AcquireString(const(char)*);
	char*  CloneString(char**, const(char)*);
	char*  ConstantString(const(char)*);
	char*  DestroyString(char*);
	char** DestroyStringList(char**);
	char*  EscapeString(const(char)*, const char);
	char*  FileToString(const(char)*, const size_t, ExceptionInfo*);
	char*  GetEnvironmentValue(const(char)*);
	char*  StringInfoToHexString(const(StringInfo)*);
	char*  StringInfoToString(const(StringInfo)*);
	char** StringToArgv(const(char)*, int*);
	char*  StringToken(const(char)*, char**);
	char** StringToList(const(char)*);

	const(char)* GetStringInfoPath(const(StringInfo)*);

	static if ( MagickLibVersion >= 0x674 )
	{
		double InterpretSiPrefixValue(const(char)*, char**);
	}
	static if ( MagickLibVersion >= 0x677 )
	{
		double* StringToArrayOfDoubles(const(char)*, ssize_t*, ExceptionInfo*);
	}

	int	CompareStringInfo(const(StringInfo)*, const(StringInfo)*);
	int	LocaleCompare(const(char)*, const(char)*);
	int	LocaleNCompare(const(char)*, const(char)*, const size_t);

	MagickBooleanType ConcatenateString(char**, const(char)*);

	static if ( MagickLibVersion >= 0x677 )
	{
		MagickBooleanType IsStringTrue(const(char)*);
		MagickBooleanType IsStringNotFalse(const(char)*);
	}

	MagickBooleanType SubstituteString(char**, const(char)*, const(char)*);

	size_t ConcatenateMagickString(char*, const(char)*, const size_t);
	size_t CopyMagickString(char*, const(char)*, const size_t);
	size_t GetStringInfoLength(const(StringInfo)*);

	ssize_t	FormatMagickSize(const MagickSizeType, const MagickBooleanType, char*);

	static if ( MagickLibVersion < 0x670 )
	{
		ssize_t	FormatMagickString(char*, const size_t, const(char)*, ...);
		ssize_t	FormatMagickStringList(char*, const size_t, const(char)*, va_list);
	}

	ssize_t	FormatMagickTime(const time_t, const size_t, char*);

	StringInfo* AcquireStringInfo(const size_t);

	static if ( MagickLibVersion >= 0x673 )
	{
		StringInfo* BlobToStringInfo(const(void)*, const size_t);
	}

	StringInfo* CloneStringInfo(const(StringInfo)*);
	StringInfo* ConfigureFileToStringInfo(const(char)*);
	StringInfo* DestroyStringInfo(StringInfo*);
	StringInfo* FileToStringInfo(const(char)*, const size_t, ExceptionInfo*);
	StringInfo* SplitStringInfo(StringInfo*, const size_t);
	StringInfo* StringToStringInfo(const(char)*);

	ubyte* GetStringInfoDatum(const(StringInfo)*);

	void ConcatenateStringInfo(StringInfo*, const(StringInfo)*);
	void LocaleLower(char*);
	void LocaleUpper(char*);
	void PrintStringInfo(FILE *file, const(char)*, const(StringInfo)*);
	void ResetStringInfo(StringInfo*);
	void SetStringInfo(StringInfo*, const(StringInfo)*);
	void SetStringInfoDatum(StringInfo*, const(ubyte)*);
	void SetStringInfoLength(StringInfo*, const size_t);
	void SetStringInfoPath(StringInfo*, const(char)*);
	void StripString(char*);
}
