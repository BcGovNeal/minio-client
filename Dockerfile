FROM minio/mc

# Create the Minio Client config directory and allow read/write from all users
RUN mkdir /.mc && chmod ugo+rw /.mc

# Override the default entrypoint to do nothing
ENTRYPOINT [ ]