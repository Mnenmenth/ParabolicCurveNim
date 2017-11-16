import libgraph
import ParabolicCurvePkg/line
import ParabolicCurvePkg/frame_manager
import sdl2.sdl
from math import round

const
    Title = "Parabolic Curve"
    Width = 1280
    Height = 720
    WindowFlags = 0
    RenderFlags = 0
    FPS: int = 60

type
    App = ref object of RootObj
        window*: Window
        renderer*: Renderer

let 
    app = App(window: nil, renderer: nil)
    g: Graph = newGraph(newDimension(Width, Height), 100, 100, 100, 100)
    fpsMgr = newFpsManager(FPS)

var
    done = false
    pressed: seq[sdl.KeyCode] = @[]
    lines: seq[Line] = @[]
    mPos: sdl.Point

method init(app: App): bool {.base.} =
# Only initialize sdl if it has not already been initialized
    # Initialize sdl
    if sdl.init(sdl.InitVideo or sdl.InitTimer) != 0:
        # Print error if sdl cannot Initalize
        echo "Error: Cannot init sdl: ", sdl.getError()
        return false

    # Create new window
    app.window = sdl.createWindow(
        Title,
        sdl.WindowPosCentered,
        sdl.WindowPosCentered,
        Width,
        Height,
        WindowFlags
    )

    # Check if window was created successfully
    if app.window == nil:
        # If window failed creation, print out the error
        echo "Error: Cannot open window: ", sdl.getError()
        return false

    # Create the renderer for the window
    app.renderer = sdl.createRenderer(app.window, -1, RenderFlags)
    # Check if the renderer was created successfully
    if app.renderer == nil:
        # If renderer failed creation, print out the error
        echo "Error: Cannot open window: ", sdl.getError()
        return false

    # Check if the renderer is able to set the color for drawing
    if app.renderer.setRenderDrawColor(0xFF, 0xFF, 0xFF, 0xFF) != 0:
        # If renderer is unable to set draw color, print out the error
        echo "Error: Cannot set draw color" , sdl.getError()
        return false

    # Get the information about the current modeling the window is in
    var mode: DisplayMode
    
    discard sdl.getDisplayMode(0, 0, addr(mode))

    # The window should be 5/8 the resolution of the host monitor
    let scale = 5/8

    # Apply the scale
    let w = int(round(mode.w.float * scale))
    let h = int(round(mode.h.float * scale))

    # Set the window size
    app.window.setWindowSize(w, h)
    # Set the window position to be centered on the screen
    app.window.setWindowPosition(sdl.WindowPosCentered, sdl.WindowPosCentered)
    # Set the parent dimension of the conversion graph to the new size
    g.parentDim = newDimension(w, h)

    echo "SDL init successfully"
    return true

method exit(app: App) {.base.} = 
    # Destroy window and renderer, and quit sdl
    app.renderer.destroyRenderer()
    app.window.destroyWindow()
    sdl.quit()
    echo "SDL shutdown complete"

proc events(pressed: var seq[sdl.Keycode]): bool =
    # Gathers input events. Returns if program should quit

    # False by default
    result = false
    # Current event
    var e: sdl.Event
    # Empty last list of pressed keys
    if pressed != nil:
        pressed = @[]
    
    while sdl.pollEvent(addr(e)) != 0:
        # If the window receives the quit signal, then exit
        if e.kind == sdl.Quit:
            return true
        elif e.kind == sdl.KeyDown:
            # If a key is pressed, add it to the list of pressed keys
            if pressed != nil:
                pressed.add(e.key.keysym.sym)
            # If escape is pressed, then exit
            if e.key.keysym.sym == sdl.K_ESCAPE:
                return true

proc mainLoop() =
    if init(app):
        # Test if the screen can be cleared
        if app.renderer.renderClear() != 0:
            # Print out error if screen cannot be cleared
            echo "Warning: Can't clear screen: ", sdl.getError()

        # Set the color for the blank frame
        discard app.renderer.setRenderDrawColor(0xFF, 0xFF, 0xFF, 0xFF)
        # Clear the screen
        discard app.renderer.renderClear()
        # Set default draw color to black
        discard app.renderer.setRenderDrawColor(0, 0, 0, 0)

        while not done:

            discard app.renderer.setRenderDrawColor(0xFF, 0xFF, 0xFF, 0xFF)
            discard app.renderer.renderClear()
            discard app.renderer.setRenderDrawColor(0, 0, 0, 0)

            for line in lines:
                line.draw(g, app.renderer)

            app.renderer.renderPresent
            done = events(pressed)

            var newPos: sdl.Point

            discard getMouseState(addr(newPos.x), addr(newPos.y))

            if newPos.x != mPos.x:
                lines = @[]
                            
                var x = 0
                var y = 100
                let numLines = 100
                var posinc = g.p2c(newPoint(newPos.x, 0)).x.int
                var inc = 0
                if posinc > 0 or posinc < 0:
                    inc = abs(posinc)
                else:
                    inc = 1

                while x <= numLines:
                    # Quadrant I
                    lines.add(newLine((0.0, y.float), (x.float, 0.0)))

                    # Quadrant II
                    lines.add(newLine((0.0, y.float), (-x.float, 0.0)))

                    # Quadrant III
                    lines.add(newLine((0.0, -y.float), (-x.float, 0.0)))

                    # Quadrant IIII
                    lines.add(newLine((0.0, -y.float), (x.float, 0.0)))

                    x += inc
                    y -= inc
                
            mPos = newPos

            fpsMgr.manage()
    else:
        exit(app)
        quit("SDL could not init", -1)

mainLoop()
