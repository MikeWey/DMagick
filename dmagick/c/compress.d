module dmagick.c.compress;

import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	/**
	 * Express the desired compression type when encoding an image. Be aware
	 * that most image types only support a sub-set of the available
	 * compression types. If the compression type specified is incompatible
	 * with the image, ImageMagick selects a compression type compatible
	 * with the image type.
	 */
	enum CompressionType
	{
		/** */
		UndefinedCompression,

		/**
		 * The default for most formats.
		 */
		NoCompression,
		
		/**
		 * BZip (Burrows-Wheeler block-sorting text compression algorithm
		 * and Huffman coding) as used by bzip2 utilities
		 */
		BZipCompression,
		
		/** */
		DXT1Compression,
		
		/** */
		DXT3Compression,
		
		/** */
		DXT5Compression,
		
		/**
		 * CCITT Group 3 FAX compression.
		 */
		FaxCompression,
		
		/**
		 * CCITT Group 4 FAX compression (used only for TIFF).
		 */
		Group4Compression,
		
		/**
		 * JPEG compression.
		 * 
		 * See_Also: $(LINK2 http://www.faqs.org/faqs/jpeg-faq/part1/,
		 *     The JPEG image compression FAQ).
		 */
		JPEGCompression,
		
		/**
		 * JPEG2000 compression for compressed PDF images.
		 * 
		 * ISO/IEC std 15444-1
		 */
		JPEG2000Compression,
		
		/** */
		LosslessJPEGCompression,
		
		/**
		 * Lempel-Ziv-Welch (LZW) compression.
		 */
		LZWCompression,
		
		/**
		 * Run-length encoding.
		 * 
		 * See_Also: $(LINK2 http://en.wikipedia.org/wiki/Run_length_encoding,
		 *     Wikipedia).
		 */
		RLECompression,
		
		/**
		 * Lempel-Ziv compression (LZ77) as used in PKZIP and GNU gzip.
		 */
		ZipCompression,
		
		/** */
		ZipSCompression,
		
		/** */
		PizCompression,
		
		/** */
		Pxr24Compression,
		
		/** */
		B44Compression,
		
		/** */
		B44ACompression,
		
		/**
		 * Lempel-Ziv-Markov chain algorithm
		 */
		LZMACompression,
		
		/**
		 * ISO/IEC std 11544 / ITU-T rec T.82
		 */
		JBIG1Compression,
		
		/**
		 * ISO/IEC std 14492 / ITU-T rec T.88
		 */
		JBIG2Compression
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
