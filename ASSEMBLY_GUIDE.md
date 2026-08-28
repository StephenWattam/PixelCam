# Assembly Guide

## Physical Assembly
1. Print 3d printed enclosure.
2. Mount the rocker switch into case.
3. Insert battery into the compartment in the case.
4. Cut 1 lead from the battery and solder the rocker switch in between the 2 halves.
5. Connect the battery to VBAT and G on the ESP32 board.
6. Slide the board into the enclosure. Secure it with adhesive/screws.
7. Compile the firmware and flash it via USB.


## Software Setup
1. Install the ESP32 Arduino core (3.3.11) via Arduino IDE or `make setup` (see [README](README.md)).
2. Compile and flash the firmware via USB. The board should boot into the camera application.
3. Insert a microSD card into the slot on the back of the board
4. Add some hex colour profiles to the 'palettes' folder on the microSD card. The camera supports .hex color palette files downloadable from https://lospec.com/palette-list.
