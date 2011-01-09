module dmagick.c.registry;

import dmagick.c.exception;
import dmagick.c.magickType;

extern(C)
{
	enum RegistryType
	{
		UndefinedRegistryType,
		ImageRegistryType,
		ImageInfoRegistryType,
		StringRegistryType
	}

	char* GetNextImageRegistry();

	MagickBooleanType DefineImageRegistry(const RegistryType, const(char)*, ExceptionInfo*);
	MagickBooleanType DeleteImageRegistry(const(char)*);
	MagickBooleanType RegistryComponentGenesis();
	MagickBooleanType SetImageRegistry(const RegistryType, const(char)*, const(void)*, ExceptionInfo*);

	void* GetImageRegistry(const RegistryType, const(char)*, ExceptionInfo*);
	void  RegistryComponentTerminus();
	void* RemoveImageRegistry(const(char)*);
	void  ResetImageRegistryIterator();
}
