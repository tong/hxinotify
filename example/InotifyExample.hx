
import Sys.println;
import sys.FileSystem;
import sys.io.Inotify;

/*
	Example of using hxinotify to monitor given path (or cwd) for filesystem events.
*/
class InotifyExample {

	static function main() {

		if( Sys.systemName() != 'Linux' ) {
			println( 'Inotify is only available on linux' );			
			Sys.exit(1);
		}

		var paths = new Array<String>();
		var args = Sys.args();
		if( args.length > 0 ) {
			for( path in args ) {
				if( !FileSystem.exists( path ) )
					throw 'path not found ($path)';
				paths.push( path );
			}
		} else
			paths.push( Sys.getCwd() );

		var inotify = new Inotify();
		var wds = new Array<Int>();
		for( path in paths ) {
			//var wd = inotify.addWatch( path, Inotify.ALL_EVENTS );
			var wd = inotify.addWatch( path,
				Inotify.ACCESS |
				Inotify.MODIFY |
				Inotify.ATTRIB |
				Inotify.CLOSE_WRITE |
				Inotify.CLOSE_NOWRITE |
				Inotify.OPEN |
				Inotify.MOVED_FROM |
				Inotify.MOVED_TO |
				Inotify.CREATE |
				Inotify.DELETE |
				Inotify.DELETE_SELF |
				Inotify.MOVE_SELF |
				Inotify.CLOSE |
				Inotify.MOVE |
				Inotify.UNMOUNT
			);
			wds.push( wd );
		}

		println( 'Watching: '+paths );

		while( true ) {
			var events = inotify.getEvents();
			for( e in events ) {
				var action =
					if( e.mask & Inotify.ACCESS > 0 ) 'accessed';
					else if( e.mask & Inotify.DELETE > 0 ) 'deleted';
					else if( e.mask & Inotify.MODIFY > 0 ) 'modified';
					else if( e.mask & Inotify.CLOSE > 0 ) 'closed';
					else if( e.mask & Inotify.CLOSE_WRITE > 0 ) 'closed and saved';
					else if( e.mask & Inotify.CLOSE_NOWRITE > 0 ) 'closed unsaved';
					else if( e.mask & Inotify.OPEN > 0 ) 'opened';
					else if( e.mask & Inotify.MOVE > 0 ) 'moved';
					else if( e.mask & Inotify.MOVED_FROM > 0 ) 'moved from';
					else if( e.mask & Inotify.MOVED_TO > 0 ) 'moved to';
					else if( e.mask & Inotify.CREATE > 0 ) 'created';
					else if( e.mask & Inotify.ATTRIB > 0 ) null;
					else null;
				if( action != null ) {
					var type = (e.mask & Inotify.ISDIR > 0) ? 'directory' : 'file';
					var name = (e.name != null) ? '"${e.name}"' : '';					
					var now = DateTools.format( Date.now(), '%H:%M:%S' );
					println( now+' $type $name $action' );
				}
			}
		}
		for( wd in wds )
			inotify.removeWatch( wd );
		inotify.close();
	}

}
