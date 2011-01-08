module dmagick.c.resource;

import core.stdc.stdio;

import dmagick.c.exception;
import dmagick.c.magickType;

extern(C)
{
	enum ResourceType
	{
		UndefinedResource,
		AreaResource,
		DiskResource,
		FileResource,
		MapResource,
		MemoryResource,
		ThreadResource,
		TimeResource,
		ThrottleResource
	}

	int AcquireUniqueFileResource(char*);

	MagickBooleanType AcquireMagickResource(const ResourceType, const MagickSizeType);
	MagickBooleanType ListMagickResourceInfo(FILE*, ExceptionInfo*);
	MagickBooleanType RelinquishUniqueFileResource(const char*);
	MagickBooleanType ResourceComponentGenesis();
	MagickBooleanType SetMagickResourceLimit(const ResourceType, const MagickSizeType);

	MagickSizeType GetMagickResource(const ResourceType);
	MagickSizeType GetMagickResourceLimit(const ResourceType);

	void AsynchronousResourceComponentTerminus();
	void RelinquishMagickResource(const ResourceType, const MagickSizeType);
	void ResourceComponentTerminus();
}
