/**
 * A collection of helper functions used in DMagick.
 *
 * Copyright: Mike Wey 2011
 * License:   To be determined
 * Authors:   Mike Wey
 */

module dmagick.Utils;

import std.math;

import dmagick.c.memory;
import dmagick.c.magickString;
import dmagick.c.magickType;

/**
 * Copy a string into a static array used
 * by ImageMagick for some atributes.
 */
private void copyString(ref char[MaxTextExtent] dest, string source)
{
	if ( source.length < MaxTextExtent )
		throw new Exception("text is to long"); //TODO: a proper exception.

	dest[0 .. source.length] = source;
	dest[source.length] = '\0';
}

/**
 * Our implementation of ImageMagick's CloneString.
 *
 * We use this since using CloneString forces us to
 * append a \0 to the end of the string, and the realocation
 * whould be wastefull if we are just going to copy it
 */
private void copyString(ref char* dest, string source)
{
	if ( source is null )
	{
		if ( dest !is null )
			DestroyString(dest);
		return;
	}

	if ( ~source.length < MaxTextExtent )
		throw new Exception("UnableToAcquireString"); //TODO: a proper exception.

	if ( dest is null )
		dest = cast(char*)AcquireQuantumMemory(source.length+MaxTextExtent, dest.sizeof);
	else
		dest = cast(char*)ResizeQuantumMemory(dest, source.length+MaxTextExtent, dest.sizeof);

	if ( dest is null )
		throw new Exception("UnableToAcquireString"); //TODO: a proper exception.

	if ( source.length > 0 )
		dest[0 .. source.length] = source;

	dest[source.length] = '\0';
}

real degreesToRadians(real deg)
{
	return deg*PI/180;
}

struct RefCounted(alias pred, T)
	if ( !is(T == class) && is(typeof(pred(cast(T*)null)) == T*) )
{
	T* payload;

	private bool isInitialized;
	private size_t* refcount;

	alias payload this;

	this(T* payload)
	{
		this.payload = payload;

		refcount  = new size_t;
		*refcount = 1;

		isInitialized = true;
	}

	this(this)
	{
		if ( isInitialized )
			(*refcount)++;
	}

	~this()
	{
		(*refcount)--;

		if ( *refcount == 0 )
			payload = pred(payload);
	}

	@property size_t refCount()
	{
		return *refcount;
	}
}

unittest
{
	int x = 10;
	int y = 20;

	alias RefCounted!( (int* t){ x = 20; return t; }, int ) IntRef;

	auto a = IntRef(&x);
	assert( a.refCount == 1 );
	auto b = a;
	assert( a.refCount == 2 );

	b = IntRef(&y);
	assert( a.refCount == 1 );
	assert( b.refCount == 1 );
	a = b;
	assert( b.refCount == 2 );
	assert( x == 20 );
}
