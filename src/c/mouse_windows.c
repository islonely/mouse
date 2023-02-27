// See .h for comments.
#include "mouse_windows.h"

struct Position get_mouse_pos() {
	POINT p;
	GetCursorPos(&p);
	struct Position pos = {p.x, p.y};
	return pos;
}

void set_mouse_pos(int x, int y) {
	int nX = x * 65535 / GetSystemMetrics(SM_CXSCREEN);
	int nY = y * 65535 / GetSystemMetrics(SM_CYSCREEN);
	mouse_event(MOUSEEVENTF_ABSOLUTE | MOUSEEVENTF_MOVE, nX, nY, 0, 0);
}

struct Size screen_size() {
	struct Size size = {
		GetSystemMetrics(SM_CXSCREEN),
		GetSystemMetrics(SM_CYSCREEN)
	};
	return size;
}