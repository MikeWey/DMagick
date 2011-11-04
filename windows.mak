DMD=dmd
DFLAGS=-O -release

LIBNAME=DMagick.lib
MAGICKCOREDLLNAME=CORE_RL_magick_.dll
MAGICKCORELIBNAME=MagickCore.lib

target : $(LIBNAME) $(MAGICKCORELIBNAME)

SOURCE= \
	dmagick\Array.d \
	dmagick\CoderInfo.d \
	dmagick\Color.d \
	dmagick\ColorCMYK.d \
	dmagick\ColorGray.d \
	dmagick\ColorHSL.d \
	dmagick\ColorRGB.d \
	dmagick\ColorYUV.d \
	dmagick\DrawingContext.d \
	dmagick\Exception.d \
	dmagick\Geometry.d \
	dmagick\Image.d \
	dmagick\ImageView.d \
	dmagick\Montage.d \
	dmagick\Options.d \
	dmagick\Utils.d \
	\
	dmagick\c\accelerate.d \
	dmagick\c\animate.d \
	dmagick\c\annotate.d \
	dmagick\c\artifact.d \
	dmagick\c\attribute.d \
	dmagick\c\blob.d \
	dmagick\c\cache.d \
	dmagick\c\cacheView.d \
	dmagick\c\cipher.d \
	dmagick\c\client.d \
	dmagick\c\coder.d \
	dmagick\c\color.d \
	dmagick\c\colormap.d \
	dmagick\c\colorspace.d \
	dmagick\c\compare.d \
	dmagick\c\composite.d \
	dmagick\c\compress.d \
	dmagick\c\configure.d \
	dmagick\c\constitute.d \
	dmagick\c\decorate.d \
	dmagick\c\deprecate.d \
	dmagick\c\display.d \
	dmagick\c\distort.d \
	dmagick\c\draw.d \
	dmagick\c\effect.d \
	dmagick\c\enhance.d \
	dmagick\c\exception.d \
	dmagick\c\feature.d \
	dmagick\c\fourier.d \
	dmagick\c\fx.d \
	dmagick\c\gem.d \
	dmagick\c\geometry.d \
	dmagick\c\hashmap.d \
	dmagick\c\histogram.d \
	dmagick\c\identify.d \
	dmagick\c\image.d \
	dmagick\c\imageView.d \
	dmagick\c\layer.d \
	dmagick\c\list.d \
	dmagick\c\locale.d \
	dmagick\c\log.d \
	dmagick\c\magic.d \
	dmagick\c\magick.d \
	dmagick\c\MagickCore.d \
	dmagick\c\magickDelegate.d \
	dmagick\c\magickModule.d \
	dmagick\c\magickString.d \
	dmagick\c\magickType.d \
	dmagick\c\magickVersion.d \
	dmagick\c\matrix.d \
	dmagick\c\memory.d \
	dmagick\c\mime.d \
	dmagick\c\monitor.d \
	dmagick\c\montage.d \
	dmagick\c\morphology.d \
	dmagick\c\option.d \
	dmagick\c\paint.d \
	dmagick\c\pixel.d \
	dmagick\c\policy.d \
	dmagick\c\prepress.d \
	dmagick\c\profile.d \
	dmagick\c\property.d \
	dmagick\c\quantize.d \
	dmagick\c\quantum.d \
	dmagick\c\random.d \
	dmagick\c\registry.d \
	dmagick\c\resample.d \
	dmagick\c\resize.d \
	dmagick\c\resource.d \
	dmagick\c\segment.d \
	dmagick\c\semaphore.d \
	dmagick\c\shear.d \
	dmagick\c\signature.d \
	dmagick\c\splayTree.d \
	dmagick\c\statistic.d \
	dmagick\c\stream.d \
	dmagick\c\threshold.d \
	dmagick\c\timer.d \
	dmagick\c\token.d \
	dmagick\c\transform.d \
	dmagick\c\type.d \
	dmagick\c\utility.d \
	dmagick\c\xmlTree.d \
	dmagick\c\xwindow.d
	
################## DOCS ####################################

