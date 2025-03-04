# TMBM V1 Project Schedule

## Progress Tracking Table

| Sprint | Status | Points Complete | Total Points | Progress % | Key Deliverables Status |
|--------|--------|----------------|--------------|------------|------------------------|
| 1. Core Infrastructure | In Progress | 5 | 21 | 24% | 🟡 Window Management<br>🟡 Menu Bar<br>⚪ CI/CD Pipeline |
| 2. Menu Bar & Notifications | Not Started | 0 | 18 | 0% | ⚪ Menu Bar Features<br>⚪ Notifications |
| 3. Network & Storage | Not Started | 0 | 21 | 0% | ⚪ Network Mounts<br>⚪ Storage Management |
| 4. Backup & Snapshots | Not Started | 0 | 21 | 0% | ⚪ Snapshot Management<br>⚪ Backup Status |
| 5. UI Polish | Not Started | 0 | 18 | 0% | ⚪ UI Refinements<br>⚪ Performance |
| 6. Release Prep | Not Started | 0 | 16 | 0% | ⚪ Testing<br>⚪ Documentation |

**Legend**:
- ⚪ Not Started
- 🟡 In Progress
- 🟢 Complete
- 🔴 Blocked

**Overall Progress**: 5/115 Points (4%)

## Overview
This document outlines the implementation schedule for TMBM V1, organized into 2-week sprints. Each task is assigned story points (1-5) based on complexity and effort:
- 1 point: Simple task, can be completed in a few hours
- 2 points: Straightforward task, about a day's work
- 3 points: Complex task, may take 2-3 days
- 5 points: Major feature, requires significant effort

## External Dependencies & Required Assets

### 1. Application Assets
#### 1.1 Application Icon
- **Required By**: Sprint 1, Task 2 (Splash Screen)
- **Specifications**:
  - macOS ICNS format
  - Sizes required: 16x16, 32x32, 64x64, 128x128, 256x256, 512x512, 1024x1024
  - Both @1x and @2x (Retina) versions
  - Style: Should match macOS design guidelines
  - Format: PNG source files + compiled ICNS
  - Deadline: Before Sprint 1 starts

#### 1.2 Menu Bar Icons
- **Required By**: Sprint 1, Task 5 (Basic Menu Bar Integration)
- **Specifications**:
  - Template images (single color, transparency supported)
  - Sizes: 16x16, 32x32 (@1x and @2x)
  - States needed:
    - Normal (idle)
    - Backup in progress
    - Warning/Error
    - Paused
  - Format: PDF or PNG
  - Deadline: Before Sprint 1, Task 5

#### 1.3 Splash Screen Design
- **Required By**: Sprint 1, Task 2 (Splash Screen)
- **Specifications**:
  - Size: 800x600 or 16:9 ratio
  - Format: PNG/PDF with separate layers for:
    - Background
    - Logo
    - Loading indicator area
  - Dark/Light mode versions
  - Deadline: Before Sprint 1, Task 2

### 2. UI Design Assets
#### 2.1 Snapshot View Icons
- **Required By**: Sprint 4, Task 4 (Snapshot UI Implementation)
- **Specifications**:
  - Action icons: delete, info, restore
  - Size: 16x16, 20x20 (@1x and @2x)
  - Style: SF Symbols compatible
  - Format: PDF or PNG
  - Deadline: Before Sprint 4

#### 2.2 Status Indicators
- **Required By**: Sprint 2, Task 4 (Status Updates Integration)
- **Specifications**:
  - Status icons for:
    - Success
    - Failure
    - In Progress
    - Warning
  - Size: 12x12, 16x16 (@1x and @2x)
  - Format: PDF or PNG
  - Style: Should match system status indicators
  - Deadline: Before Sprint 2, Task 4

### 3. Documentation Resources
#### 3.1 User Guide Graphics
- **Required By**: Sprint 5, Task 7 (Documentation Finalization)
- **Specifications**:
  - Screenshot templates
  - Annotation styles
  - Icon usage guidelines
  - Format: Sketch/Figma/PDF
  - Deadline: Before Sprint 5

