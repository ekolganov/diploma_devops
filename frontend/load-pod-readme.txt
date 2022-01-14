# exec pod
k exec -ti traffic-generator -- sh
# install wrk
apk add --no-cache wrk
# gen load; -d duration -c connection open time -t treads -d -H header
wrk -c 5 -t 5 -d 99999 -H "Connection: Close" http://nhl-app-fe-svc


#checks
k get hpa
k top po
k get po
