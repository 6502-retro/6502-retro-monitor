# Sources and objects
C_SOURCES = \
	  monitor/func.s \
	  monitor/xm.s \
	  monitor/main.c \
	  monitor/vectors.s
APPNAME = bankmon

# DO NOT EDIT THIS
include Make.rules# Sources and objects

$(BUILD_DIR)/$(APPNAME).img: $(C_SOURCES)
	mkdir -pv $(BUILD_DIR)
	$(CC) $(CCFLAGS) $(C_SOURCES) $(TOP)/lib/build/bios.lib 

