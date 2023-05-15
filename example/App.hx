
import sys.FileSystem;
import sys.io.Inotify;

function main() {

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

    var inotify = new Inotify();
    //var mask = ALL;
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
        Sys.println( DateTools.format( Date.now(), '%H:%M:%S' ) );
        for( e in events ) {
            var actions = new Array<String>();
            if( e.mask & CREATE > 0 ) actions.push( 'CREATE' );
            if( e.mask & DELETE > 0 ) actions.push( 'DELETE' );
            if( e.mask & OPEN > 0 ) actions.push( 'OPEN' );
            if( e.mask & ACCESS > 0 ) actions.push( 'ACCESS' );
            if( e.mask & MODIFY > 0 ) actions.push( 'MODIFY' );
            if( e.mask & ATTRIB > 0 ) actions.push( 'ATTRIB' );
            if( e.mask & CLOSE_WRITE > 0 ) actions.push( 'CLOSE_WRITE' );
            else if( e.mask & CLOSE_NOWRITE > 0 ) actions.push( 'CLOSE_NOWRITE' );
            else if( e.mask & CLOSE > 0 ) actions.push( 'CLOSE' );
            if( e.mask & MOVE > 0 ) actions.push( 'MOVE' );
            else if( e.mask & MOVED_FROM > 0 ) actions.push( 'MOVED_FROM' );
            else if( e.mask & MOVED_TO > 0 ) actions.push( 'MOVED_TO' );
            Sys.print('  '+((e.mask & ISDIR > 0) ? 'directory' : 'file'));
            if( e.name != null ) Sys.print( ' "${e.name}"' );
            Sys.print( ' ['+actions.join(',')+']' );
            Sys.print( '\n' );
        }
    }
    inotify.removeWatch( wd );
    inotify.close();
}

