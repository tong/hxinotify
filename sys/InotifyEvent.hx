package sys;

@:require(sys)
typedef InotifyEvent = {
	var wd : Int;
	var mask : InotifyMask;
	var cookie : Int;
	var len : Int;
	var name : String;
}
