# ========== Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ========== 
# Committed by: Adam Fox 
# Commit ID: 7658507407b7e1161e891fbd7e0ebefa6983706e 
# Date: 2020-10-11 18:13:45 -0600 
# ========== End of Keysight Technologies Notice ========== 
#
#  Tests Makefile for GNUstep Base Library.
#  
#  Copyright (C) 2011 Free Software Foundation, Inc.
#
#  Written by:	Richard Frith-Macdonald <rfm@gnu.org>
#
#  This file is part of the GNUstep Base Library.
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
#  General Public License for more details.
#
#  You should have received a copy of the GNU General Public
#  License along with this library; if not, write to the Free
#  Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#  Boston, MA 02111 USA
#

ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
  ifeq ($(GNUSTEP_MAKEFILES),)
    $(warning )
    $(warning Unable to obtain GNUSTEP_MAKEFILES setting from gnustep-config!)
    $(warning Perhaps gnustep-make is not properly installed,)
    $(warning so gnustep-config is not in your PATH.)
    $(warning )
    $(warning Your PATH is currently $(PATH))
    $(warning )
  endif
endif

ifeq ($(GNUSTEP_MAKEFILES),)
  $(error You need to set GNUSTEP_MAKEFILES before running this!)
endif

ifeq ($(GNUSTEP_TESTS_TARGET),)
  GNUSTEP_TESTS_TARGET := base
endif

include $(GNUSTEP_MAKEFILES)/common.make

TOP_DIR := $(shell dirname $(CURDIR))

# This message is also printed when you type 'make' top-level.  It is
# the last message printed (since 'Tests' is the last directory in
# SUBPROJECTS top-level), which is good as it becomes a recommendation
# to run 'make check' after 'make'.
all::
	@(echo If you want to run the gnustep-base testsuite, please type \'make check\')

#
# 'make check' runs the testsuite (Objective-C tests only)
#
# Use 'make check GNUSTEP_TEST_OBJCXX=yes' to run both Objective-C
# and Objective-C++ tests
#
check::
	(\
	GNUSTEP_LOCAL_ADDITIONAL_MAKEFILES="$(TOP_DIR)/base.make";\
	ADDITIONAL_INCLUDE_DIRS="-I$(TOP_DIR)/Headers -I$(TOP_DIR)/Source/$(GNUSTEP_TARGET_DIR)";\
	ADDITIONAL_LIB_DIRS="-L$(TOP_DIR)/Source/$(GNUSTEP_OBJ_DIR)";\
	LD_LIBRARY_PATH="$(TOP_DIR)/Source/$(GNUSTEP_OBJ_DIR):${LD_LIBRARY_PATH}";\
	PATH="$(TOP_DIR)/Tools/$(GNUSTEP_OBJ_DIR):${PATH}";\
	export GNUSTEP_LOCAL_ADDITIONAL_MAKEFILES;\
	export ADDITIONAL_INCLUDE_DIRS;\
	export ADDITIONAL_LIB_DIRS;\
	export LD_LIBRARY_PATH;\
	export PATH;\
	if [ "$(DEBUG)" = "" ]; then \
	  gnustep-tests $(GNUSTEP_TESTS_FLAGS) $(GNUSTEP_TESTS_TARGET);\
        else \
	  gnustep-tests --debug $(GNUSTEP_TESTS_FLAGS) $(GNUSTEP_TESTS_TARGET);\
        fi; \
	)

clean::
	-gnustep-tests --clean

# This makefile does nothing.
include $(GNUSTEP_MAKEFILES)/rules.make
