module dmagick.c.semaphore;

import dmagick.c.magickType;
import dmagick.c.magickVersion;

extern(C)
{
	struct SemaphoreInfo {}

	MagickBooleanType SemaphoreComponentGenesis();

	SemaphoreInfo* AllocateSemaphoreInfo();

	static if ( MagickLibVersion < 0x689 )
	{
		void AcquireSemaphoreInfo(SemaphoreInfo**);
	}

	static if ( MagickLibVersion >= 0x689 )
	{
		void ActivateSemaphoreInfo(SemaphoreInfo**);
	}

	void DestroySemaphoreInfo(SemaphoreInfo**);
	void LockSemaphoreInfo(SemaphoreInfo*);

	static if ( MagickLibVersion < 0x689 )
	{
		void RelinquishSemaphoreInfo(SemaphoreInfo*);
	}

	void SemaphoreComponentTerminus();
	void UnlockSemaphoreInfo(SemaphoreInfo*);
}
