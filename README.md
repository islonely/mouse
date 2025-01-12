## Cross-Platform mouse and keyboard manipulation.
Cross-platform tool to manipulate the mouse and keyboard to automate tasks.
```v
import islonely.mouse

import time

fn main() {
    // get current mouse position
    x, y := mouse.get_pos()
    println('Mouse is at: X: ${x}, Y: ${y}')

    // get the dimensions of the primary display
    sz := mouse.screen_size()

    // center the mouse in the middle of the screen
    mouse.set_pos(sz.width / 2, sz.height / 2)

    // left and right click the mouse
    mouse.click(.left)
    mouse.click(.right)

    // double left click
    mouse.double_click()

    // click and drag mouse to 100, 150
    mouse.drag_to(100, 150, button: .left, duration: time.second)

    // emulate keyboard typing
    mouse.Keyboard.press(.s)
    mouse.Keyboard.write('some message to write', speed: 100 * time.millisecond)
}
```
