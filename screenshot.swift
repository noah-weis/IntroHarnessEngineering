import Cocoa
import WebKit

// A simple screenshot tool that renders HTML using macOS WebKit and saves a PNG.
// No browser automation frameworks (Playwright, Puppeteer, Selenium) are used.
// WebKit is a native macOS system framework — this is just rendering HTML to an image.

let args = CommandLine.arguments
guard args.count >= 2 else {
    print("Usage: swift screenshot.swift <html-file> [output.png]")
    exit(1)
}

let htmlPath = args[1]
let outputPath = args.count >= 3 ? args[2] : "screenshot.png"

let htmlURL = URL(fileURLWithPath: htmlPath)
guard FileManager.default.fileExists(atPath: htmlURL.path) else {
    print("Error: file not found: \(htmlPath)")
    exit(1)
}

// Set up the application so we can use WebKit off-screen
let app = NSApplication.shared

class ScreenshotDelegate: NSObject, WKNavigationDelegate {
    let webView: WKWebView
    let outputPath: String

    init(webView: WKWebView, outputPath: String) {
        self.webView = webView
        self.outputPath = outputPath
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Wait briefly for any rendering to settle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.captureScreenshot()
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Error loading page: \(error.localizedDescription)")
        exit(1)
    }

    func captureScreenshot() {
        let config = WKSnapshotConfiguration()
        config.snapshotWidth = 1280

        webView.takeSnapshot(with: config) { image, error in
            if let error = error {
                print("Snapshot error: \(error.localizedDescription)")
                exit(1)
            }
            guard let image = image else {
                print("Error: no image produced")
                exit(1)
            }

            guard let tiffData = image.tiffRepresentation,
                  let bitmap = NSBitmapImageRep(data: tiffData),
                  let pngData = bitmap.representation(using: .png, properties: [:]) else {
                print("Error: could not convert image to PNG")
                exit(1)
            }

            let outputURL = URL(fileURLWithPath: self.outputPath)
            do {
                try pngData.write(to: outputURL)
                print("Screenshot saved to \(self.outputPath)")
            } catch {
                print("Error writing file: \(error.localizedDescription)")
                exit(1)
            }

            exit(0)
        }
    }
}

// Create an off-screen web view at a reasonable viewport size
let webViewConfig = WKWebViewConfiguration()
let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 1280, height: 900), configuration: webViewConfig)

let delegate = ScreenshotDelegate(webView: webView, outputPath: outputPath)
webView.navigationDelegate = delegate

// Load the HTML file
webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())

// Run the event loop so WebKit can render
app.run()
