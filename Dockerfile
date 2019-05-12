FROM alpine:3.9
LABEL maintainer="julia"
WORKDIR /src
EXPOSE 5000


RUN apk update && apk add nodejs npm

COPY foaas/ /src

RUN npm install
ENTRYPOINT ["npm","start"]
