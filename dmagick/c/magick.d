module dmagick.c.magick;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.magickVersion;
import dmagick.c.semaphore;

extern(C)
{
	enum MagickFormatType
	{
		UndefinedFormatType,
		ImplicitFormatType,
		ExplicitFormatType
	}

	enum MagickThreadSupport
	{
		NoThreadSupport = 0x0000,
		DecoderThreadSupport = 0x0001,
		EncoderThreadSupport = 0x0002
	}

	alias Image* function(const(ImageInfo)*, ExceptionInfo*) DecodeImageHandler;
	alias MagickBooleanType function(const(ImageInfo)*, Image*) EncodeImageHandler;
	alias MagickBooleanType function(const(ubyte)*, const size_t) IsImageFormatHandler;

	struct MagickInfo
	{
		char*
			name,
			description,
			vversion,
			note,
			mmodule;

		ImageInfo*
			image_info;

		DecodeImageHandler*
			decoder;

		EncodeImageHandler*
			encoder;

		IsImageFormatHandler*
			magick;

		void*
			client_data;

		MagickBooleanType
			adjoin,
			raw,
			endian_support,
			blob_support,
			seekable_stream;

		MagickFormatType
			format_type;

		MagickStatusType
			thread_support;

		MagickBooleanType
			stealth;

		MagickInfo*
			previous,
			next;

		size_t
			signature;

		static if ( MagickLibVersion >= 0x687 )
		{
			char*
				mime_type;
		}

		static if (MagickLibVersion >= 0x689)
		{
			SemaphoreInfo*
				semaphore;
		}
	}

	char** GetMagickList(const(char)*, size_t*, ExceptionInfo*);

	const(char)* GetMagickDescription(const(MagickInfo)*);

	static if ( MagickLibVersion >= 0x687 )
	{
		const(char)* GetMagickMimeType(const(MagickInfo)*);
	}

	DecodeImageHandler* GetImageDecoder(const(MagickInfo)*);

	EncodeImageHandler* GetImageEncoder(const(MagickInfo)*);

	int GetMagickPrecision();
	int SetMagickPrecision(const int);

	MagickBooleanType GetImageMagick(const(ubyte)*, const size_t, char*);
	MagickBooleanType GetMagickAdjoin(const(MagickInfo)*);
	MagickBooleanType GetMagickBlobSupport(const(MagickInfo)*);
	MagickBooleanType GetMagickEndianSupport(const(MagickInfo)*);
	MagickBooleanType GetMagickRawSupport(const(MagickInfo)*);
	MagickBooleanType GetMagickSeekableStream(const(MagickInfo)*);
	
	static if (MagickLibVersion < 0x689)
	{
		MagickBooleanType IsMagickInstantiated();
	}

	static if (MagickLibVersion >= 0x689)
	{
		MagickBooleanType IsMagickCoreInstantiated();
	}

	MagickBooleanType MagickComponentGenesis();
	MagickBooleanType UnregisterMagickInfo(const(char)*);

	const(MagickInfo)*  GetMagickInfo(const(char)*, ExceptionInfo*);
	const(MagickInfo)** GetMagickInfoList(const(char)*, size_t*, ExceptionInfo*);

	MagickInfo* RegisterMagickInfo(MagickInfo*);
	MagickInfo* SetMagickInfo(const(char)*);

	MagickStatusType GetMagickThreadSupport(const(MagickInfo)*);

	void MagickComponentTerminus();
	void MagickCoreGenesis(const(char)*, const MagickBooleanType);
	void MagickCoreTerminus();
}
