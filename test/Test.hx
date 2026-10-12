import sys.FileSystem;
import sys.io.File;
import sys.io.Inotify;

function assert( cond : Bool, msg : String, ?pos : haxe.PosInfos ) {
	if( !cond ) {
		Sys.println( 'FAIL ${pos.lineNumber}: $msg' );
		Sys.exit( 1 );
	}
}

function main() {
	var dir = '/tmp/hxinotify-test-' + Std.random( 0xFFFFFF );
	FileSystem.createDirectory( dir );

	// Blocking read reports created file with correct name
	var inotify = new Inotify();
	assert( inotify.fd >= 0, 'init fd=${inotify.fd}' );
	var wd = inotify.addWatch( dir, CREATE );
	assert( wd >= 0, 'addWatch wd=$wd' );
	File.saveContent( '$dir/a.txt', '' );
	var events = inotify.read();
	assert( events.length == 1, 'events.length=${events.length}' );
	assert( events[0].wd == wd, 'wd' );
	assert( events[0].mask & CREATE != 0, 'mask=${events[0].mask}' );
	assert( events[0].name == 'a.txt', 'name=[${events[0].name}] length=${events[0].name.length}' );
	assert( inotify.removeWatch( wd ) == 0, 'removeWatch' );
	inotify.close();

	// Non-blocking read returns no events instead of blocking or throwing
	var inotify = new Inotify( true, true );
	assert( inotify.fd >= 0, 'nonblock init fd=${inotify.fd}' );
	inotify.addWatch( dir, CREATE );
	var events = inotify.read();
	assert( events.length == 0, 'nonblock events.length=${events.length}' );
	File.saveContent( '$dir/b.txt', '' );
	var events = inotify.read();
	assert( events.length == 1 && events[0].name == 'b.txt', 'nonblock event' );
	inotify.close();

	// DONT_FOLLOW watches the symlink itself, not its target
	var inotify = new Inotify();
	Sys.command( 'ln', ['-s', '$dir/a.txt', '$dir/link'] );
	var wdLink = inotify.addWatch( '$dir/link', DONT_FOLLOW | ATTRIB );
	var wdFile = inotify.addWatch( '$dir/a.txt', ATTRIB );
	assert( wdLink != wdFile, 'DONT_FOLLOW resolved symlink (wd=$wdLink)' );
	inotify.close();

	// Missing path fails with an error code instead of crashing
	var inotify = new Inotify();
	assert( inotify.addWatch( '$dir/missing', CREATE ) < 0, 'missing path' );
	inotify.close();

	// Blocking read in a thread must not stall garbage collection in other threads
	var inotify = new Inotify();
	inotify.addWatch( dir, CREATE );
	var main = sys.thread.Thread.current();
	sys.thread.Thread.create( () -> main.sendMessage( inotify.read()[0].name ) );
	Sys.sleep( 0.2 );
	#if cpp cpp.vm.Gc.run( true ); #elseif hl hl.Gc.major(); #elseif neko neko.vm.Gc.run( true ); #end
	File.saveContent( '$dir/c.txt', '' );
	assert( sys.thread.Thread.readMessage( true ) == 'c.txt', 'thread read' );
	inotify.close();

	Sys.command( 'rm', ['-rf', dir] );
	Sys.println( 'OK' );
}
