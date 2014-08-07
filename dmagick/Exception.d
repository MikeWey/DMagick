/**
 * Classes that wrap the Imagemagick exception handling.
 *
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */

module dmagick.Exception;

import std.conv;

import dmagick.c.client;
import dmagick.c.exception;

/**
 * A base class for all exceptions thrown bij DMagick.
 * The following Exceptions are derived from this class:
 *
 * ResourceLimitException, TypeException, OptionException,
 * DelegateException, MissingDelegateException, CorruptImageException,
 * FileOpenException, BlobException, StreamException, CacheException,
 * CoderException, FilterException, ModuleException, DrawException,
 * ImageException, WandException, RandomException, XServerException,
 * MonitorException, RegistryException, ConfigureException, PolicyException
 */
class DMagickException : Exception
{
	this(string reason, string description = null, string file = __FILE__, size_t line = __LINE__)
	{
		string message = to!(string)(GetClientName());

		if ( reason.length > 0 )
			message ~= ": " ~ reason;
		if ( description.length > 0 )
			message ~= " (" ~ description ~ ")";

		super(message, file, line);
	}

	private enum string[] severities = [ "Blob", "Cache", "Coder",
		"Configure", "CorruptImage", "Delegate", "Draw", "FileOpen",
		"Filter", "Image", "MissingDelegate", "Module", "Monitor",
		"Option", "Policy", "Random", "Registry", "ResourceLimit",
		"Stream", "Type", "Wand", "XServer" ];

	/**
	 * Throws an Exception or error matching the ExceptionInfo.
	 */
	static void throwException(ExceptionInfo* exception, string file = __FILE__, size_t line = __LINE__)
	{
		if ( exception.severity == ExceptionType.UndefinedException )
			return;

		string reason      = to!(string)(exception.reason);
		string description = to!(string)(exception.description);

		scope(exit) exception = DestroyExceptionInfo(exception);

		mixin(
		{
			string exceptions =
				"switch ( exception.severity )
			 	{";

			foreach ( severity; severities )
			{
				//TODO: Warnings?
				exceptions ~=
					"case ExceptionType."~ severity ~"Error:
						throw new "~ severity ~"Exception(reason, description, file, line);
					 case ExceptionType."~ severity ~"FatalError:
						throw new "~ severity ~"Error(reason, description, file, line);";
			}

			return exceptions ~= 
				"	default:
						return;
				}";
		}());
	}
}

/**
 * A base class for all errors thrown bij DMagick.
 * The following Errors are derived from this class:
 *
 * ResourceLimitError, TypeError, OptionError,
 * DelegateError, MissingDelegateError, CorruptImageError,
 * FileOpenError, BlobError, StreamError, CacheError,
 * CoderError, FilterError, ModuleError, DrawError,
 * ImageError, WandError, RandomError, XServerError,
 * MonitorError, RegistryError, ConfigureError, PolicyError
 */
class DMagickError : Error
{
	this(string reason, string description = null, string file = __FILE__, size_t line = __LINE__)
	{
		string message = to!(string)(GetClientName());

		if ( reason.length > 0 )
			message ~= ": " ~ reason;
		if ( description.length > 0 )
			message ~= " (" ~ description ~ ")";

		super(message, file, line);
	}
}

/**
 * Generate the exceptions and the throwException function;
 */
mixin(
{
	string exceptions;

	foreach ( severity; DMagickException.severities )
	{
		exceptions ~= 
			"class " ~ severity ~ "Exception : DMagickException
			 {
				this(string reason, string description = null, string file = __FILE__, size_t line = __LINE__)
				{
					super(reason, description, file, line);
				}
			 }";

		exceptions ~= 
			"class " ~ severity ~ "Error : DMagickError
			 {
				this(string reason, string description = null, string file = __FILE__, size_t line = __LINE__)
				{
					super(reason, description, file, line);
				}
			 }";
	}

	return exceptions;
}());

/**
 * This struct is used to wrap the ImageMagick exception handling.
 * Needs dmd >= 2.053
 * Usage:
 * --------------------
 * CFunctionCall(param1, param2, DExceptionInfo());
 * --------------------
 */
struct DMagickExceptionInfo
{
	ExceptionInfo* exceptionInfo;

	string file;
	size_t line;

	private bool isInitialized;
	private size_t* refcount;

	alias exceptionInfo this;

	static DMagickExceptionInfo opCall(string file = __FILE__, size_t line = __LINE__)
	{
		DMagickExceptionInfo info;

		info.exceptionInfo = AcquireExceptionInfo();
		info.refcount = new size_t;

		*(info.refcount) = 1;
		info.isInitialized = true;

		info.file = file;
		info.line = line;

		return info;
	}

	this(this)
	{
		if ( isInitialized )
			(*refcount)++;
	}

	~this()
	{
		if ( !isInitialized )
			return;

		(*refcount)--;

		if ( *refcount == 0 )
		{
			DMagickException.throwException(exceptionInfo, file, line);
		}
	}
}

unittest
{
	void testDMagickExcepionInfo(ExceptionInfo* info)
	{
		assert(info !is null);
	}

	testDMagickExcepionInfo(DMagickExceptionInfo());
}
