module dmagick.c.timer;

import dmagick.c.magickType;

extern(C)
{
	enum TimerState
	{
		UndefinedTimerState,
		StoppedTimerState,
		RunningTimerState
	}

	struct Timer
	{
		double
			start,
			stop,
			total;
	}

	struct TimerInfo
	{
		Timer
			user,
			elapsed;

		TimerState
			state;

		size_t
			signature;
	}

	double GetElapsedTime(TimerInfo*);
	double GetUserTime(TimerInfo*);

	MagickBooleanType ContinueTimer(TimerInfo*);

	TimerInfo* AcquireTimerInfo();
	TimerInfo* DestroyTimerInfo(TimerInfo*);

	void GetTimerInfo(TimerInfo*);
	void ResetTimer(TimerInfo*);
	void StartTimer(TimerInfo*, const MagickBooleanType);
}
