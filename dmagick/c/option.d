module dmagick.c.option;

import core.stdc.stdio;
import core.sys.posix.sys.types;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;

extern(C)
{
	enum MagickOption
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
		MagickImageListOptions,
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

	struct OptionInfo
	{
		const(char)*
			mnemonic;

		ssize_t
			type;

		MagickBooleanType
			stealth;
	}

	char** GetMagickOptions(const MagickOption);
	char*  GetNextImageOption(const(ImageInfo)*);
	char*  RemoveImageOption(ImageInfo*, const(char)*);

	const(char)* GetImageOption(const(ImageInfo)*, const(char)*);
	const(char)* MagickOptionToMnemonic(const MagickOption, const ssize_t);

	MagickBooleanType CloneImageOptions(ImageInfo*, const(ImageInfo)*);
	MagickBooleanType DefineImageOption(ImageInfo*, const(char)*);
	MagickBooleanType DeleteImageOption(ImageInfo*, const(char)*);
	MagickBooleanType IsMagickOption(const(char)*);
	MagickBooleanType ListMagickOptions(FILE*, const MagickOption, ExceptionInfo*);
	MagickBooleanType SetImageOption(ImageInfo*, const(char)*, const(char)*);

	ssize_t ParseChannelOption(const(char)*);
	ssize_t ParseMagickOption(const MagickOption, const MagickBooleanType,const(char)*);

	void DestroyImageOptions(ImageInfo*);
	void ResetImageOptions(const(ImageInfo)*);
	void ResetImageOptionIterator(const(ImageInfo)*);
}
