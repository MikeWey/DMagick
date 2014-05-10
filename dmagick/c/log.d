module dmagick.c.log;

import core.stdc.stdio;
import core.vararg;

import dmagick.c.exception;
import dmagick.c.magickType;
import dmagick.c.magickVersion;

extern(C)
{
	static if (MagickLibVersion >= 0x663)
	{
		enum LogEventType
		{
			UndefinedEvents,
			NoEvents = 0x00000,
			TraceEvent = 0x00001,
			AnnotateEvent = 0x00002,
			BlobEvent = 0x00004,
			CacheEvent = 0x00008,
			CoderEvent = 0x00010,
			ConfigureEvent = 0x00020,
			DeprecateEvent = 0x00040,
			DrawEvent = 0x00080,
			ExceptionEvent = 0x00100,
			ImageEvent = 0x00200,
			LocaleEvent = 0x00400,
			ModuleEvent = 0x00800,
			PolicyEvent = 0x01000,
			ResourceEvent = 0x02000,
			TransformEvent = 0x04000,
			UserEvent = 0x09000,
			WandEvent = 0x10000,
			X11Event = 0x20000,
			AccelerateEvent = 0x40000,
			AllEvents = 0x7fffffff
		}
	}
	else
	{
		enum LogEventType
		{
			UndefinedEvents,
			NoEvents = 0x00000,
			TraceEvent = 0x00001,
			AnnotateEvent = 0x00002,
			BlobEvent = 0x00004,
			CacheEvent = 0x00008,
			CoderEvent = 0x00010,
			ConfigureEvent = 0x00020,
			DeprecateEvent = 0x00040,
			DrawEvent = 0x00080,
			ExceptionEvent = 0x00100,
			LocaleEvent = 0x00200,
			ModuleEvent = 0x00400,
			PolicyEvent = 0x00800,
			ResourceEvent = 0x01000,
			TransformEvent = 0x02000,
			UserEvent = 0x04000,
			WandEvent = 0x08000,
			X11Event = 0x10000,
			AllEvents = 0x7fffffff
		}
	}

	struct LogInfo {}

	static if (MagickLibVersion >= 0x689)
	{
		alias void function(const LogEventType, const(char)*) MagickLogMethod;
	}

	char** GetLogList(const(char)*, size_t*, ExceptionInfo*);

	const(char)* GetLogName();
	const(char)* SetLogName(const(char)*);

	const(LogInfo)** GetLogInfoList(const(char)*, size_t*, ExceptionInfo*);

	LogEventType SetLogEventMask(const(char)*);

	MagickBooleanType IsEventLogging();
	MagickBooleanType ListLogInfo(FILE*, ExceptionInfo*);
	MagickBooleanType LogComponentGenesis();
	MagickBooleanType LogMagickEvent(const LogEventType, const(char)*, const(char)*, const size_t, const(char)*, ...);
	MagickBooleanType LogMagickEventList(const LogEventType, const(char)*, const(char)*, const size_t, const(char)*, va_list);

	void CloseMagickLog();
	void LogComponentTerminus();
	void SetLogFormat(const(char)*);

	static if (MagickLibVersion >= 0x689)
	{
		void SetLogMethod(MagickLogMethod);
	}
}
