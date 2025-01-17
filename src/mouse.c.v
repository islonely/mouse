module auto

import time

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

// Mouse acts as a namespace for mouse related functions.
@[noinit]
pub struct Mouse {}

// Mouse.get_pos returns the global X and Y coordinates of the mouse cursor.
// Returns -1, -1 if there is an error getting the mosue position.
pub fn Mouse.get_pos() (int, int) {
	$if macos {
		event := C.CGEventCreate(unsafe { nil })
		point := C.CGEventGetLocation(event)
		C.CFRelease(event)
		return int(point.x), int(point.y)
	} $else $if windows {
		mut point := &C.POINT{}
		if C.GetCursorPos(point) {
			return point.x, point.y
		}
		return -1, -1
	} $else {
		if compositor == .x11 {
			display := C.XOpenDisplay(0)
			defer { _ := C.XCloseDisplay(display) }
			window := C.XRootWindow(display, 0)
			root_id, child_id := u32(0), u32(0)
			win_x, win_y, mask := u32(0), u32(0), u32(0)
			mut pos_x, mut pos_y := 0, 0
			C.XQueryPointer(display, window, &root_id, &child_id, &pos_x, &pos_y, &win_x, &win_y, &mask)
			return pos_x, pos_y
		}
		println(compositor)
	}
	return -1, -1
}

// Mouse.get_pos_opt returns the global X and Y coordinates of the mouse cursor.
@[inline]
pub fn Mouse.get_pos_opt() ?(int, int) {
	x, y := Mouse.get_pos()
	if -1 in [x, y] {
		return none
	}
	return x, y
}

// Mouse.set_pos immediately moves the mouse cursor to the `x`, `y`.
pub fn Mouse.set_pos(x int, y int) {
	$if macos {
		C.CGWarpMouseCursorPosition(C.CGPoint{x, y})
		return
	} $else $if windows {
		target_x := x * 65535 / C.GetSystemMetrics(C.SM_CXSCREEN)
		target_y := y * 65535 / C.GetSystemMetrics(C.SM_CYSCREEN)
		C.mouse_event(C.MOUSEEVENTF_ABSOLUTE | C.MOUSEEVENTF_MOVE, target_x, target_y,
			0, 0)
	} $else {
		if compositor == .x11 {
			display := C.XOpenDisplay(0)
			defer { _ := C.XCloseDisplay(display) }
			window := C.XRootWindow(display, 0)
			C.XSelectInput(display, window, C.KeyReleaseMask)
			C.XWarpPointer(display, C.None, window, 0, 0, 0, 0, x, y)
			C.XFlush(display)
		}
	}
}

// Mouse.click triggers a mouse click event at the current mouse cursor position.
pub fn Mouse.click(button Button) {
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
	} $else $if windows {
		button_down, button_up := match button {
			.left { C.MOUSEEVENTF_LEFTDOWN, C.MOUSEEVENTF_LEFTUP }
			.right { C.MOUSEEVENTF_RIGHTDOWN, C.MOUSEEVENTF_RIGHTUP }
			.middle { C.MOUSEEVENTF_MIDDLEDOWN, C.MOUSEEVENTF_MIDDLEUP }
		}
		C.mouse_event(button_down, 0, 0, 0, 0)
		C.mouse_event(button_up, 0, 0, 0, 0)
	}
}

// Mouse.double_click triggers a double click event at the current mouse cursor position.
@[inline]
pub fn Mouse.double_click(button Button) {
	Mouse.click(button)
	Mouse.click(button)
}

// DragParams are the options for determining how the mouse is dragged
// across the screen.
@[params]
pub struct DragParams {
__global:
	duration time.Duration = time.millisecond * 750
	button   Button        = .left
}

// Mouse.drag_rel drags the mouse cursor relative to the current location of
// the mouse.
@[inline]
pub fn Mouse.drag_rel(rel_x int, rel_y int, params DragParams) {
	cur_x, cur_y := Mouse.get_pos()
	target_x := cur_x + rel_x
	target_y := cur_y + rel_y
	Mouse.drag_to(target_x, target_y, params)
}

// Mouse.drag_to moves the the mouse cursor while holding down a mouse button.
pub fn Mouse.drag_to(target_x int, target_y int, params DragParams) {
	start_x, start_y := Mouse.get_pos()
	mut refresh_rate := Screen.refresh_rate() or { 60 }
	mut duration := params.duration
	if params.duration == 0 {
		refresh_rate = 60
		duration = 1_000_000_000
	}
	duration_in_seconds := f64(duration) / 1000000000.0
	steps := refresh_rate * duration_in_seconds
	delta_x := (target_x - start_x) / steps
	delta_y := (target_y - start_y) / steps
	sleep_for := duration / steps

	$if macos {
		target_point := C.CGPoint{target_x, target_y}
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
	} $else $if windows {
		button_down, button_up := match params.button {
			.left { C.MOUSEEVENTF_LEFTDOWN, C.MOUSEEVENTF_LEFTUP }
			.right { C.MOUSEEVENTF_RIGHTDOWN, C.MOUSEEVENTF_RIGHTUP }
			.middle { C.MOUSEEVENTF_MIDDLEDOWN, C.MOUSEEVENTF_MIDDLEUP }
		}
		C.mouse_event(button_down, 0, 0, 0, 0)
		for i := 0; i < steps; i++ {
			current_x := start_x + delta_x * i
			current_y := start_y + delta_y * i
			Mouse.set_pos(int(current_x), int(current_y))
			time.sleep(sleep_for)
		}
		C.mouse_event(button_up, 0, 0, 0, 0)
	}
}
