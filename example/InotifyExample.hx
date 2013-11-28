
import sys.FileSystem;
import sys.io.Inotify;

/*
	A simple example of using hxinotify to monitor given path (or cwd) for filesystem events.
*/
class InotifyExample {

	static function main() {

		if( Sys.systemName() != 'Linux' ) {
			Sys.println( 'Inotify is only available on linux' );			
			Sys.exit(1);
		}

		var path = Sys.args()[0];
		if( path == null  )
			path = Sys.getCwd();
		path = FileSystem.fullPath( path );
		if( !FileSystem.exists( path ) ) {
			Sys.println( 'Path not found : $path' );
			Sys.exit(1);
		}

		Sys.println( 'Watching : $path' );

		var inotify = new Inotify();
		var wd = inotify.addWatch( path, Inotify.ALL_EVENTS );
		while( true ) {
			var events = inotify.getEvents( wd );
			if( events == null ) continue;
			for( e in events ) {
				if( e == null ) { // WTF!
					continue;
				}
				//trace(e);
				var action =
					if( e.mask & Inotify.ACCESS > 0 ) 'accessed';
					else if( e.mask & Inotify.MODIFY > 0 ) 'modified';
					else if( e.mask & Inotify.CLOSE > 0 ) 'closed';
					else if( e.mask & Inotify.CLOSE_WRITE > 0 ) 'closed and saved';
					else if( e.mask & Inotify.CLOSE_NOWRITE > 0 ) 'closed unsaved';
					else if( e.mask & Inotify.OPEN > 0 ) 'opened';
					else if( e.mask & Inotify.MOVE > 0 ) 'moved';
					else if( e.mask & Inotify.MOVED_FROM > 0 ) 'moved from';
					else if( e.mask & Inotify.MOVED_TO > 0 ) 'moved to';
					else if( e.mask & Inotify.CREATE > 0 ) 'created';
					else if( e.mask & Inotify.DELETE > 0 ) 'deleted';
					//else if( e.mask & Inotify.DELETE_SELF > 0 ) 
					//else if( e.mask & Inotify.MOVE_SELF > 0 ) 
					else if( e.mask & Inotify.ATTRIB > 0 ) null;
					else null;
				if( action != null ) {
					var type = ( e.mask & Inotify.ISDIR > 0 ) ? 'directory' : 'file';
					var name = (e.name!=null) ? ' "${e.name}"' : '';					
					var now = DateTools.format( Date.now(), '%H:%M:%S' );
					Sys.println( now+' : $type$name was $action' );
				}
			}
		}
		inotify.removeWatch( wd );
		inotify.close();
	}

}
