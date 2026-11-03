
# Stage 1: Dependencies
FROM node:22-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Stage 2: Production
FROM node:22-alpine

WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --chown=appuser:appgroup package.json ./
COPY --chown=appuser:appgroup instrumentation.js ./instrumentation.js
COPY --chown=appuser:appgroup src ./src

ENV NODE_ENV=production

EXPOSE 5001

USER appuser

CMD ["npm", "start"]

