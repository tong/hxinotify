
#define IMPLEMENT_API
#define NEKO_COMPATIBLE

#include <hx/CFFI.h>
#include <unistd.h>
#include <sys/inotify.h>

#define EVENT_SIZE ( sizeof (struct inotify_event) )
#define BUF_LEN ( 1024 * ( EVENT_SIZE + 16 ) )
//#define val_throw_errno ( val_throw( alloc_string( strerror( errno ) ) ) )


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

/**
	Returns the index of the according haxe enum constructor of given flag
*/
static int getMaskIndex( int flag ) {
	int i;
	switch( flag ) {
	case IN_ACCESS : i = 0; break;
	}
	return i;
}


static value hxinotify_init( value flags ) {
	int fd = inotify_init1( val_int( flags ) );
	return alloc_int( fd );
}

static value hxinotify_add_watch( value _fd, value _pathname, value _mask ) {
	int wd = inotify_add_watch( val_int( _fd ), val_string( _pathname ), val_int( _mask ) );
	if( wd == -1 )
		throwErrno();
	return alloc_int( wd );
}

static value hxinotify_remove_watch( value fd, value wd ) {
	int err = inotify_rm_watch( val_int( fd ), val_int( wd ) );
	if( err == -1 )
		throwErrno();
	return alloc_null();
}

static value hxinotify_read( value fd, value wd ) {
	char buffer[BUF_LEN];
	int len = read( val_int( fd ), buffer, BUF_LEN ); 
	if( len == -1 )
		throwErrno();
	int i, n = 0;
	value events = alloc_array( len / (EVENT_SIZE*2) );
	while( i < len ) {
		struct inotify_event *e = ( struct inotify_event * ) &buffer[i];
		if( e->len ) {
			printf( "MMMMMMMMMMMMMMMM %d\n",e->mask );
			value o = alloc_empty_object();
			alloc_field( o, val_id( "wd" ), wd );
			alloc_field( o, val_id( "mask" ), alloc_int( getMaskIndex( e->mask ) ) );
			alloc_field( o, val_id( "cookie" ), alloc_int( e->cookie ) );
			alloc_field( o, val_id( "len" ), alloc_int( e->len ) );
			alloc_field( o, val_id( "name" ), alloc_string( e->name ) );
			val_array_set_i( events, n, o );
			n++;
		}
		i += EVENT_SIZE + e->len;
	}
	val_array_set_size( events, n );
	return events;
}

static value hxinotify_close( value fd ) {
	( void ) close( val_int( fd ) );
	return alloc_null();
}

DEFINE_PRIM( hxinotify_init, 1 );
DEFINE_PRIM( hxinotify_add_watch, 3 );
DEFINE_PRIM( hxinotify_remove_watch, 2 );
DEFINE_PRIM( hxinotify_read, 2 );
DEFINE_PRIM( hxinotify_close, 1 );
