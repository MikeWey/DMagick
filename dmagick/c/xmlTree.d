module dmagick.c.xmlTree;

import dmagick.c.exception;
import dmagick.c.magickType;
import dmagick.c.splayTree;

extern(C)
{
	struct XMLTreeInfo {}

	char* CanonicalXMLContent(const(char)*, const MagickBooleanType);
	char* XMLTreeInfoToXML(XMLTreeInfo*);

	const(char)*  GetXMLTreeAttribute(XMLTreeInfo*, const(char)*);
	const(char)*  GetXMLTreeContent(XMLTreeInfo*);
	const(char)** GetXMLTreeProcessingInstructions(XMLTreeInfo*, const(char)*);
	const(char)*  GetXMLTreeTag(XMLTreeInfo*);

	MagickBooleanType GetXMLTreeAttributes(const(XMLTreeInfo)*, SplayTreeInfo*);

	XMLTreeInfo* AddChildToXMLTree(XMLTreeInfo*, const(char)*, const size_t);
	XMLTreeInfo* AddPathToXMLTree(XMLTreeInfo*, const(char)*, const size_t);
	XMLTreeInfo* DestroyXMLTree(XMLTreeInfo*);
	XMLTreeInfo* GetNextXMLTreeTag(XMLTreeInfo*);
	XMLTreeInfo* GetXMLTreeChild(XMLTreeInfo*, const(char)*);
	XMLTreeInfo* GetXMLTreeOrdered(XMLTreeInfo*);
	XMLTreeInfo* GetXMLTreePath(XMLTreeInfo*, const(char)*);
	XMLTreeInfo* GetXMLTreeSibling(XMLTreeInfo*);
	XMLTreeInfo* InsertTagIntoXMLTree(XMLTreeInfo*, XMLTreeInfo*, const size_t);
	XMLTreeInfo* NewXMLTree(const(char)*, ExceptionInfo*);
	XMLTreeInfo* NewXMLTreeTag(const(char)*);
	XMLTreeInfo* ParseTagFromXMLTree(XMLTreeInfo*);
	XMLTreeInfo* PruneTagFromXMLTree(XMLTreeInfo*);
	XMLTreeInfo* SetXMLTreeAttribute(XMLTreeInfo*, const(char)*, const(char)*);
	XMLTreeInfo* SetXMLTreeContent(XMLTreeInfo*, const(char)*);
}