DOCS= \
	docs\Array.html \
	docs\CoderInfo.html \
	docs\Color.html \
	docs\ColorCMYK.html \
	docs\ColorGray.html \
	docs\ColorHSL.html \
	docs\ColorRGB.html \
	docs\ColorYUV.html \
	docs\DrawingContext.html \
	docs\Exception.html \
	docs\Geometry.html \
	docs\Image.html \
	docs\ImageView.html \
	docs\Montage.html \
	docs\Options.html \
	docs\Utils.html \
	\
	docs\c\accelerate.html \
	docs\c\animate.html \
	docs\c\annotate.html \
	docs\c\artifact.html \
	docs\c\attribute.html \
	docs\c\blob.html \
	docs\c\cache.html \
	docs\c\cacheView.html \
	docs\c\cipher.html \
	docs\c\client.html \
	docs\c\coder.html \
	docs\c\color.html \
	docs\c\colormap.html \
	docs\c\colorspace.html \
	docs\c\compare.html \
	docs\c\composite.html \
	docs\c\compress.html \
	docs\c\configure.html \
	docs\c\constitute.html \
	docs\c\decorate.html \
	docs\c\deprecate.html \
	docs\c\display.html \
	docs\c\distort.html \
	docs\c\draw.html \
	docs\c\effect.html \
	docs\c\enhance.html \
	docs\c\exception.html \
	docs\c\feature.html \
	docs\c\fourier.html \
	docs\c\fx.html \
	docs\c\gem.html \
	docs\c\geometry.html \
	docs\c\hashmap.html \
	docs\c\histogram.html \
	docs\c\identify.html \
	docs\c\image.html \
	docs\c\imageView.html \
	docs\c\layer.html \
	docs\c\list.html \
	docs\c\locale.html \
	docs\c\log.html \
	docs\c\magic.html \
	docs\c\magick.html \
	docs\c\MagickCore.html \
	docs\c\magickDelegate.html \
	docs\c\magickModule.html \
	docs\c\magickString.html \
	docs\c\magickType.html \
	docs\c\magickVersion.html \
	docs\c\matrix.html \
	docs\c\memory.html \
	docs\c\mime.html \
	docs\c\monitor.html \
	docs\c\montage.html \
	docs\c\morphology.html \
	docs\c\option.html \
	docs\c\paint.html \
	docs\c\pixel.html \
	docs\c\policy.html \
	docs\c\prepress.html \
	docs\c\profile.html \
	docs\c\property.html \
	docs\c\quantize.html \
	docs\c\quantum.html \
	docs\c\random.html \
	docs\c\registry.html \
	docs\c\resample.html \
	docs\c\resize.html \
	docs\c\resource.html \
	docs\c\segment.html \
	docs\c\semaphore.html \
	docs\c\shear.html \
	docs\c\signature.html \
	docs\c\splayTree.html \
	docs\c\statistic.html \
	docs\c\stream.html \
	docs\c\threshold.html \
	docs\c\timer.html \
	docs\c\token.html \
	docs\c\transform.html \
	docs\c\type.html \
	docs\c\utility.html \
	docs\c\xmlTree.html \
	docs\c\xwindow.html

html: docs
docs: $(DOCS)

docs\Array.html: dmagick\Array.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc -Df$@

docs\CoderInfo.html: dmagick\CoderInfo.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc -Df$@

docs\Color.html: dmagick\Color.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc -Df$@

docs\ColorCMYK.html: dmagick\ColorCMYK.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc -Df$@

docs\ColorGray.html: dmagick\ColorGray.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc -Df$@

docs\ColorHSL.html: dmagick\ColorHSL.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc -Df$@

docs\ColorRGB.html: dmagick\ColorRGB.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc -Df$@

docs\ColorYUV.html: dmagick\ColorYUV.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc -Df$@

docs\DrawingContext.html: dmagick\DrawingContext.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc -Df$@

docs\Exception.html: dmagick\Exception.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc -Df$@

docs\Geometry.html: dmagick\Geometry.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc -Df$@

docs\Image.html: dmagick\Image.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc -Df$@

docs\ImageView.html: dmagick\ImageView.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc -Df$@

docs\Montage.html: dmagick\Montage.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc -Df$@

docs\Options.html: dmagick\Options.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc -Df$@

docs\Utils.html: dmagick\Utils.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc -Df$@

