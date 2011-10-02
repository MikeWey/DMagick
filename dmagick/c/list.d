module dmagick.c.list;

import dmagick.c.exception;
import dmagick.c.image;
import dmagick.c.magickVersion;

alias ptrdiff_t ssize_t;

extern(C)
{
	Image*  CloneImageList(const(Image)*, ExceptionInfo*);
	Image*  CloneImages(const(Image)*, const(char)*, ExceptionInfo*);
	Image*  DestroyImageList(Image*);

	static if ( MagickLibVersion >= 0x669 )
	{
		Image*  DuplicateImages(Image*, const size_t, const char*, ExceptionInfo*);
	}

	Image*  GetFirstImageInList(const(Image)*);
	Image*  GetImageFromList(const(Image)*, const ssize_t);
	Image*  GetLastImageInList(const(Image)*);
	Image*  GetNextImageInList(const(Image)*);
	Image*  GetPreviousImageInList(const(Image)*);
	Image** ImageListToArray(const(Image)*, ExceptionInfo*);
	Image*  NewImageList();
	Image*  RemoveImageFromList(Image**);
	Image*  RemoveLastImageFromList(Image**);
	Image*  RemoveFirstImageFromList(Image**);
	Image*  SpliceImageIntoList(Image**, const size_t, const(Image)*);
	Image*  SplitImageList(Image*);
	Image*  SyncNextImageInList(const(Image)*);

	size_t GetImageListLength(const(Image)*);

	ssize_t GetImageIndexInList(const(Image)*);

	void AppendImageToList(Image**, const(Image)*);
	void DeleteImageFromList(Image**);
	void DeleteImages(Image**, const(char)*, ExceptionInfo*);
	void InsertImageInList(Image**, Image*);
	void PrependImageToList(Image**, Image*);
	void ReplaceImageInList(Image**, Image*);

	static if ( MagickLibVersion >= 0x669 )
	{
		void ReplaceImageInListReturnLast(Image**, Image*);
	}

	void ReverseImageList(Image**);
	void SyncImageList(Image*);
}
