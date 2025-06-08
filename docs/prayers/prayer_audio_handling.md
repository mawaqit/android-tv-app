
# Prayer Audio Handling

## Table of Contents

- [Core Concepts](#core-concepts)

- [Architecture](#architecture)

- [State Management Flow](#state-management-flow)

- [Error Handling](#error-handling)

- [UI Integration](#ui-integration)

- [Screen Implementation Patterns](#screen-implementation-patterns)

- [Adhan Screen Pattern](#adhan-screen-pattern)

- [After-Adhan Screen Pattern](#after-adhan-screen-pattern)

- [Iqama Screen Pattern](#iqama-screen-pattern)

- [Technical Implementation](#technical-implementation)

  

This document explains how prayer audio (Adhan, Iqama, and post-prayer Dua) is managed in the Mawaqit app using Riverpod's AsyncNotifier pattern for robust state handling.

  

## Core Concepts

  

The Prayer Audio system is built on these key concepts:

  

1. **AsyncValue-based States**: Leveraging Riverpod's AsyncValue to properly track loading, success, and error states

2. **ProcessingState Integration**: Using JustAudio's ProcessingState for detailed audio playback status

3. **Class-based Error Handling**: Structured error classes for consistent error handling

4. **UI State Simplification**: Abstracting complex state into simplified UI models

  

## Architecture

  

The prayer audio system follows a layered architecture:

  

```mermaid

graph TD

A[UI Screens] --> B[PrayerAudioUIState]

B --> C[PrayerAudioProvider]

C --> D[PrayerAudioState]

C --> E[JustAudio Player]

C --> F[PrayerAudioExceptions]

class B,C provider

class D,F state

class E external

```

  

The key components are:

  

- **PrayerAudioState**: Core data model with processingState and duration

- **PrayerAudioNotifier**: AsyncNotifier managing audio logic and state transitions

- **PrayerAudioUIState**: Simplified model for UI consumption with AudioStatus enum

- **PrayerAudioExceptions**: Structured error classes for different error scenarios

  

## State Management Flow

  

The audio state flows through these stages:

  

```mermaid

stateDiagram-v2

[*] --> Idle

Idle --> Loading: playAdhan/playIqama/playDua

Loading --> Playing: setSource success

Loading --> Error: setSource failure

Playing --> Completed: playback finished

Playing --> Error: playback error

Playing --> Idle: stop()

Error --> Idle: retry/reset

Completed --> Idle: reset

```

  

### AudioStatus to ProcessingState Mapping

  

```mermaid

graph LR

A[AsyncLoading] --> B[AudioStatus.loading]

C[ProcessingState.loading] --> B

D[ProcessingState.buffering] --> B

E[ProcessingState.idle] --> F[AudioStatus.idle]

G[ProcessingState.ready] --> H[AudioStatus.playing]

I[ProcessingState.completed] --> J[AudioStatus.completed]

K[AsyncError] --> L[AudioStatus.error]

```

  

## Error Handling

  

Error handling uses a class hierarchy for structured error management:

  

```mermaid

classDiagram

Exception <|-- PrayerAudioException

PrayerAudioException <|-- PlayAdhanException

PrayerAudioException <|-- PlayIqamaException

PrayerAudioException <|-- PlayDuaException

PrayerAudioException <|-- AudioInitializationTimeoutException

PrayerAudioException <|-- UnknownPrayerAudioException

class PrayerAudioException {

+String message

+String errorCode

+toString()

}

class PlayAdhanException {

+PlayAdhanException(String message)

}

class PlayIqamaException {

+PlayIqamaException(String message)

}

class PlayDuaException {

+PlayDuaException(String message)

}

class AudioInitializationTimeoutException {

+AudioInitializationTimeoutException(String message)

}

class UnknownPrayerAudioException {

+UnknownPrayerAudioException(String message)

}

```

  

## UI Integration

  
## Screen Implementation Patterns

  

### Adhan Screen Pattern

  

The key pattern for Adhan playback screens:

  

```mermaid

graph TD

A[Initialize] --> B[Start playback]

B --> C[Start fallback timer]

B --> D{Listen for status changes}

D -->|Completed| E[Close screen]

D -->|Error| F[Log error]

F --> G[Let fallback timer handle closure]

C -->|5 min timeout| E

```

  

### After-Adhan Screen Pattern

  

The after-Adhan pattern includes a minimum display time:

  

```mermaid

graph TD

A[Initialize] --> B[Start playback]

B --> C[Start minimum time timer]

B --> D{Listen for status changes}

D -->|Completed| E{Minimum time elapsed?}

E -->|Yes| F[Close screen]

E -->|No| G[Wait for timer]

G --> F

D -->|Error| H[Log error]

H --> I[Let timer handle closure]

C -->|Min time elapsed| J{Audio completed?}

J -->|Yes| F

J -->|No| K[Wait for completion]

```

  

### Iqama Screen Pattern

  

The simpler Iqama screen pattern:

  

```mermaid

graph TD

A[Initialize] --> B{Iqama bip enabled?}

B -->|Yes| C[Play bip sound]

B -->|No| D[Display visual only]

C --> E{Monitor for errors}

E -->|Error| F[Log error]

E -->|Success| G[Continue displaying screen]

D --> G

```

  

## Technical Implementation

  
