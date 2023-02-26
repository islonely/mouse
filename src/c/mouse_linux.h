#include <stdio.h>
#include <X11/X.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include "mouse.h"

// get_mouse_pos gets the mouse position and returns it.
struct Position get_mouse_pos();
// set_mouse_pos moves the position of the mouse to X, Y.
void set_mouse_pos(int x, int y);