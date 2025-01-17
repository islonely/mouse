module auto

import os

// The compositor used by the user.
const compositor = Screen.compositor()

// Compositor is the window compositor being used by the system.
pub enum Compositor {
	unknown
	wayland
	x11
	quartz
	windows
}

// Screen acts as a namespace for screen related functions.
@[noinit]
pub struct Screen {}

// Screen.get_compositor gets whether or not a user has X11 or Wayland as
// their window compositor.
pub fn Screen.compositor() Compositor {
	$if macos {
		return .quartz
	}
	$if windows {
		return .windows
	}
	xdg_session_type := os.getenv_opt('XDG_SESSION_TYPE') or {
		// assume X11
		return .x11
	}
	return if xdg_session_type == 'wayland' {
		.wayland
	} else {
		// assume X11
		.x11
	}
}

// Screen.size returns the size of the primary display.
pub fn Screen.size() Size {
	$if macos {
		primary_screen := C.CGDisplayBounds(C.CGMainDisplayID())
		return Size{
			width:  int(primary_screen.size.width)
			height: int(primary_screen.size.height)
		}
	} $else $if linux {
		display := C.XOpenDisplay(unsafe { nil })
		if display == unsafe { nil } {
			return Size{}
		}
		defer { C.XCloseDisplay(display) }
		root := C.DefaultRootWindow(display)
		resources := C.XRRGetScreenResources(display, root)
		if resources == unsafe { nil } {
			return Size{}
		}
		defer { C.XRRFreeScreenResources(resources) }
		primary_output := C.XRRGetOutputPrimary(display, root)
		if primary_output == 0 {
			return Size{}
		}
		for i := 0; i < resources.noutput; i++ {
			if unsafe { u64(resources.outputs[i]) } == primary_output {
				output_info := C.XRRGetOutputInfo(display, resources, unsafe { resources.outputs[i] })
				if output_info == unsafe { nil } {
					return Size{}
				}
				defer { C.XRRFreeOutputInfo(output_info) }
				crtc_info := C.XRRGetCrtcInfo(display, resources, output_info.crtc)
				if crtc_info == unsafe { nil } {
					return Size{}
				}
				defer { C.XRRFreeCrtcInfo(crtc_info) }
				return Size{
					width:  unsafe { int(crtc_info.width) }
					height: unsafe { int(crtc_info.height) }
				}
			}
		}
	} $else $if windows {
		return Size{
			width:  C.GetSystemMetrics(C.SM_CXSCREEN)
			height: C.GetSystemMetrics(C.SM_CYSCREEN)
		}
	}
	return Size{}
}

// Screen.refresh_rate returns the screen refresh rate of the primary display.
pub fn Screen.refresh_rate() ?int {
	$if macos {
		primary_display := C.CGMainDisplayID()
		display_mode := C.CGDisplayCopyDisplayMode(primary_display)
		if display_mode == unsafe { nil } {
			return none
		}
		return int(C.CGDisplayModeGetRefreshRate(display_mode))
	} $else $if windows {
		devmode := C.DEVMODE{}
		if C.EnumDisplaySettings(unsafe { nil }, C.ENUM_CURRENT_SETTINGS, &devmode) {
			return int(devmode.dmDisplayFrequency)
		}
	}
	return none
}