### 4. Development Resources
#### 4.1 Test Data
- **Required By**: Throughout development
- **Specifications**:
  - Sample backup bundles
  - Various snapshot configurations
  - Network mount test scenarios
  - Deadline: Before respective feature implementation

#### 4.2 Development Certificates
- **Required By**: Sprint 1
- **Specifications**:
  - Apple Developer Program membership
  - Development certificates
  - Provisioning profiles
  - Deadline: Before Sprint 1

### 5. Design Specifications
#### 5.1 UI/UX Guidelines
- **Required By**: Throughout development
- **Specifications**:
  - Color palette (Light/Dark mode)
  - Typography specifications
  - Layout grids
  - Component library
  - Animation specifications
  - Accessibility guidelines
  - Deadline: Before Sprint 1

#### 5.2 Interaction Patterns
- **Required By**: Sprint 2 onwards
- **Specifications**:
  - Menu bar interaction flows
  - Window management behaviors
  - Notification patterns
  - Error state handling
  - Loading state specifications
  - Deadline: Before Sprint 2

### Asset Delivery Guidelines
1. All assets should be provided in both light and dark mode versions where applicable
2. Vector formats preferred for scalable assets
3. Include source files for future modifications
4. Provide clear naming conventions for all assets
5. Include documentation for any special rendering requirements
6. Accessibility considerations must be documented

### Version Control
- All assets should be stored in a designated assets folder in the repository
- Asset updates should be tracked with version numbers
- Changes to assets should be documented in the repository

## Sprint 1: Core Infrastructure & Window Management
**Focus**: Basic application structure and window handling
**Duration**: 2 weeks
**Total Points**: 21

### Tasks
1. [3] Set up WindowCoordinator base implementation
   - Implement window persistence
   - Add application switcher registration
   - Basic window state management

2. [2] Create SplashScreenController
   - Basic splash screen UI
   - Loading state handling

3. [3] Implement AppLifecycleCoordinator
   - Application state management
   - Launch sequence coordination
   - Basic error handling

4. [2] Window State Persistence
   - Save/restore window position
   - Handle multiple displays

5. [2] Basic Menu Bar Integration
   - Persistent menu bar item
   - Basic status display

6. [3] Application Switcher Integration
   - Proper Alt+Tab behavior
   - Window z-index management

7. [2] Window Management Testing
   - Unit tests for window coordination
   - Basic integration tests

8. [2] Initial CI/CD Setup
   - Basic build pipeline
   - Automated testing framework

### Deliverables
- Functional window management
- Basic menu bar presence
- Initial test framework
- Working CI/CD pipeline

## Sprint 2: Menu Bar & Notifications
**Focus**: Enhanced menu bar functionality and notification system
**Duration**: 2 weeks
**Total Points**: 18

### Tasks
1. [3] Enhanced Menu Bar Manager
   - Persistent presence across app lifecycle
   - Right-click menu implementation
   - Quick actions menu

2. [3] Menu Bar View Model
   - Status updates
   - Action handlers
   - State management

3. [3] Desktop Notifications Service
   - Basic notification infrastructure
   - Permission handling
   - Notification preferences

4. [2] Status Updates Integration
   - Menu bar icon states
   - Status message handling

5. [2] Notification Types Implementation
   - Backup completion notifications
   - Error notifications
   - Network status notifications

6. [3] Menu Bar & Notifications Testing
   - Unit tests for notifications
   - Menu bar interaction tests
   - Integration tests

7. [2] Documentation Update
   - Menu bar usage documentation
   - Notification preferences guide

### Deliverables
- Complete menu bar functionality
- Working notification system
- Updated documentation
- Test coverage for new features

## Sprint 3: Network Mount & Storage Management
**Focus**: Network functionality and storage handling
**Duration**: 2 weeks
**Total Points**: 21

### Tasks
1. [5] Network Mount Handler Implementation
   - Mount status detection
   - Reachability checking
   - Auto-remount functionality

2. [3] Network Environment Management
   - Network change monitoring
   - Connection state handling
   - Error recovery

3. [3] Storage Quota Management
   - Quota reading
   - Quota modification
   - Size impact calculation

4. [3] Bundle Resizing Implementation
   - Size calculation
   - Resize operation
   - Progress monitoring

