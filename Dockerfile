# Multi-stage build for optimal image size and security
# Stage 1: Build the client assets and bundle the server
FROM node:20-slim AS builder

WORKDIR /app

# Copy package descriptors for dependency installation caching
COPY package*.json ./

# Install all dependencies (including devDependencies needed for build)
RUN npm ci

# Copy application source code
COPY . .

# Build the Vite SPA client and the Esbuild Express server bundle
RUN npm run build

# Stage 2: Production runtime image
FROM node:20-slim AS runner

WORKDIR /app

# Configure production environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Copy package descriptors
COPY package*.json ./

# Install production dependencies only (using cached npm cache if possible)
RUN npm ci --omit=dev

# Copy only the built production assets and server bundle from builder stage
COPY --from=builder /app/dist ./dist

# Expose the designated application port
EXPOSE 3000

# Start the full-stack server
CMD ["npm", "run", "start"]
