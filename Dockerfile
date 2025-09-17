# ---------- Assets stage: build Tailwind CSS ----------
FROM node:20-alpine AS assets
WORKDIR /src

# 1) Install Tailwind + DaisyUI
COPY package*.json ./
RUN npm ci

# 2) Copy Tailwind config + input css
COPY tailwind.config.js styles.css ./

# 3) Make a 'templates' folder and copy your root HTML into it
#    (Tailwind just needs to read them for class scanning/purge)
RUN mkdir -p templates
COPY ./*.html ./templates/

# If later you move files into app/templates/, use this instead:
# COPY app/templates ./templates

# 4) Build CSS
RUN npx tailwindcss -c tailwind.config.js \
  -i ./styles.css \
  -o ./output.css \
  --minify


# ---------- Runtime image ----------
FROM python:3.11-slim AS runtime
WORKDIR /app

# system deps for pip (if needed)
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    ca-certificates curl && rm -rf /var/lib/apt/lists/*

# 5) Python deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 6) App code
COPY . .

# 7) Bring in the built CSS to the right path your templates reference
RUN mkdir -p /app/static/css
COPY --from=assets /src/output.css /app/static/css/output.css

# 8) Non-root (optional)
RUN useradd -m -u 10001 appuser
USER appuser

# 9) Entrypoint (example)
# CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8001", "--proxy-headers"]
