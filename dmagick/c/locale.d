module dmagick.c.locale;

import core.stdc.stdio;

import dmagick.c.exception;
import dmagick.c.hashmap;
import dmagick.c.magickType;

extern(C)
{
	struct LocaleInfo
	{
		char*
			path,
			tag,
			message;

		MagickBooleanType
			stealth;

		LocaleInfo*
			previous,
			next;

		size_t
			signature;
	}

	char** GetLocaleList(const(char)*, size_t*, ExceptionInfo*);

	const(char)* GetLocaleMessage(const(char)*);

	const(LocaleInfo)*  GetLocaleInfo_(const(char)*, ExceptionInfo*);
	const(LocaleInfo)** GetLocaleInfoList(const(char)*, size_t*, ExceptionInfo*);

	LinkedListInfo* DestroyLocaleOptions(LinkedListInfo*);
	LinkedListInfo* GetLocaleOptions(const(char)*, ExceptionInfo*);

	MagickBooleanType ListLocaleInfo(FILE*, ExceptionInfo*);
	MagickBooleanType LocaleComponentGenesis();

	void LocaleComponentTerminus();
}
