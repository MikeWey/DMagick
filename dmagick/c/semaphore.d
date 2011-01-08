module dmagick.c.semaphore;

import dmagick.c.magickType;

extern(C)
{
	struct SemaphoreInfo {}

	MagickBooleanType SemaphoreComponentGenesis();

	SemaphoreInfo* AllocateSemaphoreInfo();

	void AcquireSemaphoreInfo(SemaphoreInfo**);
	void DestroySemaphoreInfo(SemaphoreInfo**);
	void LockSemaphoreInfo(SemaphoreInfo*);
	void RelinquishSemaphoreInfo(SemaphoreInfo*);
	void SemaphoreComponentTerminus();
	void UnlockSemaphoreInfo(SemaphoreInfo*);
}
