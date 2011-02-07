module dmagick.c.magickType;

extern (C)
{
	alias double MagickRealType;
	alias ushort Quantum;
	alias uint   MagickStatusType;
	alias long   MagickOffsetType;
	alias ulong  MagickSizeType;

	alias int MagickBooleanType;

	alias MagickSizeType QuantumAny;
	alias QuantumRange TransparentOpacity;

	enum MaxTextExtent = 4096;
	enum QuantumRange = 65535UL;

	enum ChannelType
	{
		UndefinedChannel,
		RedChannel     = 0x0001,
		GrayChannel    = 0x0001,
		CyanChannel    = 0x0001,
		GreenChannel   = 0x0002,
		MagentaChannel = 0x0002,
		BlueChannel    = 0x0004,
		YellowChannel  = 0x0004,
		AlphaChannel   = 0x0008,
		OpacityChannel = 0x0008,
		MatteChannel   = 0x0008,  // deprecated
		BlackChannel   = 0x0020,
		IndexChannel   = 0x0020,
		AllChannels    = 0x002F,

		TrueAlphaChannel = 0x0040, // extract actual alpha channel from opacity
		RGBChannels      = 0x0080, // set alpha from  grayscale mask in RGB
		GrayChannels     = 0x0080,
		SyncChannels     = 0x0100, // channels should be modified equally
		DefaultChannels  = 0x0127  //( (AllChannels | SyncChannels) &~ OpacityChannel)
	}

	enum ClassType
	{
		UndefinedClass,
		DirectClass,
		PseudoClass
	}

	struct BlobInfo {}
}
