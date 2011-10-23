/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */

module dmagick.ColorGray;

import dmagick.Color;

import dmagick.c.magickType;
import dmagick.c.quantum;

/**
 * A Gray scale color.
 */
class ColorGray : Color
{
	/** */
	this()
	{
		super();
	}

	/**
	 * Create a Color from the specified Bytes.
	 */
	this(ubyte shade, ubyte opacity = 0)
	{
		Quantum gray = ScaleCharToQuantum(shade);

		super(gray, gray, gray, ScaleCharToQuantum(opacity));
	}

	/**
	 * Create a Color from the specified doubles.
	 * The values should be between 0.0 and 1.0.
	 */
	this(double shade, double opacity = 0)
	{
		Quantum gray = scaleDoubleToQuantum(shade);

		super(gray, gray, gray, scaleDoubleToQuantum(opacity));
	}

	/**
	 * The value for the shade as a double in the range [0.0 .. 1.0]
	 */
	void shade(double shade)
	{
		packet.red   = scaleDoubleToQuantum(shade);
		packet.green = scaleDoubleToQuantum(shade);
		packet.blue  = scaleDoubleToQuantum(shade);
	}
	///ditto
	double shade()
	{
		return scaleQuantumToDouble(packet.red);
	}
}
