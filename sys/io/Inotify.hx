package sys.io;

#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#end

using Lambda;

typedef InotifyEvent = {

	/** Watch descriptor */
	var wd : Int;

	/** Mask of events */
	var mask : Int;

	/** Unique cookie associating related events */
	var cookie : Int;

	/** Size of "name" field */
	var len : Int;

	/** Optional null-terminated name */
	var name : String;
}

/**
	Inode-based filesystem notification.
*/
@:require(cpp||neko)
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
	
	/**
		Adds a new watch, or modifies an existing watch, for the file whose location is specified in path.
	*/
	public function addWatch( path : String, mask : Int ) : Int {
		#if neko
		return _add_watch( fd, untyped path.__s, mask );
		#elseif cpp
		return _add_watch( fd, path, mask );
		#end
	}

	/**
		Removes the watch associated with the watch descriptor wd from the inotify instance
	*/
	public function removeWatch( wd : Int ) {
		_rm_watch( fd, wd );
	}

	/**
	*/
	public function getEvents( wd : Int ) : Array<InotifyEvent> {
		
		#if cpp
		var events : Array<InotifyEvent> = _read( fd, wd );
		return events;
		
		#elseif neko
		//var events : Dynamic = _read( fd, wd );
		//return (events==null) ? null : neko.Lib.nekoToHaxe(events);
		//trace( _read( fd, wd ) );
		//return null;
		//var v : Dynamic = _read( fd, wd );
		//trace(v);
		//var events : Array<InotifyEvent> = neko.Lib.nekoToHaxe( _read( fd, wd ) );
		//trace(events);
		//return events;
		//var v : Dynamic = _read( fd, wd );
		var events : Array<InotifyEvent> = neko.Lib.nekoToHaxe( _read( fd, wd ) );
		return events;
		#end
	}

	/**
	*/
	public function close() _close( fd );

	private static var moduleName = 'inotify';
	#if neko
	private static var moduleInit = false;
	private static function loadNekoAPI() {
		var init = neko.Lib.load( moduleName, 'neko_init', 5 );
		if( init != null ) {
			init(
				function(s) return new String(s),
				function(len:Int) { var r=[]; if(len>0) r[len - 1] = null; return r; }, null, true, false );
			moduleInit = true;
		} else
			throw 'Could not find nekoapi interface';
	}
	#end

	static var _init = lib( 'init', 1 );
	static var _add_watch = lib( 'add_watch', 3 );
	static var _rm_watch = lib( 'rm_watch', 2 );
	static var _read = lib( 'read', 2 );
	static var _close = lib( 'close', 1 );

	private static inline function lib( f : String, n : Int = 0 ) : Dynamic {
		return Lib.load( moduleName, 'hxinotify_'+f, n );
		/* TODO
		#if cpp
		#elseif neko
		//if( !moduleInit ) loadNekoAPI();
		return neko.Lib.load( moduleName, 'hxinotify_'+f, n );
		#end
		*/
	}
	
}
