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
#   * LVGL 8.4.0 must be installed via the Arduino Library Manager (see README).
#   * bsp_cst816 and Arduino_GFX 1.6.7 are bundled in ./libraries and pulled in
#     automatically below (Arduino_GFX 1.6.7 is required for ESP32 core 3.x).

# ---- Configuration (override on the command line, e.g. `make build FQBN=...`) ----
SKETCH       ?= PixelArtCamera.ino
FQBN         ?= esp32:esp32:esp32s3:PSRAM=opi,FlashSize=16M,CDCOnBoot=cdc
BUILD_DIR    ?= build
PORT         ?=
MONITOR_BAUD ?= 115200
ARDUINO_CLI  ?= arduino-cli

# Bundled libraries that are not available through the Arduino Library Manager.
LIBRARIES := \
	--library libraries/bsp_cst816 \
	--library libraries/GFX_Library_for_Arduino

# Resolve the serial port into the shell variable $PORT: use $(PORT) if the user
# set it, otherwise auto-detect the first ESP32 board from `arduino-cli board list`.
define resolve_port
PORT="$(PORT)"; \
if [ -z "$$PORT" ]; then \
	PORT=$$($(ARDUINO_CLI) board list | awk 'tolower($$0) ~ /esp32/ && $$1 != "" && $$1 != "Port" { print $$1; exit }'); \
	if [ -n "$$PORT" ]; then echo "Auto-detected ESP32 port: $$PORT"; fi; \
fi; \
if [ -z "$$PORT" ]; then \
	echo "ERROR: could not auto-detect an ESP32 serial port."; \
	echo "  Run 'make ports' to list ports, then pass it explicitly, e.g.:"; \
	echo "  make $(or $(MAKECMDGOALS),flash) PORT=/dev/cu.usbmodem1101"; \
	exit 1; \
fi
endef

.PHONY: all build rebuild flash upload monitor ports clean help

all: build

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
