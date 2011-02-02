/**
 * A class to expose ImageInfo QuantizeInfo and DrawInfo
 *
 * Copyright: Mike Wey 2011
 * License:   To be determined
 * Authors:   Mike Wey
 */

module dmagick.Exception;

import std.conv;

import dmagick.c.client;
import dmagick.c.exception;

/**
 * A base class for all exceptions thrown bij DMagick.
 * The following Exceptions are derived from this class: $(BR)$(BR)
 * ResourceLimitException, TypeException, OptionException,
 * DelegateException, MissingDelegateException, CorruptImageException,
 * FileOpenException, BlobException, StreamException, CacheException,
 * CoderException, FilterException, ModuleException, DrawException,
 * ImageException, WandException, RandomException, XServerException,
 * MonitorException, RegistryException, ConfigureException, PolicyException
 */
class MagickException : Exception
{
	this(string reason, string description)
	{
		string message = to!(string)(GetClientName());

		if ( reason.length > 0 )
			message ~= ": " ~ reason;
		if ( description.length > 0 )
			message ~= " (" ~ description ~ ")";

		super(message);
	}
}

/**
 * A base class for all errors thrown bij DMagick.
 * The following Errors are derived from this class: $(BR)$(BR)
 * ResourceLimitError, TypeError, OptionError,
 * DelegateError, MissingDelegateError, CorruptImageError,
 * FileOpenError, BlobError, StreamError, CacheError,
 * CoderError, FilterError, ModuleError, DrawError,
 * ImageError, WandError, RandomError, XServerError,
 * MonitorError, RegistryError, ConfigureError, PolicyError
 */
class MagickError : Error
{
	this(string reason, string description)
	{
		string message = to!(string)(GetClientName());

		if ( reason.length > 0 )
			message ~= ": " ~ reason;
		if ( description.length > 0 )
			message ~= " (" ~ description ~ ")";

		super(message);
	}
}

mixin(generateExceptions());

/**
 * Generate the exceptions and the throwException function;
 */
private string generateExceptions()
{
	string[] severities = [ "Blob", "Cache", "Coder", "Configure",
		"CorruptImage", "Delegate", "Draw", "FileOpen", "Filter",
		"Image", "MissingDelegate", "Module", "Monitor", "Option",
		"Policy", "Random", "Registry", "ResourceLimit", "Stream",
		"Type", "Wand", "XServer" ];

	string exceptions;

	exceptions ~= 
		"void throwException(ExceptionInfo* exception)
		 {
			if ( exception.severity == ExceptionType.UndefinedException )
				return;

			string reason      = to!(string)(exception.reason);
			string description = to!(string)(exception.description);	

			switch(exception.severity)
			{";

	foreach ( severity; severities )
	{
		exceptions ~=
			"case ExceptionType."~ severity ~"Warning:
				throw new "~ severity ~"Exception(reason, description);
				break;";
	}

	exceptions ~= "}}";

	foreach ( severity; severities )
	{
		exceptions ~= 
			"class " ~ severity ~ "Exception : MagickException
			 {
				this(string reason, string description)
				{
					super(reason, description);
				}
			 }";

		exceptions ~= 
			"class " ~ severity ~ "Error : MagickError
			 {
				this(string reason, string description)
				{
					super(reason, description);
				}
			 }";
	}

	return exceptions;
}

