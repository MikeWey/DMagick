module dmagick.c.magickModule;

import core.stdc.stdio;
import core.stdc.time;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;

extern(C)
{
	enum MagickModuleType
	{
		MagickImageCoderModule,
		MagickImageFilterModule
	}

	struct ModuleInfo
	{
		char*
			path,
			tag;

		void*
			handle;

		void
			function() unregister_module;

		size_t
			function() register_module;

		time_t
			timestamp;

		MagickBooleanType
			stealth;

		ModuleInfo*
			previous,
			next;

		size_t
			signature;
	}

	size_t ImageFilterHandler(Image**, const int, const(char)**, ExceptionInfo*);

	char** GetModuleList(const(char)*, const MagickModuleType, size_t*, ExceptionInfo*);

	const(ModuleInfo)** GetModuleInfoList(const(char)*, size_t*, ExceptionInfo*);

	static if ( MagickLibVersion < 0x689 )
	{
		MagickBooleanType InitializeModuleList(ExceptionInfo*);
	}

	MagickBooleanType InvokeDynamicImageFilter(const(char)*, Image**, const int, const(char)**, ExceptionInfo*);
	MagickBooleanType ListModuleInfo(FILE*, ExceptionInfo*);
	MagickBooleanType ModuleComponentGenesis();
	MagickBooleanType OpenModule(const(char)*, ExceptionInfo*);
	MagickBooleanType OpenModules(ExceptionInfo*);

	ModuleInfo* GetModuleInfo(const(char)*, ExceptionInfo*);

	void DestroyModuleList();
	void ModuleComponentTerminus();
	void RegisterStaticModules();
	void UnregisterStaticModules();
}
