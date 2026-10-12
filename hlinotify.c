
#define HL_NAME(n) hlinotify_##n

#include <errno.h>
#include <hl.h>
#include <sys/inotify.h>
#include <unistd.h>

HL_PRIM int HL_NAME(init)(int flags) {
  int fd;
  fd = inotify_init1(flags);
  return fd < 0 ? -errno : fd;
}

HL_PRIM int HL_NAME(add_watch)(int fd, vbyte *path, int mask) {
  int wd;
  wd = inotify_add_watch(fd, hl_to_utf8((uchar *)path), mask);
  return wd < 0 ? -errno : wd;
}

HL_PRIM int HL_NAME(rm_watch)(int fd, int wd) {
  return inotify_rm_watch(fd, wd) < 0 ? -errno : 0;
}

HL_PRIM int HL_NAME(read)(int fd, vbyte *buf, int size) {
  ssize_t len;
  // Allow GC in other threads while blocked (buf is rooted by the caller, HL GC
  // does not move)
  hl_blocking(true);
  len = read(fd, (char *)buf, size);
  int err = errno;
  hl_blocking(false);
  return len < 0 ? -err : (int)len;
}

HL_PRIM int HL_NAME(close)(int fd) { return close(fd) < 0 ? -errno : 0; }

DEFINE_PRIM(_I32, init, _I32);
DEFINE_PRIM(_I32, add_watch, _I32 _BYTES _I32);
DEFINE_PRIM(_I32, rm_watch, _I32 _I32);
DEFINE_PRIM(_I32, read, _I32 _BYTES _I32);
DEFINE_PRIM(_I32, close, _I32);
