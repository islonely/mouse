module mouse

import os { user_os }
import time

#flag -I @VMODROOT/src/c
#include "mouse.h"
#flag linux -lX11
#flag linux @VMODROOT/src/c/mouse_linux.o
#flag windows @VMODROOT/src/c/mouse_windows.o

$if linux {
	#include "mouse_linux.h"
} $else $if windows {
	#include "mouse_windows.h"
} $else $if macos {
	#flag -framework ApplicationServices
	#include <ApplicationServices/ApplicationServices.h>
}

// Button is the buttons on a mouse or touchpad.
pub enum Button {
	left
	right
	middle
}

// EventType is an event used by C.CGEventCreateMouseEvent.
enum EventType {
	tap_disabled_by_timeout    = -2
	tap_disabled_by_user_input = -1
	null
	left_mouse_down
	left_mouse_up
	right_mouse_down
	right_mouse_up
	mouse_moved
	left_mouse_dragged
	right_mouse_dragged
	key_down                   = 10
	key_up
	flags_changed
	scroll_wheel               = 22
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
pub fn get_pos() (int, int) {
	$if macos {
		event := C.CGEventCreate(unsafe { nil })
		point := C.CGEventGetLocation(event)
		C.CFRelease(event)
		return int(point.x), int(point.y)
	} $else {
		pos := C.get_mouse_pos()
		return pos.x, pos.y
	}
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

// `fn set_pos` immediately moves the mouse cursor to the `x`, `y`.
pub fn set_pos(x int, y int) {
	$if macos {
		C.CGWarpMouseCursorPosition(C.CGPoint{x, y})
		return
	} $else {
		C.set_mouse_pos(x, y)
	}
}

// `fn click` a mouse click with the set `Button`.
pub fn click(button Button) {
	$if macos {
		mouse_x, mouse_y := get_pos()
		point := C.CGPoint{mouse_x, mouse_y}
		mut mouse_down_evt := C.CGEventCreateMouseEvent(0, int(EventType.left_mouse_down),
			point, int(button))
		mut mouse_up_evt := C.CGEventCreateMouseEvent(0, int(EventType.left_mouse_up),
			point, int(button))
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

// `fn double_click` simulates a mouse left clicking twice in rapid succession.
@[inline]
pub fn double_click(button Button) {
	click(.left)
	click(.left)
}

@[params]
pub struct DragParams {
__global:
	duration time.Duration = time.millisecond * 1000
	button   Button        = .left
}

// drag_to moves the the mouse cursor while holding down a mouse button.
pub fn drag_to(target_x int, target_y int, params DragParams) {
	target_point := C.CGPoint{target_x, target_y}
	start_x, start_y := get_pos()
	start_point := C.CGPoint{start_x, start_y}
	button := match params.button {
		.left { C.kCGMouseButtonLeft }
		.right { C.kCGMouseButtonRight }
		.middle { C.kCGMouseButtonCenter }
	}
	mouse_down_event := C.CGEventCreateMouseEvent(unsafe { nil }, C.kCGEventLeftMouseDown,
		start_point, button)
	C.CGEventPost(C.kCGHIDEventTap, mouse_down_event)
	C.CFRelease(mouse_down_event)
	mut refresh_rate := get_refresh_rate()
	mut duration := params.duration
	if params.duration == 0 {
		refresh_rate = 60
		duration = 1
	}
	duration_in_seconds := f64(duration) / 1000000000.0
	steps := refresh_rate * duration_in_seconds
	delta_x := (target_x - start_x) / steps
	delta_y := (target_y - start_y) / steps
	sleep_for := duration / steps
	for i := 0; i < steps; i++ {
		current_point := C.CGPoint{
			x: start_x + delta_x * i
			y: start_y + delta_y * i
		}
		mouse_drag_event := C.CGEventCreateMouseEvent(unsafe { nil }, C.kCGEventLeftMouseDragged,
			current_point, button)
		C.CGEventPost(C.kCGHIDEventTap, mouse_drag_event)
		C.CFRelease(mouse_drag_event)
		time.sleep(sleep_for)
	}
	mouse_up_event := C.CGEventCreateMouseEvent(unsafe { nil }, C.kCGEventLeftMouseUp,
		target_point, button)
	C.CGEventPost(C.kCGHIDEventTap, mouse_up_event)
	C.CFRelease(mouse_up_event)
}
