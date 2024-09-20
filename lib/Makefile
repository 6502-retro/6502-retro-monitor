# Assembler, linker and scripts
AS = ca65
LD = ld65
CC = cl65
AR = ar65

TOP = ..
INCLUDES = -I $(TOP)/inc
#NONE = /home/davelatham/cc65/lib/none.lib
NONE = ./none.lib

# Assembler flags
ASFLAGS += $(INCLUDES) -g --feature labels_without_colons --cpu 65C02 --feature string_escapes

BUILD_DIR = build

SOURCES = \
	$(TOP)/bios/acia.s \
	$(TOP)/bios/sn76489.s

OBJS = $(addprefix $(BUILD_DIR)/, $(SOURCES:.s=.o))

all: clean $(BUILD_DIR)/bios.lib

clean:
	rm -fr $(BUILD_DIR)/*

$(BUILD_DIR)/%.o: %.s
	@mkdir -p $$(dirname $@)
	$(AS) $(ASFLAGS) -l $(BUILD_DIR)/$*.lst $< -o $@

$(BUILD_DIR)/bios.lib: $(OBJS)
	cp $(NONE) $@
	$(AR) a $@ $(OBJS)
