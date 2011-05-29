/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */

module dmagick.Color;

import std.conv;
import std.string;

import dmagick.Exception;
import dmagick.Utils;

import dmagick.c.color;
import dmagick.c.magickType;
import dmagick.c.pixel;
import dmagick.c.quantum;

/**
 * A container for the pixel values: red, green, blue and opacity.
 */
class Color
{
	PixelPacket* packet;

	/** */
	this()
	{
		packet = new PixelPacket;

		packet.opacity = TransparentOpacity;
	}

	/**
	 * Create a Color from the specified Quantums.
	 */
	this(Quantum red, Quantum green, Quantum blue, Quantum opacity = 0)
	{
		this();

		packet.red     = red;
		packet.green   = green;
		packet.blue    = blue;
		packet.opacity = opacity;
	}

	/**
	 * Create a Color from a X11 color specification string
	 */
	this(string color)
	{
		this();

		const(char)* name = toStringz(color);

		QueryColorDatabase(name, packet, DMagickExceptionInfo());
	}

	/**
	 * Create a Color from this PixelPacket.
	 */
	this(PixelPacket packet)
	{
		this();

		packet.red     = packet.red;
		packet.green   = packet.green;
		packet.blue    = packet.blue;
		packet.opacity = packet.opacity;
	}

	/**
	 * Create a Color and set the internal pointer to this PixelPacket.
	 * We can use this to change pixels in an image through Color.
	 */
	this(PixelPacket* packet)
	{
		packet = packet;
	}

	PixelPacket pixelPacket()
	{
		return *packet;
	}

	bool opEquals(Color color)
	{
		return pixelPacket == color.pixelPacket;
	}

	override string toString()
	{
		static if ( MagickQuantumDepth == 8 )
			string frm = "%02X";
		else static if ( MagickQuantumDepth == 16 )
			string frm = "%04X";
		else
			string frm = "%08X";

		if ( packet.opacity == 0 )
			frm = "#" ~ frm ~ frm ~ frm;
		else
			frm = "#" ~ frm ~ frm ~ frm ~ frm;

		return format(frm, packet.red, packet.green, packet.blue, packet.opacity);
	}

	/**
	 * The value for red in the range [0 .. QuantumRange]
	 */
	void redQuantum(Quantum red)
	{
		packet.red = red;
	}
	///ditto
	Quantum redQuantum()
	{
		return packet.red;
	}

	/**
	 * The value for green in the range [0 .. QuantumRange]
	 */
	void greenQuantum(Quantum green)
	{
		packet.green = green;
	}
	///ditto
	Quantum greenQuantum()
	{
		return packet.green;
	}

	/**
	 * The value for blue in the range [0 .. QuantumRange]
	 */
	void blueQuantum(Quantum blue)
	{
		packet.blue = blue;
	}
	///ditto
	Quantum blueQuantum()
	{
		return packet.blue;
	}

	/**
	 * The opacity as a byte. [0 .. 255]
	 */
	void opacityByte(ubyte opacity)
	{
		packet.opacity = ScaleCharToQuantum(opacity);
	}
	///ditto
	ubyte opacityByte()
	{
		return ScaleQuantumToChar(packet.opacity);
	}

	/**
	 * The value for opacity in the range [0 .. QuantumRange]
	 */
	void opacityQuantum(Quantum opacity)
	{
		packet.opacity = opacity;
	}
	///ditto
	Quantum opacityQuantum()
	{
		return packet.opacity;
	}

	/**
	 * The value for opacity as a double in the range [0.0 .. 1.0]
	 */
	void opacity(double opacity)
	{
		packet.opacity = scaleDoubleToQuantum(opacity);
	}
	///ditto
	double opacity()
	{
		return scaleQuantumToDouble(packet.opacity);
	}

	/**
	 * The intensity of this color.
	 */
	double intensity()
	{
		//The Constants used here are derived from BT.709 Which standardizes HDTV

		return scaleQuantumToDouble(cast(Quantum)(
			0.2126*packet.red+0.7152*packet.green+0.0722*packet.blue));
	}

	/**
	 * Create a copy of this Color.
	 */
	Color clone()
	{
		return new Color(pixelPacket);
	}

	/**
	 * Returns the name of the color or the value as a hex string.
	 */
	string name()
	{
		size_t numberOfColors;
		const(ColorInfo)** colorList;
		const(char)* pattern = toStringz("*");

		colorList = GetColorInfoList(pattern, &numberOfColors, DMagickExceptionInfo());

		for ( int i = 0; i < numberOfColors; i++ )
		{
			if ( colorList[i].compliance == ComplianceType.UndefinedCompliance )
				continue;

			MagickPixelPacket color = colorList[i].color;

			if ( packet.red == color.red && packet.green == color.green
				&& packet.blue == color.blue && packet.opacity == color.opacity )
					return to!(string)(colorList[i].name);
		}

		return toString();
	}

	unittest
	{
		Color color = new Color("red");
		assert( color.name == "red" );
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
