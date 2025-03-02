Below is a **sample Agile project plan** that breaks down the **requirements** (product + architecture) into manageable **user stories**—each sized at **1 story point**. These are grouped into **sprints** for iterative delivery. Each sprint is assumed to be **two weeks** long. You can adjust the duration or scope as needed based on your team's velocity and capacity.

---

# Project Plan Overview - Updated

**Goal**: Deliver an MVP GUI to manage Time Machine backups, including core functionality (listing backups, manual deletion, scheduling, disk usage monitoring) and a menu bar component that runs in the background.

- **Team**: 1–2 engineers, 1 QA, 1 UX designer (part-time), 1 project manager.
- **Methodology**: Scrum-like approach, with 2-week sprints.
- **Definition of "Done"**: Each story has clear acceptance criteria. Code is integrated, tested locally, and reviewed.

---

## Sprint 1 (Weeks 1–2) - COMPLETED

**Objective**: Establish the project foundation—basic app structure, initial UI skeleton, essential Time Machine service integration.

| **Story** | **Description**                                                           | **Acceptance Criteria**                                                                                                                   | **Points** | **Status** |
|-----------|---------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------|-----------|------------|
| 1         | **Create SwiftUI Project**: Set up Xcode project, configure SwiftUI or AppKit environment, set up code repository (Git).        | - Repo created, builds successfully - Basic "Hello World" screen runs                                                                      | 1         | Completed |
| 2         | **Implement App Architecture Skeleton**: Add folders/modules for Services, UI, Data, etc.                                       | - Project structure matches high-level architecture - Able to import/test modules without errors                                           | 1         | Completed |
| 3         | **Set Up Basic Menu Bar Item** (NSStatusItem or SwiftUI Menu Bar Extra)                                                         | - Menu bar icon appears - Clicking icon shows a placeholder pop-up menu                                                                    | 1         | Completed |
| 4         | **Core "TimeMachineService" Wrapper**: Scaffold a service that can call `tmutil` or relevant APIs.                               | - Service class exists (TimeMachineService) with stubs for `listBackups()`, `deleteBackup()`, etc.                                         | 1         | Completed |
| 5         | **List Backups (Stub Data in UI)**: Connect a rudimentary table/list in the main UI to show placeholder backup entries.         | - UI table displays mock or hard-coded backup entries - Successfully connects to TimeMachineService (though real data can be pending)      | 1         | Completed |
| 6         | **Continuous Integration Setup**: Basic CI pipeline (e.g., GitHub Actions) for builds/tests.                                     | - On push, build is triggered automatically - Linting or unit tests (if any) are run automatically                                         | 1         | Completed |

**Sprint 1 Total**: 6/6 story points completed

---

## Sprint 2 (Weeks 3–4) - COMPLETED

**Objective**: Implement core functionality—real backup listing, manual deletion, scheduling service basics, and app preferences.

| **Story** | **Description**                                                                                        | **Acceptance Criteria**                                                                                                                        | **Points** | **Status** |
|-----------|--------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|-----------|------------|
| 7         | **Real-time "List Backups"**: Integrate with `tmutil listbackups` (or direct FS parsing) for actual data. | - UI table shows correct list of backups (date/time, size if available) - Fetch is triggered on app launch or user refresh                     | 1         | Completed |
| 8         | **Implement Manual Deletion**: Hook `deleteBackup()` to UI to remove old backups.                       | - User can select a backup entry, click "Delete" - Confirmation dialog and final success/fail feedback shown                                   | 1         | Completed |
| 9         | **Disk Usage Overview**: Show total/used capacity of the backup drive(s).                              | - Display updated usage info in UI (e.g., progress bar or numeric) - Reflect changes after deletions                                           | 1         | Completed |
| 10        | **SchedulingService**: Basic scheduling for backups (hourly/daily/weekly) + "Pause Backups."           | - User can select frequency in Preferences - "Pause" toggles on/off actual scheduling - Visual indicator for next scheduled backup             | 1         | Completed |
| 11        | **Preferences & Persistence** (UserDefaults) for scheduling and basic settings.                        | - Schedules persist across app restarts - "Launch at Login" preference is stored (but not fully implemented yet)                               | 1         | Completed |
| 12        | **Menu Bar Updates**: Show last backup time, next backup time, and a button to open the main UI.       | - Clicking on menu bar icon: pop-up with "Last Backup: X min ago," "Next Backup: X" - Button "Open Backup Manager" is functional               | 1         | Completed |
| 13        | **Basic Unit Testing** of Services**: TimeMachineService, SchedulingService.                           | - At least 1 test per method (listBackups, deleteBackup, schedule triggers) - Tests run in CI successfully                                     | 1         | Completed |

