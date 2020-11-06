# minio-client
An OpenShift compatible Minio client to help Bc Gov teams migrate Minio buckets between OCP3 and OCP4 clusters.  This image can be used on the BC Gov OpenShift platform to migrate Minio data directly between different clusters.

#### Why not just use the official Minio Client image?
The official  Minio Client images needs to create a `.mc` directory in the root directory.  This will not work when running on OpenShift because OpenShift runs containers as non-root user.

This image solves this problem by creating the `.mc` directory ahead of the time and give it read and write access to all users.

## Usage
The following documentation assumes you have two Minio deployments running.  The source Minio deployment will be used to copy files from and the destination Minio deployment will be used to copy files to.

To run as a container in OpenShift you must have the required roles to create and run pods in a namespace.

The following commands use syntax for Mac/Linux shell.  Please adjust accordingly if you're on Windows.

### Set environment variables
First create the connection environment variables in the terminal.
```
# Do not include https:// or trailing / in the endpoint
export SRC_MINIO_ENDPOINT=source-minio.pathfinder.gov.bc.ca
export SRC_MINIO_ACCESS_KEY=the-source-minio-access-key
export SRC_MINIO_SECRET_KEY=the-source-minio-secret-key

# Do not include https:// or trailing / in the endpoint
export DST_MINIO_ENDPOINT=destination-minio.apps.silver.devops.gov.bc.ca
export DST_MINIO_ACCESS_KEY=the-destination-minio-access-key
export DST_MINIO_SECRET_KEY=the-destination-minio-secret-key
```
### Run container in OpenShift
The following command will create a temporary pod called `minio-client` in your current logged in namespace. You will be presented with the interactive shell once the pod is up and runing.  

When you exit the pod by typing in `exit` the pod will be destroyed automatically.

Running this image in OpenShift has the advantage of enabling cluster to cluster data transfer
```
oc run -i -t minio-client --rm --restart=Never \
  --env MC_HOST_source="https://$SRC_MINIO_ACCESS_KEY:$SRC_MINIO_SECRET_KEY@$SRC_MINIO_ENDPOINT" \
  --env MC_HOST_destination="https://$DST_MINIO_ACCESS_KEY:$DST_MINIO_SECRET_KEY@$DST_MINIO_ENDPOINT" \
  --image=bcgovneal/minio-client:latest -- /bin/sh
```

### Run container in Docker locally
Running this image locally on your computer will cause all data to pass through your computer from the source to the destination.  This means your internet connection will be used for the data transfer and can signficantly slow the transfer speed and clog your internet connection.

This should only be used for testing purposes or migrating small amount of data.
```
docker run -it --rm --entrypoint=/bin/sh \
  -e MC_HOST_source="https://$SRC_MINIO_ACCESS_KEY:$SRC_MINIO_SECRET_KEY@$SRC_MINIO_ENDPOINT" \
  -e MC_HOST_destination="https://$DST_MINIO_ACCESS_KEY:$DST_MINIO_SECRET_KEY@$DST_MINIO_ENDPOINT" \
  bcgovneal/minio-client:latest
```

### Mirror a bucket
List the existing buckets in your `source` endpoint using `mc ls source`
```
~ $ mc ls source
[2020-11-02 23:31:23 UTC]     0B uploads/
```

Mirror the entire contents of the `source` bucket to the `destination` bucket using `mc mirror source/bucket destination/bucket`
```
~ $ mc mirror source/uploads destination/uploads
...file.pdf:  748.98 MiB / 748.98 MiB ┃▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┃ 43.84 MiB/s
```

More Minio Client references can be found at https://docs.min.io/docs/minio-client-complete-guide.html

Minio Client on Dockerhub https://hub.docker.com/r/minio/mc/
Minio Client on Github https://github.com/minio/mc