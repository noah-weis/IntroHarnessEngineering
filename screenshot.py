import sys
import os

import objc
from Cocoa import (
    NSApplication,
    NSApp,
    NSObject,
    NSMakeRect,
    NSWindow,
    NSWindowStyleMaskTitled,
    NSBackingStoreBuffered,
    NSURL,
    NSURLRequest,
    NSBitmapImageRep,
    NSPNGFileType,
    NSTimer,
)
from WebKit import WKWebView, WKWebViewConfiguration
from Quartz import CGRectMake

WIDTH = 1280
HEIGHT = 900


class ScreenshotDelegate(NSObject):
    """Delegate that waits for page load, then captures a screenshot."""

    def init(self):
        self = objc.super(ScreenshotDelegate, self).init()
        if self is None:
            return None
        self.output_path = "screenshot.png"
        self.webview = None
        return self

    def webView_didFinishNavigation_(self, webview, navigation):
        """Called by WebKit when the page finishes loading."""
        self.webview = webview
        # Short delay so CSS rendering finalizes
        NSTimer.scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_(
            0.5, self, "doCapture:", None, False
        )

    def webView_didFailNavigation_withError_(self, webview, navigation, error):
        print(f"Navigation failed: {error}", file=sys.stderr)
        NSApp.terminate_(None)

    def doCapture_(self, timer):
        """Take a snapshot of the webview and save it as PNG."""
        output_path = self.output_path

        def on_snapshot(image, error):
            if error:
                print(f"Screenshot error: {error}", file=sys.stderr)
                NSApp.terminate_(None)
                return
            tiff_data = image.TIFFRepresentation()
            bitmap = NSBitmapImageRep.imageRepWithData_(tiff_data)
            png_data = bitmap.representationUsingType_properties_(NSPNGFileType, None)
            png_data.writeToFile_atomically_(output_path, True)
            print(os.path.abspath(output_path))
            NSApp.terminate_(None)

        self.webview.takeSnapshotWithConfiguration_completionHandler_(
            None, on_snapshot
        )


def take_screenshot(html_path, output_path="screenshot.png"):
    """Render an HTML file with native WebKit and save a screenshot."""
    html_path = os.path.abspath(html_path)
    if not os.path.exists(html_path):
        print(f"Error: {html_path} not found", file=sys.stderr)
        sys.exit(1)

    app = NSApplication.sharedApplication()

    rect = NSMakeRect(0, 0, WIDTH, HEIGHT)
    window = NSWindow.alloc().initWithContentRect_styleMask_backing_defer_(
        rect, NSWindowStyleMaskTitled, NSBackingStoreBuffered, False
    )

    config = WKWebViewConfiguration.alloc().init()
    webview = WKWebView.alloc().initWithFrame_configuration_(
        CGRectMake(0, 0, WIDTH, HEIGHT), config
    )

    delegate = ScreenshotDelegate.alloc().init()
    delegate.output_path = output_path
    webview.setNavigationDelegate_(delegate)

    url = NSURL.fileURLWithPath_(html_path)
    request = NSURLRequest.requestWithURL_(url)
    webview.loadRequest_(request)

    window.setContentView_(webview)
    window.orderBack_(None)

    app.run()


if __name__ == "__main__":
    html_file = "index.html"
    output_file = "screenshot.png"

    if len(sys.argv) >= 2:
        html_file = sys.argv[1]
    if len(sys.argv) >= 3:
        output_file = sys.argv[2]

    take_screenshot(html_file, output_file)
