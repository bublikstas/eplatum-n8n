# eplatum-n8n

## Render Deployment

This repository is configured to deploy on Render as a **Docker service** using the official n8n Docker image (`n8nio/n8n:1.93.0`). The Dockerfile handles workflow imports and n8n startup automatically.

**Note:** Node.js build commands (`npm install`, `npm start`) are no longer used. Render should be configured as a Docker service, not a Node service.