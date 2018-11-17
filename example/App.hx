
import sys.FileSystem;
import sys.io.Inotify;

class App {

	static function main() {

		if( Sys.systemName() != 'Linux' ) {
			Sys.println( 'Inotify is only available on linux' );
			Sys.exit(1);
		}

		var path = Sys.args()[0];
		if( path == null ) {
			path = Sys.getCwd();
			Sys.println( 'No path specified, using cwd' );
		}
		path = FileSystem.fullPath( path );
		if( !FileSystem.exists( path ) ) {
			Sys.println( 'Watch path not found [$path]' );
			Sys.exit(1);
		}

		var inotify = new Inotify();
		var mask =
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
			UNMOUNT;
		var wd = inotify.addWatch( path, mask );
		while( true ) {
			var events = inotify.read();
			for( e in events ) {
				Sys.println( e );
			}
		}
		inotify.removeWatch( wd );
		inotify.close();
	}

}
