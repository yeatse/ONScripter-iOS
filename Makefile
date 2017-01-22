all: \
	$(INSTALL_PATH)/lib/liblua.a \
	$(INSTALL_PATH)/lib/libsmpeg.a

$(INSTALL_PATH)/lib/liblua.a:
	make -C lua macosx CC=$(SDK_CC) CFLAGS="$(SDK_CFLAGS) -isysroot $(SDK_PATH)" INSTALL_TOP=$(INSTALL_PATH)
	make -C lua install CC=$(SDK_CC) CFLAGS="$(SDK_CFLAGS) -isysroot $(SDK_PATH)" INSTALL_TOP=$(INSTALL_PATH)

$(INSTALL_PATH)/lib/libsmpeg.a:
	make -C smpeg -f Makefile.ons CC=$(SDK_CC) CFLAGS="$(SDK_CFLAGS) -isysroot $(SDK_PATH)" INSTALL_TOP=$(INSTALL_PATH)
	make -C smpeg -f Makefile.ons install CC=$(SDK_CC) CFLAGS="$(SDK_CFLAGS) -isysroot $(SDK_PATH)" INSTALL_TOP=$(INSTALL_PATH)

clean:
	make -C lua clean
	make -C smpeg -f Makefile.ons clean
	-rm $(INSTALL_PATH)/lib/liblua.a
	-rm $(INSTALL_PATH)/lib/libsmpeg.a
