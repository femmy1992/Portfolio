# Migrate from local machine to Kubernetes cloud 
1. write a python code and download flask to run the website
-install flask in a directory in your project directory with =  
# https://flask.palletsprojects.com/en/2.2.x/installation/
a. python3 -m venv venv = to create an environment 
b. . venv/bin/activate = to activate the environment 
c. pip install Flask = to install 
d. pip3 show flask = to see version
- check if the server is running in the specified port with = python3 ./server.py
- if the port is not available check who is using the port with = lsof -i:<port_number>
- verify on your browser with = localhost:5050

2. containerize the code still in your local machine
- install docker GUI on local with = brew install docker --cask (because it is a GUI)
- create a dockerfile 
- run docker build -t <image-name> . = to create an image
- run docker images = to view list of images 
- run docker run -d -p 5050:5050 <image> = to create a container
- run docker logs <container-id> = to check container log

3. Prepare for cloud by pushing your image to docker hub
- create a repo in dockerhub = femmy1992/flaskapp
- run docker login = to login to your docker hub from cli
- run docker tag <image-id> femmy1992/flaskapp:v1.0.0 = to tag your image with your repo 
- run docker push femmy1992/flaskapp:v1.0.0 = to push to repo

4. Deploy into Cloud AWS
- authenticate local computer with aws with =  aws eks get-token --cluster-name <clustername> or 
- install authenticatior with = brew install aws-iam-authenticator
- test with = aws-iam-authenticator help
- instal eksctl with = brew tap weaveworks/tap
brew install weaveworks/tap/eksctl
- install kubectl and check version with = kubectl version --short --client
- run eksctl create cluster = to create a serverless cluster
- run kubectl get pods = to see pods 
- create deployment.yml file via cli with = kubectl create deployment <deployment-name> --image=femmy1992/flaskapp:v1.0.0 --dry-run=client -o yaml > <file-name.yaml>   
# --dry-run=client means it wont run it.
- kubectl apply -f <filen-name> = to deploy

5. Expose container to the world by creating a service and pointing to the pod 
- create a service on the deployment file with loadbalancer and increase replica
- reapply the flaskdeployment.yaml file 
- run kubectl get service = to see the service created and loadbalancer


