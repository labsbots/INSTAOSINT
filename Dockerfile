FROM python:3.9.2-alpine3.13 as build
WORKDIR /wheels
RUN apk add --no-cache \
    ncurses-dev \
    build-base
COPY docker_reqs.txt /opt/INSTAOSINT/requirements.txt
RUN pip3 wheel -r /opt/INSTAOSINT/requirements.txt


FROM python:3.9.2-alpine3.13
WORKDIR /home/INSTAOSINT
RUN adduser -D INSTAOSINT

COPY --from=build /wheels /wheels
COPY --chown=INSTAOSINT:INSTAOSINT requirements.txt /home/INSTAOSINT/
RUN pip3 install -r requirements.txt -f /wheels \
  && rm -rf /wheels \
  && rm -rf /root/.cache/pip/* \
  && rm requirements.txt

COPY --chown=INSTAOSINT:INSTAOSINT src/ /home/INSTAOSINT/src
COPY --chown=INSTAOSINT:INSTAOSINT main.py /home/INSTAOSINT/
COPY --chown=INSTAOSINT:INSTAOSINT config/ /home/INSTAOSINT/config
USER INSTAOSINT

ENTRYPOINT ["python", "main.py"]
