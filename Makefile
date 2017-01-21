all: \
	$(INSTALL_PATH)/lib/libfreetype.a \
	$(INSTALL_PATH)/lib/libmad.a \
	$(INSTALL_PATH)/lib/libogg.a \
	$(INSTALL_PATH)/lib/libvorbisidec.a \
	$(INSTALL_PATH)/lib/liblua.a \
	$(INSTALL_PATH)/lib/libsmpeg.a

$(INSTALL_PATH)/lib/libfreetype.a:
	cd freetype; ./configure CC=$(SDK_CC) CFLAGS="$(SDK_CFLAGS) -isysroot $(SDK_PATH)" --host=$(HOST) --disable-shared --prefix=$(INSTALL_PATH)
	make -C freetype
	make -C freetype install

$(INSTALL_PATH)/lib/libmad.a:
	cd libmad; sh ./configure CC=$(SDK_CC) CFLAGS="$(SDK_CFLAGS) -isysroot $(SDK_PATH)" SDL_CFLAGS="$(SDK_CFLAGS) -isysroot $(SDK_PATH)" --host=$(HOST) --disable-shared --prefix=$(INSTALL_PATH) --disable-aso
	make -C libmad
	make -C libmad install

$(INSTALL_PATH)/lib/libogg.a:
	cd libogg; ./configure CC=$(SDK_CC) CFLAGS="$(SDK_CFLAGS) -isysroot $(SDK_PATH)" SDL_CFLAGS="-isysroot $(SDK_PATH)" --host=$(HOST) --disable-shared --prefix=$(INSTALL_PATH)
	make -C libogg
	make -C libogg install

$(INSTALL_PATH)/lib/libvorbisidec.a:
	cd tremor; ./autogen.sh CC=$(SDK_CC) CFLAGS="$(SDK_CFLAGS) -isysroot $(SDK_PATH)" SDL_CFLAGS="-isysroot $(SDK_PATH)" OGG_CFLAGS="-I$(INSTALL_PATH)/include" OGG_LIBS="-L$(INSTALL_PATH)/lib" --host=$(HOST) --disable-shared --prefix=$(INSTALL_PATH)
	make -C tremor
	make -C tremor install

$(INSTALL_PATH)/lib/liblua.a:
	make -C lua macosx CC=$(SDK_CC) CFLAGS="$(SDK_CFLAGS) -isysroot $(SDK_PATH)" INSTALL_TOP=$(INSTALL_PATH)
	make -C lua install CC=$(SDK_CC) CFLAGS="$(SDK_CFLAGS) -isysroot $(SDK_PATH)" INSTALL_TOP=$(INSTALL_PATH)

$(INSTALL_PATH)/lib/libsmpeg.a:
	make -C smpeg -f Makefile.ons CC=$(SDK_CC) CFLAGS="$(SDK_CFLAGS) -isysroot $(SDK_PATH)" INSTALL_TOP=$(INSTALL_PATH)
	make -C smpeg -f Makefile.ons install CC=$(SDK_CC) CFLAGS="$(SDK_CFLAGS) -isysroot $(SDK_PATH)" INSTALL_TOP=$(INSTALL_PATH)

clean:
	make -C freetype clean
	make -C libmad clean
	make -C libogg clean
	make -C tremor clean
	make -C lua clean
	make -C tremor -f Makefile.ons clean
	-rm $(INSTALL_PATH)/lib/libfreetype.a
	-rm $(INSTALL_PATH)/lib/libmad.a
	-rm $(INSTALL_PATH)/lib/libogg.a
	-rm $(INSTALL_PATH)/lib/libvorbisidec.a
	-rm $(INSTALL_PATH)/lib/liblua.a
	-rm $(INSTALL_PATH)/lib/libsmpeg.a
