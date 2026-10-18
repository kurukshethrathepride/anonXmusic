
FROM python:3.11-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DENO_INSTALL=/usr/local \
    PATH="/usr/local/bin:/usr/local/deno/bin:/root/.deno/bin:${PATH}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    curl \
    ca-certificates \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deno.land/install.sh | sh \
    && install -m 0755 /root/.deno/bin/deno /usr/local/bin/deno \
    && deno --version \
    && ffmpeg -version

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN python -c "import shutil; assert shutil.which('deno'), 'Deno missing'; assert shutil.which('ffmpeg'), 'FFmpeg missing'; print('Deno and FFmpeg PATH checks passed')"

CMD ["python3", "-m", "anony"]
