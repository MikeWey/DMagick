/**
 * Copyright: Mike Wey 2011
 * License:   To be determined
 * Authors:   Mike Wey
 */

module dmagick.ColorRGB;

import dmagick.Color;

import dmagick.c.magickType;
import dmagick.c.quantum;

class ColorRGB : Color
{
	this()
	{
		super();
	}

	/**
	 * Create a Color from the specified Bytes.
	 */
	this(ubyte red, ubyte green, ubyte blue, ubyte opacity = 0)
	{
		super();

		pixelPacket.red     = ScaleCharToQuantum(red);
		pixelPacket.green   = ScaleCharToQuantum(green);
		pixelPacket.blue    = ScaleCharToQuantum(blue);
		pixelPacket.opacity = ScaleCharToQuantum(opacity);
	}

	/**
	 * Create a Color from the specified doubles.
	 * The values should be between 0.0 and 1.0.
	 */
	this(double red, double green, double blue, double opacity = 0)
	{
		super();

		pixelPacket.red     = scaleDoubleToQuantum(red);
		pixelPacket.green   = scaleDoubleToQuantum(green);
		pixelPacket.blue    = scaleDoubleToQuantum(blue);
		pixelPacket.opacity = scaleDoubleToQuantum(opacity);
	}

	/**
	 * Create a Color from a X11 color specification string
	 */
	this(string color)
	{
		super(color);
	}

	void redByte(ubyte red)
	{
		pixelPacket.red = ScaleCharToQuantum(red);
	}
	ubyte redByte()
	{
		return ScaleQuantumToChar(pixelPacket.red);
	}

	void greenByte(ubyte green)
	{
		pixelPacket.green = ScaleCharToQuantum(green);
	}
	ubyte greenByte()
	{
		return ScaleQuantumToChar(pixelPacket.green);
	}

	void blueByte(ubyte blue)
	{
		pixelPacket.blue = ScaleCharToQuantum(blue);
	}
	ubyte blueByte()
	{
		return ScaleQuantumToChar(pixelPacket.blue);
	}

	void red(double red)
	{
		pixelPacket.red = scaleDoubleToQuantum(red);
	}
	double red()
	{
		return scaleQuantumToDouble(pixelPacket.red);
	}

	void green(double green)
	{
		pixelPacket.green = scaleDoubleToQuantum(green);
	}
	double green()
	{
		return scaleQuantumToDouble(pixelPacket.green);
	}

	void blue(double blue)
	{
		pixelPacket.blue = scaleDoubleToQuantum(blue);
	}
	double blue()
	{
		return scaleQuantumToDouble(pixelPacket.blue);
	}
}