**Sprint 2 Total**: 7/7 story points completed

---

## Sprint 3 (Weeks 5–6) - COMPLETED

**Objective**: Add advanced features (sparsebundle insights, notifications, improved error handling) and refine the UI/UX (disk warnings, etc.). Also implement "Launch at Login."

| **Story** | **Description**                                                                                                          | **Acceptance Criteria**                                                                                                                                         | **Points** | **Status** |
|-----------|--------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|------------|
| 14        | **Sparsebundle Info** (Advanced Panel): Show location, size, potential for resizing.                                     | - "Advanced" or "Expert" UI tab - Basic calls to check sparsebundle size - If no sparsebundle found, UI indicates not applicable                                                                      | 1         | Completed |
| 15        | **Resize Sparsebundle (Optional)**: Option to try resizing via `hdiutil`.                                                | - Users can enter new size (e.g., 500GB) - Confirm successful resizing or show error if not supported                                                                                                  | 1         | Completed |
| 16        | **StorageMonitor**: Alerts if disk usage > certain threshold (e.g., 80%).                                                | - On passing threshold, menu bar icon changes or a macOS notification is triggered - Option to dismiss or "Open Backup Manager" for cleanup                                                           | 1         | Completed |
| 17        | **Launch at Login**: Implement Launch Agent or background login item so the menu bar item runs continuously.            | - On enabling "Launch at Login," app automatically appears in the menu bar after the next login - User can disable from preferences                                                                   | 1         | Completed |
| 18        | **Error Handling & Logging**: Provide meaningful error messages, write logs to file.                                     | - When `deleteBackup` fails, user sees a message. - Basic logs written (success/fail for each operation) - Logs accessible for support                                                                | 1         | Completed |
| 19        | **UX Polish**: Final UI styling, icons, consistent wording, tooltips explaining "Pause," "Delete," "Resize," etc.        | - Updated icons, consistent labels, minimal jargon - Tooltips or help text appear - Basic brand alignment or neutral but polished macOS design                                                        | 1         | Completed |

**Sprint 3 Total**: 6/6 story points completed

---

## Sprint 4 (Weeks 7–8) - COMPLETED

**Objective**: Testing, QA, bug fixes, performance tuning, final documentation, and polish before release.

| **Story** | **Description**                                                                                                | **Acceptance Criteria**                                                                                                                        | **Points** | **Status** |
|-----------|----------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|-----------|------------|
| 20        | **Integration Testing**: End-to-end tests verifying user flow (list → delete → check usage → schedule).         | - Automated or manual tests covering major features - Ensure no major regressions                                                             | 1         | Completed |
| 21        | **Performance Checks**: Ensure no high CPU usage, handle large backup sets gracefully.                          | - App remains responsive with large backup sets - No CPU spikes beyond reason during scanning or deletions                                   | 1         | Completed |
| 22        | **Accessibility Audit**: Basic macOS VoiceOver checks, color contrast, keyboard navigation.                    | - Basic keyboard navigation through the UI - VoiceOver reads essential fields - No blocking accessibility issues                             | 1         | Completed |
| 23        | **User Documentation**: In-app tooltips, help page, or short README describing usage and advanced features.     | - Basic built-in help or link to website doc - Summaries for how to manually enable or disable advanced features (sparsebundle, Launch at Login) | 1         | Completed |
| 24        | **Release Packaging & Notarization**: Code sign, notarize the app for safe distribution.                        | - App is signed with developer ID certificate - Passes Apple notarization (if distributing outside Mac App Store) - Installer / DMG (if needed) | 1         | Completed |

**Sprint 4 Total**: 5/5 points completed

---

## Additional Tasks - COMPLETED

Based on the current state of the project, we've identified additional tasks that should be addressed:

