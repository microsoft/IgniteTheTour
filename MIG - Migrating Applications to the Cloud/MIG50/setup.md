# prereqs

# before steps
 make setup #both rgs
 make secrets
 export KUBECONFIG=`pwd`/.kubeconfig
 make setup-kubernetes
 make setup-kubernetes2

 make acrbuild && make helm2 #offline to 2nd cluster
 make setup-fd

 # demo - helm deployment

 make acrbuild
 make helm

## demo - Azure Front Door Basics
 make setup-fd (idempotent)
 - then show front door in portal
 
## demo - multi region AKS
 make helm-reinstall-frontend
 - change the frontend to go through FD to get to the backend
 - this changes the CORS headers so that the FE can talk to FD

 then helm delete one of the frontend releases
 and show the app still working
 - except for the healthcheck timeout period
 - show the healthcheck & the healthcheck frequency in the portal
   - Explain the tradeoffs in business requirement terms


