FROM 0chainkube/zchain_genkeys
COPY ./single.sh /root/single.sh
COPY ./key_gen.go /0chain/go/0chain.net/core/
ENTRYPOINT ["sh", "/root/single.sh"]
