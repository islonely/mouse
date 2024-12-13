## Cross-Platform Get/Set Mouse Position in V
This has been tested on Windows, Linux, and MacOS. If there is some other OS you would like support for, feel free to contribute
```v
import mouse

fn main() {
    x, y := mouse.get_pos()
    println('Mouse is at: X: ${x}, Y: ${y}')

    // center the mouse in the middle of the screen
    sz := mouse.screen_size()
    mouse.set_pos(sz.width / 2, sz.height / 2)
}
```