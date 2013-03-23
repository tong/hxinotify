
#define IMPLEMENT_API
#define NEKO_COMPATIBLE

#include <hx/CFFI.h>
#include <unistd.h>
#include <sys/inotify.h>

#define EVENT_SIZE  ( sizeof (struct inotify_event) )
#define BUF_LEN ( 1024 * ( EVENT_SIZE + 16 ) )

static value hxinotify_init( value _flags ) {
	int flags = val_int( _flags );
	int fd;
	if( flags == 0 )
		fd = inotify_init();
	else 
		fd = inotify_init1( flags );
	return alloc_int( fd );
}

static value hxinotify_add_watch( value _fd, value _pathname, value _mask ) {
	int wd = inotify_add_watch( val_int( _fd ), val_string( _pathname ), val_int( _mask ) );
	return alloc_int( wd );
}

static value hxinotify_listen( value fd, value wd ) {
	char buffer[BUF_LEN];
	int length = read( val_int( fd ), buffer, BUF_LEN ); 
	if( length < 0 ) {
		//perror( "read" );
		val_throw( alloc_string( "read" ) );
	}
	int i, n = 0;
	value arr = alloc_array(10); //TODO hmmm
	while ( i < length ) {
		struct inotify_event *e = ( struct inotify_event * ) &buffer[i];
		if( e->len ) {
			value o = alloc_empty_object();
			alloc_field( o, val_id( "wd" ), wd );
			alloc_field( o, val_id( "mask" ), alloc_int( e->mask ) );
			alloc_field( o, val_id( "cookie" ), alloc_int( e->cookie ) );
			alloc_field( o, val_id( "len" ), alloc_int( e->len ) );
			alloc_field( o, val_id( "name" ), alloc_string( e->name ) );
			val_array_set_i( arr, n, o );
			n++;
		}
		i += EVENT_SIZE + e->len;
	}
	val_array_set_size( arr, n );
	return arr;
}

static value hxinotify_remove_watch( value fd, value wd ) {
	( void ) inotify_rm_watch( val_int( fd ), val_int( wd ) );
	return alloc_null();
}

static value hxinotify_close( value fd ) {
	( void ) close( val_int( fd ) );
	return alloc_null();
}

DEFINE_PRIM( hxinotify_init, 1 );
DEFINE_PRIM( hxinotify_add_watch, 3 );
DEFINE_PRIM( hxinotify_listen, 2 );
DEFINE_PRIM( hxinotify_remove_watch, 2 );
DEFINE_PRIM( hxinotify_close, 1 );
