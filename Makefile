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
LDFLAGS = -L. 
LIBS = -lz
LIBZ = -lsparse_host -lselinux -lpcre
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
    extras/ext4_utils/uuid.c \
    extras/ext4_utils/sha1.c \
    extras/ext4_utils/wipe.c \
    extras/ext4_utils/crc16.c \
    extras/ext4_utils/ext4_sb.c
EXT4FS_MAIN= \
    extras/ext4_utils/make_ext4fs_main.c \
    extras/ext4_utils/canned_fs_config.c

all:libselinux \
    libz libsparse_host  \
	libpcre\
	libmincrypt_host \
	mkbootimg$(EXE) \
	mkbootfs$(EXE) \
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
		
libsparse_host:
	@$(ECHO) "Building libsparse_host..."
	@$(ECHO) "*******************************************"
	@$(CROSS_COMPILE)$(CC) -c $(LIBSPARSE_SRCS) $(CFLAGS)
	@$(AR) -x libz.a
	@$(AR) cqs $@.a *.o
	@$(RM) -rfv *.o
	@$(ECHO) "*******************************************"
	
libmincrypt_host:
	@$(ECHO) "Building libmincrypt_host..."
	@$(CROSS_COMPILE)$(CC) -c $(LIBMINCRYPT_SRCS) $(CFLAGS)
	@$(AR) cqs $@.a *.o
	@$(RM) -rfv *.o
	@$(ECHO) "*******************************************"
	
mkbootimg$(EXE):
	@$(ECHO) "Building mkbootimg..."
	@$(CROSS_COMPILE)$(CC) core/mkbootimg/mkbootimg.c -o $@ $(CFLAGS) $(LIBS) libmincrypt_host.a
	@$(ECHO) "*******************************************"
	
mkbootfs$(EXE):
	@$(ECHO) "Building mkbootfs..."
	@$(CROSS_COMPILE)$(CC) core/cpio/mkbootfs.c -o $@ $(CFLAGS) $(LIBS)
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
	@$(CROSS_COMPILE)$(CC) external/android_system_core/mkbootimg/unpackbootimg.c -o $@ $(CFLAGS) $(LIBS) libmincrypt_host.a
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
	libselinux \
	zlib \
	external \
	pcre \
	sepolicy

	@$(ECHO) "*******************************************"
		