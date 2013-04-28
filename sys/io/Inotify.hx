package sys.io;

using Lambda;

/**
	Inode-based filesystem notification to monitor various filesystem events.
*/
@:require(sys)
class Inotify {

	public static inline var NONBLOCK = 04000;
	public static inline var CLOEXEC = 02000000;

	public static inline var ACCESS = 0x00000001;
	public static inline var MODIFY = 0x00000002;
	public static inline var ATTRIB = 0x00000004;
	public static inline var CLOSE_WRITE = 0x00000008;
	public static inline var CLOSE_NOWRITE = 0x00000010;
	public static inline var OPEN = 0x00000020;
	public static inline var MOVED_FROM = 0x00000040;
	public static inline var MOVED_TO = 0x00000080;
	public static inline var CREATE = 0x00000100;
	public static inline var DELETE = 0x00000200;
	public static inline var DELETE_SELF = 0x00000400;
	public static inline var MOVE_SELF = 0x00000800;
	
	public static inline var CLOSE = CLOSE_WRITE | CLOSE_NOWRITE;
	public static inline var MOVE = MOVED_FROM | MOVED_TO;

	public static inline var UNMOUNT = 0x00002000;
	public static inline var Q_OVERFLOW = 0x00004000;
	public static inline var IGNORED = 0x00008000;
	
	public static inline var ONLYDIR = 0x01000000;
	public static inline var DONT_FOLLOW = 0x02000000;
	public static inline var EXCL_UNLINK = 0x04000000;
	public static inline var MASK_ADD = 0x20000000;
	public static inline var ISDIR = 0x40000000;
	public static inline var ONESHOT = 0x80000000;
	
	public static inline var ALL_EVENTS =
		ACCESS | MODIFY | ATTRIB | CLOSE_WRITE
		| CLOSE_NOWRITE | OPEN | MOVED_FROM
		| MOVED_TO | CREATE | DELETE
		| DELETE_SELF | MOVE_SELF;

	var fd : Int;

	public function new( nonBlock : Bool = false, closeOnExec : Bool = false ) {
		fd = _init( ( nonBlock ? NONBLOCK : 0 ) | ( closeOnExec ? CLOEXEC : 0 ) );
	}
	
	public function addWatch( path : String, mask : Int ) : Int {
		#if neko
		return _add_watch( fd, untyped path.__s, mask );
		#elseif cpp
		return _add_watch( fd, path, mask );
		#end
	}

	public function removeWatch( wd : Int ) {
		_remove_watch( fd, wd );
	}

	public function getEvents( wd : Int ) : Array<InotifyEvent> {
		#if cpp
		var events : Array<InotifyEvent> = _read( fd, wd );
		return events;
		#elseif neko
		var events : Array<InotifyEvent> = neko.Lib.nekoToHaxe( _read( fd, wd ) );
		return events;
		#end
	}

	public function close() _close( fd );

	static var _init = ext( 'init', 1 );
	static var _add_watch = ext( 'add_watch', 3 );
	static var _remove_watch = ext( 'remove_watch', 2 );
	static var _read = ext( 'read', 2 );
	static var _close = ext( 'close', 1 );

	static inline function ext( f : String, n : Int = 0 ) {
		#if cpp
		return cpp.Lib.load( 'inotify', 'hxinotify_'+f, n );
		#elseif neko
		return neko.Lib.load( 'inotify', 'hxinotify_'+f, n );
		#end
	}
	
}
