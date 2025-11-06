# syntax=docker/dockerfile:1

FROM mcr.microsoft.com/playwright:v1.55.1-noble

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

RUN apt-get update && apt-get install -y \
    x11vnc \
    fluxbox \
    novnc \
    supervisor \
    nodejs \
    dbus-x11 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g playwright@1.55

RUN mkdir -p /tmp/.X11-unix \
    && chown root:root /tmp/.X11-unix \
    && chmod 1777 /tmp/.X11-unix

RUN mkdir -p /home/pwuser/.vnc \
    && mkdir -p /opt/bin \
    && mkdir -p /app

# Set up VNC password
RUN x11vnc -storepasswd password /home/pwuser/.vnc/passwd

COPY start-vnc.sh /opt/bin/



# Set working directory
WORKDIR /app

COPY playwright-server-config.json /app/

USER pwuser

CMD ["/opt/bin/start-vnc.sh"]
