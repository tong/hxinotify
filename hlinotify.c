
#define HL_NAME(n) hlinotify_##n

#include <hl.h>
#include <unistd.h>
#include <sys/inotify.h>

HL_PRIM int HL_NAME(init)( int flags ) {
	int fd;
	fd = inotify_init1( flags );
	return fd;
}

HL_PRIM int HL_NAME(add_watch)( int fd, vbyte *path, int mask ) {
	int wd;
	wd = inotify_add_watch( fd, hl_to_utf8((uchar*)path), mask );
	return wd;
}

HL_PRIM int HL_NAME(rm_watch)( int fd, int wd ) {
	return inotify_rm_watch( fd, wd );
}

HL_PRIM int HL_NAME(read)( int fd, vbyte *buf, int size ) {
	ssize_t len;
	len = read( fd, (char*)buf, size );
	return (int)len;
}

HL_PRIM int HL_NAME(close)( int fd ) {
	return close( fd );
}

DEFINE_PRIM(_I32, init, _I32);
DEFINE_PRIM(_I32, add_watch, _I32 _BYTES _I32);
DEFINE_PRIM(_I32, rm_watch, _I32 _I32);
DEFINE_PRIM(_I32, read, _I32 _BYTES _I32);
DEFINE_PRIM(_I32, close, _I32);
