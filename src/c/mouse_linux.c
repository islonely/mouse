// See .h for comments.
#include "mouse_linux.h"

struct Position get_mouse_pos() {
	struct Position pos = {-1, -1};
	Display *dpy = XOpenDisplay(0);
	Window root_window = XRootWindow(dpy, 0);
	Window root_id = 0, child_id = 0;
	int win_x = 0,
		win_y = 0,
		mask = 0;
	XQueryPointer(dpy, root_window, &root_id, &child_id, &pos.x, &pos.y, &win_x, &win_y, &mask);
	XCloseDisplay(dpy);
	return pos;
}

void set_mouse_pos(int x, int y) {
	Display *dpy = XOpenDisplay(0);
	Window root_window = XRootWindow(dpy, 0);
	XSelectInput(dpy, root_window, KeyReleaseMask);
	XWarpPointer(dpy, None, root_window, 0, 0, 0, 0, x, y);
	XFlush(dpy);
	XCloseDisplay(dpy);
}

struct Size screen_size() {
	Display *dpy = XOpenDisplay(0);
	int screen = DefaultScreen(dpy);
	struct Size sz = {
		DisplayWidth(dpy, screen),
		DisplayHeight(dpy, screen)
	};
	XCloseDisplay(dpy);
	return sz;
}
