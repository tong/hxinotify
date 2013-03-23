package sys;

typedef InotifyEvent = {
	var wd : Int;
	var mask : InotifyMask;
	//var mask : Int;
	var cookie : Int;
	var len : Int;
	var name : String;
}
