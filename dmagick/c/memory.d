module dmagick.c.memory;

extern(C)
{
	alias void* function(size_t) AcquireMemoryHandler;
	alias void	function(void*) DestroyMemoryHandler;
	alias void* function(void*, size_t) ResizeMemoryHandler;

	void* AcquireAlignedMemory(const size_t, const size_t);
	void* AcquireMagickMemory(const size_t);
	void* AcquireQuantumMemory(const size_t, const size_t);
	void* CopyMagickMemory(void*, const(void)*, const size_t);
	void  DestroyMagickMemory();
	void  GetMagickMemoryMethods(AcquireMemoryHandler*, ResizeMemoryHandler*, DestroyMemoryHandler*);
	void* RelinquishAlignedMemory(void*);
	void* RelinquishMagickMemory(void*);
	void* ResetMagickMemory(void*, int, const size_t);
	void* ResizeMagickMemory(void*, const size_t);
	void* ResizeQuantumMemory(void*, const size_t, const size_t);
	void  SetMagickMemoryMethods(AcquireMemoryHandler, ResizeMemoryHandler, DestroyMemoryHandler);
}
