docker run -it --rm --privileged --cap-add=NET_ADMIN --net=host \

-v /lib/modules:/lib/modules \
-v `pwd`/my_config:/etc/ipsec.config.d \
-v `pwd`/my_secrets:/etc/ipsec.secrets.d <image>
