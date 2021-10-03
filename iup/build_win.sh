#!/bin/sh
#Judicaël Grasset 2021
set +x

INSTALL_DIR=${INSTALL_DIR-install_dir}
mkdir -p "$INSTALL_DIR/lib"
mkdir -p "$INSTALL_DIR/include"

IUP_TGZ=iup-3.30_Sources.tar.gz
LUA_TGZ=lua-5.4.2_Sources.tar.gz

#Download Lua if not already downloaded
if [ ! -e $LUA_TGZ ]; then 
	wget "https://downloads.sourceforge.net/luabinaries/$LUA_TGZ"
fi
test -e $LUA_TGZ || exit

#Download IUP if not already downloaded
if [ ! -e $IUP_TGZ ]; then 
	wget "https://downloads.sourceforge.net/iup/$IUP_TGZ"
fi
test -e $IUP_TGZ || exit


export TECMAKE_SETUP="TEC_SYSNAME=Win32 \
  TEC_SYSARCH=i386 \
  TEC_UNAME=win32-gcc \
  TEC_SYSARCH=x86 \
  TEC_TOOLCHAIN=x86_64-w64-mingw32-"

tar xf $LUA_TGZ
cd lua54/src || exit
make $TECMAKE_SETUP -f Makefile.tecmake
#For some reason when building lua (the interpreter) directory with the lua lib is not included, so add it and relaunch command
x86_64-w64-mingw32-gcc -o ../bin/win32-gcc/lua54 ../obj/win32-gcc/lua.o ../obj/win32-gcc/lua.ro   -llua54 -lm -L ../lib/win32-gcc/
cd .. || exit
cp lib/*/liblua54.* "$INSTALL_DIR/lib/"
cp -r include "$INSTALL_DIR/include/lua"
cd .. || exit


tar xf $IUP_TGZ
cd iup || exit
sed -i 's/do_all: iup.*/do_all: iup/' src/Makefile
sed -i "s/ShlObj.h/shlobj.h/" src/win/iupwin_info.c
sed -i "s|iupwin_image_wdl.c|win/iupwin_image_wdl.c|" src/config.mak
sed -i.bak "s|do_all:.*|do_all: iuplua \$(WINLIBS)|" srclua5/Makefile
make $TECMAKE_SETUP iup
export USE_LUA_VERSION=54
export USE_LUA54=YES
make $TECMAKE_SETUP iuplua5

cp lib/*/libiup.a "$INSTALL_DIR/lib/"
cp lib/*/Lua54/libiuplua54.a "$INSTALL_DIR/lib/"
cp -r include "$INSTALL_DIR/include/iup"
cd .. || exit

rm -r iup lua54

#Compile with: x86_64-w64-mingw32-gcc main.c -o out.exe -I${INSTALL_DIR}/include/iup -I${INSTALL_DIR}/include/lua/ -L${INSTALL_DIR}/lib -liuplua54 -liup -llua54 -liup -lgdi32 -lcomdlg32 -lcomctl32 -luuid -loleaut32 -lole32
