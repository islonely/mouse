module main

#flag -I @VMODROOT/src/c
#flag linux -lX11
#flag linux @VMODROOT/src/c/mouse_linux.o
#flag windows @VMODROOT/src/c/mouse_windows.o

$if linux {
	#include "mouse_linux.h"
} $else $if windows {
	#include "mouse_windows.h"
} $else $if macos {

}

// See .c files for comments.
struct C.Position {
	x int
	y int
}

fn C.get_mouse_pos() C.Position
fn C.set_mouse_pos(int, int)

[inline]
pub fn get() (int, int) {
	pos := C.get_mouse_pos()
	return pos.x, pos.y
}

[inline]
pub fn get_opt() ?(int, int) {
	x, y := get()
	if -1 in [x, y] {
		return none
	}
	return x, y
}

[inline]
pub fn set(x int, y int) {
	C.set_mouse_pos(x, y)
}

fn main() {
	println(get())
}
