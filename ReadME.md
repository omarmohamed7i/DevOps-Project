omar@Alaswar:~/Music/pikado-task$ kubectl create namespace web-app --dry-run=client -o yaml | kubectl apply -f -
namespace/web-app created



omar@Alaswar:~/Music/pikado-task$ helm upgrade --install webapp ./helm/webapp --namespace web-app
^[[BRelease "webapp" has been upgraded. Happy Helming!
NAME: webapp
LAST DEPLOYED: Thu Nov 20 14:31:02 2025
NAMESPACE: web-app
STATUS: deployed
REVISION: 2
DESCRIPTION: Upgrade complete
TEST SUITE: None



omar@Alaswar:~/Music/pikado-task$ kubectl get pods -n web-app
NAME                      READY   STATUS    RESTARTS   AGE
webapp-6d8549775d-g55cw   1/1     Running   0          43s
webapp-6d8549775d-t77wn   1/1     Running   0          54s
omar@Alaswar:~/Music/pikado-task$ kubectl get svc -n web-app
NAME     TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
webapp   ClusterIP   10.2.1.14    <none>        80/TCP    2m39s
omar@Alaswar:~/Music/pikado-task$ curl ^C
omar@Alaswar:~/Music/pikado-task$ kubectl port-forward -n web-app svc/webapp 8081:80
Forwarding from 127.0.0.1:8081 -> 8080
Forwarding from [::1]:8081 -> 8080
Handling connection for 8081
Handling connection for 8081
Handling connection for 8081


curl -s http://localhost:8081
OUT
Hello from Omar Alaswar, this is Pikade task 👋 — running on Node.js!
Bash
⎿
Test the health endpoint
IN
curl -s http://localhost:8081/health
OUT
{"status":"UP","timestamp":"2025-11-20T12:33:41.480Z"}








omar@Alaswar:~/Music/pikado-task$ kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
namespace/monitoring created
omar@Alaswar:~/Music/pikado-task$ kubectl apply -f monitoring/prometheus.yaml
configmap/prometheus-config created
deployment.apps/prometheus created
service/prometheus created
omar@Alaswar:~/Music/pikado-task$ kubectl apply -f monitoring/grafana.yaml
deployment.apps/grafana created
configmap/grafana-config created
service/grafana created
omar@Alaswar:~/Music/pikado-task$ kubectl get pods -n monitoring
NAME                          READY   STATUS              RESTARTS   AGE
grafana-544bf94d4f-psr6z      0/1     ContainerCreating   0          111s
prometheus-6f8d46bf76-l8hws   1/1     Running             0          2m14s
omar@Alaswar:~/Music/pikado-task$ kubectl get pods -n monitoring
NAME                          READY   STATUS    RESTARTS   AGE
grafana-6dff7744d8-tmmqp      1/1     Running   0          84s
prometheus-6f8d46bf76-l8hws   1/1     Running   0          17m
omar@Alaswar:~/Music/pikado-task$ 
omar@Alaswar:~/Music/pikado-task$ omar@Alaswar:~/Music/pikado-task$ kubectl get pods -n monitoring
NAME                          READY   STATUS              RESTARTS   AGE
grafana-544bf94d4f-psr6z      0/1     ContainerCreating   0          111s
prometheus-6f8d46bf76-l8hws   1/1     Running             ^C
omar@Alaswar:~/Music/pikado-task$ ^C
omar@Alaswar:~/Music/pikado-task$ ^C
omar@Alaswar:~/Music/pikado-task$ kubectl port-forward -n monitoring svc/prometheus 9090:9090
Forwarding from 127.0.0.1:9090 -> 9090
Forwarding from [::1]:9090 -> 9090
Handling connection for 9090
Handling connection for 9090
Handling connection for 9090
Handling connection for 9090
![alt text](image.png)


omar@Alaswar:~/Music/pikado-task$ 
omar@Alaswar:~/Music/pikado-task$ kubectl get pods -n monitoring | grep grafana
grafana-6dff7744d8-tmmqp      1/1     Running   0          6s
omar@Alaswar:~/Music/pikado-task$ .
bash: .: filename argument required
.: usage: . filename [arguments]
omar@Alaswar:~/Music/pikado-task$ kubectl port-forward -n monitoring svc/grafana 3000:3000
Forwarding from 127.0.0.1:3000 -> 3000
Forwarding from [::1]:3000 -> 3000
Handling connection for 3000


![alt text](image-1.png)