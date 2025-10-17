FROM python:3.12-slim as builder

WORKDIR /app

COPY requirements.txt .
RUN python -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

FROM python:3.12-alpine

ARG LAB_LOGIN=$LAB_TOKEN \
	LAB_TOKEN=$TOKEN

ENV LAB_LOGIN=$LAB_LOGIN \
	LAB_TOKEN=$LAB_TOKEN

LABEL org.lab.login=$LAB_LOGIN \
      org.lab.token=$LAB_TOKEN

WORKDIR /app

RUN apk add --no-cache curl

COPY --from=builder /opt/venv /opt/venv

COPY app/ ./app/

RUN adduser -D user && \
    chown -R user:user /app
	
ENV PATH="/opt/venv/bin:$PATH"

USER user

HEALTHCHECK --interval=5s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1
	
ENTRYPOINT ["python", "-m", "app.app"]