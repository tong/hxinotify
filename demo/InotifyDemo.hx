
#if cpp
import cpp.vm.Thread;
#elseif neko
import neko.vm.Thread;
#end
import sys.FileSystem;
import sys.Inotify;
import sys.InotifyMask;
import sys.io.File;

class InotifyDemo {

	/*
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
	*/

	static function main() {

		var path = Sys.args()[0];
		if( path == null  )
			path = Sys.getCwd();
			//path = Sys.getEnv( "HOME" ); // watch user home
		else if( !FileSystem.exists( path ) )
			throw 'path not found : $path';
		
		Sys.println( 'inotify : '+path );

		var inotify = new sys.Inotify();
		var wd = inotify.addWatch( path, [create,delete,modify,open] );
		while( true ) {
			var events = inotify.getEvents( wd );
			if( events != null ) {
				for( e in events )
					Sys.println( e );
			}
		}
		inotify.removeWatch( wd );
		inotify.close();
		
		/*
		var inotify = new Inotify();
		var wd = inotify.addWatch( path, [access,attrib,closeWrite,closeNoWrite,create,delete,deleteSelf,modify,moveSelf,movedFrom,movedTo,open] );
		while( true ) {
			var events = inotify.getEvents( wd );
			if( events != null ) {
				for( e in events ) {
					Sys.println( e );
				}
			}
		}
		inotify.removeWatch( wd );
		inotify.close();
		*/

		//var inotify = createInotify( path, [modify,create,delete,open] );
		//File.saveContent( "temp", "delete me!" );
		//Sys.sleep( 0.1 );
		//FileSystem.deleteFile( "temp" );
		//inotify.sendMessage( "close" );
		//Thread.readMessage(true);

		/*
		while( true ) {
			var m = Thread.readMessage( false );
			if( m == "close" ) {
				inotify.removeWatch( wd );
				inotify.close();
				//main.sendMessage( true );
			}
			var events = inotify.getEvents( wd );
			for( e in events ) {
				Sys.println( e );
			}
		}
		*/
	}
}
