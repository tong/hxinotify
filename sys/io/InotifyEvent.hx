package sys.io;

typedef InotifyEvent = {
	var wd : Int;
	var mask : Int;
	var cookie : Int;
	var len : Int;
	var name : String;
}
