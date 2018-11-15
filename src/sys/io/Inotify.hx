package sys.io;

@:enum abstract Mask(Int) from Int to Int {

	/** */
	var NONBLOCK = 0x04000;

	/** */
	var CLOEXEC = 0x02000000;

	/** File was accessed */
	var ACCESS = 0x00000001;

	/** File was modified. */
	var MODIFY = 0x00000002;

	/** Metadata changed */
	var ATTRIB = 0x00000004;

	/** File opened for writing was closed. */
	var CLOSE_WRITE = 0x00000008;

	/** File or directory not opened for writing was closed. */
	var CLOSE_NOWRITE = 0x00000010;

	/** File or directory was opened. */
	var OPEN = 0x00000020;

	/** Generated for the directory containing the old filename when a file is renamed. */
	var MOVED_FROM = 0x00000040;

	/** Generated for the directory containing the new filename when a file is renamed. */
	var MOVED_TO = 0x00000080;

	/** File/directory created in watched directory */
	var CREATE = 0x00000100;

	/** File/directory deleted from watched directory. */
	var DELETE = 0x00000200;

	/** Watched file/directory was itself deleted. */
	var DELETE_SELF = 0x00000400;

	/** Watched file/directory was itself moved. */
	var MOVE_SELF = 0x00000800;

	/** Equates to `IN_CLOSE_WRITE  IN_CLOSE_NOWRITE`. */
	var CLOSE = 0x00000008 | 0x00000010;

	/** Equates to `IN_MOVED_FROM | IN_MOVED_TO`. */
	var MOVE = 0x00000040 | 0x00000080;

	/** Filesystem containing watched object was unmounted. */
	var UNMOUNT = 0x00002000;

	/** */
	var Q_OVERFLOW = 0x00004000;

	/** Watch was removed explicitly (inotify_rm_watch(2)) or automatically (file was deleted, or filesystem was unmounted). */
	var IGNORED = 0x00008000;

	/**
		Only watch pathname if it is a directory.

		Using this flag  provides an application with a race-free way of ensuring that the monitored object is a directory.
	*/
	var ONLYDIR = 0x01000000;

	/** Don't dereference pathname if it is a symbolic link. */
	var DONT_FOLLOW = 0x02000000;

	/** */
	var EXCL_UNLINK = 0x04000000;

	/** If a watch instance already exists for the filesystem object corresponding to pathname, add (OR) the events in mask to the watch mask (instead of replacing the mask). */
	var MASK_ADD = 0x20000000;

	/** Subject of this event is a directory. */
	var ISDIR = 0x40000000;

	/** Monitor the filesystem object corresponding to pathname for one event, then remove from watch list. */
	var ONESHOT = 0x80000000;
}

typedef Event = {

	/** Watch descriptor */
	var wd : Int;

	/** Mask of events, bits that describe the event that occurred. */
	var mask : Int;

	/** Unique cookie associating related events */
	var cookie : Int;

	/**
		Size of `name` field.

		The len field counts all of the bytes in name, including the null bytes; the length of each inotify_event structure is thus `sizeof(struct inotify_event)+len`.
	*/
	//var len : Int;

	/**
		Optional null-terminated filename associated with this event (local to parent directory).

		The name field is present only when an event is returned for a file inside a watched directory; it identifies the filename within to the watched directory.
		This filename is null-terminated, and may include further null bytes `('\0')` to align subsequent reads to a suitable address boundary.
	*/
	var name : String;
}

/**
	Inode-based filesystem notification.

	Linux kernel subsystem that acts to extend filesystems to notice changes to the filesystem, and report those changes to applications.
	Inotify does not support recursively watching directories, meaning that a separate inotify watch must be created for every subdirectory.
	Inotify does report some but not all events in sysfs and procfs.
**/
@:require(sys)
class Inotify {

	var fd : Int;

	public function new( nonBlock = false, closeOnExec = false ) {
		fd = _init( (nonBlock ? NONBLOCK : 0) | (closeOnExec ? CLOEXEC : 0) );
	}

	/**
		Adds a new watch, or modifies an existing watch, for the file whose location is specified in path.
	**/
	public function addWatch( path : String, mask : Mask ) : Int {
		path = FileSystem.fullPath( path );
		#if neko
		return _add_watch( fd, untyped path.__s, mask );
		#elseif cpp
		return _add_watch( fd, path, mask );
		#else
		return 0;
		#end
	}

	/**
		Removes the watch associated with the watch descriptor `wd` from the inotify instance.
	**/
	public function removeWatch( wd : Int ) : Int {
		return _rm_watch( fd, wd );
	}

	/**
		Read available inotify events.

		@param  size  Buffer size (1 event: sizeof(struct inotify_event) + (event name length))
	**/
	public function read( size = 4096 ) : Array<Event> {
		var bytes = haxe.io.Bytes.alloc( size );
		var length = _read( fd, bytes.getData(), size );
		if( length < 0 )
			throw 'inotify read '+length;
		var events = new Array<Event>();
		if( length > 0 ) {
			var i = 0;
			while( i < length ) {
				var wd = bytes.getInt32( i );
				var mask = bytes.getInt32( i + 4 );
				var cookie = bytes.getInt32( i + 8 );
				var len = bytes.getInt32( i + 12 );
				var name : String = null;
				if( len > 0 ) name = bytes.getString( i + 16, len );
				events.push( { wd: wd, mask: mask, cookie: cookie, name: name } );
				i += 16 + len;
			}
		}
		return events;
	}

	/**
		Remove all watches and close the file descriptor
	**/
	public function close() : Int {
		return _close( fd );
	}

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

	static inline var MODULE_NAME = 'inotify';

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

}
