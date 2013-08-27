/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */

module dmagick.Color;

import std.conv;
import std.math;
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

		packet.opacity = OpaqueOpacity;
	}

	/**
	 * Create a Color from the specified Quantums.
	 */
	this(Quantum red, Quantum green, Quantum blue, Quantum opacity = OpaqueOpacity)
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

		this.packet.red     = packet.red;
		this.packet.green   = packet.green;
		this.packet.blue    = packet.blue;
		this.packet.opacity = packet.opacity;
	}

	/**
	 * Create a Color and set the internal pointer to this PixelPacket.
	 * We can use this to change pixels in an image through Color.
	 */
	package this(PixelPacket* packet)
	{
		this.packet = packet;
	}

	package PixelPacket pixelPacket() const
	{
		return *packet;
	}

	package void pixelPacket(PixelPacket packet)
	{
		this.packet.red     = packet.red;
		this.packet.green   = packet.green;
		this.packet.blue    = packet.blue;
		this.packet.opacity = packet.opacity;
	}

	/** */
	override bool opEquals(Object obj)
	{
		Color color = cast(Color)obj;

		if ( color is null )
			return false;

		return pixelPacket == color.pixelPacket;
	}

	/**
	 * Returns the value as a hex string.
	 */
	override string toString() const
	{
		static if ( MagickQuantumDepth == 8 )
			string frm = "%02X";
		else static if ( MagickQuantumDepth == 16 )
			string frm = "%04X";
		else static if ( MagickQuantumDepth == 32 )
			string frm = "%08X";
		else
			string frm = "%016X";

		if ( packet.opacity == OpaqueOpacity )
			return format("#"~frm~frm~frm, rndtol(packet.red), rndtol(packet.green), rndtol(packet.blue));
		else
			return format("#"~frm~frm~frm~frm, rndtol(packet.red), rndtol(packet.green), rndtol(packet.blue), rndtol(QuantumRange-packet.opacity));
	}

	unittest
	{
		Color color = new Color("blue");

		static if ( MagickQuantumDepth == 8 )
			assert(color.toString() == "#0000FF");
		else static if ( MagickQuantumDepth == 16 )
			assert(color.toString() == "#00000000FFFF");
		else static if ( MagickQuantumDepth == 16 )
			assert(color.toString() == "#0000000000000000FFFFFFFF");
		else
			assert(color.toString() == "#00000000000000000000000000000000FFFFFFFFFFFFFFFF");
	}

	/*
	 * Needed when comparing colors with dmd 2.058.
	 */
	Object opCast(T)()
		if ( is(T == Object) )
	{
		return this;
	}

	/**
	 * Support casting between different colors.
	 * You can also use std.conv.to
	 */
	T opCast(T : Color)()
	{
		T color = new T();
		color.packet = packet;

		return color;
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

	static pure nothrow Quantum scaleDoubleToQuantum(double value)
	{
		return cast(Quantum)(value*QuantumRange);
	}

	static pure nothrow double scaleQuantumToDouble(Quantum value)
	{
		return (cast(double)value)/QuantumRange;
	}
}
