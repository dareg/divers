#!/bin/sh
set +x

INSTALL_DIR=${INSTALL_DIR-lua_iup_lib}
mkdir -p "$INSTALL_DIR"

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


tar xvf $LUA_TGZ
cd lua54/src || exit
make -f Makefile.tecmake
cd .. || exit
cp lib/*/liblua54.so "../$INSTALL_DIR/"
cp bin/*/lua54 "../$INSTALL_DIR/"
cd .. || exit


tar xvf $IUP_TGZ
cd iup || exit
#Exclude all targets apart from iup itself and its Lua binding
export EXCLUDE_TARGETS="iupcd iupcontrols iupgl iupglcontrols iup_plot iup_mglplot iup_scintilla iupim iupimglib iupweb iuptuio ledc iupview iupvled iupluaconsole iupluascripter iupole"
#Don't build for Motif, only for GTK
#Also display which targets will be build (just so we're sure)
sed -i.bak "s|OTHERDEPENDENCIES := iupgtk iupmot|OTHERDEPENDENCIES := iupgtk\\n\$(info \$\$TARGETS is [\${TARGETS}])|" Makefile
#Remove all lua binding apart the one for iup and maybe some windows stuff
sed -i.bak "s|do_all:.*|do_all: iuplua \$(WINLIBS)|" srclua5/Makefile
#We build IUP for LUA 5.4
export USE_LUA_VERSION=54
export USE_LUA54=YES
make

cp lib/*/libiup.so "../$INSTALL_DIR/"
cp lib/*/Lua*/libiuplua*.so "../$INSTALL_DIR/"

