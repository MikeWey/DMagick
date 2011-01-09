module dmagick.c.splayTree;

import dmagick.c.magickType;

extern(C)
{
	struct SplayTreeInfo {}

	MagickBooleanType AddValueToSplayTree(SplayTreeInfo*, const(void)*, const(void)*);
	MagickBooleanType DeleteNodeByValueFromSplayTree(SplayTreeInfo*, const(void)*);
	MagickBooleanType DeleteNodeFromSplayTree(SplayTreeInfo*, const(void)*);

	const(void)* GetNextKeyInSplayTree(SplayTreeInfo*);
	const(void)* GetNextValueInSplayTree(SplayTreeInfo*);
	const(void)* GetValueFromSplayTree(SplayTreeInfo*, const(void)*);

	int CompareSplayTreeString(const(void)*, const(void)*);
	int CompareSplayTreeStringInfo(const(void)*, const(void)*);

	SplayTreeInfo* CloneSplayTree(SplayTreeInfo*, void* function(void*), void* function(void*));
	SplayTreeInfo* DestroySplayTree(SplayTreeInfo*);
	SplayTreeInfo* NewSplayTree(int function(const(void)*, const(void)*), void* function(void*), void* function(void*));

	size_t GetNumberOfNodesInSplayTree(const(SplayTreeInfo)*);

	void* RemoveNodeByValueFromSplayTree(SplayTreeInfo*, const(void)*);
	void* RemoveNodeFromSplayTree(SplayTreeInfo*, const(void)*);
	void  ResetSplayTree(SplayTreeInfo*);
	void  ResetSplayTreeIterator(SplayTreeInfo*);
}
