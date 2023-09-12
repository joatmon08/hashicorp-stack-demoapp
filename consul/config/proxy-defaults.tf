resource "consul_config_entry" "proxy_defaults" {
  kind = "proxy-defaults"
  name = "global"

  config_json = jsonencode({
    Expose           = {}
    MeshGateway      = {}
    TransparentProxy = {}
    AccessLogs       = {}

    Config = {
      envoy_dogstatsd_url = "udp://$${HOST_IP}:8125"

      envoy_extra_static_clusters_json = <<EOT
      {
        "name": "datadog_agent",
        "type": "STRICT_DNS",
        "connect_timeout": "1.000s",
        "dns_lookup_family": "V4_ONLY",
        "lb_policy": "ROUND_ROBIN",
        "load_assignment": {
        "cluster_name": "datadog_agent",
        "endpoints": [
            {
            "lb_endpoints": [
                {
                "endpoint": {
                    "address": {
                    "socket_address": {
                        "address": "datadog",
                        "port_value": 8126,
                        "protocol": "TCP"
                    }
                    }
                }
                }
            ]
            }
        ]
        }
      }
      EOT

      envoy_tracing_json = <<EOT
      {
          "http": {
              "name": "envoy.tracers.datadog",
              "typed_config": {
                  "@type": "type.googleapis.com/envoy.config.trace.v3.DatadogConfig",
                  "collector_cluster": "datadog_agent",
                  "service_name": "envoy-proxy"
              }
          }
      }
      EOT
    }
  })
}