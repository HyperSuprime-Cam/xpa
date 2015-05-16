# EupsPkg config file. Sourced by 'eupspkg'

CONFIGURE_OPTIONS+=" --enable-shared=yes"

case $(uname) in
	Darwin) LIBNAME="libxpa.1.0.dylib" ;;
	Linux)	LIBNAME="libxpa.so.1.0" ;;
esac

build()
{
	detect_compiler

	# xpa's configure fails to add -fPIC to both clang and gcc, unless the compiler executable is named 'gcc'
	if [[ ( "$COMPILER_TYPE" == "clang" || "$COMPILER_TYPE" == "gcc" ) && "$(uname)" == "Linux" ]]; then
		export CFLAGS="$CFLAGS -fPIC"
	fi

	make -j$NJOBS CFLAGS="$CFLAGS"

	# test that the build succeeded since XPAs makefiles don't indicate
	# failure on error
	test -z "$LIBNAME" -o -f "$LIBNAME"
}

install()
{
	clean_old_install

	mkdir -p "$PREFIX"
	# make install cannot run in parallel through at least xpa-2.1.15
	make install
	test -z "$LIBNAME" -o -f "$PREFIX/lib/$LIBNAME"

	install_ups
}
