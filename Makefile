# Sources and objects
C_SOURCES = \
	  monitor/func.s \
	  monitor/vectors.s \
	  monitor/xm.s \
	  monitor/main.c
APPNAME = bankmon

# DO NOT EDIT THIS
include Make.rules# Sources and objects

$(BUILD_DIR)/$(APPNAME).img: $(C_SOURCES)
	mkdir -pv $(BUILD_DIR)
	$(CC) $(CCFLAGS) -o $(BUILD_DIR)/$(APPNAME).img $(C_SOURCES) $(TOP)/lib/build/bios.lib 

