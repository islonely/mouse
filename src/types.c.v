module mouse

$if linux {
	#flag -lXrandr
	#include <X11/extensions/Xrandr.h>
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
}

fn C.XOpenDisplay(int) voidptr
fn C.XCloseDisplay(voidptr) int
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
