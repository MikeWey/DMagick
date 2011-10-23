/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */

module dmagick.ColorHSL;

import dmagick.Color;

import dmagick.c.gem;
import dmagick.c.magickType;
import dmagick.c.quantum;

/**
 * The HSL color model describes a color by using the three color components
 * hue (H), saturation (S) and luminance (L). This color format is very
 * popular for designing and editing (e.g. within graphics design tools)
 * because it gives the user a good impression about the resulting color
 * for a certain color value: Hue defines the pure color tone out of the
 * color spectrum, saturation defines the mixture of the color tone with
 * gray and finally luminance defines the lightness of the resulting color.
 */
class ColorHSL : Color
{
	/** */
	this()
	{
		super();
	}

	/**
	 * Create a Color from the specified doubles.
	 */
	this(double hue, double saturation, double luminance, double opacity = 0)
	{
		Quantum red, green, blue;

		 ConvertHSLToRGB(hue, saturation, luminance, &red, &green, &blue);

		super(red, green, blue, scaleDoubleToQuantum(opacity));
	}

	/**
	 * Create a Color from a X11 color specification string
	 */
	this(string color)
	{
		super(color);
	}

	/**
	 * The value for hue as a an angle between 0 and 360 degrees.
	 */
	void hue(double hue)
	{
		double oldHue, saturation, luminance;

		ConvertRGBToHSL(packet.red, packet.green, packet.blue, &oldHue, &saturation, &luminance);
		ConvertHSLToRGB(hue, saturation, luminance, &(packet.red), &(packet.green), &(packet.blue));
	}
	///ditto
	double hue()
	{
		double hue, saturation, luminance;

		ConvertRGBToHSL(packet.red, packet.green, packet.blue, &hue, &saturation, &luminance);

		return hue;
	}

	/**
	 * The value the saturation as a double in the range [0.0 .. 1.0]
	 */
	void saturation(double saturation)
	{
		double hue, oldSaturation, luminance;

		ConvertRGBToHSL(packet.red, packet.green, packet.blue, &hue, &oldSaturation, &luminance);
		ConvertHSLToRGB(hue, saturation, luminance, &(packet.red), &(packet.green), &(packet.blue));
	}
	///ditto
	double saturation()
	{
		double hue, saturation, luminance;

		ConvertRGBToHSL(packet.red, packet.green, packet.blue, &hue, &saturation, &luminance);

		return saturation;
	}

	/**
	 * The value for the luminance as a double in the range [0.0 .. 1.0]
	 */
	void luminance(double luminance)
	{
		double hue, saturation, oldLuminance;

		ConvertRGBToHSL(packet.red, packet.green, packet.blue, &hue, &saturation, &oldLuminance);
		ConvertHSLToRGB(hue, saturation, luminance, &(packet.red), &(packet.green), &(packet.blue));
	}
	///ditto
	double luminance()
	{
		double hue, saturation, luminance;

		ConvertRGBToHSL(packet.red, packet.green, packet.blue, &hue, &saturation, &luminance);

		return luminance;
	}
}
