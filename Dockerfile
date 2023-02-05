FROM postgres:13.6

# Install gsutils
RUN apt-get update && apt-get install -y apt-transport-https ca-certificates gnupg curl python
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN apt-get update && apt-get install google-cloud-cli

# Script to backup PG to GCS
COPY pg_dump_to_gcs.sh /pg_dump_to_gcs.sh
RUN chmod +x /pg_dump_to_gcs.sh

ENTRYPOINT [ "/pg_dump_to_gcs.sh" ]