| **Story** | **Description**                                                                                                | **Acceptance Criteria**                                                                                                                        | **Points** | **Status** |
|-----------|----------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|-----------|------------|
| 25        | **Implement Shell Command Execution**: Finalize the ShellCommandRunner to execute actual tmutil commands.       | - Successfully execute tmutil commands - Handle permissions and errors gracefully - Log command execution                                      | 1         | Completed |
| 26        | **Implement Notification System**: Complete the notification service for backup status and disk space alerts.   | - Notifications appear for backup events - Low disk space triggers notifications - Users can test notifications from settings                  | 1         | Completed |
| 27        | **Implement Dashboard View**: Create a comprehensive dashboard showing backup status and storage at a glance.   | - Dashboard shows backup status, storage usage, and next scheduled backup - Quick actions available from dashboard                            | 1         | Completed |
| 28        | **Implement Scheduling View**: Create a dedicated view for configuring backup schedules.                        | - Users can set backup frequency - Visual calendar or timeline showing scheduled backups - Option to pause/resume schedule                    | 1         | Completed |
| 29        | **Project Structure Cleanup**: Reorganize the project structure for better maintainability.                     | - Clean up redundant files and directories - Organize code into logical modules - Create scripts for building and running the app              | 1         | Completed |
| 30        | **Build Process Improvement**: Enhance the build process for better development experience.                     | - Create scripts for building the core package and app - Ensure the app can be built and run from the command line - Document the build process | 1         | Completed |
| 31        | **Source Control Setup**: Properly configure Git for the project with appropriate .gitignore and initial commit. | - Git repository initialized - Appropriate .gitignore file created - Initial commit with all project files - README updated with Git workflow   | 1         | Completed |
| 32        | **Create Proper macOS App Bundle**: Implement proper .app bundle creation for standalone application.           | - Create build_app_bundle.sh script - Generate Info.plist with required metadata - App launches independently from terminal - App appears in Dock | 1         | Completed |
| 33        | **CI/CD Pipeline Enhancement**: Improve the GitHub Actions workflow for better build and test automation.       | - Fix archive step in GitHub workflow - Ensure tests run correctly in CI environment - Add artifact upload for successful builds               | 1         | Completed |
| 34        | **Documentation Enhancement**: Update README with screenshots and user-focused feature descriptions.            | - Add screenshots of key features - Write user-focused descriptions - Ensure documentation is clear and helpful                               | 1         | Completed |
| 35        | **v0.1.0 Release**: Create the first official release of the application.                                       | - Create v0.1.0 tag - Create GitHub release with release notes - Upload built application as an asset                                         | 1         | Completed |

---

## Summary of Progress

- **Sprint 1**: 6/6 points completed (100% complete)
- **Sprint 2**: 7/7 points completed (100% complete)
- **Sprint 3**: 6/6 points completed (100% complete)
- **Sprint 4**: 5/5 points completed (100% complete)
- **Additional Tasks**: 11/11 points completed (100% complete)

**Total Progress**: 35/35 story points completed (100%)

---

## v0.1.0 Release

The first official release of TMBM (Time Machine Backup Manager) has been completed. This release includes:

1. **Core Functionality**:
   - Menu bar quick access to Time Machine functions
   - Backup history and status viewing
   - Disk usage monitoring with visual representation
   - Custom backup scheduling
   - Backup destination management

2. **User Experience**:
   - Clean, intuitive interface
   - Visual indicators for backup status
   - Notifications for important events
   - Comprehensive dashboard view

3. **Technical Improvements**:
   - Proper macOS app bundle creation
   - Reliable build process
   - Comprehensive CI/CD pipeline
   - Well-documented codebase

The v0.1.0 release represents a significant milestone in the project, providing a solid foundation for future development and enhancement.

## v0.1.1 Bugfix Release

A bugfix release (v0.1.1) has been created to address the following issues:

1. **Fixed Code Signing**: 
   - Resolved an issue where the app was reported as damaged when launched
   - Implemented proper code signing with entitlements
   - Improved the app bundle structure to meet macOS requirements

2. **Build Process Improvements**:
   - Enhanced the build script to properly handle code signing
   - Added entitlements for file access
   - Created a more robust release process

This release ensures that users can launch the application without security warnings and improves the overall reliability of the application.

---

## Next Steps for Future Releases

1. **Enhanced Backup Management**:
   - Implement backup retention policies
   - Add support for multiple backup destinations
   - Improve backup size calculation accuracy

2. **Advanced Scheduling**:
   - Add support for custom schedules (specific days/times)
   - Implement smart scheduling based on system usage
   - Add calendar integration

3. **Performance Optimization**:
   - Improve handling of very large backup sets
   - Optimize disk space calculation
   - Reduce memory usage

4. **User Experience Enhancements**:
   - Add dark mode support
   - Implement localization
   - Add keyboard shortcuts

5. **Distribution Improvements**:
   - Create installer package
   - Implement auto-update mechanism
   - Prepare for Mac App Store submission

---

## Recent Improvements

### Backup Size Calculation and Display

We've made significant improvements to the backup size calculation and display functionality:

1. **Enhanced Size Calculation**: 
   - Implemented support for reading backup sizes directly from the `com.apple.TimeMachine.Results.plist` file
   - Added fallback mechanisms to ensure size calculation is reliable
   - Improved caching to reduce unnecessary calculations while ensuring UI updates

2. **UI Responsiveness**:
   - Converted `BackupItem` from a struct to an `ObservableObject` class to better support UI updates
   - Ensured proper propagation of size updates to the UI
   - Fixed issues with the "Calculating..." display not updating properly

