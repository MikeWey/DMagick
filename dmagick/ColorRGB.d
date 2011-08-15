/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */

module dmagick.ColorRGB;

import dmagick.Color;

import dmagick.c.magickType;
import dmagick.c.quantum;

/**
 * An RGB(A) Color.
 */
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
		super(ScaleCharToQuantum(red),
			ScaleCharToQuantum(green),
			ScaleCharToQuantum(blue),
			ScaleCharToQuantum(opacity));
	}

	/**
	 * Create a Color from the specified doubles.
	 * The values should be between 0.0 and 1.0.
	 */
	this(double red, double green, double blue, double opacity = 0)
	{
		super(scaleDoubleToQuantum(red),
			scaleDoubleToQuantum(green),
			scaleDoubleToQuantum(blue),
			scaleDoubleToQuantum(opacity));
	}

	/**
	 * Create a Color from a X11 color specification string
	 */
	this(string color)
	{
		super(color);
	}

	/**
	 * The value for red as a byte
	 */
	void redByte(ubyte red)
	{
		pixelPacket.red = ScaleCharToQuantum(red);
	}
	///ditto
	ubyte redByte()
	{
		return ScaleQuantumToChar(pixelPacket.red);
	}

	/**
	 * The value for green as a byte
	 */
	void greenByte(ubyte green)
	{
		pixelPacket.green = ScaleCharToQuantum(green);
	}
	///ditto
	ubyte greenByte()
	{
		return ScaleQuantumToChar(pixelPacket.green);
	}

	/**
	 * The value for blue as a byte
	 */
	void blueByte(ubyte blue)
	{
		pixelPacket.blue = ScaleCharToQuantum(blue);
	}
	///ditto
	ubyte blueByte()
	{
		return ScaleQuantumToChar(pixelPacket.blue);
	}

	/**
	 * The value for red as a double in the range [0.0 .. 1.0]
	 */
	void red(double red)
	{
		pixelPacket.red = scaleDoubleToQuantum(red);
	}
	///ditto
	double red()
	{
		return scaleQuantumToDouble(pixelPacket.red);
	}

	/**
	 * The value for green as a double in the range [0.0 .. 1.0]
	 */
	void green(double green)
	{
		pixelPacket.green = scaleDoubleToQuantum(green);
	}
	///ditto
	double green()
	{
		return scaleQuantumToDouble(pixelPacket.green);
	}

	/**
	 * The value for blue as a double in the range [0.0 .. 1.0]
	 */
	void blue(double blue)
	{
		pixelPacket.blue = scaleDoubleToQuantum(blue);
	}
	///ditto
	double blue()
	{
		return scaleQuantumToDouble(pixelPacket.blue);
	}
}
