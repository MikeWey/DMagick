/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */

module dmagick.ColorYUV;

import dmagick.Color;

import dmagick.c.magickType;
import dmagick.c.quantum;

/**
 * The YUV color format describes a color by using the color components
 * luminance and chrominance. The luminance component (Y) represents the
 * brightness information of a color, the chrominance components (U and V)
 * contain the color differences.
 * 
 * The YUV color format was developed for analog TV transmissions to provide
 * compatibility between black-and-white television and color television:
 * The luminance component is sufficient for black-and-white TV sets,
 * whereas color TV sets need the additional chrominance information.
 */
class ColorYUV : Color
{
	/** */
	this()
	{
		super();
	}

	/**
	 * Create a YUV Color from the specified doubles.
	 * 
	 * Params:
	 *     y = The luminance as a value between 0.0 and 1.0
	 *     u = The U chrominance component as a value between -0.5 and 0.5
	 *     v = The V chrominance component as a value between -0.5 and 0.5
	 */
	this(double y, double u, double v, double opacity = 0)
	{
		Quantum red, green, blue;

		convertYUVToRGB(y, u, v, red, green, blue);

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
	 * The value for the luminance in the range [0.0 .. 1.0]
	 */
	void y(double y)
	{
		double oldY, u, v;

		convertRGBToYUV(packet.red, packet.green, packet.blue, oldY, u, v);
		convertYUVToRGB(y, u, v, packet.red, packet.green, packet.blue);	
	}
	///ditto
	double y()
	{
		return 0.299 * scaleQuantumToDouble(packet.red) +
		       0.587 * scaleQuantumToDouble(packet.green) +
		       0.114 * scaleQuantumToDouble(packet.blue);
	}

	/**
	 * The value for U chrominance component in the range [-0.5 .. 0.5]
	 */
	void u(double u)
	{
		double y, oldU, v;

		convertRGBToYUV(packet.red, packet.green, packet.blue, y, oldU, v);
		convertYUVToRGB(y, u, v, packet.red, packet.green, packet.blue);
	}
	///ditto
	double u()
	{
		return -0.147 * scaleQuantumToDouble(packet.red) +
		       -0.289 * scaleQuantumToDouble(packet.green) +
		        0.436 * scaleQuantumToDouble(packet.blue);
	}

	/**
	 * The value for V chrominance component in the range [-0.5 .. 0.5]
	 */
	void v(double v)
	{
		double y, u, oldV;

		convertRGBToYUV(packet.red, packet.green, packet.blue, y, u, oldV);
		convertYUVToRGB(y, u, v, packet.red, packet.green, packet.blue);	
	}
	///ditto
	double v()
	{
		return  0.615 * scaleQuantumToDouble(packet.red) +
		       -0.515 * scaleQuantumToDouble(packet.green) +
		       -0.100 * scaleQuantumToDouble(packet.blue);
	}

	/**
	 * Convert an RGB value to a YUV value.
	 */
	private void convertRGBToYUV(Quantum red, Quantum green, Quantum blue, ref double y, ref double u, ref double v)
	{
		// ⌈Y⌉ ⌈ 0.299  0.587  0.114⌉ ⌈R⌉
		// |U|=|-0.147 -0.289  0.436|·|G|
		// ⌊V⌋ ⌊ 0.615 -0.515 -0.100⌋ ⌊B⌋

		double r = scaleQuantumToDouble(red);
		double g = scaleQuantumToDouble(green);
		double b = scaleQuantumToDouble(blue);

		y =  0.299*r +  0.587*g +  0.114*b;
		u = -0.147*r + -0.289*g +  0.436*b;
		v =  0.615*r + -0.515*g + -0.100*b;
	}

	/**
	 * Convert an YUV value to a RGB value.
	 */
	private void convertYUVToRGB(double y, double u, double v, ref Quantum red, ref Quantum green, ref Quantum blue)
	in
	{
		assert(y <=  1   && y >= 0  );
		assert(u <= -0.5 && u >= 0.5);
		assert(v <= -0.5 && v >= 0.5);
	}
	body
	{
		// ⌈R⌉ ⌈ 1.000  0.000  1.140⌉ ⌈Y⌉
		// |G|=| 1.000 -0.395 -0.581|·|U|
		// ⌊B⌋ ⌊ 1.000  2.032  0.000⌋ ⌊V⌋

		double r = 1.000*y +  0.000*u +  1.140*v;
		double g = 1.000*y + -0.395*u + -0.581*v;
		double b = 1.000*y +  2.032*u +  0.000*v;

		red   = scaleDoubleToQuantum(r);
		green = scaleDoubleToQuantum(g);
		blue  = scaleDoubleToQuantum(b);
	}
}
