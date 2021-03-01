FROM 0chainkube/zchain_genkeys
COPY ./entrypoint.sh /root/entrypoint.sh
COPY ./key_gen.go /0chain/go/0chain.net/core/
ENTRYPOINT ["sh", "/root/entrypoint.sh"]