docs\c\accelerate.html: dmagick\c\accelerate.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\animate.html: dmagick\c\animate.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\annotate.html: dmagick\c\annotate.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\artifact.html: dmagick\c\artifact.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\attribute.html: dmagick\c\attribute.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\blob.html: dmagick\c\blob.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\cache.html: dmagick\c\cache.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\cacheView.html: dmagick\c\cacheView.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\cipher.html: dmagick\c\cipher.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\client.html: dmagick\c\client.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\coder.html: dmagick\c\coder.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\color.html: dmagick\c\color.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\colormap.html: dmagick\c\colormap.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\colorspace.html: dmagick\c\colorspace.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\compare.html: dmagick\c\compare.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\composite.html: dmagick\c\composite.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\compress.html: dmagick\c\compress.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\configure.html: dmagick\c\configure.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\constitute.html: dmagick\c\constitute.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\decorate.html: dmagick\c\decorate.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\deprecate.html: dmagick\c\deprecate.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\display.html: dmagick\c\display.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\distort.html: dmagick\c\distort.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\draw.html: dmagick\c\draw.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\effect.html: dmagick\c\effect.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\enhance.html: dmagick\c\enhance.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\exception.html: dmagick\c\exception.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\feature.html: dmagick\c\feature.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\fourier.html: dmagick\c\fourier.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\fx.html: dmagick\c\fx.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\gem.html: dmagick\c\gem.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\geometry.html: dmagick\c\geometry.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\hashmap.html: dmagick\c\hashmap.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\histogram.html: dmagick\c\histogram.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\identify.html: dmagick\c\identify.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\image.html: dmagick\c\image.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\imageView.html: dmagick\c\imageView.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\layer.html: dmagick\c\layer.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\list.html: dmagick\c\list.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\locale.html: dmagick\c\locale.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\log.html: dmagick\c\log.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\magic.html: dmagick\c\magic.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\magick.html: dmagick\c\magick.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\MagickCore.html: dmagick\c\MagickCore.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\magickDelegate.html: dmagick\c\magickDelegate.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\magickModule.html: dmagick\c\magickModule.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\magickString.html: dmagick\c\magickString.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\magickType.html: dmagick\c\magickType.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\magickVersion.html: dmagick\c\magickVersion.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\matrix.html: dmagick\c\matrix.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\memory.html: dmagick\c\memory.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\mime.html: dmagick\c\mime.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\monitor.html: dmagick\c\monitor.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\montage.html: dmagick\c\montage.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\morphology.html: dmagick\c\morphology.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\option.html: dmagick\c\option.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\paint.html: dmagick\c\paint.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\pixel.html: dmagick\c\pixel.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\policy.html: dmagick\c\policy.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\prepress.html: dmagick\c\prepress.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\profile.html: dmagick\c\profile.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\property.html: dmagick\c\property.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\quantize.html: dmagick\c\quantize.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\quantum.html: dmagick\c\quantum.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\random.html: dmagick\c\random.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\registry.html: dmagick\c\registry.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\resample.html: dmagick\c\resample.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\resize.html: dmagick\c\resize.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\resource.html: dmagick\c\resource.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\segment.html: dmagick\c\segment.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\semaphore.html: dmagick\c\semaphore.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\shear.html: dmagick\c\shear.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\signature.html: dmagick\c\signature.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\splayTree.html: dmagick\c\splayTree.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\statistic.html: dmagick\c\statistic.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\stream.html: dmagick\c\stream.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\threshold.html: dmagick\c\threshold.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\timer.html: dmagick\c\timer.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\token.html: dmagick\c\token.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\transform.html: dmagick\c\transform.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\type.html: dmagick\c\type.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\utility.html: dmagick\c\utility.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\xmlTree.html: dmagick\c\xmlTree.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

docs\c\xwindow.html: dmagick\c\xwindow.d
	$(DMD) $** $(DFLAGS) -c -o- -I. docs\dmagick.ddoc docs\dmagick.c.ddoc -Df$@

################### Library generation #########################

$(LIBNAME): $(SOURCE)
	$(DMD) -lib -of$(LIBNAME) $(DFLAGS) $(SOURCE)

unittest: stubmain.d $(SOURCE) $(MAGICKCORELIBNAME)
	$(DMD) -of$@.exe -unittest $(DFLAGS) $**
	unittest

$(MAGICKCORELIBNAME):
	@echo @for %%i in (%1) do @if NOT "%%~$$PATH:i"=="" @copy "%%~$$PATH:i" > copydll.bat
	copydll $(MAGICKCOREDLLNAME)
	implib /s $@ $(MAGICKCOREDLLNAME)
	@del copydll.bat
	del $(MAGICKCOREDLLNAME)

stubmain.d:
	echo void main(){} > $@

clean:
	del $(LIBNAME)
	del $(MAGICKCORELIBNAME)
	del $(DOCS)
	del stubmain.d unittest.obj unittest.exe
