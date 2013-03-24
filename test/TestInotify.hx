
import cpp.vm.Thread;
import sys.FileSystem;
import sys.Inotify;
import sys.InotifyMask;
import sys.io.File;

class TestInotify {

	static function run_inotify() {
		
		var main = Thread.readMessage( true );
		var path : String = Thread.readMessage( true );
		var mask : Array<InotifyMask> = Thread.readMessage( true );
		
		var inotify = new Inotify();
		var wd = inotify.addWatch( path, mask );
		while( true ) {
			var m = Thread.readMessage( false );
			if( m == "close" ) {
				inotify.removeWatch( wd );
				inotify.close();
				main.sendMessage( true );
			}
			var events = inotify.getEvents( wd );
			for( e in events ) {
				Sys.println( e );
			}
		}
	}

	static function createInotify( path : String, mask : Array<InotifyMask> ) : Thread {
		var t = Thread.create( run_inotify );
		t.sendMessage( Thread.current() );
		t.sendMessage( path );
		t.sendMessage( mask );
		return t;
	}

	static function main() {

		var path = Sys.args()[0];
		if( path == null  )
			path = Sys.getCwd();
		else if( !FileSystem.exists( path ) )
			throw 'path not found : $path';

		var inotify = createInotify( path, [modify,create,delete,open] );

		//Sys.sleep( 0.1 );
		//File.saveContent( "temp", "delete me!" );

		//Sys.sleep( 0.1 );
		//FileSystem.deleteFile( "temp" );

		inotify.sendMessage( "close" );
		//Thread.readMessage(true);
	}
}
