// The Swift Programming Language
// https://docs.swift.org/swift-book

import HtmlFormsServer

let fman = FileManager.default
let tempDir = fman.temporaryDirectory
let sessionDir = tempDir.appendingPathComponent("HtmlFormsServerTests")

let server = HtmlFormsServer(port:9999, sessionDir:sessionDir)

class MyServerDelegate : NSObject, HtmlFormsServerDelegate {
    func open(_ url: URL, window windowID: Int) -> Void {
    }

    func closeWindow(_ windowId: Int) -> Void {
    }

    func showErrorMessage(_ errMsg: String, window windowId: Int) -> Void {
    }
}

let del = MyServerDelegate()
server.delegate = del

func pretendRun() -> Void {
    server.start()
    server.stop()
    server.connectClientFd(123)
}
