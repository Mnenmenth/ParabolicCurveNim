## FPS Manager
#                                                      
#  Made by Earl Kennedy                               
#  https://github.com/Mnenmenth                        
#  https://mnenmenth.com

import sdl2.sdl
type
    FPSManager* = ref object of RootObj
        ## FPSManager. Contains relevant information for managing fps
        fps: int
        delta: float
        ticks, freq: uint64

proc newFpsManager*(fps: int): FPSManager =
    ## Creates new fps manager with given fps
    FPSManager(fps: fps, delta: 0.0, ticks: sdl.getPerformanceCounter(), freq: sdl.getPerformanceFrequency())

method getFPS*(manager: FPSManager): int {.base.} = 
    ## Get FPS
    return manager.fps

method setFPS*(manager: FPSManager, fps: int) {.base.} = 
    ## Set FPS
    manager.fps = fps

method manage*(manager: FPSManager) {.base.} =
    ## Manages the FPS. Call between loop executions to cap FPS
    let spare = uint32(1000 / manager.fps) -
        1000'u32 * uint32((sdl.getPerformanceCounter() - manager.ticks).float / manager.freq.float)
    if spare > 0'u32:
        sdl.delay(spare)
    
    manager.delta = (sdl.getPerformanceCounter() - manager.ticks).float / manager.freq.float
    manager.ticks = sdl.getPerformanceCounter()