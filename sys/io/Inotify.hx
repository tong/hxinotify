package sys.io;

/**
**/
@:enum abstract InotifyMask(Int) from Int to Int {

	/**
	**/
	var NONBLOCK = 0x04000;

	/**
	**/
	var CLOEXEC = 0x02000000;

	/**
		File was accessed  (e.g., `read`,`execve`)
	**/
	var ACCESS = 0x00000001;

	/**
		File was modified (e.g., `write`,`truncate`).
	**/
	var MODIFY = 0x00000002;

	/**
		Metadata changed (permissions (e.g., `chmod`), timestamps (e.g., `utimensat`), extended attributes (`setxattr`)).
	**/
	var ATTRIB = 0x00000004;

	/**
		File opened for writing was closed.
	**/
	var CLOSE_WRITE = 0x00000008;

	/**
		File or directory not opened for writing was closed.
	**/
	var CLOSE_NOWRITE = 0x00000010;

	/**
		File or directory was opened.
	**/
	var OPEN = 0x00000020;

	/**
		Generated for the directory containing the old filename when a file is renamed.
	**/
	var MOVED_FROM = 0x00000040;

	/**
		Generated for the directory containing the new filename when a file is renamed.
	**/
	var MOVED_TO = 0x00000080;

	/**
		File/directory created in watched directory
	**/
	var CREATE = 0x00000100;

	/**
		File/directory deleted from watched directory.
	**/
	var DELETE = 0x00000200;

	/**
		Watched file/directory was itself deleted.
	**/
	var DELETE_SELF = 0x00000400;

	/**
		Watched file/directory was itself moved.
	**/
	var MOVE_SELF = 0x00000800;

	/**
		Equates to `CLOSE_WRITE|CLOSE_NOWRITE`.
	**/
	var CLOSE = 0x00000008 | 0x00000010;

	/**
		Equates to `MOVED_FROM|MOVED_TO`.
	**/
	var MOVE = 0x00000040 | 0x00000080;

	/**
		Filesystem containing watched object was unmounted.
	**/
	var UNMOUNT = 0x00002000;

	/**
	**/
	var Q_OVERFLOW = 0x00004000;

	/**
		Watch was removed explicitly (`removeWatch()`) or automatically (file was deleted, or filesystem was unmounted).
	**/
	var IGNORED = 0x00008000;

	/**
		Only watch `pathname` if it is a directory.

		Using this flag provides an application with a race-free way of ensuring that the monitored object is a directory.
	**/
	var ONLYDIR = 0x01000000;

	/**
		Don't dereference `pathname` if it is a symbolic link.
	**/
	var DONT_FOLLOW = 0x02000000;

	/**
	**/
	var EXCL_UNLINK = 0x04000000;

	/**
		If a watch instance already exists for the filesystem object corresponding to pathname, add (OR) the events in mask to the watch mask (instead of replacing the mask).
	**/
	var MASK_ADD = 0x20000000;

	/**
		Subject of this event is a directory.
	**/
	var ISDIR = 0x40000000;

	/**
		Monitor the filesystem object corresponding to `pathname` for one event, then remove from watch list.
	**/
	var ONESHOT = 0x80000000;

	/**
		All of the events (`ACCESS|MODIFY|ATTRIB|CLOSE_WRITE|CLOSE_NOWRITE|OPEN|MOVED_FROM|MOVED_TO|DELETE|CREATE|DELETE_SELF|MOVE_SELF`).
	**/
	var ALL = 0xFFF;
}

/**
**/
typedef InotifyEvent = {

	/**
		Identifies the watch for which this event occurs.
		It is one of the watch descriptors returned by a previous call to `addWatch`.
	**/
	var wd : Int;

	/**
		Mask of bits that describe the event that occurred.
	**/
	var mask : Int;

	/**
		Optional unique integer that connects related events.
	**/
	var cookie : Int;

	/**
		Optional filename associated with this event (local to parent directory).

		Present only when an event is returned for a file inside a watched directory; it identifies the filename within to the watched directory.
		This filename is null-terminated, and may include further null bytes `('\0')` to align subsequent reads to a suitable address boundary.
	*/
	var name : String;
}

/**
	Inode-based filesystem notification.

	Linux kernel subsystem that acts to extend filesystems to notice changes to the filesystem, and report those changes to applications.
	Inotify does not support recursively watching directories, meaning that a separate inotify watch must be created for every subdirectory.
	Inotify does report some but not all events in sysfs and procfs.

	@see http://man7.org/linux/man-pages/man7/inotify.7.html
**/
@:require(sys)
class Inotify {

