# Bootstrap

## Flux

### Install Flux

```sh
kubectl apply --server-side --kustomize ./clusters/test/flux/bootstrap
```

### Kick off Flux applying this repository

```sh
kubectl apply --server-side --kustomize ./clusters/test/flux/config
```
