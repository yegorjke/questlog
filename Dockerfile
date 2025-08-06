FROM python:3.13-slim

EXPOSE 8000

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV UV_SYSTEM_PYTHON=1

RUN apt-get update && apt-get install -y \
    curl ca-certificates build-essential libpq-dev && \
    apt-get clean

# Wait-for-it utility
RUN curl --silent -o wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh
RUN chmod +x wait-for-it.sh

# Download and install uv
ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && \
    mv /root/.local/bin/uv /usr/local/bin/uv && \
    rm /uv-installer.sh

RUN adduser -uid 5678 --disabled-password --gecos "" appuser

# Сopy files and install dependencies
WORKDIR /app
RUN chown -R appuser:appuser /app
COPY . .
COPY .env.docker .env
RUN uv sync --locked --no-dev --no-install-project
RUN chmod +x ./entrypoint.sh

USER appuser

ENTRYPOINT ["./entrypoint.sh"]
CMD ["uv", "run", "--no-sync", "uvicorn", "questlog.app:app", "--host", "0.0.0.0", "--port", "8000"]
