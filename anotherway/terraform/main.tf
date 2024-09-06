# creating a cluster with kind of the name "test-cluster" with kubernetes version v1.27.1 and two nodes
resource "kind_cluster" "default" {
    name = "test-cluster"
    node_image = "kindest/node:v1.27.1"
    #kubeconfig_path = pathexpand("./config")
    wait_for_ready  = true

    kind_config  {
        kind = "Cluster"
        api_version = "kind.x-k8s.io/v1alpha4"
        node {
            role = "control-plane"
        }
        node {
            role =  "worker"
        }
    }
}
