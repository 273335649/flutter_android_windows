#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include "flutter_window.h"
#include "win32_window.h"
#include <memory>

#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  // Initialize to fullscreen at 0,0
  Win32Window::Point origin(0, 0);
  Win32Window::Size size(GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN));
  if (!window.Create(L"flutter_windows_android_app", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  HWND hwnd = ::FindWindowW(nullptr, L"flutter_windows_android_app");
  if (hwnd != nullptr) {
    LONG_PTR style = ::GetWindowLongPtrW(hwnd, GWL_STYLE);
    style &= ~(WS_CAPTION | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX | WS_SYSMENU);
    ::SetWindowLongPtrW(hwnd, GWL_STYLE, style);
    ::SetWindowPos(hwnd, nullptr, 0, 0, GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN), SWP_NOZORDER | SWP_FRAMECHANGED);
  }

  // Create a MethodChannel to handle minimize requests from Flutter.
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      window.flutter_controller()->engine()->messenger(),
      "com.hf.mes/window",
      &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [&window](const flutter::MethodCall<flutter::EncodableValue>& call, std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name().compare("minimizeWindow") == 0) {
          window.Minimize();
          result->Success();
        } else if (call.method_name().compare("restoreWindow") == 0) {
          // Check if the window is maximized, if so, restore to normal size
          if (window.IsMaximized() || window.IsMinimized()) {
            window.Restore();
          } else {
            window.Maximize();
          }
          // Ensure the window is visible and active after restoration
          window.Show();
          window.Activate();
          // Force refresh the window to ensure state update
          window.ForceRedraw();
          result->Success();
        } else {
          result->NotImplemented();
        }
      });

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    // Allow the keyboard to control the window.
    if (msg.message == WM_APP + 1) {
      window.Minimize();
    }



    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
