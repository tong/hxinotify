
#ifndef _HXINOTIFY_H
#define _HXINOTIFY_H

#define IMPLEMENT_API
#define NEKO_COMPATIBLE

#include <hx/CFFI.h>
#include <unistd.h>
#include <sys/inotify.h>

static value hxinotify_init( value flags );
static value hxinotify_add_watch( value fd, value path, value mask );
static value hxinotify_remove_watch( value fd, value wd ) ;
static value hxinotify_read( value fd, value wd );
static value hxinotify_close( value fd );

DEFINE_PRIM( hxinotify_init, 1 );
DEFINE_PRIM( hxinotify_add_watch, 3 );
DEFINE_PRIM( hxinotify_remove_watch, 2 );
DEFINE_PRIM( hxinotify_read, 2 );
DEFINE_PRIM( hxinotify_close, 1 );

#endif
