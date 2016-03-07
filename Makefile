CC = gcc -I. -DANDROID
AR = ar
ECHO = echo
ifeq ($(windir),)
EXE =
RM = rm -f
else
EXE = .exe
RM = del
endif

CFLAGS = -DHOST -Icore/include -Icore/libsparse/include -Icore/libsparse -Ilibselinux/include -Icore/mkbootimg
DFLAGS = -Werror -Iandroid_suport_include
EFLAGS = -Ibionic/libc/include -Ibionic/libc/kernel/uapi -Ibionic/libc/kernel/uapi/asm-x86
LDFLAGS = -L.
LIBS = -lz
LIBZ = -lsparse -lselinux -lpcre -lcutils -llog
SELINUX_SRCS= \
	libselinux/src/booleans.c \
	libselinux/src/canonicalize_context.c \
	libselinux/src/disable.c \
	libselinux/src/enabled.c \
	libselinux/src/fgetfilecon.c \
	libselinux/src/fsetfilecon.c \
	libselinux/src/getenforce.c \
	libselinux/src/getfilecon.c \
	libselinux/src/getpeercon.c \
	libselinux/src/lgetfilecon.c \
	libselinux/src/load_policy.c \
	libselinux/src/lsetfilecon.c \
	libselinux/src/policyvers.c \
	libselinux/src/setenforce.c \
	libselinux/src/setfilecon.c \
	libselinux/src/context.c \
	libselinux/src/mapping.c \
	libselinux/src/stringrep.c \
	libselinux/src/compute_create.c \
	libselinux/src/compute_av.c \
	libselinux/src/avc.c \
	libselinux/src/avc_sidtab.c \
	libselinux/src/get_initial_context.c \
	libselinux/src/sestatus.c \
	libselinux/src/deny_unknown.c
SELINUX_HOST= \
	libselinux/src/callbacks.c \
	libselinux/src/check_context.c \
	libselinux/src/freecon.c \
	libselinux/src/init.c \
	libselinux/src/label.c \
	libselinux/src/label_file.c \
	libselinux/src/label_android_property.c
