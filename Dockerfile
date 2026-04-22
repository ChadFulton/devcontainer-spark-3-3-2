FROM mcr.microsoft.com/devcontainers/python:3.12-bookworm

# 1. Install Java 17
ARG TARGETARCH
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    openjdk-17-jdk \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME="/usr/lib/jvm/java-17-openjdk-${TARGETARCH}"

# 2. Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /workspace

RUN chown vscode:vscode /workspace

USER vscode

ENV UV_CACHE_DIR=/home/vscode/.cache/uv
ENV UV_PROJECT_ENVIRONMENT=/home/vscode/.venv

RUN --mount=type=bind,source=.python-version,target=.python-version \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    uv sync --frozen --no-install-project
