module dmagick.c.configure;

import core.stdc.stdio;

import dmagick.c.exception;
import dmagick.c.hashmap;
import dmagick.c.magickType;

extern(C)
{
	struct ConfigureInfo
	{
		char*
			path,
			name,
			value;

		MagickBooleanType
			exempt,
			stealth;

		ConfigureInfo*
			previous,
			next;

		size_t
			signature;
	}

	char** GetConfigureList(const(char)*, size_t*, ExceptionInfo*);
	char*  GetConfigureOption(const(char)*);

	const(char*) GetConfigureValue(const(ConfigureInfo)*);

	const(ConfigureInfo)*  GetConfigureInfo(const(char)*, ExceptionInfo*);
	const(ConfigureInfo)** GetConfigureInfoList(const(char)*, size_t*, ExceptionInfo*);

	LinkedListInfo* DestroyConfigureOptions(LinkedListInfo *);
	LinkedListInfo* GetConfigurePaths(const(char)*,ExceptionInfo *);
	LinkedListInfo* GetConfigureOptions(const(char)*,ExceptionInfo *);

	MagickBooleanType ConfigureComponentGenesis();
	MagickBooleanType ListConfigureInfo(FILE*, ExceptionInfo*);

	void ConfigureComponentTerminus();
}
