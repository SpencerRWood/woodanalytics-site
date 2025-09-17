# ---- build static assets (Tailwind/DaisyUI) ----
FROM node:20-alpine AS assets
WORKDIR /src
# only copy what we need first for better layer caching
COPY package*.json tailwind.config.js ./
# copy the rest so tailwind has the source files
COPY . .
RUN npm ci
COPY tailwind.config.js styles.css ./         
COPY templates ./templates                    
RUN npx tailwindcss -c tailwind.config.js -i ./styles.css -o ./static/css/output.css --minify

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