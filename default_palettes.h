#ifndef DEFAULT_PALETTES_H
#define DEFAULT_PALETTES_H

// Built-in palettes seeded onto the SD card's /palette/ folder on boot so a
// fresh card always has something to choose from. Each entry's `data` is in
// the same format the palette loader expects: one "RRGGBB" per line terminated
// with CRLF (6 hex chars + "\r\n" == the loader's fixed 8-byte-per-colour
// stride). Every line, including the last, MUST end in "\r\n".

struct DefaultPalette {
  const char* name;  // filename written under /palette/
  const char* data;  // file contents (RRGGBB\r\n per colour)
};

static const DefaultPalette default_palettes[] = {
  // PICO-8 (16) - https://lospec.com/palette-list/pico-8
  { "pico-8.hex",
    "000000\r\n1D2B53\r\n7E2553\r\n008751\r\nAB5236\r\n5F574F\r\nC2C3C7\r\nFFF1E8\r\n"
    "FF004D\r\nFFA300\r\nFFEC27\r\n00E436\r\n29ADFF\r\n83769C\r\nFF77A8\r\nFFCCAA\r\n" },

  // Sweetie 16 (16) - https://lospec.com/palette-list/sweetie-16
  { "sweetie-16.hex",
    "1A1C2C\r\n5D275D\r\nB13E53\r\nEF7D57\r\nFFCD75\r\nA7F070\r\n38B764\r\n257179\r\n"
    "29366F\r\n3B5DC9\r\n41A6F6\r\n73EFF7\r\nF4F4F4\r\n94B0C2\r\n566C86\r\n333C57\r\n" },

  // Game Boy DMG (4) - https://lospec.com/palette-list/nintendo-gameboy-bgb
  { "gameboy.hex",
    "0F380F\r\n306230\r\n8BAC0F\r\n9BBC0F\r\n" },
};

static const int NUM_DEFAULT_PALETTES =
    sizeof(default_palettes) / sizeof(default_palettes[0]);

#endif
