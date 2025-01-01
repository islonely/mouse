module mouse

import os { user_os }

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
	#include <ApplicationServices/ApplicationServices.h>
}

// the compositor used by the user.
const compositor = get_compositor()

// Compositor is the window compositor being used by the system.
enum Compositor {
	unknown
	wayland
	x11
	quartz
	windows
}

// get_compositor gets whether or not a user has X11 or Wayland as
// their window compositor.
fn get_compositor() Compositor {
	$if macos {
		return .quartz
	}
	$if windows {
		return .windows
	}
	_ := os.getenv_opt('WAYLAND_DISPLAY') or {
		_ := os.getenv_opt('DISPLAY') or {
			return .unknown
		}
		return .x11
	}
	return .wayland
}

// macos structs and fns
struct C.CGPoint {
__global:
	x f64
	y f64
}
fn C.CGEventCreateMouseEvent(voidptr, int, C.CGPoint, int) voidptr
fn C.CFRelease(voidptr)
fn C.CGEventPost(int, voidptr)

// Button is which mouse button to be pressed.
pub enum Button {
	left
	right
	middle
}

// EventType is an event used by C.CGEventCreateMouseEvent.
enum EventType {
	tap_disabled_by_timeout = -2
	tap_disabled_by_user_input = -1
	null
	left_mouse_down
	left_mouse_up
	right_mouse_down
	right_mouse_up
	mouse_moved
	left_mouse_dragged
	right_mouse_dragged
	key_down = 10
	key_up
	flags_changed
	scroll_wheel = 22
	tablet_pointer
	tablet_proximity
	other_mouse_down
	other_mouse_up
	other_mouse_dragged
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

pub struct Rectangle {
	Size
	Position
}

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

// click simulates a left mouse click.
pub fn click() {
	$if macos {
		mouse_x, mouse_y := get_pos()
		point := C.CGPoint{mouse_x, mouse_y}
		mut mouse_down_evt := C.CGEventCreateMouseEvent(0, int(EventType.left_mouse_down), point, int(Button.left))
		mut mouse_up_evt := C.CGEventCreateMouseEvent(0, int(EventType.left_mouse_up), point, int(Button.left))
		C.CGEventPost(0, mouse_down_evt)
		C.CGEventPost(0, mouse_up_evt)
		C.CFRelease(mouse_down_evt)
		C.CFRelease(mouse_up_evt)
		return
	}
	$if debug {
		println('fn ${@MOD}.${@FN} is not supported on ${user_os()}.')
	}
}

// double_click simulates a mouse left clicking twice in a row.
@[inline]
pub fn double_click() {
	click()
	click()
}