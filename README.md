# Tajweed Quran Mushaf Generator

A Flutter desktop application designed to generate high-quality, print-ready HTML files of the Quran Mushaf with Tajweed color coding. The generated HTML is optimized for conversion to PDF using browser print functionality, supporting various page sizes and translation options.

## Screenshots

|                     Application UI                     |                       Generated Page Result                       |
| :----------------------------------------------------: | :---------------------------------------------------------------: |
| <img src="screenshots/app-screenshot.png" width="400"> | <img src="screenshots/generated-page-screenshot.png" width="400"> |

> **Note**: The core HTML generation logic and CSS layout strategies in this project were primarily developed using AI models.

## ⚠️ Disclaimer & User Responsibility

**This software is a tool for generating layouts, but it does not guarantee perfection in every scenario.**

Users are **solely responsible** for verifying the final output, including but not limited to:

- **Text Accuracy**: Ensuring Quranic text and translations are correct and have not been altered during generation.
- **Layout Integrity**: Checking for text overflowing, clipping, overlapping, or missing content, especially when using long translations or small page sizes.
- **Formatting**: Verifying that margins, page breaks, and font rendering are correct for the intended print medium.

**Always review every page of the generated HTML/PDF before printing or distribution.**

## Features

- **Tajweed Color Coding**: Precise character-level coloring for Tajweed rules:

  - 🟢 **LAFZATULLAH** (Allah's name) - Green
  - 🔵 **Izhar** - Cyan
  - 🔴 **Ikhfaa** - Red
  - 🩷 **Idgham with Ghunna** - Pink
  - ⚪ **Idgham without Ghunna** - Gray
  - 🔵 **Iqlab** - Blue
  - 🟢 **Qalqala** - Olive
  - 🟠 **Ghunna** - Orange
  - 🟣 **Madd (Prolonging)** - Purple

- **Flexible Page Formats**:

  - **Sizes**: A3, A4, B5, A5.
  - **Margins**: Configurable gutter margins for RTL book binding (odd/even page alternation).

- **Translation Support**:

  - **Side-column Translation**: Fetches translations from QuranEnc API or local JSON files.
  - **Word-by-Word (WBW)**: Interlinear translation support (e.g., English, Turkish, Indonesian) sourced from CSV.
  - **Compact Mode**: Automatically switches to inline translation layout for dense pages to prevent overflow.

- **Print Optimization**:
  - **Vector-like Quality**: Uses embedded Base64 fonts (Kitab) for consistent rendering across all devices.
  - **CSS Paged Media**: Handles page breaks, cover pages, and empty filler pages for double-sided printing.

## Developer Configuration

### Adjusting for Translations

Different languages have vastly different text lengths (e.g., English vs. Indonesian vs. Turkish).

**You must adjust `PageSize` values if using verbose languages or different fonts:**

1.  Open `lib/mushaf_page_config.dart`.
2.  Locate the `PageSize` enum (A4, A5, etc.).
3.  Tweak the parameters to fit your content.

> **Tip**: If pages are overflowing (content cut off at the bottom), try reducing `translationFontSize` or increasing `translationCompactThreshold`.

## How It Works

1.  **Data Source**:

    - `qpc-v4-tajweed-15-lines.db`: SQLite DB containing the 15-line Madani layout coordinates.
    - `uthmani.db`: SQLite DB containing the Uthmani text and word metadata.
    - `wbw-words.csv`: CSV file containing word-by-word translations.

2.  **Processing**:

    - **Tokenization**: `MushafWordMapper` maps database words to pre-computed Tajweed tokens (`cached_tajweed_tokens.dart`).
    - **Layout**: `MushafHtmlGenerator` builds the DOM, applying CSS classes for colors and layout based on the selected `PageSize`.

3.  **Output**:
    - Generates a single HTML file in the user's Documents folder.
    - The file embeds all necessary assets (fonts, styles), making it portable.

## Usage

1.  **Run the App**:

    ```bash
    flutter pub get
    flutter run -d macos  # or windows/linux
    ```

2.  **Configure Generation**:

    - **Page Range**: Select start and end pages (1-604).
    - **Translation**: Toggle side translation and select source.
    - **Word-by-Word**: Toggle interlinear translation and select language.
    - **Page Size**: Choose the target paper format.

3.  **Generate & Print**:
    - Click "Generate HTML".
    - Open the resulting file in a browser (Chrome/Safari/Edge/Firefox).
    - **Print to PDF**:
      - Layout: Portrait.
      - Margins: None (CSS handles margins).
      - **Options**: Enable "Background graphics".

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── mushaf_preview_screen.dart   # Main UI
├── mushaf_html_generator.dart   # Core HTML/CSS engine
├── mushaf_page_config.dart      # Page sizes & layout configuration
├── mushaf_wbw_service.dart      # WBW CSV parser & cache
├── mushaf_word_mapper.dart      # DB word to Tajweed token mapper
├── mushaf_db_reader.dart        # SQLite interaction
├── quran_enc_translation_service.dart # API client for translations
├── local_translation_service.dart     # Local JSON translation reader
└── cached_tajweed_tokens.dart   # Large dataset of Tajweed rules
```

## Requirements

- **Flutter SDK**: >=3.0.0
- **Desktop Platform**: macOS, Windows, or Linux (Mobile is not supported due to `sqflite_common_ffi` usage).
- **Assets**: Ensure `resources/` contains the required SQLite databases.

## Data Integrity

The application implements strict bounds checking. If a word in the database does not match the expected Tajweed token structure, the generator will throw an exception and halt to prevent printing incorrect Quranic text.
