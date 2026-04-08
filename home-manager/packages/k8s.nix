# Kubernetes and cloud tooling
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kubectl
    kube3d
    k9s
    kubespy
    kdash
    (google-cloud-sdk.withExtraComponents ([ google-cloud-sdk.components.gke-gcloud-auth-plugin ]))
    infra
  ];
}
