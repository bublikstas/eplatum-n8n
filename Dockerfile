FROM docker.n8n.io/n8nio/n8n:1.93.0

WORKDIR /home/node

# Copy entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh

# Copy workflows directory if it exists
COPY workflows /home/node/workflows

USER root
RUN chmod +x /docker-entrypoint.sh
USER node

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["n8n", "start"]
