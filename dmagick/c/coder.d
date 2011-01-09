module dmagick.c.coder;

import core.stdc.stdio;

import dmagick.c.exception;
import dmagick.c.magickType;

extern(C)
{
	struct CoderInfo
	{
		char*
			path,
			magick,
			name;

		MagickBooleanType
			exempt,
			stealth;

		CoderInfo*
			previous,
			next;

		size_t
			signature;
	}

	char** GetCoderList(const(char)*, size_t*, ExceptionInfo*);

	const(CoderInfo)*  GetCoderInfo(const(char)*, ExceptionInfo*);
	const(CoderInfo)** GetCoderInfoList(const(char)*, size_t*, ExceptionInfo*);

	MagickBooleanType CoderComponentGenesis();
	MagickBooleanType ListCoderInfo(FILE*, ExceptionInfo*);
}
	void CoderComponentTerminus();
