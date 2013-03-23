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

	//public dynamic function onEvent( e : InotifyEvent ) {}

	var fd : Int;

	public function new( flags : Int = 0 ) {
		fd = _init( flags );
		if( fd == -1 )
			throw 'init';
	}

	public inline function addWatch( path : String, mask : Int ) : Int {
		var wd = _add_watch( fd, path, mask );
		if( wd == -1 )
			throw "add watch";
		return wd;
	}

	public inline function removeWatch( wd : Int ) {
		_remove_watch( fd, wd );
	}

	public function listen( wd : Int ) : Array<InotifyEvent> {
		var events : Array<Dynamic> = _listen( fd, wd );
		var a = new Array<InotifyEvent>();
		for( r in events ) {
			var e : InotifyEvent = r;
			switch( r.mask ) {
			case IN_ACCESS : e.mask = access;
			case IN_ATTRIB : e.mask = attrib;
			case IN_CLOSE_WRITE : e.mask = closeWrite;
			case IN_CLOSE_NOWRITE : e.mask = closeNoWrite;
			case IN_CREATE : e.mask = create;
			case IN_DELETE : e.mask = delete;
			case IN_DELETE_SELF : e.mask = deleteSelf;
			case IN_MODIFY : e.mask = modify;
			case IN_MOVE_SELF : e.mask = moveSelf;
			case IN_MOVED_FROM : e.mask = movedFrom;
			case IN_MOVED_TO : e.mask = movedTo;
			case IN_OPEN : e.mask = open;
			default:
			}
			a.push(e);
		}
		return a;
	}

	public inline function close() {
		_close( fd );
	}

	static var _init = ext( 'init', 1 );
	static var _add_watch = ext( 'add_watch',3 );
	static var _listen = ext( 'listen', 2 );
	static var _remove_watch = ext( 'remove_watch', 2 );
	static var _close = ext( 'close', 1 );

	static inline function ext( f : String, n : Int = 0 ) : Dynamic {
		return cpp.Lib.load( 'inotify', 'hxinotify_'+f, n );
	}
}
