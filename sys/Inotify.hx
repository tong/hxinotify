package sys;

/**
	Inode-based filesystem notification to monitor various filesystem events.
*/
@:require(sys)
class Inotify {

	public static inline var IN_NONBLOCK = 2048;
	public static inline var IN_CLOEXEC = 524288;

	public static inline var IN_ACCESS = 1;
	public static inline var IN_ATTRIB = 4;
	public static inline var IN_CLOSE_WRITE = 8;
	public static inline var IN_CLOSE_NOWRITE = 16;
	public static inline var IN_CREATE = 256;
	public static inline var IN_DELETE = 512;
	public static inline var IN_DELETE_SELF = 1024;
	public static inline var IN_MODIFY = 2;
	public static inline var IN_MOVE_SELF = 2048;
	public static inline var IN_MOVED_FROM = 64;
	public static inline var IN_MOVED_TO = 128;
	public static inline var IN_OPEN = 32;

	var fd : Int;

	public function new( nonBlock : Bool = false, closeOnExec : Bool = false ) {
		fd = _init( ( nonBlock ? IN_NONBLOCK : 0 ) |  ( closeOnExec ? IN_CLOEXEC : 0 ) );
	}

	public function addWatch( path : String, mask : Iterable<InotifyMask> ) : Int {
		var v = 0;
		for( m in mask )
			v |= getMaskFlag( m );
		#if neko
		return _add_watch( fd, untyped path.__s, v );
		#elseif cpp
		return _add_watch( fd, path, v );
		#end
	}

	public function removeWatch( wd : Int ) {
		_remove_watch( fd, wd );
	}

	public function getEvents( wd : Int ) : Array<InotifyEvent> {
		var events : Array<Dynamic> = _read( fd, wd );
		if( events != null ) {
			#if neko
			var len : Int = untyped __dollar__asize( events );
			#elseif cpp
			var len : Int = events.length;
			#end
			var i = 0;
			var a = new Array<InotifyEvent>();
			while( i < len ) {
				var r : Dynamic = events[i];
				a.push( { wd : r.wd, mask : getMask( r.mask ), cookie : r.cookie, len : r.len, name : r.name }  );
				i++;
			}
			return a;
		}
		return null;
	}

	public function close() {
		_close( fd );
	}

	/**
		Returns the inotify flag value of given enum constructor
	*/
	public static function getMaskFlag( mask : InotifyMask ) : Int {
		return switch( mask ) {
		case access : IN_ACCESS;
		case attrib : IN_ATTRIB;
		case closeWrite : IN_CLOSE_WRITE;
		case closeNoWrite : IN_CLOSE_NOWRITE;
		case create : IN_CREATE;
		case delete : IN_DELETE;
		case deleteSelf : IN_DELETE_SELF;
		case modify : IN_MODIFY;
		case moveSelf : IN_MOVE_SELF;
		case movedFrom : IN_MOVED_FROM;
		case movedTo : IN_MOVED_TO;
		case open : IN_OPEN;
		}
	}

	/**
		Get mask enum constructor from inotify flag
	*/
	public static function getMask( flag : Int ) : InotifyMask {
		return switch( flag ) {
		case IN_ACCESS : access;
		case IN_ATTRIB : attrib;
		case IN_CLOSE_WRITE : closeWrite;
		case IN_CLOSE_NOWRITE : closeNoWrite;
		case IN_CREATE : create;
		case IN_DELETE : delete;
		case IN_DELETE_SELF : deleteSelf;
		case IN_MODIFY : modify;
		case IN_MOVE_SELF : moveSelf;
		case IN_MOVED_FROM : movedFrom;
		case IN_MOVED_TO : movedTo;
		case IN_OPEN : open;
		default: null;
		}
	}

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
