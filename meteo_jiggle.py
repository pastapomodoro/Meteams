import ctypes, time, os, sys, signal, subprocess

class P(ctypes.Structure):
    _fields_ = [("x", ctypes.c_double), ("y", ctypes.c_double)]

cg = ctypes.cdll.LoadLibrary("/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics")
cg.CGEventCreate.restype          = ctypes.c_void_p
cg.CGEventCreate.argtypes         = [ctypes.c_void_p]
cg.CGEventGetLocation.restype     = P
cg.CGEventGetLocation.argtypes    = [ctypes.c_void_p]
cg.CGEventCreateMouseEvent.restype  = ctypes.c_void_p
cg.CGEventCreateMouseEvent.argtypes = [ctypes.c_void_p, ctypes.c_uint32, P, ctypes.c_uint32]
cg.CGEventPost.restype  = None
cg.CGEventPost.argtypes = [ctypes.c_uint32, ctypes.c_void_p]

PID_FILE = os.path.expanduser("~/.meteo_jiggle.pid")
open(PID_FILE, "w").write(str(os.getpid()))
signal.signal(signal.SIGTERM, lambda *_: (os.remove(PID_FILE), sys.exit(0)))

TEAMS_CLICK = """
tell application "System Events"
    set prevApp to name of first process whose frontmost is true
    if exists process "Microsoft Teams" then
        tell process "Microsoft Teams"
            click at {50, 300}
        end tell
        delay 0.2
        set frontmost of process prevApp to true
    end if
end tell
"""

def jiggle():
    ev  = cg.CGEventCreate(None)
    pos = cg.CGEventGetLocation(ev)
    for dx in (2, -2):
        cg.CGEventPost(0, cg.CGEventCreateMouseEvent(None, 5, P(pos.x+dx, pos.y), 0))
        time.sleep(0.05)
    subprocess.run(["osascript", "-e", TEAMS_CLICK], capture_output=True, timeout=5)

while True:
    jiggle()
    time.sleep(45)
