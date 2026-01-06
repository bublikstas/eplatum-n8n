FROM docker.n8n.io/n8nio/n8n:latest

WORKDIR /opt/eplatum
COPY . /opt/eplatum

USER root
RUN chmod +x /opt/eplatum/start-render.sh
USER node

CMD ["/opt/eplatum/start-render.sh"]
