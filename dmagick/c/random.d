module dmagick.c.random;

import core.stdc.config;

import dmagick.c.magickString;
import dmagick.c.magickType;
import dmagick.c.magickVersion;

extern(C)
{
	struct RandomInfo {}

	double GetRandomValue(RandomInfo*);
	double GetPseudoRandomValue(RandomInfo*);

	MagickBooleanType RandomComponentGenesis();

	RandomInfo* AcquireRandomInfo();
	RandomInfo* DestroyRandomInfo(RandomInfo*);

	StringInfo* GetRandomKey(RandomInfo*, const size_t);

	static if ( MagickLibVersion >= 0x677 )
	{
		c_ulong GetRandomSecretKey(const(RandomInfo)*);
	}

	void RandomComponentTerminus();
	void SeedPseudoRandomGenerator(const size_t);
	void SetRandomKey(RandomInfo*, const size_t, ubyte*);

	static if ( MagickLibVersion >= 0x677 )
	{
		void SetRandomSecretKey(const c_ulong);
	}

	void SetRandomTrueRandom(const MagickBooleanType);
}
