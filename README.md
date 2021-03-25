# sample-eks-fargate-infra
## 概要
EKS on FargateのサンプルAppです。  
ネットワークをTerraformで管理し、EKSの作成はeksctlを使います。

## Deploy手順
### Terraform環境立ち上げ
```
$ docker-compose up -d
```

```
$ dokcer-compose exec terraform /bin/ash
```

### ネットワーク作成
```
# terraform apply
```

### EKS作成
eksctlディレクトリ内にあるyamlに作られた値を入力した後に下記のコマンドでクラスターを作成する

### EKSClusterの作成
```
$ eksctl create cluster -f ./eksctl/cluster.yaml 
```

### FargateProfileの作成
```
$ eksctl create fargateprofile -f ./eksctl/fargateprofile.yaml
```

### AWSLoadBalancerControllerの作成
[公式はこちら](https://aws.amazon.com/jp/premiumsupport/knowledge-center/eks-alb-ingress-controller-fargate/)
```
$ kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
```

```
$ helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
      --set clusterName=YOUR_CLUSTER_NAME \
      --set serviceAccount.create=false \
      --set region=<REGION_CODE> \
      --set vpcId=<VPC_ID> \
      --set serviceAccount.name=aws-load-balancer-controller \
      -n kube-system
```

### サンプルアプリのデプロイ
ドメインを変えてDeployして、R53でALBと紐付けてください。
```
$ kubectl apply -f deployment/sample.yaml
```

## その他
### Kubectlのinstall
```
$ brew install kubectl
```

### Helmのinstall
```
$ brew install helm
```

### ALBのannotations一覧
https://kubernetes-sigs.github.io/aws-load-balancer-controller/guide/ingress/annotations/
