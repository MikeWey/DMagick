module dmagick.c.type;

import core.stdc.stdio;

import dmagick.c.exception;
import dmagick.c.magickType;

extern(C)
{
	/**
	 * This setting suggests a type of stretch that ImageMagick should try
	 * to apply to the currently selected font family.
	 */
	enum StretchType
	{
		UndefinedStretch,       ///
		NormalStretch,          /// ditto
		UltraCondensedStretch,  /// ditto
		ExtraCondensedStretch,  /// ditto
		CondensedStretch,       /// ditto
		SemiCondensedStretch,   /// ditto
		SemiExpandedStretch,    /// ditto
		ExpandedStretch,        /// ditto
		ExtraExpandedStretch,   /// ditto
		UltraExpandedStretch,   /// ditto
		AnyStretch              /// ditto
	}

	/**
	 * This setting suggests a font style that ImageMagick should try to
	 * apply to the currently selected font family.
	 */
	enum StyleType
	{
		UndefinedStyle,  ///
		NormalStyle,     /// ditto
		ItalicStyle,     /// ditto
		ObliqueStyle,    /// ditto
		AnyStyle         /// ditto
	}

	struct TypeInfo
	{
		size_t
			face;

		char*
			path,
			name,
			description,
			family;

		StyleType
			style;

		StretchType
			stretch;

		size_t
			weight;

		char*
			encoding,
			foundry,
			format,
			metrics,
			glyphs;

		MagickBooleanType
			stealth;

		TypeInfo*
			previous,
			next;

		size_t
			signature;
	}

	char** GetTypeList(const(char)*, size_t*, ExceptionInfo*);

	MagickBooleanType ListTypeInfo(FILE*, ExceptionInfo*);
	MagickBooleanType TypeComponentGenesis();

	const(TypeInfo)*  GetTypeInfo(const(char)*, ExceptionInfo*);
	const(TypeInfo)*  GetTypeInfoByFamily(const(char)*, const StyleType, const StretchType, const size_t, ExceptionInfo*);
	const(TypeInfo)** GetTypeInfoList(const(char)*, size_t*, ExceptionInfo*);

	void TypeComponentTerminus();
}
