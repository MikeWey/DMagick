module dmagick.c.magic;

import core.stdc.stdio;
import core.vararg;

import dmagick.c.exception;
import dmagick.c.magickType;

extern(C)
{
	struct MagicInfo
	{
		char*
			path,
			name,
			target;

		ubyte*
			magic;

		size_t
			length;

		MagickOffsetType
			offset;

		MagickBooleanType
			exempt,
			stealth;

		MagicInfo*
			previous,
			next;

		size_t
			signature;
	}

	char** GetMagicList(const(char)*, size_t*, ExceptionInfo*);

	const(char)* GetMagicName(const(MagicInfo)*);

	MagickBooleanType ListMagicInfo(FILE*, ExceptionInfo*);
	MagickBooleanType MagicComponentGenesis();

	const(MagicInfo)*  GetMagicInfo(const(ubyte)*, const size_t, ExceptionInfo*);
	const(MagicInfo)** GetMagicInfoList(const(char)*, size_t*, ExceptionInfo*);

	void MagicComponentTerminus();
}
