# ---- build static assets (Tailwind/DaisyUI) ----
FROM node:20-alpine AS assets
WORKDIR /src

# Install deps first for layer caching
COPY package*.json tailwind.config.js ./
RUN npm ci --no-audit --no-fund

# Copy all sources so Tailwind can scan templates
COPY . .

# Build CSS (writes to /src/app/static/css/output.css)
RUN npm run build:css


# ---- runtime (FastAPI) ----
FROM python:3.11-slim AS runtime
WORKDIR /app

# System deps (if needed)
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    ca-certificates curl && rm -rf /var/lib/apt/lists/*

# Python deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# App code
COPY . .

# Bring in compiled CSS to the exact path your templates reference
# (your container shows files under /app/app/static/css/)
RUN mkdir -p /app/app/static/css
COPY --from=assets /src/app/static/css/output.css /app/app/static/css/output.css

# (optional hardening)
# RUN useradd -m -u 10001 appuser
# USER appuser

# CMD example:
# CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8001", "--proxy-headers"]
