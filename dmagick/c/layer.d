module dmagick.c.layer;

import dmagick.c.composite;
import dmagick.c.exception;
import dmagick.c.image;

alias ptrdiff_t ssize_t;

extern(C)
{
	/**
	 * The dispose method used for GIF animations.
	 * 
	 * See_Also: $(LINK2 http://www.imagemagick.org/Usage/anim_basics/#dispose,
	 *     Frame Disposal Methods) in the Examples of ImageMagick Usage.
	 */
	enum DisposeType
	{
		/** */
		UnrecognizedDispose,

		/**
		 * No disposal specified.
		 */
		UndefinedDispose = 0,
		
		/**
		 * Do not dispose between frames.
		 */
		NoneDispose = 1,
		
		/**
		 * Overwrite the image area with the background color.
		 */
		BackgroundDispose = 2,
		
		/**
		 * Overwrite the image area with what was there prior
		 * to rendering the image.
		 */
		PreviousDispose = 3
	}

	/**
	 * Determines image operation to apply to ordered sequence of images.
	 */
	enum ImageLayerMethod
	{
		/** */
		UndefinedLayer,

		/**
		 * Apply the GIF disposal methods set in the current image sequence
		 * to form a fully defined animation sequence without, as it should
		 * be displayed. Effectively converting a GIF animation into
		 * a 'film strip' like animation.
		 */
		CoalesceLayer,

		/**
		 * Crop the second and later frames to the smallest rectangle that
		 * contains all the differences between the two images. No GIF
		 * disposal methods are taken into account.
		 * 
		 * This does not preserve a animation's normal working, especially
		 * when a animation used GIF disposal methods
		 * such as 'Previous' or 'Background'.
		 */
		CompareAnyLayer,

		/**
		 * As CompareAnyLayer but crop to the bounds of any opaque pixels
		 * which become transparent in the second frame. That is the
		 * smallest image needed to mask or erase pixels for the next frame.
		 */
		CompareClearLayer,

		/**
		 * As CompareAnyLayer but crop to pixels that add extra color to
		 * the next image, as a result of overlaying color pixels. That is
		 * the smallest single overlaid image to add or change colors.
		 * 
		 * This can, be used with the -compose alpha composition method
		 * 'change-mask', to reduce the image to just the pixels that need
		 * to be overlaid.
		 */
		CompareOverlayLayer,

		/**
		 * This is like CoalesceLayer but shows the look of the animation
		 * after the GIF disposal method has been applied, before the next
		 * sub-frame image is overlaid. That is the 'dispose' image that
		 * results from the application of the GIF disposal method. This
		 * allows you to check what is going wrong with a particular
		 * animation you may be developing.
		 */
		DisposeLayer,

		/**
		 * Optimize a coalesced animation into GIF animation using a number
		 * of general techniques. This is currently a short cut to apply
		 * both the OptimizeImageLayer and OptimizeTransLayer methods
		 * but will expand to include other methods.
		 */
		OptimizeLayer,

		/**
		 * Optimize a coalesced animation into GIF animation by reducing
		 * the number of pixels per frame as much as possible by attempting
		 * to pick the best GIF disposal method to use, while ensuring the
		 * result will continue to animate properly. 
		 * 
		 * There is no guarantee that the best optimization will be found.
		 * But then no reasonably fast GIF optimization algorithm can do
		 * this. However this does seem to do better than most other GIF
		 * frame optimizers seen.
		 */
		OptimizeImageLayer,

		/**
		 * As OptimizeImageLayer but attempt to improve the overall
		 * optimization by adding extra frames to the animation, without
		 * changing the final look or timing of the animation. The frames
		 * are added to attempt to separate the clearing of pixels from the
		 * overlaying of new additional pixels from one animation frame to
		 * the next. If this does not improve the optimization (for the next
		 * frame only), it will fall back to the results of the previous
		 * normal OptimizeImageLayer technique.
		 * 
		 * There is the possibility that the change in the disposal style
		 * will result in a worsening in the optimization of later frames,
		 * though this is unlikely. In other words there no guarantee that
		 * it is better than the normal 'optimize-frame' technique.
		 */
		OptimizePlusLayer,

		/**
		 * Given a GIF animation, replace any pixel in the sub-frame overlay
		 * images with transparency, if it does not change the resulting
		 * animation by more than the current fuzz factor.
		 * 
		 * This should allow a existing frame optimized GIF animation to
		 * compress into a smaller file size due to larger areas of one
		 * (transparent) color rather than a pattern of multiple colors
		 * repeating the current disposed image of the last frame.
		 */
		OptimizeTransLayer,

		/**
		 * Remove (and merge time delays) of duplicate consecutive images,
		 * so as to simplify layer overlays of coalesced animations. Usually
		 * this is a result of using a constant time delay across the whole
		 * animation, or after a larger animation was split into smaller
		 * sub-animations. The duplicate frames could also have been used as
		 * part of some frame optimization methods.
		 */
		RemoveDupsLayer,

		/**
		 * Remove any image with a zero time delay, unless ALL the images
		 * have a zero time delay (and is not a proper timed animation, a
		 * warning is then issued). In a GIF animation, such images are
		 * usually frames which provide partial intermediary updates between
		 * the frames that are actually displayed to users. These frames are
		 * usually added for improved frame optimization in GIF animations.
		 */
		RemoveZeroLayer,

		/**
		 * Alpha Composition of two image lists, separated by a "null:"
		 * image, with the destination image list first, and the source
		 * images last. An image from each list are composited together
		 * until one list is finished. The separator image and source image
		 * lists are removed.
		 * 
		 * The geometry offset is adjusted according to gravity in
		 * accordance of the virtual canvas size of the first image in each
		 * list. Unlike a normal composite operation, the canvas offset is
		 * also added to the final composite positioning of each image.
		 * 
		 * If one of the image lists only contains one image, that image is
		 * applied to all the images in the other image list, regardless of
		 * which list it is. In this case it is the image meta-data of the
		 * list which preserved.
		 */
		CompositeLayer,

		/**
		 * As FlattenLayer but merging all the given image layers into a
		 * new layer image just large enough to hold all the image without
		 * clipping or extra space. The new image's virtual offset will
		 * prevere the position of the new layer, even if this offset is
		 * negative. the virtual canvas size of the first image is preserved.
		 * 
		 * Caution is advised when handling image layers with negative
		 * offsets as few image file formats handle them correctly.
		 */
		MergeLayer,

		/**
		 * Create a canvas the size of the first images virtual canvas using
		 * the current background color, and compose each image in turn onto
		 * that canvas. Images falling outside that canvas will be clipped.
		 * Final image will have a zero virtual canvas offset.
		 * 
		 * This is usually used as one of the final 'image layering'
		 * operations overlaying all the prepared image layers into a
		 * final image.
		 * 
		 * For a single image this method can also be used to fillout a
		 * virtual canvas with real pixels, or to underlay a opaque color
		 * to remove transparency from an image.
		 */
		FlattenLayer,

		/**
		 * As FlattenLayer but expanding the initial canvas size of the
		 * first image so as to hold all the image layers. However as a
		 * virtual canvas is 'locked' to the origin, by definition, image
		 * layers with a negative offsets will still be clipped by the top
		 * and left edges.
		 * 
		 * This method is commonly used to layout individual image using
		 * various offset but without knowing the final canvas size. The
		 * resulting image will, like FlattenLayer not have any virtual
		 * offset, so can be saved to any image file format. This method
		 * corresponds to mosaic, above.
		 */
		MosaicLayer,

		/**
		 * Find the minimal bounds of all the images in the current image
		 * sequence, then adjust the offsets so all images are contained
		 * on a minimal positive canvas. None of the image data is modified,
		 * only the virtual canvas size and offset. Then all the images will
		 * have the same canvas size, and all will have a positive offset,
		 * at least one image will touch every edge of that canvas with
		 * actual pixel data, though that data may be transparent.
		 */
		TrimBoundsLayer
	}

	Image* CoalesceImages(const(Image)*, ExceptionInfo*);
	Image* DisposeImages(const(Image)*, ExceptionInfo*);
	Image* CompareImageLayers(const(Image)*, const ImageLayerMethod, ExceptionInfo*);
	Image* DeconstructImages(const(Image)*, ExceptionInfo*);
	Image* MergeImageLayers(Image*, const ImageLayerMethod, ExceptionInfo*);
	Image* OptimizeImageLayers(const(Image)*, ExceptionInfo*);
	Image* OptimizePlusImageLayers(const(Image)*, ExceptionInfo*);

	void CompositeLayers(Image*, const CompositeOperator, Image*, const ssize_t, const ssize_t, ExceptionInfo*);
	void OptimizeImageTransparency(const(Image)*, ExceptionInfo*);
	void RemoveDuplicateLayers(Image**, ExceptionInfo*);
	void RemoveZeroDelayLayers(Image**, ExceptionInfo*);
}
