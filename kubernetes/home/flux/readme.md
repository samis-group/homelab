# Bootstrap

## Flux

### Install Flux

```sh
kubectl apply --server-side --kustomize ./kubernetes/home/flux/bootstrap
```

### Kick off Flux applying this repository

```sh
kubectl apply --server-side --kustomize ./kubernetes/home/flux/config
```
