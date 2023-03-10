## Cross-Platform Get/Set Mouse Position in V
Get and set the mouse position like so:
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

### TODO
Contributions for MacOS support would be most appreciated. I don't have access to a MacOS device, so I'm unable to
do this myself. I believe these links will help whoever decides to contribute:
- [set mouse position MacOS](https://developer.apple.com/documentation/coregraphics/1456387-cgwarpmousecursorposition)
- [get mouse position MacOS](https://gist.github.com/mhamilt/7209c809c03e42a7027e9fe5b18fdfa2)
- [get display size MacOS](https://developer.apple.com/documentation/coregraphics/1456599-cgdisplayscreensize)