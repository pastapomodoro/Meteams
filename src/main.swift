import AppKit

private let pythonPath = "/opt/homebrew/bin/python3"
private let pidFile    = NSHomeDirectory() + "/.meteo_jiggle.pid"

private let jiggleScript = """
import ctypes,os,sys,signal,time
PID_FILE=sys.argv[1]
class P(ctypes.Structure):_fields_=[("x",ctypes.c_double),("y",ctypes.c_double)]
cg=ctypes.cdll.LoadLibrary("/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics")
cg.CGEventCreate.restype=ctypes.c_void_p;cg.CGEventCreate.argtypes=[ctypes.c_void_p]
cg.CGEventGetLocation.restype=P;cg.CGEventGetLocation.argtypes=[ctypes.c_void_p]
cg.CGEventCreateMouseEvent.restype=ctypes.c_void_p;cg.CGEventCreateMouseEvent.argtypes=[ctypes.c_void_p,ctypes.c_uint32,P,ctypes.c_uint32]
cg.CGEventCreateKeyboardEvent.restype=ctypes.c_void_p;cg.CGEventCreateKeyboardEvent.argtypes=[ctypes.c_void_p,ctypes.c_uint16,ctypes.c_bool]
cg.CGEventPost.restype=None;cg.CGEventPost.argtypes=[ctypes.c_uint32,ctypes.c_void_p]
def jiggle():
    ev=cg.CGEventCreate(None);pos=cg.CGEventGetLocation(ev)
    for dx in(2,-2):cg.CGEventPost(0,cg.CGEventCreateMouseEvent(None,5,P(pos.x+dx,pos.y),0));time.sleep(.05)
    cg.CGEventPost(0,cg.CGEventCreateKeyboardEvent(None,56,True));time.sleep(.05)
    cg.CGEventPost(0,cg.CGEventCreateKeyboardEvent(None,56,False))
if os.fork()>0:sys.exit(0)
os.setsid()
if os.fork()>0:sys.exit(0)
dev=os.open(os.devnull,os.O_RDWR)
for fd in(0,1,2):os.dup2(dev,fd)
open(PID_FILE,"w").write(str(os.getpid()))
signal.signal(signal.SIGTERM,lambda*_:sys.exit(0))
while True:jiggle();time.sleep(45)
"""

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem  : NSStatusItem!
    var toggleItem  : NSMenuItem!
    var active      = false

    func applicationDidFinishLaunching(_ n: Notification) {
        buildMenu()
        if daemonRunning() { markActive(true) }
    }

    private func buildMenu() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateIcon()
        toggleItem = NSMenuItem(title: "Attiva", action: #selector(toggle), keyEquivalent: "")
        toggleItem.target = self
        let quit = NSMenuItem(title: "Esci", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        let menu = NSMenu()
        menu.addItem(toggleItem)
        menu.addItem(.separator())
        menu.addItem(quit)
        statusItem.menu = menu
    }

    private func updateIcon() {
        let name = active ? "sun.max.fill" : "moon.zzz"
        if let img = NSImage(systemSymbolName: name, accessibilityDescription: nil) {
            statusItem.button?.image = img.withSymbolConfiguration(.init(pointSize: 14, weight: .medium))
            statusItem.button?.image?.isTemplate = true
            statusItem.button?.title = ""
        }
    }

    private func markActive(_ on: Bool) {
        active = on; updateIcon()
        toggleItem.title = on ? "Disattiva" : "Attiva"
    }

    private func daemonRunning() -> Bool {
        guard let s = try? String(contentsOfFile: pidFile, encoding: .utf8),
              let pid = Int32(s.trimmingCharacters(in: .whitespacesAndNewlines)) else { return false }
        return kill(pid, 0) == 0
    }

    private func startDaemon() {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: pythonPath)
        p.arguments = ["-c", jiggleScript, pidFile]
        p.standardOutput = FileHandle.nullDevice
        p.standardError  = FileHandle.nullDevice
        try? p.run()
    }

    private func stopDaemon() {
        guard let s = try? String(contentsOfFile: pidFile, encoding: .utf8),
              let pid = Int32(s.trimmingCharacters(in: .whitespacesAndNewlines)) else { return }
        kill(pid, SIGTERM)
        try? FileManager.default.removeItem(atPath: pidFile)
    }

    @objc private func toggle() {
        if active { stopDaemon(); markActive(false) }
        else {
            startDaemon()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.markActive(true) }
        }
    }

    @objc private func quit() { stopDaemon(); NSApplication.shared.terminate(nil) }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let d = AppDelegate()
app.delegate = d
app.run()