	var fd : Int;

	/**
		Creates an inotify instance.
	**/
	public function new( nonBlock = false, closeOnExec = false ) {
		#if !doc_gen
		fd = _init( (nonBlock ? NONBLOCK : 0) | (closeOnExec ? CLOEXEC : 0) );
		#end
	}

	/**
		Adds a new watch, or modifies an existing watch.

		@param  path  Path to file ot directory to watch
		@param  mask  Set of events that the kernel should monitor
		@returns  Created watch descriptior itdentifier
	**/
	public function addWatch( path : String, mask : InotifyMask ) : Int {
		path = FileSystem.fullPath( path );
		return #if doc_gen 0; #else
			_add_watch(
				fd,
				#if cpp path,
				#elseif hl @:privateAccess path.bytes,
				#elseif neko untyped path.__s,
				#end
				mask
			);
		#end
	}

	/**
		Removes the watch associated with the watch descriptor `wd` from the inotify instance.

		@param  wd  Watch descriptor identifier
		@returns  Result status code
	**/
	public function removeWatch( wd : Int ) : Int {
		return #if doc_gen 0 #else _rm_watch( fd, wd ) #end;
	}

	/**
		Read available inotify events.

		@param  size  Buffer size (1 event = `sizeof(struct inotify_event) + (event name length)`)
		@returns  List of events occurred.
	**/
	public function read( size = 4096 ) : Array<InotifyEvent> {
		#if doc_gen return null; #else
		var buf = haxe.io.Bytes.alloc( size );
		var length = _read( fd, buf.getData(), size );
		if( length < 0 )
			throw 'inotify read';
		buf = buf.sub( 0, length );
		var events = new Array<InotifyEvent>();
		if( length > 0 ) {
			var i = 0;
			while( i < length ) {
				var wd = buf.getInt32( i );
				var mask = buf.getInt32( i + 4 );
				var cookie = buf.getInt32( i + 8 );
				var len = buf.getInt32( i + 12 );
				var name : String = null;
				if( len > 0 ) name = buf.getString( i + 16, len );
				events.push( { wd: wd, mask: mask, cookie: cookie, name: name } );
				i += 16 + len;
			}
		}
		return events;
		#end
	}

	/**
		Remove all watches and close the file descriptor.
	**/
	public function close() : Int {
		return #if doc_gen 0 #else _close( fd ) #end;
	}

	#if (cpp||neko)

	static inline var MODULE_NAME = 'inotify';

	static var _init = lib( 'init', 1 );
	static var _add_watch = lib( 'add_watch', 3 );
	static var _rm_watch = lib( 'rm_watch', 2 );
	static var _read = lib( 'read', 3 );
	static var _close = lib( 'close', 1 );

	static inline function lib( f : String, n : Int = 0 ) : Dynamic {
		#if neko
		if( !moduleInit ) loadNekoAPI();
		return neko.Lib.load( MODULE_NAME, 'hxinotify_'+f, n );
		#elseif cpp
		return cpp.Lib.load( MODULE_NAME, 'hxinotify_'+f, n );
		#else
		return null;
		#end
	}

	#end

	#if neko

	static var moduleInit = false;

	static function loadNekoAPI() {
		var init = neko.Lib.load( MODULE_NAME, 'neko_init', 5 );
		if( init != null ) {
			init( function(s) return new String(s), function(len:Int) { var r=[]; if(len > 0) r[len-1] = null; return r; }, null, true, false );
			moduleInit = true;
		} else
			throw 'Could not find nekoapi interface';
	}

	#end

	#if hl

	@:hlNative("inotify","init")
	static function _init( flags : Int ) : Int { return 0; }

	@:hlNative("inotify","add_watch")
	static function _add_watch( fd : Int, path : hl.Bytes, mask : Int ) : Int { return 0; }

	@:hlNative("inotify","rm_watch")
	static function _rm_watch( fd : Int, wd : Int ) : Int { return 0; }

	@:hlNative("inotify","read")
	static function _read( fd : Int, buf : hl.Bytes, size : Int ) : Int { return 0; }

	@:hlNative("inotify","close")
	static function _close( fd : Int ) : Int { return 0; }

	#end

}
