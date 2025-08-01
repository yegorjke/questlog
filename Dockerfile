FROM python:3.13-slim

EXPOSE 8000

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV POETRY_VERSION=1.8.2

RUN apt-get update && apt-get install -y \
    curl build-essential libpq-dev && \
    apt-get clean

RUN curl -sSL https://install.python-poetry.org | python3 -

ENV PATH="/root/.local/bin:$PATH"

WORKDIR /app
COPY pyproject.toml poetry.lock* ./

RUN poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi

COPY . .

RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

CMD ["uvicorn", "questlog.app:app", "--host", "0.0.0.0", "--port", "8000"]
