FROM minio/mc

# Minio client needs to create a .mc directory in the root to 
# hold configurations at run time.  This is not possible on OpenShift
# because the container runs as a non-root user.
#
# To solve this we can create the .mc directory ahead of the time
# and give it read and write permission on all users
RUN mkdir /.mc && chmod ugo+rw /.mc

# Override the default entrypoint to do nothing
ENTRYPOINT [ ]