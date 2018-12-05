# prereqs

# before steps
 make setup #both rgs
 make secrets
 export KUBECONFIG=`pwd`/.kubeconfig
 make setup-kubernetes
 make setup-kubernetes2

 make acrbuild && make helm2 #offline to 2nd cluster

 #
 make acrbuild
 make helm

 #
 make setup-fd

 # frontdoor setup in portal
 
 make helm-reinstall-frontend