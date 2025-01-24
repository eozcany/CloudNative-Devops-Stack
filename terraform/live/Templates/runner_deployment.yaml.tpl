apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: "${name}"
  namespace: "${namespace}"
spec:
  replicas: 1
  template:
    spec:
      repository: "${repository}"
      serviceAccountName: actions-runner
      labels:
%{ for label in labels ~}
      - ${label}
%{ endfor ~}