LIBMINCRYPT_SRCS= core/libmincrypt/*.c
LIBSPARSE_SRCS= \
	core/libsparse/backed_block.c \
	core/libsparse/output_file.c \
	core/libsparse/sparse.c \
	core/libsparse/sparse_crc32.c \
	core/libsparse/sparse_err.c \
	core/libsparse/sparse_read.c
EXT4FS_SRCS= \
    extras/ext4_utils/make_ext4fs.c \
    extras/ext4_utils/ext4fixup.c \
    extras/ext4_utils/ext4_utils.c \
    extras/ext4_utils/allocate.c \
    extras/ext4_utils/contents.c \
    extras/ext4_utils/extent.c \
    extras/ext4_utils/indirect.c \
    extras/ext4_utils/sha1.c \
    extras/ext4_utils/wipe.c \
    extras/ext4_utils/crc16.c \
    extras/ext4_utils/ext4_sb.c
EXT4FS_MAIN= \
    extras/ext4_utils/make_ext4fs_main.c \
    extras/ext4_utils/canned_fs_config.c
LIBCUTILS_SRCS= \
	core/libcutils/hashmap.c \
	core/libcutils/native_handle.c \
	core/libcutils/config_utils.c \
	core/libcutils/load_file.c \
	core/libcutils/strlcpy.c \
	core/libcutils/open_memstream.c \
	core/libcutils/strdup16to8.c \
	core/libcutils/strdup8to16.c \
	core/libcutils/record_stream.c \
	core/libcutils/process_name.c \
	core/libcutils/threads.c \
	core/libcutils/sched_policy.c \
	core/libcutils/iosched_policy.c \
	core/libcutils/str_parms.c \
	core/libcutils/fs_config.c
LIBLOG1_SRCS= \
	core/liblog/uio.c \
	core/liblog/event_tag_map.c \
	core/liblog/fake_log_device.c \
	core/liblog/log_event_write.c \
	core/liblog/logprint.c
LIBLOG2_SRCS= \
	core/liblog/log_read.c \
	core/liblog/logd_write.c \
	core/liblog/log_read_kern.c \
	core/liblog/logd_write_kern.c

all:libselinux \
    libz libsparse  \
	libpcre\
	libmincrypt \
	libcutils \
	liblog \
	simg2img$(EXE) \
	simg2simg$(EXE) \
	img2simg$(EXE) \
	make_ext4fs$(EXE) \
	ext2simg$(EXE) \
	unpackbootimg$(EXE) \
	sgs4ext4fs$(EXE)

.PHONY: libselinux

libselinux:
	@$(ECHO) "Building libselinux..."
	@$(CROSS_COMPILE)$(CC) -c $(SELINUX_SRCS) $(CFLAGS) $(SELINUX_HOST)
	@$(AR) cqs $@.a *.o
	@$(RM) -rfv *.o
	@$(ECHO) "*******************************************"
	
libpcre:
	@$(ECHO) "Building libpcre..."
	@$(AR) cqs $@.a pcre/dist/*.o
	@$(ECHO) "*******************************************"
	
libz:
	@$(ECHO) "Building zlib_host..."
	@$(AR) cqs $@.a zlib/src/*.o
	@$(ECHO) "*******************************************"
		
libsparse:
	@$(ECHO) "Building libsparse_host..."
	@$(ECHO) "*******************************************"
	@$(CROSS_COMPILE)$(CC) -c $(LIBSPARSE_SRCS) $(CFLAGS)
	@$(AR) -x libz.a
	@$(AR) cqs $@.a *.o
	@$(RM) -rfv *.o
	@$(ECHO) "*******************************************"
	
libmincrypt:
	@$(ECHO) "Building libmincrypt_host..."
	@$(CROSS_COMPILE)$(CC) -c $(LIBMINCRYPT_SRCS) $(CFLAGS)
	@$(AR) cqs $@.a *.o
	@$(RM) -rfv *.o
	@$(ECHO) "*******************************************"
	
libcutils:
	@$(ECHO) "Building libcutils_host..."
	@$(CC) -c $(LIBCUTILS_SRCS) $(CFLAGS) $(LIBZ)
	@$(AR) cqs $@.a *.o
	@$(RM) -rfv *.o
	@$(ECHO) "*******************************************"
	
liblog:
	@$(ECHO) "Building liblog_host..."
	@$(CC) -c $(LIBLOG1_SRCS) $(CFLAGS) $(DFLAGS) $(LIBZ)
	@$(CC) -c $(LIBLOG2_SRCS) $(CFLAGS) $(EFLAGS) $(LIBZ)
	@$(AR) cqs $@.a *.o
	@$(RM) -rfv *.o
	@$(ECHO) "*******************************************"
	
mkbootimg$(EXE):
	@$(ECHO) "Building mkbootimg..."
	@$(CC) external/android_system_core/mkbootimg/mkbootimg.c -o $@ $(CFLAGS) $(LDFLAGS) $(LIBS) $(LIBZ)
	@$(ECHO) "*******************************************"
	
mkbootfs$(EXE):
	@$(ECHO) "Building mkbootfs..."
	@$(CC) core/cpio/mkbootfs.c -o $@  $(CFLAGS) $(LDFLAGS) $(LIBS) $(LIBZ)
	@$(ECHO) "*******************************************"

simg2img$(EXE):
	@$(ECHO) "Building simg2img..."
	@$(CROSS_COMPILE)$(CC) core/libsparse/simg2img.c -o $@ $(LIBSPARSE_SRCS) $(CFLAGS) $(LIBS)
	@$(ECHO) "*******************************************"
	
simg2simg$(EXE):
	@$(ECHO) "Building simg2simg..."
	@$(CROSS_COMPILE)$(CC) core/libsparse/simg2simg.c -o $@ $(LIBSPARSE_SRCS) $(CFLAGS) $(LIBS)
	@$(ECHO) "*******************************************"
	
img2simg$(EXE):
	@$(ECHO) "Building img2simg..."
	@$(CROSS_COMPILE)$(CC) core/libsparse/img2simg.c -o $@ $(LIBSPARSE_SRCS) $(CFLAGS) $(LIBS)
	@$(ECHO) "*******************************************"
	
make_ext4fs$(EXE):
	@$(ECHO) "Building make_ext4fs..."
	@$(CROSS_COMPILE)$(CC) -o $@ $(EXT4FS_MAIN) $(EXT4FS_SRCS) $(CFLAGS) $(LDFLAGS) $(LIBS) $(LIBZ)
	@$(ECHO) "*******************************************"
	
ext2simg$(EXE):
	@$(ECHO) "Building ext2simg..."
	@$(CROSS_COMPILE)$(CC) -o $@ extras/ext4_utils/ext2simg.c $(EXT4FS_SRCS) $(CFLAGS) $(LDFLAGS) $(LIBS) $(LIBZ)
	@$(ECHO) "*******************************************"
	
unpackbootimg$(EXE):
	@$(ECHO) "Building unpackbootimg..."
	@$(CROSS_COMPILE)$(CC) external/android_system_core/mkbootimg/unpackbootimg.c -o $@ $(CFLAGS) $(LDFLAGS) $(LIBS) $(LIBZ)
	@$(RM) -rfv *.a
	@$(ECHO) "*******************************************"

sgs4ext4fs$(EXE):
	@$(ECHO) "Building sgs4ext4fs..."
	@$(CROSS_COMPILE)$(CC) external/sgs4ext4fs/main.c -o $@
	@$(ECHO) "*******************************************"
	
.PHONY:

clean:
	@$(ECHO) "Cleaning..."
	@$(RM) -rfv *.o *.a *.exe
	

	@$(ECHO) "*******************************************"
	
.PHONY:

clear:
	@$(ECHO) "Clearing..."
	@$(RM) -rfv *.o *.a *.sh file_contexts
	@$(RM) -drfv \
	core \
	extras \
	android_system_extras \
	libselinux \
	zlib \
	external \
	pcre \
	sepolicy \
	bionic

	@$(ECHO) "*******************************************"
		
