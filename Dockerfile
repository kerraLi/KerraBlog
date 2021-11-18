FROM ubuntu:20.04

LABEL maintainer="zhen(535875999@qq.com)"

ENV HEXO_SERVER_PORT=4000

WORKDIR /opt/zknow

COPY start.sh /opt/zknow/

RUN chmod +X start.sh

RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list \
     && sed -i s@/security.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list \
     && apt clean

RUN apt update \
    && apt install -y tzdata \
    && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata

RUN apt-get install git curl dirmngr apt-transport-https lsb-release ca-certificates -y \
    && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean

RUN npm config set registry https://registry.npm.taobao.org

RUN npm install hexo-cli -g \
    && npm i hexo -g \
    && npm i hexo-generator-json-content --save \
    && npm i --save hexo-wordcount
 
RUN git clone https://github.com/MrYuanZhen/zknow_blog.git

RUN cd zknow_blog/zknow && npm install -g 

CMD [ "/bin/bash","start.sh" ]