$ cat <<EOF | kubectl apply -f -
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-with-tls
  annotations:
      kubernetes.io/ingress.class: nginx
spec:
  rules:
      - host: test.example.com
        http:
          paths:
          - backend:
              serviceName: echoserver-svc
              servicePort: 8080
            path: /ping
  tls:
      - hosts:
        - test.example.com
        secretName: tls-secret-test-example-com
EOF