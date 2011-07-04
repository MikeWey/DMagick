module dmagick.c.compress;

import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	enum CompressionType
	{
		UndefinedCompression,
		NoCompression,
		BZipCompression,
		DXT1Compression,
		DXT3Compression,
		DXT5Compression,
		FaxCompression,
		Group4Compression,
		JPEGCompression,
		JPEG2000Compression,     /* ISO/IEC std 15444-1 */
		LosslessJPEGCompression,
		LZWCompression,
		RLECompression,
		ZipCompression,
		ZipSCompression,
		PizCompression,
		Pxr24Compression,
		B44Compression,
		B44ACompression,
		LZMACompression,         /* Lempel-Ziv-Markov chain algorithm */
		JBIG1Compression,        /* ISO/IEC std 11544 / ITU-T rec T.82 */
		JBIG2Compression         /* ISO/IEC std 14492 / ITU-T rec T.88 */
	}

	struct Ascii85Info {}

	MagickBooleanType HuffmanDecodeImage(Image*);
	MagickBooleanType HuffmanEncodeImage(const(ImageInfo)*, Image*, Image*);
	MagickBooleanType LZWEncodeImage(Image*, const size_t, ubyte*);
	MagickBooleanType PackbitsEncodeImage(Image*, const size_t, ubyte*);
	MagickBooleanType ZLIBEncodeImage(Image*, const size_t, ubyte*);

	void Ascii85Encode(Image*, const ubyte);
	void Ascii85Flush(Image*);
	void Ascii85Initialize(Image*);
}
