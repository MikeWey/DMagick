module dmagick.c.type;

import core.stdc.stdio;

import dmagick.c.exception;
import dmagick.c.magickType;

extern(C)
{
	enum StretchType
	{
		UndefinedStretch,
		NormalStretch,
		UltraCondensedStretch,
		ExtraCondensedStretch,
		CondensedStretch,
		SemiCondensedStretch,
		SemiExpandedStretch,
		ExpandedStretch,
		ExtraExpandedStretch,
		UltraExpandedStretch,
		AnyStretch
	}

	enum StyleType
	{
		UndefinedStyle,
		NormalStyle,
		ItalicStyle,
		ObliqueStyle,
		AnyStyle
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

	char** GetTypeList(const char*, size_t*, ExceptionInfo*);

	MagickBooleanType ListTypeInfo(FILE*, ExceptionInfo*);
	MagickBooleanType TypeComponentGenesis();

	const(TypeInfo*)  GetTypeInfo(const char*, ExceptionInfo*);
	const(TypeInfo*)  GetTypeInfoByFamily(const char*, const StyleType, const StretchType, const size_t, ExceptionInfo*);
	const(TypeInfo**) GetTypeInfoList(const char*, size_t*, ExceptionInfo*);

	void TypeComponentTerminus();
}
