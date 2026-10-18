
FROM python:3.11-slim-bookworm

ENV PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    DENO_INSTALL=/usr/local

# Install FFmpeg and the tools required to install Deno.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    curl \
    ca-certificates \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Deno into /usr/local/bin.
RUN curl -fsSL https://deno.land/install.sh | sh \
    && test -x /usr/local/bin/bin/deno \
    && ln -sf /usr/local/bin/bin/deno /usr/local/bin/deno

ENV PATH="/usr/local/bin:${PATH}"

# Verify both executables during the image build.
RUN command -v deno \
    && deno --version \
    && command -v ffmpeg \
    && ffmpeg -version

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Verify the executables are discoverable by Python.
RUN python -c "import shutil; assert shutil.which('deno'), 'Deno missing'; assert shutil.which('ffmpeg'), 'FFmpeg missing'; print('Deno and FFmpeg are accessible')"

CMD ["python", "-m", "anony"]
