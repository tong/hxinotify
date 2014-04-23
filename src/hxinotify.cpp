
#include "hxinotify.h"
#include <string.h>

static void throwErrno() { // Thread safe usage of strerror
	char buf[256];
	if( strerror_r( errno, buf, 256 ) == 0 )
		val_throw( alloc_string( buf ) );
	else
		val_throw( alloc_string( strerror( errno ) ) );
}

static void throwError( char * err) {
	val_throw( alloc_string( err ) );
}

value hxinotify_init( value flags ) {
	int fd = inotify_init1( val_int( flags ) );
	if( fd < 0 )
		val_throw( alloc_string( "inotify_init" ) );
	return alloc_int( fd );
}

value hxinotify_add_watch( value _fd, value _path, value _mask ) {
	int wd = inotify_add_watch( val_int( _fd ), val_string( _path ), val_int( _mask ) );
	if( wd < 0 )
		throwErrno();
	return alloc_int( wd );
}

value hxinotify_rm_watch( value fd, value wd ) {
	if( inotify_rm_watch( val_int( fd ), val_int( wd ) ) == -1 )
		throwErrno();
	return alloc_null();
}

value hxinotify_read( value fd, value wd ) {

	val_check(fd,int);
	val_check(wd,int);

	int len;
	int i = 0, j = 0;
	char buf[BUF_LEN];
	int size;

	len = read( val_int(fd), buf, BUF_LEN );
	if( !len ) {
		//printf( "buf length too small\n" );
		val_throw( alloc_string( "inotify read" ) );
	}
	size = len / ( EVENT_SIZE * 2 );
	value events = alloc_array( size );
	//while( i < len ) {
	while( j < size ) {
		struct inotify_event *e;
		e = (struct inotify_event *) &buf[i];
		//printf ("\twd=%d mask=%u cookie=%u len=%u\n", e->wd, e->mask, e->cookie, e->len );
		value o = alloc_empty_object();
		alloc_field( o, val_id( "wd" ), wd );
		alloc_field( o, val_id( "mask" ), alloc_int( e->mask ) );
		alloc_field( o, val_id( "cookie" ), alloc_int( e->cookie ) );
		alloc_field( o, val_id( "len" ), alloc_int( e->len ) );
		if( e->len ) alloc_field( o, val_id( "name" ), alloc_string( e->name ) );
		val_array_set_i( events, j++, o );
		i += EVENT_SIZE + e->len;
	}
	return events;
}

value hxinotify_close( value fd ) {
	(void) close( val_int(fd) );
	return alloc_null();
}
