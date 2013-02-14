/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */

module dmagick.CoderInfo;

import std.conv;
import std.string;

import dmagick.Exception;

import dmagick.c.magick;

/**
 * This provides information about the image formats supported by
 * Imagemagick. The MatchType determines if a coder should be returned
 * in the array. MatchType.Any matches both MatchType.True
 * and MatchType.True.
 * 
 * Params:
 *     readable   = Does the coder need to provide read support.
 *     writable   = Does the coder need to provide write support.
 *     multiFrame = Does the coder need to provide multi frame support.
 */
CoderInfo[] coderInfoList(MatchType readable, MatchType writable, MatchType multiFrame)
{
	size_t length;
	CoderInfo[] list;

	const(MagickInfo)*[] infoList =
		GetMagickInfoList("*", &length, DMagickExceptionInfo())[0 .. length];

	foreach ( info; infoList )
	{
		CoderInfo coder = CoderInfo(info);

		if ( readable == MatchType.False && coder.readable )
			continue;

		if ( readable == MatchType.True && !coder.readable )
			continue;

		if ( writable == MatchType.False && coder.writable )
			continue;

		if ( writable == MatchType.True && !coder.writable )
			continue;

		if ( multiFrame == MatchType.False && coder.supportsMultiFrame )
			continue;

		if ( multiFrame == MatchType.True && !coder.supportsMultiFrame )
			continue;

		list ~= coder;
	}

	return list;
}

/**
 * CoderInfo provides the means to get information regarding ImageMagick
 * support for an image format (designated by a magick string). It may be
 * used to provide information for a specific named format (provided as an
 * argument to the constructor).
 */
struct CoderInfo
{
	/**
	 * Format name. (e.g. "GIF")
	 */
	string name;

	/**
	 * Format description. (e.g.  "CompuServe graphics interchange format")
	 */
	string description;

	/**
	 * Format is readable.
	 */
	bool readable;

	/**
	 * Format is writable.
	 */
	bool writable;

	/**
	 * Format supports multiple frames.
	 */
	bool supportsMultiFrame;


	/**
	 * Construct object corresponding to named format. (e.g. "GIF")
	 */
	this (string format)
	{
		const(MagickInfo)* info =
			GetMagickInfo(toStringz(format), DMagickExceptionInfo());

		this(info);
	}

	this (const(MagickInfo)* info)
	{
		name = to!(string)(info.name);
		description = to!(string)(info.description);
		readable = info.decoder !is null;
		writable = info.encoder !is null;
		supportsMultiFrame = info.adjoin != 0;
	}
}

///
enum MatchType
{
	Any,  /// Don't care.
	True, /// Matches.
	False /// Doesn't match.
}
