CLUSTER_NAME="test-cluster"
CONTEXT_NAME="kind-${CLUSTER_NAME}"

# Add Bitnami PostgreSql Repo
helm repo add bitnami https://charts.bitnami.com/bitnami
# Update Helm Repo
helm repo update
# Add Persistent Volume to Kind Cluster
kubectl --context ${CONTEXT_NAME} apply -f postgresql/postgres-pv.yaml
# Add Persistent Volume Claim to Kind Cluster
kubectl --context ${CONTEXT_NAME} apply -f postgresql/postgres-pvc.yaml
# Get PVC
kubectl --context ${CONTEXT_NAME} get pvc
# Install Bitnami PostgreSql Helm Chart
helm install psql-test bitnami/postgresql --set persistence.existingClaim=postgresql-pv-claim --set volumePermissions.enabled=true
