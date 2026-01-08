FROM n8nio/n8n:1.93.0

USER root
# На всякий случай создаём /data и даём права node
RUN mkdir -p /data && chown -R node:node /data

USER node

# Твои workflows (если нужны)
COPY workflows/ /home/node/workflows/

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]