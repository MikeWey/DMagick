module dmagick.c.magickType;

extern (C)
{
	version(Quantum8)
	{
		alias ubyte  Quantum;
		alias double MagickRealType;

		enum MAGICKCORE_QUANTUM_DEPTH = 8;
		enum QuantumRange = Quantum.max;
		enum MaxColormapSize = 256;
		enum MagickEpsilon = 1.0e-6;
		enum MagickHuge    = 1.0e6;
	}
	else version(Quantum32)
	{
		alias uint   Quantum;
		alias double MagickRealType;

		enum MAGICKCORE_QUANTUM_DEPTH = 32;
		enum QuantumRange = Quantum.max;
		enum MaxColormapSize = 65536;
		enum MagickEpsilon = 1.0e-10;
		enum MagickHuge    = 1.0e12;
	}
	else version(Quantum64)
	{
		static assert(false, "64bit Quantum not implemented, need long double");

		//alias double Quantum;
		//alias long double MagickRealType;

		//enum MAGICKCORE_QUANTUM_DEPTH = 64;
		//enum QuantumRange = 18446744073709551615.0;
		//enum MaxColormapSize = 65536;
		//enum MagickEpsilon = 1.0e-10;
		//enum MagickHuge = 1.0e12;
	}
	else
	{
		alias ushort Quantum;
		alias double MagickRealType;

		enum MAGICKCORE_QUANTUM_DEPTH = 16;
		enum QuantumRange = Quantum.max;
		enum MaxColormapSize = 65536;
		enum MagickEpsilon = 1.0e-10;
		enum MagickHuge    = 1.0e12;
	}

	alias uint  MagickStatusType;
	alias long  MagickOffsetType;
	alias ulong MagickSizeType;
	alias int   MagickBooleanType;

	alias MagickSizeType  QuantumAny;
	alias QuantumRange    TransparentOpacity;
	alias MaxColormapSize MaxMap;

	alias MAGICKCORE_QUANTUM_DEPTH MagickQuantumDepth;

	enum MaxTextExtent = 4096;
	enum OpaqueOpacity = 0;

	enum ChannelType
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
		CompositeChannels = 0x002F,
		AllChannels       =   ~0UL,

		TrueAlphaChannel = 0x0040, // extract actual alpha channel from opacity
		RGBChannels      = 0x0080, // set alpha from  grayscale mask in RGB
		GrayChannels     = 0x0080,
		SyncChannels     = 0x0100, // channels should be modified equally
		DefaultChannels  = ( (AllChannels | SyncChannels) &~ OpacityChannel)
	}

	enum ClassType
	{
		UndefinedClass,
		DirectClass,
		PseudoClass
	}

	struct BlobInfo {}
}
