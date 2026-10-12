
import sys.FileSystem;
import sys.io.Inotify;
import sys.thread.Thread;

class App {

	static function monitorFiles() {
		var main : Thread = Thread.readMessage( true );
		var path : String = Thread.readMessage( true );
		var mask : Int = Thread.readMessage( true );
		var inotify = new Inotify();
		var wd = inotify.addWatch( path, mask );
		while( true ) {
			var events = inotify.read();
			trace( events );
			main.sendMessage(events);
		}
		inotify.removeWatch( wd );
		inotify.close();
		//main.sendMessage("thread done");
	}

	static function main() {

		if( Sys.systemName() != 'Linux' ) {
			Sys.println( 'Inotify is only available on linux' );
			Sys.exit(1);
		}

		var path = Sys.args()[0];
		if( path == null ) {
			path = Sys.getCwd();
			Sys.println( 'No path specified, using cwd [$path]' );
		}
		path = FileSystem.fullPath( path );
		if( !FileSystem.exists( path ) ) {
			Sys.println( 'Watch path not found [$path]' );
			Sys.exit(1);
		}

		var mask : Int = ALL;

		var thread = Thread.create( monitorFiles );
		thread.sendMessage( Thread.current() );
		thread.sendMessage( path );
		thread.sendMessage( mask );

		while( true ) {
			var events : Array<InotifyEvent> = Thread.readMessage( true );
			trace(events);
		}
		trace("done");
	}

}
