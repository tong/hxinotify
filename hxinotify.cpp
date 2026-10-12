
#define IMPLEMENT_API
#define NEKO_COMPATIBLE

#include <hx/CFFI.h>
#include <errno.h>
#include <unistd.h>
#include <sys/inotify.h>

static value hxinotify_init( value flags ) {
	val_check(flags,int);
	int fd;
	fd = inotify_init1( val_int( flags ) );
	return alloc_int( fd < 0 ? -errno : fd );
}

static value hxinotify_add_watch( value fd, value path, value mask ) {
	val_check(fd,int);
	val_check(path,string);
	val_check(mask,int);
	int wd;
	wd = inotify_add_watch( val_int(fd), val_string(path), val_int(mask) );
	return alloc_int( wd < 0 ? -errno : wd );
}

static value hxinotify_rm_watch( value fd, value wd ) {
	val_check(fd,int);
	val_check(wd,int);
	int r;
	r = inotify_rm_watch( val_int( fd ), val_int( wd ) );
	return alloc_int( r < 0 ? -errno : 0 );
}

static value hxinotify_read( value fd, value buf, value size ) {
	val_check(fd,int);
	//TODO
	//val_check(buf,string); // error hxcpp
	//val_check(buf,buffer); // error neko
	val_check(size,int);
	int _fd = val_int(fd), _size = val_int(size);
	char *data = (char*)val_string(buf);
	// Allow GC in other threads while blocked (buf is rooted by the caller, GC does not move)
	gc_enter_blocking();
	ssize_t len = read( _fd, data, _size );
	int err = errno;
	gc_exit_blocking();
	return alloc_int( len < 0 ? -err : len );
}

static value hxinotify_close( value fd ) {
	val_check(fd,int);
	int r;
	r = close( val_int(fd) );
	return alloc_int( r < 0 ? -errno : 0 );
}

DEFINE_PRIM( hxinotify_init, 1 );
DEFINE_PRIM( hxinotify_add_watch, 3 );
DEFINE_PRIM( hxinotify_rm_watch, 2 );
DEFINE_PRIM( hxinotify_read, 3 );
DEFINE_PRIM( hxinotify_close, 1 );
