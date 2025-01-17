module auto

$if linux {
	#flag -lX11
	#flag -lXrandr
	#include <X11/X.h>
	#include <X11/Xlib.h>
	#include <X11/Xutil.h>
	#include <X11/extensions/Xrandr.h>
} $else $if windows {
	#flag -mwindows
	#include <windows.h>
} $else $if macos {
	#flag -framework ApplicationServices
	#include <ApplicationServices/ApplicationServices.h>
} $else {
	$compile_error('Unsupported OS')
}

// Size is the width and height of a screen.
pub struct Size {
__global:
	width  int
	height int
}

// Pos is the X and Y coordinates on a screen.
pub struct Pos {
__global:
	x int
	y int
}

// Linux X11
@[typedef]
struct C.XRRScreenResources {
	noutput int
	outputs &int
}

@[typedef]
struct C.XRROutputInfo {
	crtc u64
}

@[typedef]
struct C.XRRCrtcInfo {
	width  u32
	height u32
	x      int
	y      int
}

fn C.XOpenDisplay(int) voidptr
fn C.XCloseDisplay(voidptr) int
fn C.XQueryPointer(voidptr, voidptr, &u32, &u32, &int, &int, &u32, &u32, &u32)
fn C.XRootWindow(voidptr, int) voidptr
fn C.XSelectInput(voidptr, voidptr, int)
fn C.XWarpPointer(voidptr, int, voidptr, int, int, int, int, int, int)
fn C.XFlush(voidptr)
fn C.DefaultScreen(voidptr) int
fn C.DefaultRootWindow(voidptr) u64
fn C.XRRGetScreenResources(voidptr, u64) &C.XRRScreenResources
fn C.XRRGetOutputPrimary(voidptr, u64) u64
fn C.XRRFreeScreenResources(&C.XRRScreenResources)
fn C.XRRGetOutputInfo(voidptr, &C.XRRScreenResources, u64) &C.XRROutputInfo
fn C.XRRFreeOutputInfo(&C.XRROutputInfo)
fn C.XRRGetCrtcInfo(voidptr, &C.XRRScreenResources, u64) &C.XRRCrtcInfo
fn C.XRRFreeCrtcInfo(&C.XRRCrtcInfo)

// MacOS declarations
@[typedef]
struct C.CGPoint {
__global:
	x f64
	y f64
}

@[typedef]
struct C.CGSize {
__global:
	width  f64
	height f64
}

@[typedef]
struct C.CGRect {
__global:
	origin C.CGPoint
	size   C.CGSize
}

fn C.CGDisplayBounds(u32) C.CGRect
fn C.CGMainDisplayID() u32
fn C.CGWarpMouseCursorPosition(C.CGPoint)
fn C.CGEventCreate(voidptr) voidptr
fn C.CGEventGetLocation(voidptr) C.CGPoint
fn C.CGEventCreateMouseEvent(voidptr, int, C.CGPoint, int) voidptr
fn C.CFRelease(voidptr)
fn C.CGEventPost(int, voidptr)
fn C.CGDisplayCopyDisplayMode(u32) voidptr
fn C.CGDisplayModeGetRefreshRate(voidptr) f64
fn C.CGEventCreateKeyboardEvent(voidptr, int, bool) voidptr

// Windows
@[typedef]
struct C.POINT {
	x int
	y int
}

@[typedef]
struct C.DEVMODE {
	dmDisplayFrequency u32
	dmSize             u16
}

fn C.GetCursorPos(&C.POINT) bool
fn C.GetSystemMetrics(int) int
fn C.mouse_event(u32, u32, u32, u32, u64)
fn C.EnumDisplaySettings(&u16, u32, &C.DEVMODE) bool
fn C.keybd_event(u8, u8, u32, u64)
