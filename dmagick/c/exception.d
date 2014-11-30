module dmagick.c.exception;

import core.vararg;

import dmagick.c.magickType;
import dmagick.c.magickVersion;
import dmagick.c.semaphore;

extern(C)
{
	enum ExceptionType
	{
		UndefinedException,
		WarningException = 300,
		ResourceLimitWarning = 300,
		TypeWarning = 305,
		OptionWarning = 310,
		DelegateWarning = 315,
		MissingDelegateWarning = 320,
		CorruptImageWarning = 325,
		FileOpenWarning = 330,
		BlobWarning = 335,
		StreamWarning = 340,
		CacheWarning = 345,
		CoderWarning = 350,
		FilterWarning = 352,
		ModuleWarning = 355,
		DrawWarning = 360,
		ImageWarning = 365,
		WandWarning = 370,
		RandomWarning = 375,
		XServerWarning = 380,
		MonitorWarning = 385,
		RegistryWarning = 390,
		ConfigureWarning = 395,
		PolicyWarning = 399,
		ErrorException = 400,
		ResourceLimitError = 400,
		TypeError = 405,
		OptionError = 410,
		DelegateError = 415,
		MissingDelegateError = 420,
		CorruptImageError = 425,
		FileOpenError = 430,
		BlobError = 435,
		StreamError = 440,
		CacheError = 445,
		CoderError = 450,
		FilterError = 452,
		ModuleError = 455,
		DrawError = 460,
		ImageError = 465,
		WandError = 470,
		RandomError = 475,
		XServerError = 480,
		MonitorError = 485,
		RegistryError = 490,
		ConfigureError = 495,
		PolicyError = 499,
		FatalErrorException = 700,
		ResourceLimitFatalError = 700,
		TypeFatalError = 705,
		OptionFatalError = 710,
		DelegateFatalError = 715,
		MissingDelegateFatalError = 720,
		CorruptImageFatalError = 725,
		FileOpenFatalError = 730,
		BlobFatalError = 735,
		StreamFatalError = 740,
		CacheFatalError = 745,
		CoderFatalError = 750,
		FilterFatalError = 752,
		ModuleFatalError = 755,
		DrawFatalError = 760,
		ImageFatalError = 765,
		WandFatalError = 770,
		RandomFatalError = 775,
		XServerFatalError = 780,
		MonitorFatalError = 785,
		RegistryFatalError = 790,
		ConfigureFatalError = 795,
		PolicyFatalError = 799
	}

	struct ExceptionInfo
	{
		ExceptionType
			severity;

		int
			error_number;

		char*
			reason,
			description;

		void*
			exceptions;

		MagickBooleanType
			relinquish;

		SemaphoreInfo*
			semaphore;

		size_t
			signature;
	}

	alias void function(const ExceptionType, const(char)*, const(char)*) ErrorHandler;
	alias void function(const ExceptionType, const(char)*, const(char)*) FatalErrorHandler;
	alias void function(const ExceptionType, const(char)*, const(char)*) WarningHandler;

	char* GetExceptionMessage(const int);

	const(char*) GetLocaleExceptionMessage(const ExceptionType, const(char)*);

	ErrorHandler SetErrorHandler(ErrorHandler);

	ExceptionInfo* AcquireExceptionInfo();

	static if ( MagickLibVersion >= 0x669 )
	{
		ExceptionInfo* CloneExceptionInfo(ExceptionInfo*);
	}

	ExceptionInfo* DestroyExceptionInfo(ExceptionInfo*);

	FatalErrorHandler SetFatalErrorHandler(FatalErrorHandler);

	MagickBooleanType ThrowException(ExceptionInfo*, const ExceptionType, const(char)*, const(char)*);
	MagickBooleanType ThrowMagickException(ExceptionInfo*, const(char)*, const(char)*, const size_t, const ExceptionType, const(char)*, const(char)*, ...);
	MagickBooleanType ThrowMagickExceptionList(ExceptionInfo*, const(char)*, const(char)*, const size_t, const ExceptionType, const(char)*, const(char)*, va_list);

	void CatchException(ExceptionInfo*);
	void ClearMagickException(ExceptionInfo*);

	static if ( MagickLibVersion < 0x689 )
	{
		void GetExceptionInfo(ExceptionInfo*);
	}

	void InheritException(ExceptionInfo*, const(ExceptionInfo)*);
	void MagickError(const ExceptionType, const(char)*, const(char)*);
	void MagickFatalError(const ExceptionType, const(char)*, const(char)*);
	void MagickWarning(const ExceptionType, const(char)*, const(char)*);

	WarningHandler SetWarningHandler(WarningHandler);
}
