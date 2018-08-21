# aidb
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fpeterducai%2Faidb.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fpeterducai%2Faidb?ref=badge_shield)

asset inventory database

## Psql

```bash
export PGPASSWORD=<password>
psql -h <host> -d <database> -U <user_name> -p <port> -a -w -f <file>.sql
```

## Docker

to run DB use 

```bash
sudo docker stop aidb1 && sudo docker rm aidb1
sudo docker run -it --name aidb1 -p 5432:5432 -e POSTGRES_PASSWORD=post123. -d peterducai/aidb:latest
sudo docker logs aidb1
```


> see also https://github.com/peterducai/aidb_portal


## License
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fpeterducai%2Faidb.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Fpeterducai%2Faidb?ref=badge_large)