FROM zz535875999/zknow:v0.1

LABEL maintainer="zhen(535875999@qq.com)"

WORKDIR /opt/zknow

COPY ./zknow /opt/zknow

RUN cd /opt/zknow 
RUN npm install -g

EXPOSE 4000

CMD [ "hexo s &" ]


