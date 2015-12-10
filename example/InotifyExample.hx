
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
				ACCESS |
				MODIFY |
				ATTRIB |
				CLOSE_WRITE |
				CLOSE_NOWRITE |
				OPEN |
				MOVED_FROM |
				MOVED_TO |
				CREATE |
				DELETE |
				DELETE_SELF |
				MOVE_SELF |
				CLOSE |
				MOVE |
				UNMOUNT
			);
			wds.push( wd );
		}

		println( 'Watching: '+paths );

		while( true ) {
			var events = inotify.getEvents();
			for( e in events ) {
				var action =
					if( e.mask & ACCESS > 0 ) 'accessed';
					else if( e.mask & DELETE > 0 ) 'deleted';
					else if( e.mask & MODIFY > 0 ) 'modified';
					else if( e.mask & CLOSE > 0 ) 'closed';
					else if( e.mask & CLOSE_WRITE > 0 ) 'closed and saved';
					else if( e.mask & CLOSE_NOWRITE > 0 ) 'closed unsaved';
					else if( e.mask & OPEN > 0 ) 'opened';
					else if( e.mask & MOVE > 0 ) 'moved';
					else if( e.mask & MOVED_FROM > 0 ) 'moved from';
					else if( e.mask & MOVED_TO > 0 ) 'moved to';
					else if( e.mask & CREATE > 0 ) 'created';
					else if( e.mask & ATTRIB > 0 ) null;
					else null;
				if( action != null ) {
					var type = (e.mask & ISDIR > 0) ? 'directory' : 'file';
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
