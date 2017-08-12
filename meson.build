project('DMagick', 'd', version: '0.2.0', meson_version: '>=0.41')

magick_core = dependency('MagickCore')
magick_core_lib = magick_core.get_pkgconfig_variable('libname')
pkg_conf = import('pkgconfig')

conf_data = configuration_data()
conf_data.set('MagickLibVersion', ''.join(magick_core.version().split('.')))
conf_data.set('MagickLibVersionText', magick_core.version())

if magick_core_lib.contains('HDRI')
	conf_data.set('HDRI', 'true')
else
	conf_data.set('HDRI', 'false')
endif

if magick_core_lib.contains('Q8')
	conf_data.set('QuantumDepth', '8')
elif magick_core_lib.contains('Q32')
	conf_data.set('QuantumDepth', '32')
elif magick_core_lib.contains('Q64')
	conf_data.set('QuantumDepth', '64')
else
	conf_data.set('QuantumDepth', '16')
endif

magick_version = configure_file(input: 'dmagick/c/magickVersion.d.in',
               output: 'magickVersion.d',
               configuration: conf_data,
			   install_dir: get_option('includedir') + '/d/dmagick/c/')

compiler = meson.get_compiler('d')

if compiler.has_argument('-mv=dmagick.c.magickVersion=' + meson.current_build_dir() + '/magickVersion.d')
	add_project_arguments('-mv=dmagick.c.magickVersion=' + meson.current_build_dir() + '/magickVersion.d', language: 'd')
else
	run_command('mkdir', '-p', meson.current_build_dir() + '/dmagick/c')
	run_command('ln', '-s', meson.current_build_dir() + '/magickVersion.d', meson.current_build_dir() + '/dmagick/c/magickVersion.d')
endif

source_dmagick = [
	'dmagick/Array.d',
	'dmagick/CoderInfo.d',
	'dmagick/ColorCMYK.d',
	'dmagick/Color.d',
	'dmagick/ColorGray.d',
	'dmagick/ColorHSL.d',
	'dmagick/ColorRGB.d',
	'dmagick/ColorYUV.d',
	'dmagick/DrawingContext.d',
	'dmagick/Exception.d',
	'dmagick/Geometry.d',
	'dmagick/Image.d',
	'dmagick/ImageView.d',
	'dmagick/Montage.d',
	'dmagick/Options.d',
	'dmagick/Utils.d'
]

source_magick = [
	'dmagick/c/accelerate.d',
	'dmagick/c/animate.d',
	'dmagick/c/annotate.d',
	'dmagick/c/artifact.d',
	'dmagick/c/attribute.d',
	'dmagick/c/blob.d',
	'dmagick/c/cache.d',
	'dmagick/c/cacheView.d',
	'dmagick/c/channel.d',
	'dmagick/c/cipher.d',
	'dmagick/c/client.d',
	'dmagick/c/coder.d',
	'dmagick/c/color.d',
	'dmagick/c/colormap.d',
	'dmagick/c/colorspace.d',
	'dmagick/c/compare.d',
	'dmagick/c/composite.d',
	'dmagick/c/compress.d',
	'dmagick/c/configure.d',
	'dmagick/c/constitute.d',
	'dmagick/c/decorate.d',
	'dmagick/c/deprecate.d',
	'dmagick/c/display.d',
	'dmagick/c/distort.d',
	'dmagick/c/draw.d',
	'dmagick/c/effect.d',
	'dmagick/c/enhance.d',
	'dmagick/c/exception.d',
	'dmagick/c/feature.d',
	'dmagick/c/fourier.d',
	'dmagick/c/fx.d',
	'dmagick/c/gem.d',
	'dmagick/c/geometry.d',
	'dmagick/c/hashmap.d',
	'dmagick/c/histogram.d',
	'dmagick/c/identify.d',
	'dmagick/c/image.d',
	'dmagick/c/imageView.d',
	'dmagick/c/layer.d',
	'dmagick/c/list.d',
	'dmagick/c/locale.d',
	'dmagick/c/log.d',
	'dmagick/c/magic.d',
	'dmagick/c/MagickCore.d',
	'dmagick/c/magick.d',
	'dmagick/c/magickDelegate.d',
	'dmagick/c/magickModule.d',
	'dmagick/c/magickString.d',
	'dmagick/c/magickType.d',
	'dmagick/c/matrix.d',
	'dmagick/c/memory.d',
	'dmagick/c/mime.d',
	'dmagick/c/monitor.d',
	'dmagick/c/montage.d',
	'dmagick/c/morphology.d',
	'dmagick/c/option.d',
	'dmagick/c/paint.d',
	'dmagick/c/pixel.d',
	'dmagick/c/policy.d',
	'dmagick/c/prepress.d',
	'dmagick/c/profile.d',
	'dmagick/c/property.d',
	'dmagick/c/quantize.d',
	'dmagick/c/quantum.d',
	'dmagick/c/random.d',
	'dmagick/c/registry.d',
	'dmagick/c/resample.d',
	'dmagick/c/resize.d',
	'dmagick/c/resource.d',
	'dmagick/c/segment.d',
	'dmagick/c/semaphore.d',
	'dmagick/c/shear.d',
	'dmagick/c/signature.d',
	'dmagick/c/splayTree.d',
	'dmagick/c/statistic.d',
	'dmagick/c/stream.d',
	'dmagick/c/threshold.d',
	'dmagick/c/timer.d',
	'dmagick/c/token.d',
	'dmagick/c/transform.d',
	'dmagick/c/type.d',
	'dmagick/c/utility.d',
	'dmagick/c/vision.d',
	'dmagick/c/xmlTree.d',
	'dmagick/c/xwindow.d'
]

source_internal = [
	'dmagick/internal/Windows.d'
]

source = source_dmagick + source_magick

if ( host_machine.system() == 'windows' )
	source += source_internal
endif

install_headers(source_dmagick,  subdir : 'd/dmagick')
install_headers(source_magick,   subdir : 'd/dmagick/c')
install_headers(source_internal, subdir : 'd/dmagick/internal')

dmagick_lib = static_library('DMagick',
	source, magick_version,
	install : true)

pkg_conf.generate(name: 'DMagick',
	libraries: [dmagick_lib, '-l'+magick_core_lib],
	subdirs: 'd/dmagick',
	version: meson.project_version(),
	description: 'DMagick - A D binding for ImageMagick.')

dmagick_test_exe = executable('dmagick_test_exe',
    source_dmagick, magick_version,
    #dependencies: [magick_core], -> generates flags dmd/ldc don't support.
    d_args: compiler.unittest_args(),
	link_with: dmagick_lib,
	link_args: ['-main', '-l'+magick_core_lib],
	build_by_default: false
)
test('dmagick_test', dmagick_test_exe)
