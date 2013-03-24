package sys;

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

	public inline function addWatch( path : String, mask : Array<InotifyMask> ) : Int {
		return _add_watch( fd, path, createMaskFlag( mask ) );
	}

	public inline function removeWatch( wd : Int ) {
		_remove_watch( fd, wd );
	}

	public function getEvents( wd : Int ) : Array<InotifyEvent> {
		// TODO well, this sucks
		var events : Array<Dynamic> = _read( fd, wd );
		var a = new Array<InotifyEvent>();
		for( r in events ) {
			var e : InotifyEvent = r;
			e.mask = haxe.EnumTools.createByIndex( InotifyMask, r.mask );
			a.push(e);
		}
		return a;
	}

	public inline function close() {
		_close( fd );
	}

	public static function createMaskFlag( mask : Array<InotifyMask> ) : Int {
		var v = 0;
		for( f in mask ) {
			v |= switch( f ) {
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
		return v;
	}

	/*
	public static function getMask( mask : Int ) : InotifyMask {
		return switch( mask ) {
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
	*/

	static var _init = ext( 'init', 1 );
	static var _add_watch = ext( 'add_watch',3 );
	static var _remove_watch = ext( 'remove_watch', 2 );
	static var _read = ext( 'read', 2 );
	static var _close = ext( 'close', 1 );

	static inline function ext( f : String, n : Int = 0 ) {
		return cpp.Lib.load( 'inotify', 'hxinotify_'+f, n );
	}
}
