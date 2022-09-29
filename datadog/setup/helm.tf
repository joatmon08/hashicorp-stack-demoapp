resource "helm_release" "datadog" {
  name = "datadog"

  repository = "https://helm.datadoghq.com"
  chart      = "datadog"
  version    = var.datadog_helm_version

  set {
    name  = "registry"
    value = "public.ecr.aws/datadog"
  }

  set {
    name  = "datadog.apiKey"
    value = var.datadog_api_key
  }

  set {
    name  = "datadog.clusterName"
    value = local.eks_cluster_name
  }

  set {
    name  = "datadog.site"
    value = "datadoghq.com"
  }

  set {
    name  = "datadog.dogstatsd.port"
    value = "8125"
  }

  set {
    name  = "datadog.dogstatsd.useHostPort"
    value = "true"
  }

  set {
    name  = "datadog.dogstatsd.nonLocalTraffic"
    value = "true"
  }

  set {
    name  = "datadog.networkMonitoring.enabled"
    value = "true"
  }

  set {
    name  = "datadog.apm.portEnabled"
    value = "true"
  }

  set {
    name  = "datadog.logs.enabled"
    value = "true"
  }

  set {
    name  = "datadog.logs.containerCollectAll"
    value = "true"
  }

  set {
    name  = "datadog.containerExclude"
    value = "image:datadog/agent"
  }

  set {
    name  = "datadog.prometheusScrape.enabled"
    value = "true"
  }

  set {
    name  = "datadog.prometheusScrape.serviceEndpoints"
    value = "true"
  }

  set {
    name  = "agents.containers.traceAgent.logLevel"
    value = "DEBUG"
  }
}
