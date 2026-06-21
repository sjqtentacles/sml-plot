# sml-plot build
#
#   make            build the test binary with MLton (default)
#   make test       build + run tests under MLton
#   make test-poly  run tests under Poly/ML (use-and-run; no link step)
#   make all-tests  run the suite under both compilers
#   make example    render the multi-series demo chart PNG
#   make clean      remove build artifacts
#
# Layout B (dependent): own sources live in src/; sml-font and its dependency
# stack (sml-raster -> sml-image -> sml-inflate + sml-color) are vendored under
# lib/ and loaded first, in dependency order.

MLTON      ?= mlton
POLY       ?= poly
BIN        := bin
LIBDIR     := lib/github.com/sjqtentacles
INFLATEDIR := $(LIBDIR)/sml-inflate
COLORDIR   := $(LIBDIR)/sml-color
IMAGEDIR   := $(LIBDIR)/sml-image
RASTERDIR  := $(LIBDIR)/sml-raster
FONTDIR    := $(LIBDIR)/sml-font
TEST_MLB   := test/test.mlb
SRCS       := $(wildcard $(INFLATEDIR)/* $(COLORDIR)/* $(IMAGEDIR)/* $(RASTERDIR)/* $(FONTDIR)/* src/* test/*.sml) $(TEST_MLB)

.PHONY: all test poly test-poly all-tests example clean

all: $(BIN)/test-mlton

example: $(BIN)/chart
	mkdir -p assets
	./$(BIN)/chart

$(BIN)/chart: $(SRCS) examples/chart.sml examples/sources.mlb | $(BIN)
	$(MLTON) -output $@ examples/sources.mlb

$(BIN)/test-mlton: $(SRCS) | $(BIN)
	$(MLTON) -output $@ $(TEST_MLB)

test: $(BIN)/test-mlton
	$(BIN)/test-mlton

# Poly/ML has no native .mlb support; the suite runs at top level and exits on
# its own. Load the vendored deps first (inflate, color, image, raster, font),
# then the embedded font data and plot sources, then the test driver.
poly test-poly:
	printf 'use "$(INFLATEDIR)/inflate.sig";\nuse "$(INFLATEDIR)/inflate.sml";\nuse "$(COLORDIR)/color.sig";\nuse "$(COLORDIR)/color.sml";\nuse "$(IMAGEDIR)/image.sig";\nuse "$(IMAGEDIR)/image.sml";\nuse "$(RASTERDIR)/raster.sig";\nuse "$(RASTERDIR)/raster.sml";\nuse "$(FONTDIR)/font.sig";\nuse "$(FONTDIR)/font.sml";\nuse "src/font_data.sml";\nuse "src/plot.sig";\nuse "src/plot.sml";\nuse "test/harness.sml";\nuse "test/support.sml";\nuse "test/test_clamp.sml";\nuse "test/test_extent.sml";\nuse "test/test_nice.sml";\nuse "test/test_project.sml";\nuse "test/test_render.sml";\nuse "test/entry.sml";\nuse "test/main.sml";\n' | $(POLY) -q --error-exit

all-tests: test test-poly

$(BIN):
	mkdir -p $(BIN)

clean:
	rm -f $(BIN)/test-mlton $(BIN)/chart
