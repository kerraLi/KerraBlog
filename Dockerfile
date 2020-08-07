FROM zz535875999/zknow:v0.1

LABEL maintainer="zhen(535875999@qq.com)"

COPY ./zknow /opt/

RUN cd /opt/zknow && npm install -g

EXPOSE 4000

CMD [ "hexo s &" ]


