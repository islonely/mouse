## Cross-Platform mouse and keyboard manipulation.
Cross-platform tool to manipulate the mouse and keyboard to automate tasks.
```v
import auto
import time

fn main() {
    // get current mouse position
    x, y := auto.Mouse.get_pos()
    println('Mouse is at: X: ${x}, Y: ${y}')

    // get the dimensions of the primary display
    sz := auto.Screen.size()

    // center the mouse in the middle of the screen
    auto.Mouse.set_pos(sz.width / 2, sz.height / 2)

    // left and right click the mouse
    auto.Mouse.click(.left)
    auto.Mouse.click(.right)

    // double left click
    auto.Mouse.double_click()

    // click and drag mouse to 100, 150
    auto.Mouse.drag_to(100, 150, button: .left, duration: time.second)

    // emulate keyboard typing
    auto.Keyboard.press(.s)
    auto.Keyboard.write('some message to write', speed: 100 * time.millisecond)
}
```
