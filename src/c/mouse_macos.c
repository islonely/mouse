#include "mouse_macos.h"

struct Position get_mouse_pos() {
    CGPoint point;
    CGEventRef event = CGEventCreate(NULL);
    point = CGEventGetLocation(event);
    CFRelease(event);
    struct Position pos = {point.x, point.y};
    return pos;
}

void set_mouse_pos(int x, int y) {
    CGWarpMouseCursorPosition(CGPointMake(x, y));
}

struct Size screen_size() {
    CGRect primary_screen = CGDisplayBounds(CGMainDisplayID());

    struct Size sz = {primary_screen.size.width, primary_screen.size.height};
    return sz;
}