module dmagick.c.mime;

import core.stdc.stdio;

import dmagick.c.exception;
import dmagick.c.magickType;

extern(C)
{
	struct MimeInfo {}

	char** GetMimeList(const char*, size_t*, ExceptionInfo*);
	char*  MagickToMime(const char*);

	const(char*) GetMimeDescription(const MimeInfo*);
	const(char*) GetMimeType(const MimeInfo*);

	MagickBooleanType ListMimeInfo(FILE*, ExceptionInfo*);
	MagickBooleanType LoadMimeLists(const char*, ExceptionInfo*);
	MagickBooleanType MimeComponentGenesis();

	const(MimeInfo*)  GetMimeInfo(const char*, const ubyte*, const size_t, ExceptionInfo*);
	const(MimeInfo**) GetMimeInfoList(const char*, size_t*, ExceptionInfo*);

	void MimeComponentTerminus();
}
