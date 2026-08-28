# Makefile for the Pixel Art Camera (Waveshare ESP32-S3-Touch-LCD-2 + OV5640)
#
# Common usage:
#   make build          # compile only
#   make ports          # list connected boards / serial ports
#   make flash          # compile + upload (auto-detects the ESP32 port)
#   make monitor        # open the serial monitor (auto-detects the port)
#   make clean          # remove build artifacts
#
# The serial port is auto-detected from `arduino-cli board list`. If you have
# more than one ESP32 attached (or detection fails), pass it explicitly:
#   make flash PORT=/dev/cu.usbmodem1101
#
# Notes:
#   * All libraries (LVGL, Arduino_GFX, bsp_cst816) are bundled in ./libraries
#     and pulled in automatically below, so nothing needs to be installed via the
#     Arduino Library Manager.
#   * Run `make setup` once to install the exact ESP32 core this project targets.

# ---- Configuration (override on the command line, e.g. `make build FQBN=...`) ----
SKETCH       ?= PixelArtCamera.ino
FQBN         ?= esp32:esp32:esp32s3:PSRAM=opi,FlashSize=16M,CDCOnBoot=cdc
BUILD_DIR    ?= build
PORT         ?=
MONITOR_BAUD ?= 115200
ARDUINO_CLI  ?= arduino-cli

# ESP32 platform pinned for reproducible builds (installed by `make setup`).
ESP32_CORE_VERSION ?= 3.3.11
ESP32_INDEX_URL    ?= https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json

# All libraries are bundled in ./libraries so the repo is self-contained.
LIBRARIES := \
	--library libraries/lvgl \
	--library libraries/GFX_Library_for_Arduino \
	--library libraries/bsp_cst816

# Resolve the serial port into the shell variable $PORT: use $(PORT) if the user
# set it, otherwise auto-detect. First ask arduino-cli for a board it identifies
# as an ESP32; if that fails (native-USB S3 boards often enumerate as "Unknown"
# with no FQBN), fall back to the first plausible USB serial device.
define resolve_port
PORT="$(PORT)"; \
if [ -z "$$PORT" ]; then \
	PORT=$$($(ARDUINO_CLI) board list | awk 'tolower($$0) ~ /esp32/ && $$1 ~ /^\/dev\// { print $$1; exit }'); \
	if [ -n "$$PORT" ]; then echo "Auto-detected ESP32 port: $$PORT"; fi; \
fi; \
if [ -z "$$PORT" ]; then \
	PORT=$$(ls /dev/cu.usbmodem* /dev/cu.usbserial* /dev/cu.wchusbserial* /dev/ttyACM* /dev/ttyUSB* 2>/dev/null | head -n1); \
	if [ -n "$$PORT" ]; then echo "No board identified by arduino-cli; falling back to serial device: $$PORT"; fi; \
fi; \
if [ -z "$$PORT" ]; then \
	echo "ERROR: could not auto-detect an ESP32 serial port."; \
	echo "  Run 'make ports' to list ports, then pass it explicitly, e.g.:"; \
	echo "  make $(or $(MAKECMDGOALS),flash) PORT=/dev/cu.usbmodem1101"; \
	echo "  If nothing appears, reset the board (or enter download mode:"; \
	echo "  hold BOOT, tap RESET, release BOOT) and try again."; \
	exit 1; \
fi
endef

.PHONY: all setup build rebuild flash upload monitor ports clean help

all: build

## setup: Install the pinned ESP32 core (run once on a fresh machine)
setup:
	$(ARDUINO_CLI) core update-index --additional-urls $(ESP32_INDEX_URL)
	$(ARDUINO_CLI) core install esp32:esp32@$(ESP32_CORE_VERSION) --additional-urls $(ESP32_INDEX_URL)

## build: Compile the sketch into $(BUILD_DIR)
build:
	$(ARDUINO_CLI) compile --fqbn $(FQBN) $(LIBRARIES) --output-dir $(BUILD_DIR) $(SKETCH)

## rebuild: Clean compile (ignore cached objects)
rebuild:
	$(ARDUINO_CLI) compile --clean --fqbn $(FQBN) $(LIBRARIES) --output-dir $(BUILD_DIR) $(SKETCH)

## flash: Compile and upload to the board (auto-detects PORT)
flash:
	@$(resolve_port); \
	$(ARDUINO_CLI) compile --fqbn $(FQBN) $(LIBRARIES) --output-dir $(BUILD_DIR) --upload --port "$$PORT" $(SKETCH)

## upload: Upload the already-built binaries from $(BUILD_DIR) without recompiling (auto-detects PORT)
upload:
	@$(resolve_port); \
	$(ARDUINO_CLI) upload --fqbn $(FQBN) --input-dir $(BUILD_DIR) --port "$$PORT" $(SKETCH)

## monitor: Open the serial monitor (auto-detects PORT)
monitor:
	@$(resolve_port); \
	$(ARDUINO_CLI) monitor --port "$$PORT" --config baudrate=$(MONITOR_BAUD)

## ports: List connected boards and serial ports
ports:
	$(ARDUINO_CLI) board list

## clean: Remove build artifacts
clean:
	rm -rf $(BUILD_DIR)

## help: Show available targets
help:
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## //'
