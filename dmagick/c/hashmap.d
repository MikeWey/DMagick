module dmagick.c.hashmap;

import dmagick.c.magickType;

extern(C)
{
	struct HashmapInfo {}

	struct LinkedListInfo {}

	HashmapInfo* DestroyHashmap(HashmapInfo*);
	HashmapInfo* NewHashmap(const size_t, size_t function(const(void)*),
			MagickBooleanType function(const(void)*, const(void)*), void* function(void*), void* function(void*));

	LinkedListInfo* DestroyLinkedList(LinkedListInfo*, void* function(void*));
	LinkedListInfo* NewLinkedList(const size_t);

	MagickBooleanType AppendValueToLinkedList(LinkedListInfo*, const(void)*);
	MagickBooleanType CompareHashmapString(const(void)*, const(void)*);
	MagickBooleanType CompareHashmapStringInfo(const(void)*, const(void)*);
	MagickBooleanType InsertValueInLinkedList(LinkedListInfo*, const size_t, const(void)*);
	MagickBooleanType InsertValueInSortedLinkedList(LinkedListInfo*, int function(const(void)*, const(void)*), void**, const(void)*);
	MagickBooleanType IsHashmapEmpty(const(HashmapInfo)*);
	MagickBooleanType IsLinkedListEmpty(const(LinkedListInfo)*);
	MagickBooleanType LinkedListToArray(LinkedListInfo*, void**);
	MagickBooleanType PutEntryInHashmap(HashmapInfo*, const(void)*, const(void)*);

	size_t GetNumberOfElementsInLinkedList(const(LinkedListInfo)*);
	size_t GetNumberOfEntriesInHashmap(const(HashmapInfo)*);
	size_t HashPointerType(const(void)*);
	size_t HashStringType(const(void)*);
	size_t HashStringInfoType(const(void)*);

	void  ClearLinkedList(LinkedListInfo*, void* function(void*));
	void* GetLastValueInLinkedList(LinkedListInfo*);
	void* GetNextKeyInHashmap(HashmapInfo*);
	void* GetNextValueInHashmap(HashmapInfo*);
	void* GetNextValueInLinkedList(LinkedListInfo*);
	void* GetValueFromHashmap(HashmapInfo*, const(void)*);
	void* GetValueFromLinkedList(LinkedListInfo*, const size_t);
	void* RemoveElementByValueFromLinkedList(LinkedListInfo*, const(void)*);
	void* RemoveElementFromLinkedList(LinkedListInfo*, const size_t);
	void* RemoveEntryFromHashmap(HashmapInfo*, const(void)*);
	void* RemoveLastElementFromLinkedList(LinkedListInfo*);
	void  ResetHashmapIterator(HashmapInfo*);
	void  ResetLinkedListIterator(LinkedListInfo*);
}
