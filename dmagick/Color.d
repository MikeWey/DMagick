/**
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

/**
 * A container for the pixel values: red, green, blue and opacity.
 */
class Color
{
	PixelPacket* pixelPacket;

	/** */
	this()
	{
		pixelPacket = new PixelPacket;

		pixelPacket.opacity = TransparentOpacity;
	}

	/**
	 * Create a Color from the specified Quantums.
	 */
	this(Quantum red, Quantum green, Quantum blue)
	{
		this(red, green, blue, 0);
	}

	/**
	 * ditto
	 */
	this(Quantum red, Quantum green, Quantum blue, Quantum opacity)
	{
		this();

		pixelPacket.red     = red;
		pixelPacket.green   = green;
		pixelPacket.blue    = blue;
		pixelPacket.opacity = opacity;
	}

	/**
	 * Create a Color from a X11 color specification string
	 */
	this(string color)
	{
		this();

		ExceptionInfo* exception = AcquireExceptionInfo();
		const(char)* name = toStringz(color);

		QueryColorDatabase(name, pixelPacket, exception);
		DMagickException.throwException(exception);

		DestroyExceptionInfo(exception);
	}

	/**
	 * Create a Color from this PixelPacket.
	 */
	this(PixelPacket packet)
	{
		this();

		pixelPacket.red     = packet.red;
		pixelPacket.green   = packet.green;
		pixelPacket.blue    = packet.blue;
		pixelPacket.opacity = packet.opacity;
	}

	/**
	 * Create a Color and set the internal pointer to this PixelPacket.
	 * We can use this to change pixels in an image through Color.
	 */
	this(PixelPacket* packet)
	{
		pixelPacket = packet;
	}

	bool opEquals(Color color)
	{
		return *pixelPacket == *(color.pixelPacket);
	}

	override string toString()
	{
		//TODO

		return "none";
	}

	/**
	 * Create a copy of this Color.
	 */
	Color clone()
	{
		return new Color(*pixelPacket);
	}
}
