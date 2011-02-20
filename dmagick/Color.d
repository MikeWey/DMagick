/**
 * Copyright: Mike Wey 2011
 * License:   To be determined
 * Authors:   Mike Wey
 */

module dmagick.Color;

import std.conv;
import std.string;

import dmagick.Exception;
import dmagick.Utils;

import dmagick.c.color;
import dmagick.c.exception;
import dmagick.c.magickType;
import dmagick.c.pixel;
import dmagick.c.quantum;

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
	this(Quantum red, Quantum green, Quantum blue, Quantum opacity = 0)
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
		if ( pixelPacket.opacity == 0 )
			return format("#%04X%04X%04X", pixelPacket.red, pixelPacket.green, pixelPacket.blue);
		else
			return format("#%04X%04X%04X%04X", pixelPacket.red, pixelPacket.green, pixelPacket.blue, pixelPacket.opacity);
	}

	void redQuantum(Quantum red)
	{
		pixelPacket.red = red;
	}
	Quantum redQuantum()
	{
		return pixelPacket.red;
	}

	void greenQuantum(Quantum green)
	{
		pixelPacket.green = green;
	}
	Quantum greenQuantum()
	{
		return pixelPacket.green;
	}

	void blueQuantum(Quantum blue)
	{
		pixelPacket.blue = blue;
	}
	Quantum blueQuantum()
	{
		return pixelPacket.blue;
	}

	void opacityByte(ubyte opacity)
	{
		pixelPacket.opacity = ScaleCharToQuantum(opacity);
	}
	ubyte opacityByte()
	{
		return ScaleQuantumToChar(pixelPacket.opacity);
	}

	void opacityQuantum(Quantum opacity)
	{
		pixelPacket.opacity = opacity;
	}
	Quantum opacityQuantum()
	{
		return pixelPacket.opacity;
	}

	void opacity(double opacity)
	{
		pixelPacket.opacity = scaleDoubleToQuantum(opacity);
	}
	double opacity()
	{
		return scaleQuantumToDouble(pixelPacket.opacity);
	}

	double intensity()
	{
		//The Constants used here are derived from BT.709 Which standardizes HDTV

		return scaleQuantumToDouble(cast(Quantum)(
			0.2126*pixelPacket.red+0.7152*pixelPacket.green+0.0722*pixelPacket.blue));
	}

	/**
	 * Create a copy of this Color.
	 */
	Color clone()
	{
		return new Color(*pixelPacket);
	}

	/**
	 * Returns the name of the color or the value as a hex string.
	 */
	string name()
	{
		char* pattern;
		size_t numberOfColors;
		const(ColorInfo)** colorList;
		ExceptionInfo* exception = AcquireExceptionInfo();

		copyString(pattern, "*");
		colorList = GetColorInfoList(pattern, &numberOfColors, exception);
		DMagickException.throwException(exception);

		for ( int i = 0; i < numberOfColors; i++ )
		{
			if ( colorList[i].compliance == ComplianceType.UndefinedCompliance )
				continue;

			MagickPixelPacket color = colorList[i].color;

			if ( pixelPacket.red == color.red && pixelPacket.green == color.green
				&& pixelPacket.blue == color.blue && pixelPacket.opacity == color.opacity )
					return to!(string)(colorList[i].name);
		}

		return toString();
	}

	static Quantum scaleDoubleToQuantum(double value)
	{
		return cast(Quantum)(value*QuantumRange);
	}

	static double scaleQuantumToDouble(Quantum value)
	{
		return (cast(double)value)/QuantumRange;
	}
}
