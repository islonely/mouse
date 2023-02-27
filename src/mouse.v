module mouse

#flag -I @VMODROOT/src/c
#flag linux -lX11
#flag linux @VMODROOT/src/c/mouse_linux.o
#flag windows @VMODROOT/src/c/mouse_windows.o
#flag macos @VMODROOT/src/c/mouse_macos.o

$if linux {
	#include "mouse_linux.h"
} $else $if windows {
	#include "mouse_windows.h"
} $else $if macos {

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
	width int
	height int
}
pub type Size = C.Size

fn C.get_mouse_pos() C.Position
fn C.set_mouse_pos(int, int)
fn C.screen_size() C.Size

[inline]
pub fn get_pos() (int, int) {
	pos := C.get_mouse_pos()
	return pos.x, pos.y
}

[inline]
pub fn get_pos_opt() ?(int, int) {
	x, y := get_pos()
	if -1 in [x, y] {
		return none
	}
	return x, y
}

[inline]
pub fn set_pos(x int, y int) {
	C.set_mouse_pos(x, y)
}

[inline]
pub fn screen_size() Size {
	return C.screen_size()
}