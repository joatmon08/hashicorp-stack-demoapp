Prerequisites:

- Consul 1.9.4
- Helm Chart 0.30.1
- HCP
- Kubernetes

Verified routing and connectivity:

:white_check_mark: Set the database connection host string to the IP address of RDS instance
:white_check_mark: Set the database connection host string to the IP address of pod IP for the Postgres


Tried, still doesn't work:

:x: Deployed a Postgres instance in K8s. Registered it to terminating gateway.
    - Removed ACLs
    - Setting intentions to allow all
    - Use `payload.json` to explicitly register the database.
    - Clusters show up in `curl localhost:19000/clusters` in Terminating Gateway.
    - Downstream service still doesn't connect:
      ```
      2021/03/22 18:55:58 Initializing logging reporter
      2021-03-22T18:55:58.240Z [ERROR] Unable to connect to database: error="dial tcp 127.0.0.1:5432: connect: connection refused"
      2021-03-22T18:56:00.245Z [ERROR] Unable to connect to database: error="unexpected EOF"
      2021-03-22T18:56:02.249Z [ERROR] Unable to connect to database: error="unexpected EOF"
      ```

:x: Deployed a Postgres instance in K8s. Registered it to terminating gateway.
    - Removed ACLs
    - Setting intentions to allow all
    - Use `payload.json` to explicitly register the database.
    - Clusters show up in `curl localhost:19000/clusters` in Terminating Gateway.
    - Downstream service still doesn't connect:
      ```
      2021/03/22 18:55:58 Initializing logging reporter
      2021-03-22T18:55:58.240Z [ERROR] Unable to connect to database: error="dial tcp 127.0.0.1:5432: connect: connection refused"
      2021-03-22T18:56:00.245Z [ERROR] Unable to connect to database: error="unexpected EOF"
      2021-03-22T18:56:02.249Z [ERROR] Unable to connect to database: error="unexpected EOF"
      ```