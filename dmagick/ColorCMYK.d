/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */

module dmagick.ColorCMYK;

import std.algorithm;

import dmagick.Color;

import dmagick.c.magickType;
import dmagick.c.quantum;

/**
 * The CMY(K) color model describes a color space with subtractive color
 * composition as it is used for the color printing process, e.g. used by
 * ink or laser printers. Each color is described by the color components
 * cyan (C), magenta (M) and yellow (Y). The additional component black (K)
 * is used for better gray and black reproduction.
 * 
 * Note: This class doesn't use ICC or ICM profiles for the converson of
 *       CMYK to RGB.
 */
class ColorCMYK : Color
{
	/** */
	this()
	{
		super();
	}

	/**
	 * Create a CMYK Color from the specified doubles.
	 */
	this(double cyan, double magenta, double yellow, double black)
	{
		Quantum red, green, blue;

		convertCMYKToRGB(cyan, magenta, yellow, black, red, green, blue);

		super(red, green, blue);
	}

	/**
	 * The value for cyan.
	 */
	void cyan(double cyan)
	{
		double oldCyan, magenta, yellow, black;

		convertRGBToCMYK(packet.red, packet.green, packet.blue, oldCyan, magenta, yellow, black);
		convertCMYKToRGB(cyan, magenta, yellow, black, packet.red, packet.green, packet.blue);	
	}
	///ditto
	double cyan()
	{
		double cyan, magenta, yellow, black;

		convertRGBToCMYK(packet.red, packet.green, packet.blue, cyan, magenta, yellow, black);

		return cyan;
	}

	/**
	 * The value for magenta.
	 */
	void magenta(double magenta)
	{
		double cyan, oldMagenta, yellow, black;

		convertRGBToCMYK(packet.red, packet.green, packet.blue, cyan, oldMagenta, yellow, black);
		convertCMYKToRGB(cyan, magenta, yellow, black, packet.red, packet.green, packet.blue);	
	}
	///ditto
	double magenta()
	{
		double cyan, magenta, yellow, black;

		convertRGBToCMYK(packet.red, packet.green, packet.blue, cyan, magenta, yellow, black);

		return magenta;
	}

	/**
	 * The value for yellow.
	 */
	void yellow(double yellow)
	{
		double cyan, magenta, oldYellow, black;

		convertRGBToCMYK(packet.red, packet.green, packet.blue, cyan, magenta, oldYellow, black);
		convertCMYKToRGB(cyan, magenta, yellow, black, packet.red, packet.green, packet.blue);	
	}
	///ditto
	double yellow()
	{
		double cyan, magenta, yellow, black;

		convertRGBToCMYK(packet.red, packet.green, packet.blue, cyan, magenta, yellow, black);

		return yellow;
	}

	/**
	 * The value for black.
	 */
	void black(double black)
	{
		double cyan, magenta, yellow, oldBlack;

		convertRGBToCMYK(packet.red, packet.green, packet.blue, cyan, magenta, yellow, oldBlack);
		convertCMYKToRGB(cyan, magenta, yellow, black, packet.red, packet.green, packet.blue);	
	}
	///ditto
	double black()
	{
		double cyan, magenta, yellow, black;

		convertRGBToCMYK(packet.red, packet.green, packet.blue, cyan, magenta, yellow, black);

		return black;
	}

	/**
	 * Convert an RGB value to a CMYK value.
	 */
	private void convertRGBToCMYK(Quantum red, Quantum green, Quantum blue, ref double cyan, ref double magenta, ref double yellow, ref double black)
	{
		double r = scaleQuantumToDouble(red);
		double g = scaleQuantumToDouble(green);
		double b = scaleQuantumToDouble(blue);

		black = min(1 - r, 1 - g, 1 - b);

		cyan    = (1 - r - black) / (1 - black);
		magenta = (1 - g - black) / (1 - black);
		yellow  = (1 - b - black) / (1 - black);
	}

	/**
	 * Convert an CMYK value to a RGB value.
	 */
	private void convertCMYKToRGB(double cyan, double magenta, double yellow, double black, ref Quantum red, ref Quantum green, ref Quantum blue)
	in
	{
		assert(cyan    <= 1 && cyan    >= 0);
		assert(magenta <= 1 && magenta >= 0);
		assert(yellow  <= 1 && yellow  >= 0);
		assert(black   <= 1 && black   >= 0);
	}
	body
	{
		double r = 1 - min(1, cyan    * (1 - black) + black);
		double g = 1 - min(1, magenta * (1 - black) + black);
		double b = 1 - min(1, yellow  * (1 - black) + black);

		red   = scaleDoubleToQuantum(r);
		green = scaleDoubleToQuantum(g);
		blue  = scaleDoubleToQuantum(b);
	}
}

unittest
{
	assert(new ColorCMYK(0,   1,   1,   0  ) == new Color("red"));

	auto color1 = new ColorCMYK(0.5, 0.5, 0.5, 0.5);
	auto color2 = new Color("gray25");

	//Compare the colors a bytes, to compensate for rounding errors.
	assert(ScaleQuantumToChar(color1.redQuantum)   == ScaleQuantumToChar(color2.redQuantum));
	assert(ScaleQuantumToChar(color1.greenQuantum) == ScaleQuantumToChar(color2.greenQuantum));
	assert(ScaleQuantumToChar(color1.blueQuantum)  == ScaleQuantumToChar(color2.blueQuantum));
}
