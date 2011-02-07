/**
 * The image
 *
 * Copyright: Mike Wey 2011
 * License:   To be determined
 * Authors:   Mike Wey
 */

module dmagick.Color;

import std.string;

import dmagick.Exception;
import dmagick.Utils;

import dmagick.c.color;
import dmagick.c.exception;
import dmagick.c.pixel;
import dmagick.c.magickType;

class Color
{
	PixelPacket pixelPacket;

	this()
	{
		pixelPacket.opacity = TransparentOpacity;
	}

	this(Quantum red, Quantum green, Quantum blue)
	{
		this(red, green, blue, 0);
	}

	this(Quantum red, Quantum green, Quantum blue, Quantum opacity)
	{
		this();

		pixelPacket.red     = red;
		pixelPacket.green   = green;
		pixelPacket.blue    = blue;
		pixelPacket.opacity = opacity;
	}

	this(string color)
	{
		this();

		ExceptionInfo* exception = AcquireExceptionInfo();
		const(char)* name = toStringz(color);

		QueryColorDatabase(name, &pixelPacket, exception);
		DMagickException.throwException(exception);

		DestroyExceptionInfo(exception);
	}

	this(PixelPacket packet)
	{
		pixelPacket = packet;
	}

	bool opEquals(Color color)
	{
		return pixelPacket == color.pixelPacket;
	}

	override string toString()
	{
		//TODO

		return "none";
	}

	Color clone()
	{
		return new Color(pixelPacket);
	}
}