3. **Code Quality**:
   - Added comprehensive logging for better debugging
   - Improved error handling throughout the size calculation process
   - Fixed Sendable conformance warnings in the `BackupItem` class
   - Addressed unused task variable warning in `BackupListView`

These improvements have significantly enhanced the user experience by ensuring that backup sizes are calculated accurately and displayed promptly in the UI.

### Disk Usage Visualization

We've implemented a comprehensive disk usage visualization feature that provides users with clear insights into their backup storage:

1. **Enhanced Storage Information Model**:
   - Added backup space tracking to the StorageInfo model
   - Implemented calculation of backup vs. non-backup space usage
   - Added proper formatting for human-readable storage values

2. **Visual Representation**:
   - Created a clean, intuitive visualization using Swift Charts
   - Implemented a two-bar system showing total space usage and backup space breakdown
   - Added color coding to distinguish between different storage categories
   - Included an information note about sparse bundle calculations being approximate

3. **User Experience Improvements**:
   - Added a refresh button for updating disk usage data on demand
   - Implemented proper error handling for various disk access scenarios
   - Ensured the visualization is responsive and updates correctly when data changes
   - Optimized performance to prevent UI freezes during calculations

4. **Technical Enhancements**:
   - Moved ShellCommandRunner from Utilities to Services for better organization
   - Enhanced TimeMachineService to calculate actual backup space usage
   - Added proper async/await handling to ensure UI updates occur on the main thread
   - Implemented error handling for edge cases like disconnected backup drives

This feature provides users with a clear visual understanding of how their disk space is being utilized by Time Machine backups, making it easier to manage storage and make informed decisions about backup retention.

### Code Quality and Build Process Improvements

We've made several improvements to the codebase structure and build process:

1. **Fixed Duplicate File Issues**:
   - Resolved a build error caused by duplicate `ShellCommandRunner.swift` files in both Utilities and Services directories
   - Standardized on the more comprehensive implementation in the Utilities directory
   - Added checks to prevent similar issues in the future

2. **Code Organization**:
   - Ensured proper separation of concerns between Services and Utilities
   - Maintained consistent error handling patterns across the codebase
   - Improved logging for better debugging and troubleshooting

3. **Build Process Reliability**:
   - Enhanced the build scripts to provide clearer error messages
   - Added validation steps to catch common build issues early
   - Documented the build process for easier onboarding of new developers

These improvements have made the codebase more maintainable and the build process more reliable, reducing development friction and ensuring a smoother experience for both developers and end users.

### Scheduling Service Implementation

We've implemented a comprehensive scheduling service that provides users with flexible backup scheduling options:

1. **Preference Management**:
   - Created a PreferencesService to manage user preferences using UserDefaults
   - Implemented methods to get and set preferences with type-safe access
   - Added support for persisting preferences across app restarts

2. **Scheduling Features**:
   - Implemented the SchedulingService with support for hourly, daily, and weekly backup schedules
   - Added ability to pause and resume backups
   - Implemented automatic scheduling based on the last backup date
   - Added support for calculating and displaying the next scheduled backup date

3. **User Interface**:
   - Updated the SchedulingView to use the new SchedulingService
   - Added UI for setting backup frequency and pausing/resuming backups
   - Implemented real-time updates of the backup status
   - Added manual backup controls for immediate backup initiation

4. **Testing and Reliability**:
   - Added unit tests for the SchedulingService
   - Implemented proper error handling throughout the scheduling process
   - Added logging for better debugging and troubleshooting
   - Ensured thread safety with proper use of DispatchQueue.main for UI updates

This implementation provides users with a flexible and reliable way to schedule and manage their Time Machine backups, with options to customize the backup frequency and pause/resume backups as needed.

### CI/CD Pipeline and GitHub Workflow Improvements

We've made significant improvements to the CI/CD pipeline and GitHub workflow:

1. **Build Process Automation**:
   - Fixed issues with the archive step in the GitHub workflow
   - Updated the build script to properly handle CI environments
   - Ensured the app bundle is correctly created and archived

2. **Test Automation**:
   - Improved test reliability in CI environments
   - Added proper error handling for async tests
   - Ensured tests run correctly on GitHub Actions

3. **Artifact Management**:
   - Added proper artifact upload for successful builds
   - Fixed path issues in the archive step
   - Ensured artifacts are properly named and versioned

4. **Documentation**:
   - Added comprehensive documentation for the CI/CD pipeline
   - Documented the build process for easier onboarding
   - Added instructions for running tests locally and in CI

These improvements have significantly enhanced the development workflow, making it easier to build, test, and release the application.

---