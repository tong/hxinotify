
import sys.FileSystem;
import sys.io.Inotify;

class InotifyExample {

	static function main() {

		var path = Sys.args()[0];
		if( path == null  )
			path = Sys.getCwd();
		if( !FileSystem.exists( path ) )
			throw 'Path not found : $path';
		
		Sys.println( 'Inotify : '+path );

		var inotify = new Inotify();
		var wd = inotify.addWatch( path, Inotify.ALL_EVENTS );
		while( true ) {
			var events = inotify.getEvents( wd );
			for( e in events ) {
				trace(e);
				if( e.mask & Inotify.CREATE > 0 ) {
					if( e.mask & Inotify.ISDIR > 0 )
						Sys.println( 'The directory ${e.name} was created' );
					else
						Sys.println( 'The file ${e.name} was created' );
				} else if( e.mask & Inotify.DELETE > 0 ) {
					if( e.mask & Inotify.ISDIR > 0 )
						Sys.println( 'The directory ${e.name} was deleted' );
					else
						Sys.println( 'The file ${e.name} was deleted.' );
				} else if( e.mask & Inotify.MODIFY > 0 ) {
					if( e.mask & Inotify.MODIFY > 0 )
						Sys.println( 'The directory ${e.name} was modified' );
					else
						Sys.println( 'The file ${e.name} was modified' );
				}
			}
		}
		inotify.removeWatch( wd );
		inotify.close();
	}

}
