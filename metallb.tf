resource "helm_release" "metallb" {
  name             = "metallb"
  repository       = "https://metallb.github.io/metallb"
  chart            = "metallb"
  namespace        = "metallb"
  version          = "0.10.3"
  create_namespace = true
  timeout = 300
  values = [
    <<-EOF
  configInline:
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 172.16.100.170-172.16.100.180
  EOF
  ]
}

resource "null_resource" "wait_for_metallb" {
  triggers = {
    key = uuid()
  }

  provisioner "local-exec" {
    command = <<EOF
      printf "\nWaiting for the metallb controller...\n"
      kubectl wait --namespace ${helm_release.metallb.namespace} \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=speaker \
        --timeout=90s
    EOF
  }

  depends_on = [helm_release.metallb]
}
