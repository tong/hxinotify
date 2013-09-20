
#include "hxinotify.h"

#define EVENT_SIZE ( sizeof (struct inotify_event) )
#define BUF_LEN ( 1024 * ( EVENT_SIZE + 16 ) ) // 1024 events

/**
	Thread safe usage of strerror
*/
static void throwErrno() {
	char buf[256];
	if( strerror_r( errno, buf, 256 ) == 0 )
		val_throw( alloc_string( buf ) );
	else
		val_throw( alloc_string( strerror( errno ) ) );
}

static value hxinotify_init( value flags ) {
	int fd = inotify_init1( val_int( flags ) );
	if( fd < 0 )
		val_throw( alloc_string( "inotify_init" ) );
		//perror( "inotify_init" );
	return alloc_int( fd );
}

static value hxinotify_add_watch( value _fd, value _path, value _mask ) {
	int wd = inotify_add_watch( val_int( _fd ), val_string( _path ), val_int( _mask ) );
	if( wd < 0 )
		throwErrno();
	return alloc_int( wd );
}

static value hxinotify_rm_watch( value fd, value wd ) {
	if( inotify_rm_watch( val_int( fd ), val_int( wd ) ) == -1 )
		throwErrno();
	return alloc_null();
}

static value hxinotify_read( value fd, value wd ) {
	char buf[BUF_LEN];
	int len, i = 0;
	len = read ( val_int( fd ), buf, BUF_LEN );
	if( len < 0 ) {
		if( errno == EINTR )
			printf("need to reissue system call \n" );
		else if( !len )
			printf("buf len too small ? \n" );
		throwErrno();
	}
	int asize = len / ( EVENT_SIZE * 2 );
	value events = alloc_array( asize );
	int p = 0;
	while( i < len ) {
		struct inotify_event *e = (struct inotify_event *) &buf[i];
		value o = alloc_empty_object();
		alloc_field( o, val_id( "wd" ), wd );
		alloc_field( o, val_id( "mask" ), alloc_int( e->mask ) );
		alloc_field( o, val_id( "cookie" ), alloc_int( e->cookie ) );
		alloc_field( o, val_id( "len" ), alloc_int( e->len ) );
		if( e->len )
			alloc_field( o, val_id( "name" ), alloc_string( e->name ) );
		val_array_set_i( events, p, o );
		p++;
		i += EVENT_SIZE + e->len;
	}
	return events;
}

static value hxinotify_close( value fd ) {
	( void ) close( val_int( fd ) );
	return alloc_null();
}
