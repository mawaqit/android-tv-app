## Overview

This module provides functionality for reading and listening to the Quran on a device. navigate pages, and switch between reading and listening modes.

## User Stories

- As a user, I can choose between Warsh and Hafs Quran versions to read on my device. [ Future release]
- As a user, I can switch between pages of the Quran.
- As a user, I can choose a specific page to navigate to from a grid view.
- As a user, I can switch between reading mode and listening mode.
- As a user, I can resume reading from the last page I visited when I return to the Quran reader.

## Requirements

### Functional Requirements

- **Download Quran Versions**: Users can download Warsh and Hafs Quran versions.
- **Page Navigation**: Implement page switching and specific page selection.
- **Mode Switching**: Allow users to switch between reading and listening modes.
- **SVG Rendering**: Load and display Quran pages using SVG format.
- **Progress Saving**: Automatically save and restore the last visited page.

### Non-Functional Requirements

- **Reliability**: Ensure reliable download, extraction, and page loading processes.
- **Performance**: Maintain app responsiveness during downloads, updates, and page navigation.
- **User Experience**: Implement intuitive navigation and mode-switching interface.
- **Offline Functionality**: Ensure features work offline once content is downloaded.
- **Storage Optimization**: Efficiently manage storage for downloaded Quran versions.
### Design

### Flow Diagram

[![](https://mermaid.ink/img/pako:eNp1Ultv2jAU_iuWnykiQMjlYVObtEDbobaMSVvCg4UPYDWxI9tBtMB_n2OnarZpfkq-m3U-nxPeCAo4xjtJqj36nuYcmXOdzTnTjBTsHdBzLQl_AUIZ3y2EZlsGco2urr6gm-xREIqWP6YKEU7RI1EaNUr0RHawdlk3VppkiQSiAbXBf6QutWFaeWLlabZSII1YgyQbzQRv6dTSt6drC369OPS2Qc8LOGp78xndZckeNq-IbRFv0MqgCI5MabXuWp4kHJioVWubftqqD-Z_1lVFm3mccdYxNnqm0MG0R1vHnXX8BHVG86w1qmZoW5siB0BF051suqs-u5t2fA6Z_YO47IU4o7Rr6gCzv4G5LfE-64yQCK6lKArztE5zbzUP2Qtwal7CSSlazVv-wb0T7uESZEkYNUt0aqgc6z2UkOPYfFIiX3Oc84vRkVqL5Rvf4FjLGnq4tpEpI2b3ShxvSaEMWhH-S4jyQ2R-cXzCRxx7kdcP_ckg8EfeOPSjIOjhNxwH_XA4Gg0mw8AbR8NwEl56-N0GeP2BO54_9qLxKPJ7GCjTQn5zO29X__IbQMjtpw?type=png)](https://mermaid.live/edit#pako:eNp1Ultv2jAU_iuWnykiQMjlYVObtEDbobaMSVvCg4UPYDWxI9tBtMB_n2OnarZpfkq-m3U-nxPeCAo4xjtJqj36nuYcmXOdzTnTjBTsHdBzLQl_AUIZ3y2EZlsGco2urr6gm-xREIqWP6YKEU7RI1EaNUr0RHawdlk3VppkiQSiAbXBf6QutWFaeWLlabZSII1YgyQbzQRv6dTSt6drC369OPS2Qc8LOGp78xndZckeNq-IbRFv0MqgCI5MabXuWp4kHJioVWubftqqD-Z_1lVFm3mccdYxNnqm0MG0R1vHnXX8BHVG86w1qmZoW5siB0BF051suqs-u5t2fA6Z_YO47IU4o7Rr6gCzv4G5LfE-64yQCK6lKArztE5zbzUP2Qtwal7CSSlazVv-wb0T7uESZEkYNUt0aqgc6z2UkOPYfFIiX3Oc84vRkVqL5Rvf4FjLGnq4tpEpI2b3ShxvSaEMWhH-S4jyQ2R-cXzCRxx7kdcP_ckg8EfeOPSjIOjhNxwH_XA4Gg0mw8AbR8NwEl56-N0GeP2BO54_9qLxKPJ7GCjTQn5zO29X__IbQMjtpw)

### Flow of Operations

1. The QuranReadingNotifier is initialized, which triggers the build method.
2. The build method calls _initState, which:
   a. Loads SVGs using the repository.
   b. Retrieves the last read page from the repository.
   c. Creates a new QuranReadingState with the loaded data.
3. User interactions (next page, previous page, or update page) trigger corresponding methods in QuranReadingNotifier.
4. These methods update the state and save the last read page using the repository.
5. The UI reacts to state changes and updates accordingly.

### Dependencies

- **Path**
- **Dio**
- **Flutter Riverpod**
- **Shared Preferences**
- **Path Provider**

### Layers

#### Data Layer

##### QuranReadingLocalDataSource

**Overview**: Handles local data operations for the Quran reading feature, including managing the last read page and loading SVG files.

**Methods**:
- **getLastReadPage**: Retrieves the last read page from SharedPreferences.
- **saveLastReadPage**: Saves the last read page to SharedPreferences.
- **loadAllSvgs**: Loads all SVG files from the local storage.
- **_loadSvg**: (private) Loads a single SVG file.

#### Repository Layer

##### QuranReadingRepository (Abstract)

**Overview**: Defines the interface for Quran reading operations.

**Methods**:
- **getLastReadPage**: Retrieves the last read page.
- **saveLastReadPage**: Saves the last read page.
- **loadAllSvgs**: Loads all SVG files for the Quran.

##### QuranReadingRepositoryImpl (Implied)

**Overview**: Implements the QuranReadingRepository interface, bridging the data layer with the state management.

**Methods**:
- **getLastReadPage**: Retrieves the last read page from the local data source.
- **saveLastReadPage**: Saves the last read page using the local data source.
- **loadAllSvgs**: Loads all SVG files using the local data source.

#### State Management Layer

##### QuranReadingState

**Overview**: Represents the state of the Quran reading feature.

**Properties**:
- **currentJuz**: Current Juz number.
- **currentSurah**: Current Surah number.
- **currentPage**: Current page number.
- **svgs**: List of SVG pictures for Quran pages.
- **pageController**: Controller for page navigation.

**Methods**:
- **copyWith**: Creates a new state object with optional updated properties.

##### QuranReadingNotifier

**Overview**: Manages the state and business logic for the Quran reading feature.

**Methods**:
- **build**: Initializes the state.
- **nextPage**: Navigates to the next page.
- **previousPage**: Navigates to the previous page.
- **updatePage**: Updates the current page to a specific number.
- **_loadSvgs**: (private) Loads all SVG files.
- **_initState**: (private) Initializes the state with data from the repository.
- **_saveLastReadPage**: (private) Saves the last read page.

### Key Features

- Persistent storage of the last read page.
- Loading and caching of SVG files for Quran pages.
- Smooth navigation between pages with animation.
- State management using Riverpod for reactive updates.

---- 

Author: Yassin Hashem
Date: 16/7/2024