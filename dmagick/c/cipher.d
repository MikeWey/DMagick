module dmagick.c.cipher;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickString;
import dmagick.c.magickType;

extern(C)
{
	MagickBooleanType DecipherImage(Image*, const(char)*, ExceptionInfo*);
	MagickBooleanType EncipherImage(Image*, const(char)*, ExceptionInfo*);
	MagickBooleanType PasskeyDecipherImage(Image*, const(StringInfo)*, ExceptionInfo*);
	MagickBooleanType PasskeyEncipherImage(Image*, const(StringInfo)*, ExceptionInfo*);
}
