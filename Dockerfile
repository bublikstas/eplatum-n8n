FROM n8nio/n8n:2.2.4

USER root
# На всякий случай создаём /data и даём права node
RUN mkdir -p /data && chown -R node:node /data

USER node

# Твои workflows (если нужны)
COPY workflows/ /home/node/workflows/

# Entrypoint
COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]