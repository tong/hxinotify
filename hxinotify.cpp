
#define IMPLEMENT_API
#define NEKO_COMPATIBLE

#include <hx/CFFI.h>
#include <unistd.h>
#include <sys/inotify.h>

static value hxinotify_init( value flags ) {
	val_check(flags,int);
	int fd;
	//gc_enter_blocking();
	fd = inotify_init1( val_int( flags ) );
	//gc_exit_blocking();
	return alloc_int( fd );
}

static value hxinotify_add_watch( value fd, value path, value mask ) {
	val_check(fd,int);
	val_check(path,string);
	val_check(mask,int);
	int wd;
	wd = inotify_add_watch( val_int(fd), val_string(path), val_int(mask) );
	return alloc_int( wd );
}

static value hxinotify_rm_watch( value fd, value wd ) {
	val_check(fd,int);
	val_check(wd,int);
	int r;
	r = inotify_rm_watch( val_int( fd ), val_int( wd ) );
	return alloc_int( r );
}

static value hxinotify_read( value fd, value buf, value size ) {
	val_check(fd,int);
	//TODO
	//val_check(buf,string); // error hxcpp
	//val_check(buf,buffer); // error neko
	val_check(size,int);
	ssize_t len;
	len = read( val_int(fd), (char*)val_string(buf), val_int(size) );
	return alloc_int( len );
}

static value hxinotify_close( value fd ) {
	val_check(fd,int);
	int r;
	r = close( val_int(fd) );
	return alloc_int( r );
}

DEFINE_PRIM( hxinotify_init, 1 );
DEFINE_PRIM( hxinotify_add_watch, 3 );
DEFINE_PRIM( hxinotify_rm_watch, 2 );
DEFINE_PRIM( hxinotify_read, 3 );
DEFINE_PRIM( hxinotify_close, 1 );
