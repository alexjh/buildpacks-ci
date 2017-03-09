# Building/Pushing

wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64

docker build -t cfbuildpacks/cf-tracker-resource .
docker push cfbuildpacks/cf-tracker-resource
