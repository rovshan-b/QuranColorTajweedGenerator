# Tajweed Quran Mushaf Generator

A Flutter desktop application that generates HTML files of the Quran Mushaf with Tajweed color coding. The generated HTML can be printed to PDF using browser's print functionality.

## Features

- **Tajweed Color Coding**: Each Tajweed rule is highlighted with a specific color:

  - 🟢 **LAFZATULLAH** (Allah's name) - Green
  - 🔵 **Izhar** - Cyan
  - 🔴 **Ikhfaa** - Red
  - 🩷 **Idgham with Ghunna** - Pink
  - ⚪ **Idgham without Ghunna** - Gray
  - 🔵 **Iqlab** - Blue
  - 🟢 **Qalqala** - Olive
  - 🟠 **Ghunna** - Orange
  - 🟣 **Madd (Prolonging)** - Purple

- **Page Size Options**: Generate for A3, A4, or A5 paper sizes
- **Custom Page Range**: Generate specific pages (1-604)
- **Embedded Fonts**: Uses Kitab Arabic font embedded as base64 for consistent rendering
- **Cover Page**: Includes a decorative cover page
- **Color Legend**: Each page includes a Tajweed color legend at the bottom
- **Print-Optimized CSS**: Includes print media queries for proper PDF generation

## How It Works

1. The app reads Quran text from SQLite databases:

   - `qpc-v4-tajweed-15-lines.db` - Page layout (15 lines per page)
   - `uthmani.db` - Word-by-word Quran text

2. Tajweed rules are applied using pre-computed tokens from `cached_tajweed_tokens.dart`

3. HTML is generated with each letter/word colored according to its Tajweed rule

4. The HTML file can be opened in a browser and printed to PDF

## Usage

1. Run the app on desktop computer:

   ```bash
   flutter run
   ```

2. Select page range (e.g., 1-604 for complete Quran)

3. Choose page size (A3, A4, or A5)

4. Click "Generate HTML"

5. Open the generated HTML file in a browser

6. Print to PDF using browser's print function
   - Enable "Background graphics" in print settings to preserve colors

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── mushaf_preview_screen.dart   # UI for generation
├── mushaf_html_generator.dart   # HTML generation with CSS
├── mushaf_db_reader.dart        # SQLite database reading
├── mushaf_db_initializer.dart   # Database initialization
├── mushaf_word_mapper.dart      # Maps words to Tajweed tokens
├── tajweed_color_mapper.dart    # Tajweed rule to color mapping
├── cached_tajweed_tokens.dart   # Pre-computed Tajweed tokens
├── tajweed.dart                 # Tajweed tokenization logic
├── tajweed_rule.dart            # Tajweed rule definitions
├── tajweed_subrule.dart         # Tajweed subrule definitions
├── tajweed_token.dart           # Token data structure
└── tajweed_word.dart            # Word data structure

resources/
├── qpc-v4-tajweed-15-lines.db   # Page layout database
└── uthmani.db                   # Quran text database

assets/fonts/
├── Kitab-Regular.ttf            # Arabic font
└── Kitab-Bold.ttf               # Arabic font (bold)
```

## Requirements

- Flutter SDK
- macOS (for desktop app), Should also work on Windows and Linux
- SQLite databases in `resources/` folder

## Data Integrity

The app includes safety checks to ensure accurate Quran text rendering.
It will throw exception and stop generation in case of any problems during word mapping etc.
