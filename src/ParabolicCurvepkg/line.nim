## Drawable line shape
#                                                      
#  Made by Earl Kennedy                               
#  https://github.com/Mnenmenth                        
#  https://mnenmenth.com

import libgraph
import sdl2.sdl

type
    Line* = ref object of RootObj
        ## Holds start and end points of line
        lineStart*: Coordinate
        lineEnd*: Coordinate

proc newLine*(lineStart, lineEnd: Coordinate): Line =
    ## Creates new line from Coordinates
    Line(lineStart: lineStart, lineEnd: lineEnd)

proc newLine*(lineStart, lineEnd: tuple[x: float, y: float]): Line =
    ## Creates new line from tuples
    newLine(newCoordinate(lineStart.x, lineStart.y), newCoordinate(lineEnd.x, lineEnd.y))

method draw*(line: Line, g: Graph, renderer: sdl.Renderer) {.base.} =
    ## Draws the line

    # Converts line points from coordinate unit points to pixel points on screen
    # Then draws line between points
    let lineStart = g.c2p(line.lineStart)
    let lineEnd = g.c2p(line.lineEnd)
    discard sdl.renderDrawLine(renderer, lineStart.x, lineStart.y, lineEnd.x, lineEnd.y)