# ---- build static assets (Tailwind/DaisyUI) ----
FROM node:20-alpine AS assets
WORKDIR /src

COPY package*.json ./
RUN npm ci

# Tailwind input + config
COPY tailwind.config.js styles.css ./

# Copy templates so Tailwind can scan them
# (adjust path if yours differ)
RUN mkdir -p templates
COPY app/templates ./templates
# If you also keep some root HTML pages:
# COPY ./*.html ./templates/

# Build CSS
RUN npx tailwindcss -c tailwind.config.js \
    -i ./styles.css \
    -o ./output.css \
    --minify

# ---- python runtime ----

FROM python:3.11-slim AS runtime
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# security: create non-root user
RUN useradd -m -u 10001 appuser

WORKDIR /app
# install system deps as needed (curl for healthchecks/logs if desired)
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

# python deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# app code
COPY . .

# bring in the built CSS from the assets stage (adjust path to your repo)
# if your build wrote to ./app/static/css/output.css per your package.json, this matches it:
COPY --from=assets /src/app/static /app/app/static

# drop privileges
USER appuser

EXPOSE 8001
# NOTE: we’ll set the exact command in docker-compose.prod.yml