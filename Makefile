ifneq ("$(wildcard config.inc)","")
include config.inc
#$(info )
else
$(error Please run config.sh)
endif

srcdir = .
prefix = /usr/local/
libdir = ${prefix}/lib

CC = mpicc
LD = @LD@

RECORDER_LOG_FORMAT = $(srcdir)/./recorder-log-format.h
INCL_DEPS = include/recorder.h include/recorder-dynamic.h $(recorder_LOG_FORMAT)

CFLAGS_SHARED = -fPIC -I. -I$(srcdir) -I$(srcdir)/../\
				-I${MPI_DIR}/include -I${HDF5_DIR}/include \
				-D_LARGEFILE64_SOURCE -shared -DRECORDER_PRELOAD

LIBS += -lz @LIBBZ2@
LDFLAGS += -L${HDF5_DIR}/lib -lhdf5
CFLAGS += $(CFLAGS_SHARED) ${DISABLED_LAYERS}

all: lib/librecorder.so

lib:
	@mkdir -p $@

%.po: %.c $(INCL_DEPS) | lib
	$(CC) $(CFLAGS) -c $< -o $@

lib/librecorder.so: lib/recorder-mpi-io.po lib/recorder-mpi-init-finalize.po lib/recorder-hdf5.po lib/recorder-posix.po
	$(CC) $(CFLAGS) $(LDFLAGS) -ldl -o $@ $^ -lpthread -lrt -lz

install:: all
	install -d $(libdir)
	install -m 755 lib/librecorder.so $(libdir)

clean::
	rm -f *.o *.a lib/*.o lib/*.po lib/*.a lib/*.so

distclean:: clean
