module dmagick.c.accelerate;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickType;
import dmagick.c.morphology;

extern(C) MagickBooleanType AccelerateConvolveImage(const Image*, const KernelInfo*, Image*, ExceptionInfo*);
