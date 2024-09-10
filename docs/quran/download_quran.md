## Overview

This module provides functionality for downloading the Quran onto a device. Users can choose between two different Quran versions: Warsh and Hafs.

## User Stories

- **User Story**: As a user, I can choose between Warsh and Hafs Quran versions to download and have them available on my device.

## Requirements

### Functional Requirements

- **Download Hafs**: Users can download the Hafs Quran version.
- **Download Warsh**: Users can download the Warsh Quran version.
- **Extract SVGs**: Extract SVG files for both Warsh and Hafs versions.
- **Delete Zip Files**: Delete the downloaded zip file for either Warsh or Hafs versions.
- **Check for Updates**: Check for updates in the Quran versions.

### Non-Functional Requirements

- **Reliability**: Ensure reliable download and extraction processes.
- **Performance**: Maintain performance and responsiveness during downloads and updates.
- **Graceful Cancellation**: Handle download cancellations gracefully.

### Design

### Flow Diagram

the feature flow 
![](https://i.imgur.com/L0Q2Cfq.png)


## Implementation

### Dependencies

- **Path**
- **Dio**
- **Flutter Riverpod**
- **Shared Preferences**
- **Path Provider**

### API Endpoints

#### Download Warsh
- **GET**: `https://mawaqit.github.io/mawaqit-announcements/public/quran/v1.0.0.zip`

#### Check for Version and Update for Warsh
- **GET**: `https://mawaqit.github.io/mawaqit-announcements/public/quran/config.json`

### Layers

#### Data Layer

##### DownloadQuranRemoteDataSource

**Overview**: Handles downloading the Quran with progress tracking, extraction, download cancellation, and fetching the Quran version from a remote source.

**Methods**:
- **getRemoteQuranVersion**: Fetches the Quran version from the API JSON.
- **downloadQuranWithProgress**: Downloads the zip file and extracts it into the specified folder based on the Quran version (Warsh or Hafs).
- **cancelDownload**: Cancels or interrupts the Quran download.

##### DownloadQuranLocalDataSource

**Overview**: Manages local storage operations for the Quran, including retrieving the local Quran version, deleting zip files, and saving SVG files.

**Methods**:
- **saveSvgFiles**: Saves the SVG files to the directory corresponding to the Quran version.
- **deleteZipFile**: Deletes the downloaded zip file from the local storage.
- **getQuranVersion**: Retrieves the local Quran version from shared preferences.

##### State Management

#### DownloadQuranNotifier

**Overview**: Manages the state of the UI during Quran download, extraction, and update checks for both Warsh and Hafs versions.

**Methods**:
- **checkForUpdate**: Checks for updates using the data layer. If a local version is saved, it checks if the remote version is newer and triggers an update if necessary.
- **download**: Initiates the download process based on the Quran version. Handles the path and URL via the download method in the data class.
- **cancelDownload**: Calls the cancel method to stop the download process with an exception.
#### Repository Layer

##### QuranDownloadRepositoryImpl

**Overview**: Implements the repository interface to handle operations related to downloading and managing the Quran data both locally and remotely.

**Methods**:
- **getLocalQuranVersion**: Fetches the local Quran version.
- **downloadQuran**: Downloads the Quran zip file, extracts it, and updates the local storage.
- **deleteOldQuran**: Deletes old Quran files from the local storage.
- **getRemoteQuranVersion**: Fetches the remote Quran version.
- **cancelDownload**: Cancels the ongoing Quran download.

## Summary

The Quran Download module provides a comprehensive solution for downloading, extracting, and managing Quran files on a device. It supports two versions of the Quran (Warsh and Hafs), ensuring users can choose their preferred version. The module handles downloading with progress tracking, checks for updates, and provides seamless state management to ensure a smooth user experience.

This documentation outlines the functional and non-functional requirements, design considerations, and the structure of the implementation without delving into the code specifics. For developers, this provides a clear understanding of the module's capabilities and integration points.

---- 

Author: Yassin Hashem
Date: 16/6/2024