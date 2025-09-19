#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>

#include <memory>

#include "win32_window.h"

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
 public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

  // Minimize the window.
  void Minimize();

  // Restore the window.
  void Restore();

  // Check if the window is minimized.
  bool IsMinimized();

  // Check if the window is maximized.
  bool IsMaximized();

  // Maximize the window.
  void Maximize();

  // Activate the window.
  void Activate();

  // Force redraw the window.
  void ForceRedraw();

  // Accessor for the Flutter view controller.
  flutter::FlutterViewController* flutter_controller() { return flutter_controller_.get(); }

 protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  // The project to run.
  flutter::DartProject project_;

  // The Flutter instance hosted by this window.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;
};

#endif  // RUNNER_FLUTTER_WINDOW_H_
