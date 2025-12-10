# Crash Fix - Window Close & Stability

## Issue
**Problem**: App crashed when clicking the close button or closing a window/document.
**Root Cause**: **Multiple Memory Leaks** involving `NSEvent.addLocalMonitorForEvents`.

1. **`TypeStyleAppView` Leak**: 
   - Monitors were added repeatedly (`didBecomeActiveNotification`) and never removed.
   - Monitors persisted after window closure, accessing deallocated visual state.

2. **`KeyboardShortcutsManager` Leak** (CRITICAL):
   - This service is initialized per-window via `AppCoordinator` -> `FileManagementService`.
   - In its `init`, it created a global keyboard monitor.
   - **It ignored the return value**, making it IMPOSSIBLE to remove the monitor.
   - Result: Every window opened added a permanent, immortal event monitor to the global chain. Closing the window did NOT remove it.
   - The accumulation of these "zombie" monitors caused instability and crashes when interacting with closed window contexts.

## Solution

### 1. Fixed `KeyboardShortcutsManager`
- Updated the class to **store the monitor token**.
- Added a `deinit` block to explicitly **remove the monitor**.
- Now, when a window closes and its services are deallocated, the global monitor is cleanly removed.

### 2. Refactored `TypeStyleAppView`
- Replaced direct `NSEvent` usage with a new `KeyboardShortcutMonitor` helper.
- Moved setup to `onAppear` (once per view) and cleanup to `onDisappear`.
- Ensures UI-specific shortcuts (Escape key) are only active when the view is visible.

### 3. Created `KeyboardShortcutMonitor` Utility
- A reusable class that safely wraps `NSEvent` monitoring logic and guarantees cleanup on deallocation.

## Files Modified
- [x] `type/Utils/KeyboardShortcutsManager.swift` (Fixed Leak)
- [x] `type/UI/TypeStyleAppView.swift` (Refactored)
- [x] `type/Utils/KeyboardShortcutMonitor.swift` (New Utility)

**Status: FIXED**
