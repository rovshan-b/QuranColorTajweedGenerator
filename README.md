بسم الله الرحمن الرحيم
_In the name of Allah, Most Gracious, Most Merciful_

# Tajweed Quran Mushaf Generator

A Flutter desktop application designed to generate high-quality, print-ready HTML and PNG assets of the Quran Mushaf with Tajweed color coding. The application supports two primary workflows:

1. **HTML to PDF**: Optimized for browser-to-PDF printing with support for various page sizes and side-column translations. (Tested mainly using Firefox browser and some tests done with Google Chrome browser).
2. **PNG + Coordinates**: High-resolution image generation for use in mobile apps or websites, including pixel-perfect coordinate tracking (`glyphs.db`) for interactivity.

## 📥 Download Installers

Get the latest version for your operating system:

- **[Download for Windows (.exe)](https://github.com/rovshan-b/QuranColorTajweedGenerator/blob/master/INSTALLERS/Windows/MushafGenerator-Installer.exe?raw=true)**
- **[Windows Store](https://apps.microsoft.com/detail/9pc7hc5dhmd2?hl=en-US&gl=FI)**

- **[Download for macOS (.dmg)](https://github.com/rovshan-b/QuranColorTajweedGenerator/blob/master/INSTALLERS/macOS/MushafGenerator-Installer.dmg?raw=true)**
- **[Apple App Store](https://apps.apple.com/us/app/mushaf-generator/id6757530734)**

**[User Guide](https://sengineer.substack.com/p/mushaf-with-tajweed-colors)**

## Screenshots

|                     Application UI                     |                       Generated Page Result                       |
| :----------------------------------------------------: | :---------------------------------------------------------------: |
| <img src="screenshots/app-screenshot.png" width="400"> | <img src="screenshots/generated-page-screenshot.png" width="400"> |

## ⚠️ Disclaimer & User Responsibility

**This software is a tool for generating layouts, but it does not guarantee perfection in every scenario.**

Users are **solely responsible** for verifying the final output, including but not limited to:

- **Text Accuracy**: Ensuring Quranic text and translations are correct and have not been altered during generation.
- **Layout Integrity**: Checking for text overflowing, clipping, overlapping, or missing content, especially when using long translations or small page sizes.
- **Formatting**: Verifying that margins, page breaks, and font rendering are correct for the intended print medium.

**Always review every page of the generated HTML/PDF before printing or distribution.**

## Features

- **Custom Tajweed Coding**: Precise character-level coloring for Tajweed rules. The application comes with standard defaults, but **every rule name and color is 100% customizable**:

  - **Rules supported**: LAFZATULLAH, Izhar, Ikhfaa, Idgham (with/without Ghunna), Iqlab, Qalqala, Ghunna, and Madd.
  - **Toggles**: Enable or disable highlighting for specific rules to simplify the output.
  - **Colors**: Change any rule's color using a real-time color picker.

- **Full Localization**:

  - **Custom Surah Names**: Rename all 114 Surahs for the Table of Contents and side-column headers (ideal for different languages or transliteration styles).
  - **Localized Labels**: Customize UI labels like "Tajweed Coding" on the cover or "Idgham" in the legend.

- **Labels & Typography**:

  - **Cover Customization**: Set your own title (e.g., "The Holy Quran") and subtitle.
  - **System Labels**: Customize the Table of Contents title and the text shown on intentional blank pages.
  - **Font Stacks**: Optimized cross-platform fonts ("Segoe UI", "Helvetica Neue", Arial) for translations to ensure consistency on Windows and macOS.

- **Flexible Page Formats**:

  - **Sizes**: Presets for A3, A4, B5, A5, and fully custom dimensions.
  - **Margins**: Configurable gutter margins for RTL book binding (odd/even page alternation).
  - **Centering**: Smart vertical alignment that keeps content centered within the available space.

- **PNG Export Features**:

  - **High Resolution**: Configurable DPI (e.g., 300, 600) for sharp, professional assets.
  - **Coordinate Tracking**: Generates a `glyphs.db` SQLite file alongside images, mapping every word's bounding box to its Surah/Ayah position.
  - **Decoration Toggle**: Option to hide page headers and legends for clean screenshots.

- **Translation Support**:

  - **Multiple Sources**:
    - **QuranEnc**: Dynamic fetching from the QuranEnc API.
    - **Tarteel (SQLite)**: Support for Tarteel-format database files.
    - **Tanzil (TXT)**: Support for Tanzil-format text files.
  - **Word-by-Word (WBW)**: Interlinear translation support (e.g., English, Turkish, Indonesian).
  - **Compact Mode**: Automatically switches to inline translation layout for dense pages to prevent overflow.

- **Customization**:
  - **Cover Page**: Customize the title, subtitle, and background color.
  - **Structure**: Control the number of blank pages inserted after the cover.
  - **Typography**: Adjust font sizes for Arabic, translations, and headers.

## User Guide

### 1. Configuration

The application is organized into tabs for easy setup:

- **General & Labels**:

  - Set the **Cover Title**, **Subtitle**, and **Background Color**.
  - Customize the **Table of Contents Title** and **Blank Page text**.
  - Control the number of **Preface Blank Pages** inserted after the cover.

- **Layout & Typography**:

  - Select a **Page Size** preset (A3, A4, B5, A5) or create a **Custom Preset**.
  - Adjust high-precision **Margins** (Gutter, Outer, Top, Bottom) for professional binding.
  - Set **DPI** for PNG generation (300dpi is standard for print).

- **Translation & WBW**:

  - **Side-column Translation**: Enable and select sources (QuranEnc, Tarteel, or Tanzil format).
  - **Word-by-Word (WBW)**: Enable interlinear translation with support for multiple languages.
  - **Compact Mode**: The app automatically manages font sizes to prevent text overflow.

- **Colors**:

  - Change the **Base Text Color** for the entire Mushaf.
  - Toggle or change colors for individual **Tajweed Rules**.

- **Localization**:
  - Input your own names for **all 114 Surahs**.
  - Customize the **Rule Labels** used in the legend (e.g., translate "Qalqala" to your native language).

### 2. Generation

#### HTML Workflow (PDF)

1. Select **HTML (PDF)** in the Format setting.
2. Set the **Page Range** (e.g., 1 to 604 for the full Quran).
3. Click **Generate**.
4. The application will process the pages and automatically open the result in your default web browser.

#### PNG Workflow (Apps/Assets)

1. Select **PNG + Coordinates** in the Format setting.
2. Set the **Resolution (DPI)** (e.g., 300 for standard, 600 for high quality).
3. Toggle **Show Page Header & Legend** if you want clean pages without titles.
4. Click **Generate**.
5. A folder containing numbered PNGs (`page001.png`, etc.) and a `glyphs.db` file will be created and opened.

### 3. Printing to PDF (HTML Workflow)

To convert the HTML to a PDF file:

1. In your browser, press `Ctrl+P` (Windows/Linux) or `Cmd+P` (macOS).
2. **Destination**: Select "Save as PDF".
3. **Layout**: Portrait.
4. **Margins**: Set to **None** (the application handles margins via CSS).
5. **Options**: Check **Background graphics** (essential for Tajweed colors and cover background).
6. Click **Save**.

## Developer Instructions

### Prerequisites

- **Flutter SDK**: >=3.0.0
- **Platform**: macOS, Windows, or Linux (Mobile is not supported due to `sqflite_common_ffi` usage).

### Building and Running

1. Get dependencies:
   ```bash
   flutter pub get
   ```
2. Run the application:
   ```bash
   flutter run -d macos  # or windows/linux
   ```

### Project Structure

- `lib/mushaf_html_generator.dart`: Core logic for building the HTML DOM and CSS.
- `lib/mushaf_image_generator.dart`: Logic for rendering high-res PNGs and `glyphs.db`.
- `lib/*_translation_service.dart`: Handlers for QuranEnc API, Tarteel (SQLite), and Tanzil (TXT) translation formats.
- `lib/mushaf_wbw_service.dart`: Management for interlinear Word-by-Word datasets.
- `lib/mushaf_page_config.dart`: Centralized layout presets and book margin logic.
- `lib/ui/screens/mushaf_preview/tabs/`: Contains individual configuration screens (Localization, Colors, etc.).
- `lib/mushaf_page_config.dart`: Definitions for page sizes and layout configuration.
- `lib/mushaf_preview_screen.dart`: Main UI controller and state management.
- `resources/`: Contains the SQLite databases (`qpc-v4-tajweed-15-lines.db`, `uthmani.db`).

### Data Integrity

The application implements strict bounds checking. If a word in the database does not match the expected Tajweed token structure, the generator will throw an exception to prevent printing incorrect Quranic text.
