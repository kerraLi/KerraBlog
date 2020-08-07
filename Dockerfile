FROM zz535875999/zknow:v0.1

LABEL maintainer="zhen(535875999@qq.com)"

ENV HEXO_SERVER_PORT=4000

WORKDIR /opt/zknow

COPY ./zknow ./

RUN npm install -g
RUN npm install -g hexo
RUN npm install -g hexo-server --save
RUN npm install -g hexo-cli


CMD ["ls /usr/bin/hexo"]


