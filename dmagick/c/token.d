module dmagick.c.token;

import dmagick.c.magickType;

extern(C)
{
	struct TokenInfo {}

	int Tokenizer(TokenInfo*, const uint, char*, const size_t, const(char)*,
			const(char)*, const(char)*, const(char)*, const char, char*, int*, char*);

	MagickBooleanType GlobExpression(const(char)*, const(char)*, const MagickBooleanType);
	MagickBooleanType IsGlob(const(char)*);
	MagickBooleanType IsMagickTrue(const(char)*);

	TokenInfo* AcquireTokenInfo();
	TokenInfo* DestroyTokenInfo(TokenInfo*);

	void GetMagickToken(const(char)*, const(char)**, char*);
}
