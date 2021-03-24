# AWS Load Balancer Controller用のポリシーを作成
# https://aws.amazon.com/jp/premiumsupport/knowledge-center/eks-alb-ingress-controller-fargate/
resource "aws_iam_policy" "alb_ingress" {
  name = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("./iam/alb_policy.json")
}