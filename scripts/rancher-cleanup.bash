# Cleanup for Rancher setup
echo "Cleaning up Rancher resources..."

# Delete the Rancher server
echo "Stopping and removing Rancher server..."
docker stop $(docker ps -q --filter "ancestor=rancher/rancher")
docker rm $(docker ps -aq --filter "ancestor=rancher/rancher")

# Remove the kubectl context for Rancher
echo "Removing kubectl context for Rancher..."
kubectl config delete-context rancher-context
kubectl config delete-cluster rancher-cluster

echo "Rancher cleanup completed successfully!"
