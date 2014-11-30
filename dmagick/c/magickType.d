module dmagick.c.magickType;

import dmagick.c.magickVersion;

extern (C)
{
	version(X86)
	{
		alias real MagickFloatT;
		alias real MagickDoubleT;
	}
	else version(X86_64)
	{
		alias float  MagickFloatT;
		alias double MagickDoubleT;	
	}

	version(Quantum8)
	{
		/**
		 * Quantum is an alias for the smallest integer that can hold
		 * a pixel channel.
		 */
		version(MagickCore_HDRI)
			alias float Quantum;
		else
			alias ubyte Quantum;

		alias ptrdiff_t SignedQuantum;

		static if ( MagickLibVersion == 0x680 )
			alias float MagickRealType;
		else static if ( MagickLibVersion >= 0x681 )
			alias MagickFloatT MagickRealType;
		else
			alias double MagickRealType;

		/**
		 * The largest value that fits in a Quantum, This is the same
		 * as Quantum.max except when the Quantum dept is 64 bits.
		 */
		enum QuantumRange = ubyte.max;
		enum MagickQuantumDepth = 8;
		enum MaxColormapSize = 256;

		static if ( MagickLibVersion < 0x678 )
		{
			enum MagickEpsilon = 1.0e-6;
			enum MagickHuge    = 1.0e6;
		}
	}
	else version(Quantum32)
	{
		/**
		 * Quantum is an alias for the smallest integer that can hold
		 * a pixel channel.
		 */
		version(MagickCore_HDRI)
		{
			static if ( MagickLibVersion >= 0x690 )
				alias double Quantum;
			else
				alias float Quantum;
		}
		else
		{
			alias uint  Quantum;
		}

		alias double SignedQuantum;

		static if ( MagickLibVersion >= 0x681 )
			alias MagickDoubleT MagickRealType;
		else
			alias double MagickRealType;

		/**
		 * The largest value that fits in a Quantum, This is the same
		 * as Quantum.max except when the Quantum dept is 64 bits.
		 */
		enum QuantumRange = uint.max;
		enum MagickQuantumDepth = 32;
		enum MaxColormapSize = 65536;

		static if ( MagickLibVersion < 0x678 )
		{
			enum MagickEpsilon = 1.0e-10;
			enum MagickHuge    = 1.0e12;
		}
	}
	else version(Quantum64)
	{
		/**
		 * Quantum is an alias for the smallest integer that can hold
		 * a pixel channel.
		 */
		static if ( MagickLibVersion >= 0x690 )
		{
			alias real Quantum;
			alias real SignedQuantum;
		}
		else
		{
			alias double Quantum;
			alias double SignedQuantum;
		}
		//real seems to be the same size as long double for
		//dmc and dmd on windows and for dmd and gcc on linux. 
		alias real MagickRealType;

		/**
		 * The largest value that fits in a Quantum, This is the same
		 * as Quantum.max except when the Quantum dept is 64 bits.
		 */
		enum QuantumRange = 18446744073709551615.0;
		enum MagickQuantumDepth = 64;
		enum MaxColormapSize = 65536;

		static if ( MagickLibVersion < 0x678 )
		{
			enum MagickEpsilon = 1.0e-10;
			enum MagickHuge = 1.0e12;
		}
	}
	else
	{
		/**
		 * Quantum is an alias for the smallest integer that can hold
		 * a pixel channel.
		 */
		version(MagickCore_HDRI)
			alias float  Quantum;
		else
			alias ushort Quantum;

		alias ptrdiff_t SignedQuantum;

		static if ( MagickLibVersion == 0x680 )
			alias float MagickRealType;
		else static if ( MagickLibVersion >= 0x681 )
			alias MagickFloatT MagickRealType;
		else
			alias double MagickRealType;

		/**
		 * The largest value that fits in a Quantum, This is the same
		 * as Quantum.max except when the Quantum dept is 64 bits.
		 */
		enum QuantumRange = ushort.max;
		enum MagickQuantumDepth = 16;
		enum MaxColormapSize = 65536;

		static if ( MagickLibVersion < 0x678 )
		{
			enum MagickEpsilon = 1.0e-10;
			enum MagickHuge    = 1.0e12;
		}
	}

	static if ( MagickLibVersion == 0x678 )
	{
		enum MagickRealType MagickEpsilon = 2.220446e-16;
		enum MagickRealType MagickHuge    = 1.0/MagickEpsilon;
	}
	else static if ( MagickLibVersion == 0x679 )
	{
		enum MagickRealType MagickEpsilon = 1.0e-16;
		enum MagickRealType MagickHuge    = 1.0/MagickEpsilon;
	}
	else static if ( MagickLibVersion == 0x680 )
	{
		enum MagickRealType MagickEpsilon = 1.0e-16;
		enum MagickRealType MagickHuge    = 3.4e+38;
	}
	else static if ( MagickLibVersion >= 0x681 && MagickLibVersion < 0x689 )
	{
		enum MagickRealType MagickEpsilon = 1.0e-15;
		enum MagickRealType MagickHuge    = 3.4e+38;
	}
	else static if ( MagickLibVersion >= 0x689 )
	{
		enum MagickRealType MagickEpsilon = 1.0e-15;
	}

	alias uint  MagickStatusType;
	alias long  MagickOffsetType;
	alias ulong MagickSizeType;
	alias int   MagickBooleanType;

	alias MagickSizeType  QuantumAny;
	alias MaxColormapSize MaxMap;
	enum  MaxTextExtent = 4096;

	enum MagickMaximumValue = 1.79769313486231570E+308;
	enum MagickMinimumValue = 2.22507385850720140E-308;

	enum  QuantumScale  = (1.0/ cast(double)QuantumRange);
	alias QuantumRange    TransparentOpacity; /// Fully transparent Quantum.
	enum  OpaqueOpacity = 0;                  /// Fully opaque Quantum.

	version(D_Ddoc)
	{
		/**
		 * Specify an image channel. A channel is a color component of a
		 * pixel. In the RGB colorspace the channels are red, green, and
		 * blue. There may also be an alpha (transparency/opacity) channel.
		 * In the CMYK colorspace the channels area cyan, magenta, yellow,
		 * and black. In the HSL colorspace the channels are hue, saturation,
		 * and lightness. In the Gray colorspace the only channel is gray.
		 */
		enum ChannelType
		{
			UndefinedChannel,
			RedChannel     = 0x0001,    ///
			GrayChannel    = 0x0001,    ///
			CyanChannel    = 0x0001,    ///
			GreenChannel   = 0x0002,    ///
			MagentaChannel = 0x0002,    ///
			BlueChannel    = 0x0004,    ///
			YellowChannel  = 0x0004,    ///
			AlphaChannel   = 0x0008,    /// Same as OpacityChannel
			OpacityChannel = 0x0008,    ///
			MatteChannel   = 0x0008,    /// deprecated
			BlackChannel   = 0x0020,    ///
			IndexChannel   = 0x0020,    ///
			CompositeChannels = 0x002F, ///
			AllChannels    = 0x7ffffff, ///

			TrueAlphaChannel = 0x0040, /// extract actual alpha channel from opacity
			RGBChannels      = 0x0080, /// set alpha from  grayscale mask in RGB
			GrayChannels     = 0x0080, ///
			SyncChannels     = 0x0100, /// channels should be modified equally

			/**
			 * Same as AllChannels, excluding OpacityChannel
			 */
			DefaultChannels  = ((AllChannels | SyncChannels) &~ OpacityChannel)
		}
	}
	else
	{
		mixin(
		{
			string channels = "enum ChannelType
			{
				UndefinedChannel,
				RedChannel        = 0x0001,
				GrayChannel       = 0x0001,
				CyanChannel       = 0x0001,
				GreenChannel      = 0x0002,
				MagentaChannel    = 0x0002,
				BlueChannel       = 0x0004,
				YellowChannel     = 0x0004,
				AlphaChannel      = 0x0008,
				OpacityChannel    = 0x0008,
				MatteChannel      = 0x0008,  // deprecated
				BlackChannel      = 0x0020,
				IndexChannel      = 0x0020,
				CompositeChannels = 0x002F,";

				static if ( MagickLibVersion < 0x670 )
				{
					channels ~= "AllChannels = 0x002F,";
				}
				else static if ( MagickLibVersion == 0x670 )
				{
					channels ~= "AllChannels       =   ~0UL,";
				}
				else static if ( MagickLibVersion == 0x671 )
				{
					channels ~= "AllChannels       =    ~0L,";
				}
				else
				{
					channels ~= "AllChannels       = 0x7FFFFFF,";
				}

				channels ~= "
				TrueAlphaChannel = 0x0040, // extract actual alpha channel from opacity
				RGBChannels      = 0x0080, // set alpha from  grayscale mask in RGB
				GrayChannels     = 0x0080,
				SyncChannels     = 0x0100, // channels should be modified equally
				DefaultChannels  = ( (AllChannels | SyncChannels) &~ OpacityChannel)
			}";

			return channels;
		}());
	}

	/**
	 * Specify the image storage class.
	 */
	enum ClassType
	{
		UndefinedClass, /// No storage class has been specified.
		DirectClass,    /// Image is composed of pixels which represent literal color values.
		PseudoClass     /// Image is composed of pixels which specify an index in a color palette.
	}

	struct BlobInfo {}
}