5. [3] Network & Storage Testing
   - Mount handling tests
   - Quota management tests
   - Network error scenarios

6. [2] Error Handling & Recovery
   - Network error handling
   - Operation retry logic
   - User feedback

7. [2] Performance Optimization
   - Network operation optimization
   - Resource usage monitoring

### Deliverables
- Complete network mount handling
- Storage quota management
- Comprehensive error handling
- Performance metrics

## Sprint 4: Backup & Snapshot Management
**Focus**: Enhanced backup features and snapshot handling
**Duration**: 2 weeks
**Total Points**: 21

### Tasks
1. [5] Snapshot Management Implementation
   - Snapshot listing
   - Deletion support
   - Dependency tracking

2. [3] Backup Status Enhancement
   - Success/failure tracking
   - Progress monitoring
   - Health metrics

3. [3] Current Machine Identification
   - Machine detection
   - Backup highlighting
   - State persistence

4. [3] Snapshot UI Implementation
   - Snapshot list view
   - Detail view
   - Action handlers

5. [3] Backup Health Monitoring
   - Status tracking
   - Warning generation
   - Health metrics display

6. [2] Testing & Validation
   - Snapshot management tests
   - Backup status tests
   - UI integration tests

7. [2] Documentation
   - Feature documentation
   - API documentation update

### Deliverables
- Complete snapshot management
- Enhanced backup status tracking
- Updated documentation
- Comprehensive test coverage

## Sprint 5: UI Polish & Performance
**Focus**: UI refinement and performance optimization
**Duration**: 2 weeks
**Total Points**: 18

### Tasks
1. [3] UI Polish
   - Animation refinement
   - Layout improvements
   - Accessibility enhancements

2. [3] Performance Optimization
   - Background operation optimization
   - Memory usage improvement
   - Response time enhancement

3. [3] Resource Management
   - Cache implementation
   - Resource cleanup
   - Memory monitoring

4. [2] Error Handling Enhancement
   - Error message improvement
   - Recovery mechanisms
   - User feedback

5. [2] Logging & Diagnostics
   - Enhanced logging
   - Diagnostic tools
   - Debug information

6. [3] Final Testing
   - Performance testing
   - Stress testing
   - Edge case validation

7. [2] Documentation Finalization
   - User guide completion
   - API documentation finalization
   - Release notes preparation

### Deliverables
- Polished UI
- Optimized performance
- Complete documentation
- Final test coverage

## Sprint 6: Final Integration & Release Preparation
**Focus**: Integration testing and release preparation
**Duration**: 2 weeks
**Total Points**: 16

### Tasks
1. [3] Integration Testing
   - End-to-end testing
   - Cross-feature testing
   - Environment testing

2. [3] Bug Fixing
   - Known issue resolution
   - Edge case handling
   - Performance issues

3. [2] Release Preparation
   - Version finalization
   - Release notes
   - Installation package

4. [2] Documentation Review
   - Document verification
   - Example updates
   - Troubleshooting guide

5. [3] User Acceptance Testing
   - Feature validation
   - Usability testing
   - Feedback incorporation

6. [3] Final Release Tasks
   - Code signing
   - Package notarization
   - Distribution preparation

### Deliverables
- Release candidate
- Complete documentation
- Installation package
- Release notes

## Total Project Summary
- Duration: 12 weeks (6 sprints)
- Total Story Points: 115
- Major Milestones:
  1. Core Infrastructure (Sprint 1)
  2. Menu Bar & Notifications (Sprint 2)
  3. Network & Storage (Sprint 3)
  4. Backup & Snapshots (Sprint 4)
  5. UI & Performance (Sprint 5)
  6. Release (Sprint 6)

## Progress Tracking
- Sprint burndown charts
- Story point velocity tracking
- Feature completion status
- Test coverage metrics

## Risk Management
- Technical risks tracked per sprint
- Dependency management
- Resource allocation monitoring
- Timeline adjustment protocol

## Update Process
1. Update story points as tasks are completed
2. Track actual vs. estimated time
3. Adjust subsequent sprint planning based on velocity
4. Document lessons learned for future planning 