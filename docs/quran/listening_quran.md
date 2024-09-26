## Overview

The Quran Listening feature allows users to listen to Quran recitations from various reciters. It provides functionality to select reciters, choose specific Surahs, and manage the playback of Quran audio.

## User Stories

- As a user, I can browse and select from a list of Quran reciters.
- As a user, I can choose a specific Surah to listen to.
- As a user, I can switch between different reciters and their Riwayat type.

## Requirements

### Functional Requirements

- **Reciter Selection**: Users can browse and select from a list of Quran reciters.
- **Surah Selection**: Users can choose specific Surahs to listen to.
- **Moshaf Selection**: Users can select different Moshaf versions for each reciter.
- **Language Support**: Support for multiple languages in reciter and Surah information.

### Non-Functional Requirements

- **Performance**: Quick loading of reciter and Surah lists.
- **Reliability**: Stable playback of Quran audio.
- **User Experience**: Intuitive interface for selecting reciters and Surahs.
- **Data Management**: Efficient storage and retrieval of reciter and Surah data.

### Flow Diagram
[![](https://mermaid.ink/img/pako:eNptk1FvmzAQx7-K5WcSFUgh4WFVGpI2LUmrsk7aIA9X2xmogCNsqmYk332uDU0zzU8-3-_-d2efW0w4ZTjAv2vYZeh7mFZIrWkSS6jlBg0G39B1u6wkqysm0fQN8gJeCnZ1NOD1B3H4ycQBzZIFkyRDT4zkChdoW_NSWSWXbPOVXvMDCpOIA_2HjTiBAs2AZH3ATBcwb41y3BDChNg2RZ9-fkq_SGJ4YydFyf-jNz8VYA4WOsFNEuZiV8C-D0dRLmQXExrEGDfauE2ehYJiVjAiRR_U8bcaWZoGV1xksEU_VEU5r0SHLDVyd65i0I6408S9EYmbGjJ1R7yHGT2n7zUdfXahA772EGlgdZ5QUx2w0sC6e8JpQ3OOnp-izrvW3gczFOhRpXgB8to5H7TzMZlXdIMtXLK6hJyqkWo__CmWGStZigO1pVC_pjitjoqDRvJ4XxEcyLphFm52FCQLc1CTWOJgC4VQpzuofnFe9pAycdDidxzYnjccqeVcXvpjzx47Ft7jYGC7njMceY7j2CPX9Se-d7TwH63gDF1v5Fz4k7F7YXsTzx9bmNFc8nplvoD-Cce_Y67v3g?type=png)](https://mermaid.live/edit#pako:eNptk1FvmzAQx7-K5WcSFUgh4WFVGpI2LUmrsk7aIA9X2xmogCNsqmYk332uDU0zzU8-3-_-d2efW0w4ZTjAv2vYZeh7mFZIrWkSS6jlBg0G39B1u6wkqysm0fQN8gJeCnZ1NOD1B3H4ycQBzZIFkyRDT4zkChdoW_NSWSWXbPOVXvMDCpOIA_2HjTiBAs2AZH3ATBcwb41y3BDChNg2RZ9-fkq_SGJ4YydFyf-jNz8VYA4WOsFNEuZiV8C-D0dRLmQXExrEGDfauE2ehYJiVjAiRR_U8bcaWZoGV1xksEU_VEU5r0SHLDVyd65i0I6408S9EYmbGjJ1R7yHGT2n7zUdfXahA772EGlgdZ5QUx2w0sC6e8JpQ3OOnp-izrvW3gczFOhRpXgB8to5H7TzMZlXdIMtXLK6hJyqkWo__CmWGStZigO1pVC_pjitjoqDRvJ4XxEcyLphFm52FCQLc1CTWOJgC4VQpzuofnFe9pAycdDidxzYnjccqeVcXvpjzx47Ft7jYGC7njMceY7j2CPX9Se-d7TwH63gDF1v5Fz4k7F7YXsTzx9bmNFc8nplvoD-Cce_Y67v3g)
### Flow of Operations

Based on the updated flow diagram, here's the revised Flow of Operations for the Quran Listening feature:

1. Application startup
   a. Check for internet connectivity

2. Load Reciters
   a. If internet is available:
      i. Attempt to fetch reciters from the remote source
      ii. If successful, save reciters to local cache
      iii. If unsuccessful, proceed to step 2b
   b. If no internet or remote fetch failed:
      i. Load reciters from local cache

3. Display Reciter List
   a. Present the user with a list of available reciters

4. User Selects a Reciter
   a. Handle user interaction to choose a specific reciter

5. Load Moshaf Versions
   a. Fetch and display the available Moshaf versions for the selected reciter

6. User Selects a Moshaf Version
   a. Handle user interaction to choose a specific Moshaf version

7. Load Surahs for Selected Moshaf
   a. Fetch and prepare the list of Surahs available for the chosen Moshaf version

8. Display Surah List
   a. Present the user with a list of available Surahs for the selected Moshaf

9. User Selects a Surah
   a. Handle user interaction to choose a specific Surah

10. Fetch Audio URL
    a. Retrieve the audio URL for the selected Surah and Moshaf version

11. Start Playback
    a. Begin playing the audio for the selected Surah
### Dependencies

- **Dio**: For making HTTP requests
- **Flutter Riverpod**: For state management
- **Hive**: For local data storage
- **Path Provider**: For accessing device file system
- **Flutter SVG**: For rendering SVG images

## Layers

### Data Layer

#### ReciteRemoteDataSource

**Overview**: Handles fetching reciter data from the remote API.

**Methods**:
- **getReciters**: Fetches the list of reciters from the API.
- **_fetchReciters**: Internal method to fetch and parse reciter data.
- **_convertSurahListToIntegers**: Internal method to convert the list of the surah that comes from the api in form of string into int.
#### ReciteLocalDataSource

**Overview**: Manages local storage of reciter and Surah data.

**Methods**:
- **saveRecitersBySurah**: Saves reciters for a specific Surah.
- **saveReciters**: Saves all reciters.
- **getReciters**: Retrieves all saved reciters.
- **getReciterBySurah**: Retrieves reciters for a specific Surah.
- **clearAllReciters**: Clears all stored reciter data.
- **isRecitersCached**: Checks if reciters are cached locally.

### Repository Layer

#### ReciteRepository (Abstract)

**Overview**: Defines the interface for reciter-related operations.

**Methods**:
- **getRecitersBySurah**: Retrieves reciters for a specific Surah.


#### ReciteImpl

**Overview**: Implements the ReciteRepository interface.

**Methods**:
- **getRecitersBySurah**: Fetches reciters for a specific Surah, with local caching.
- **getAllReciters**: Fetches all reciters, with local caching.

### State Management Layer

#### ReciteState

**Overview**: Represents the state of the Quran listening feature.

**Properties**:
- **reciters**: List of available reciters.
- **selectedReciter**: Currently selected reciter.
- **selectedMoshaf**: Currently selected Moshaf version.

**Methods**:
- **copyWith**: Creates a new state object with optional updated properties.

#### ReciteNotifier

**Overview**: Manages the state and business logic for the Quran listening feature.

**Methods**:
- **getRecitersBySurah**: Fetches reciters for a specific Surah.
- **getAllReciters**: Fetches all available reciters.
- **setSelectedReciter**: Updates the selected reciter.
- **setSelectedMoshaf**: Updates the selected Moshaf version.

## Key Features

- Multiple reciter support with various Moshaf versions
- Surah-specific reciter selection
- Offline caching of reciter and Surah data
- Multi-language support for reciter and Surah information
- Integration with the overall Quran feature set (reading and listening modes)

---

Author: Yassin Hashem
Date: July 16, 2024