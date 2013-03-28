package sys;

@:require(sys)
enum InotifyMask {
	access;
	attrib;
	closeWrite;
	closeNoWrite;
	create;
	delete;
	deleteSelf;
	modify;
	moveSelf;
	movedFrom;
	movedTo;
	open;
}
