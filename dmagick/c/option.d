module dmagick.c.option;

import core.stdc.stdio;
import core.sys.posix.sys.types;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	enum CommandOption
	{
		MagickUndefinedOptions = -1,
		MagickAlignOptions = 0,
		MagickAlphaOptions,
		MagickBooleanOptions,
		MagickChannelOptions,
		MagickClassOptions,
		MagickClipPathOptions,
		MagickCoderOptions,
		MagickColorOptions,
		MagickColorspaceOptions,
		MagickCommandOptions,
		MagickComposeOptions,
		MagickCompressOptions,
		MagickConfigureOptions,
		MagickDataTypeOptions,
		MagickDebugOptions,
		MagickDecorateOptions,
		MagickDelegateOptions,
		MagickDirectionOptions,
		MagickDisposeOptions,
		MagickDistortOptions,
		MagickDitherOptions,
		MagickEndianOptions,
		MagickEvaluateOptions,
		MagickFillRuleOptions,
		MagickFilterOptions,
		MagickFontOptions,
		MagickFontsOptions,
		MagickFormatOptions,
		MagickFunctionOptions,
		MagickGravityOptions,
		MagickIntentOptions,
		MagickInterlaceOptions,
		MagickInterpolateOptions,
		MagickKernelOptions,
		MagickLayerOptions,
		MagickLineCapOptions,
		MagickLineJoinOptions,
		MagickListOptions,
		MagickLocaleOptions,
		MagickLogEventOptions,
		MagickLogOptions,
		MagickMagicOptions,
		MagickMethodOptions,
		MagickMetricOptions,
		MagickMimeOptions,
		MagickModeOptions,
		MagickModuleOptions,
		MagickMorphologyOptions,
		MagickNoiseOptions,
		MagickOrientationOptions,
		MagickPolicyOptions,
		MagickPolicyDomainOptions,
		MagickPolicyRightsOptions,
		MagickPreviewOptions,
		MagickPrimitiveOptions,
		MagickQuantumFormatOptions,
		MagickResolutionOptions,
		MagickResourceOptions,
		MagickSparseColorOptions,
		MagickStatisticOptions,
		MagickStorageOptions,
		MagickStretchOptions,
		MagickStyleOptions,
		MagickThresholdOptions,
		MagickTypeOptions,
		MagickValidateOptions,
		MagickVirtualPixelOptions
	}

	enum ValidateType
	{
		UndefinedValidate,
		NoValidate = 0x00000,
		CompareValidate = 0x00001,
		CompositeValidate = 0x00002,
		ConvertValidate = 0x00004,
		FormatsInMemoryValidate = 0x00008,
		FormatsOnDiskValidate = 0x00010,
		IdentifyValidate = 0x00020,
		ImportExportValidate = 0x00040,
		MontageValidate = 0x00080,
		StreamValidate = 0x00100,
		AllValidate = 0x7fffffff
	}

	enum CommandOptionFlags
	{
		UndefinedOptionFlag       = 0x0000,
		FireOptionFlag            = 0x0001,  /* Option sequence firing point */
		ImageInfoOptionFlag       = 0x0002,  /* Sets ImageInfo, no image needed */
		DrawInfoOptionFlag        = 0x0004,  /* Sets DrawInfo, no image needed */
		QuantizeInfoOptionFlag    = 0x0008,  /* Sets QuantizeInfo, no image needed */
		GlobalOptionFlag          = 0x0010,  /* Sets Global Option, no image needed */
		SimpleOperatorOptionFlag  = 0x0100,  /* Simple Image processing operator */
		ListOperatorOptionFlag    = 0x0200,  /* Multi-Image List processing operator */
		SpecialOperatorOptionFlag = 0x0400,  /* Specially handled Operator Option */
		GenesisOptionFlag         = 0x0400,  /* Genesis Command Wrapper Option  */
		NonConvertOptionFlag      = 0x4000,  /* Option not used by Convert */
		DeprecateOptionFlag       = 0x8000   /* Deprecate option, give warning */
	}

	struct OptionInfo
	{
		const(char)*
			mnemonic;

		ssize_t
			type,
			flags;

		MagickBooleanType
			stealth;
	}

	char** GetCommandOptions(const CommandOption);
	char*  GetNextImageOption(const(ImageInfo)*);
	char*  RemoveImageOption(ImageInfo*, const(char)*);

	const(char)* CommandOptionToMnemonic(const CommandOption, const ssize_t);
	const(char)* GetImageOption(const(ImageInfo)*, const(char)*);

	MagickBooleanType CloneImageOptions(ImageInfo*, const(ImageInfo)*);
	MagickBooleanType DefineImageOption(ImageInfo*, const(char)*);
	MagickBooleanType DeleteImageOption(ImageInfo*, const(char)*);
	MagickBooleanType IsCommandOption(const(char)*);
	MagickBooleanType ListCommandOptions(FILE*, const CommandOption, ExceptionInfo*);
	MagickBooleanType SetImageOption(ImageInfo*, const(char)*, const(char)*);

	ssize_t GetCommandOptionFlags(const CommandOption, const MagickBooleanType, const(char)*);
	ssize_t ParseChannelOption(const(char)*);
	ssize_t ParseCommandOption(const CommandOption, const MagickBooleanType, const(char)*);

	void DestroyImageOptions(ImageInfo*);
	void ResetImageOptions(const(ImageInfo)*);
	void ResetImageOptionIterator(const(ImageInfo)*);
}
