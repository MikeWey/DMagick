module dmagick.c.random;

import dmagick.c.magickString;
import dmagick.c.magickType;

extern(C)
{
	struct RandomInfo {}

	double GetRandomValue(RandomInfo*);
	double GetPseudoRandomValue(RandomInfo*);

	MagickBooleanType RandomComponentGenesis();

	RandomInfo* AcquireRandomInfo();
	RandomInfo* DestroyRandomInfo(RandomInfo*);

	StringInfo* GetRandomKey(RandomInfo*, const size_t);

	void RandomComponentTerminus();
	void SeedPseudoRandomGenerator(const size_t);
	void SetRandomKey(RandomInfo*, const size_t, ubyte*);
	void SetRandomTrueRandom(const MagickBooleanType);
}
