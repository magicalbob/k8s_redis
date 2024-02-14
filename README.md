k8s_redis
=========

Redis in kubernetes YAML.

Set up by running `./install-redis.sh`. It will try to set up a kind cluster if it can't detect a kubernetes cluster.

Once running, write a key with 
    echo -e "AUTH ${REDIS_PASSWORD}\r\nSET universe bye-bye\r\n" | nc -w1 127.0.0.1 6379

Should get back `+OK` ( but I was getting back `-ERR wrong number of arguments for 'auth' command`, haven't worked that out yet).

To read that key:
    echo -e  "AUTH ${REDIS_PASSWORD}\r\nGET universe\r\n" | nc -w1 127.0.0.1 6379|tail -n1|tr -d "[:cntrl:]"

Should get `bye-bye` (or whatever you wrote to the key) back.



