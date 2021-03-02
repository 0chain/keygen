FROM 0chainkube/zchain_genkeys
COPY ./nodes.sh /root/nodes.sh
COPY ./key_gen.go /0chain/go/0chain.net/core/
ENTRYPOINT ["sh", "/root/nodes.sh"]
