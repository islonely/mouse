module mouse

#flag -I @VMODROOT/src/c
#flag linux -lX11
#flag macos -framework ApplicationServices
#flag linux @VMODROOT/src/c/mouse_linux.o
#flag windows @VMODROOT/src/c/mouse_windows.o
#flag macos @VMODROOT/src/c/mouse_macos.o

$if linux {
	#include "mouse_linux.h"
} $else $if windows {
	#include "mouse_windows.h"
} $else $if macos {
	#include "mouse_macos.h"
}

// See .c files for comments.
struct C.Position {
__global:
	x int 
	y int
}

pub type Position = C.Position

struct C.Size {
__global:
	width  int
	height int
}

pub type Size = C.Size

fn C.get_mouse_pos() C.Position
fn C.set_mouse_pos(int, int)
fn C.screen_size() C.Size

// get_pos returns the global X and Y coordinates of the mouse cursor.
// Returns -1, -1 if there is an error getting the mosue position.
@[inline]
pub fn get_pos() (int, int) {
	pos := C.get_mouse_pos()
	return pos.x, pos.y
}

// get_pos_opt returns the global X and Y coordinates of the mouse cursor.
@[inline]
pub fn get_pos_opt() ?(int, int) {
	x, y := get_pos()
	if -1 in [x, y] {
		return none
	}
	return x, y
}

// set_pos moves the mouse cursor to the given location.
@[inline]
pub fn set_pos(x int, y int) {
	C.set_mouse_pos(x, y)
}

// screen_size returns the size of the primary display.
@[inline]
pub fn screen_size() Size {
	return C.screen_size()
}
