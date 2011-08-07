/**
 * A collection of helper functions used in DMagick.
 *
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */

module dmagick.Utils;

import std.math;

import dmagick.Exception;

import dmagick.c.memory;
import dmagick.c.magickString;
import dmagick.c.magickType;

/**
 * Copy a string into a static array used
 * by ImageMagick for some atributes.
 */
void copyString(ref char[MaxTextExtent] dest, string source)
{
	if ( source.length > MaxTextExtent )
		throw new ResourceLimitException("Source is larger then MaxTextExtend", null);

	dest[0 .. source.length] = source;
	dest[source.length] = '\0';
}

unittest
{
	char[MaxTextExtent] dest;
	copyString(dest, "unittest");

	assert(dest[0 .. 8] == "unittest");
}

/**
 * Our implementation of ImageMagick's CloneString.
 *
 * We use this since using CloneString forces us to
 * append a \0 to the end of the string, and the realocation
 * whould be wastefull if we are just going to copy it
 *
 * used for copying a string into a Imagemagick struct
 */
void copyString(ref char* dest, string source)
{
	if ( source is null )
	{
		if ( dest !is null )
			dest = DestroyString(dest);
		return;
	}

	if ( ~source.length < MaxTextExtent )
		throw new ResourceLimitException("unable to acquire string", null);

	if ( dest is null )
		dest = cast(char*)AcquireQuantumMemory(source.length+MaxTextExtent, dest.sizeof);
	else
		dest = cast(char*)ResizeQuantumMemory(dest, source.length+MaxTextExtent, dest.sizeof);

	if ( dest is null )
		throw new ResourceLimitException("unable to acquire string", null);

	if ( source.length > 0 )
		dest[0 .. source.length] = source;

	dest[source.length] = '\0';
}

unittest
{
	char* dest;
	string source = "test";

	copyString(dest, source);

	assert( dest !is source.ptr );
	assert( dest[0..5] == "test\0" );

	copyString(dest, "unit");
	assert( dest[0..5] == "unit\0" );

	copyString(dest, null);
	assert( dest is null );
}

/** */
real degreesToRadians(real deg)
{
	return deg*PI/180;
}


/**
 * A template struct to make pointers to ImageMagick structs
 * reference counted. Excepts a predicate pred which destroys
 * the struct pointer when refCount is 0.
 */
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
		if ( !isInitialized )
			return;

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
