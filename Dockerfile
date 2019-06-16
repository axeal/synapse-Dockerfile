ARG PYTHON_VERSION=3.6
ARG SYNAPSE_VERSION=v1.0.0

FROM python:${PYTHON_VERSION}-alpine3.8 as builder

RUN apk add git

RUN pip install --prefix="/install" git+https://github.com/srhoulam/synapse-s3-storage-provider.git

FROM matrixdotorg/synapse:${SYNAPSE_VERSION}

COPY --from=builder /install /usr/local

RUN echo $'{% if AWS_ACCESS_KEY_ID %}\
media_storage_providers:\n\
- module: s3_storage_provider.S3StorageProviderBackend\n\
  store_local: True\n\
  store_remote: True\n\
  store_synchronous: True\n\
  config:\n\
    bucket: "{{ S3_BUCKET }}"\n\
{% if S3_ENDPOINT %}\
    endpoint_url: "{{ S3_ENDPOINT }}"\n\
{% endif %}\
{% endif %}\n' >> /conf/homeserver.yaml
