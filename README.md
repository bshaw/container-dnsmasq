# container-dnsmasq

A lightweight container for running dnsmasq.

## Usage

### Configuration

The container expects to find config files in `/conf`

```plaintext
# /etc/dnsmasq.conf

conf-dir=/conf/,*.conf
```

### Privileges

Requires capabilities `NET_ADMIN` and `NET_RAW`

### Kubernetes

The primary motivation for creating this image is to be able to run a DHCP server from a single node kubernetes cluster on my home network.

DHCP needs direct access to the host network and privileges which you wouldn't normally provide in a k8s environment, so this helps keep things as isolated and tidy as possible.

#### Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dnsmasq
spec:
  selector:
    matchLabels:
      app: dnsmasq
  replicas: 1
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: dnsmasq
    spec:
      hostNetwork: true
      containers:
        - image: docker.io/bshaw/dnsmasq
          name: dnsmasq
          securityContext:
            capabilities:
              add: ["NET_ADMIN", "NET_RAW"]
          ports:
            - containerPort: 67
              hostPort: 67
              protocol: UDP
          volumeMounts:
            - mountPath: /conf
              name: conf
      restartPolicy: Always
      volumes:
        - name: conf
          persistentVolumeClaim:
            claimName: dnsmasq-conf-pvc
```

#### Podman / Docker

```bash
podman run \
  -d \
  --rm \
  --name=dnsmasq \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  -p 67:67/udp \
  -v /path/to/config:/config \
  --restart unless-stopped \
  bshaw/dnsmasq:latest
```
