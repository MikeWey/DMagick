module dmagick.c.resource;

import core.stdc.stdio;

import dmagick.c.exception;
import dmagick.c.magickType;
import dmagick.c.magickVersion;

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

	static if ( MagickLibVersion >= 0x681 )
	{
		MagickBooleanType GetPathTemplate(char*);
	}

	MagickBooleanType ListMagickResourceInfo(FILE*, ExceptionInfo*);
	MagickBooleanType RelinquishUniqueFileResource(const(char)*);
	MagickBooleanType ResourceComponentGenesis();
	MagickBooleanType SetMagickResourceLimit(const ResourceType, const MagickSizeType);

	MagickSizeType GetMagickResource(const ResourceType);
	MagickSizeType GetMagickResourceLimit(const ResourceType);

	void AsynchronousResourceComponentTerminus();
	void RelinquishMagickResource(const ResourceType, const MagickSizeType);
	void ResourceComponentTerminus();
}
