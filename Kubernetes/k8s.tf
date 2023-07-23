provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "aws" {
  region = "eu-central-1"
}

resource "kubernetes_deployment" "asp-web" {
  metadata {
    name = "asp-web"
    labels = {
      test = "MyExampleApp"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        test = "MyExampleApp"
      }
    }

    template {
      metadata {
        labels = {
          test = "MyExampleApp"
        }
      }

      spec {
        container {
          image = "nadertarekcs/asp-web:latest"
          name  = "asp-web"
        }
      }
    }
  }
}

resource "kubernetes_service" "asp-web-svc" {
  metadata {
    name = "asp-web-svc"
    
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol": "http"
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert": "arn:aws:acm:eu-central-1:424647653049:certificate/65ae985f-6ef3-47df-aa2f-46eebc54fd16"
      "service.beta.kubernetes.io/aws-load-balancer-type": "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-scheme": "internet-facing"
      "service.beta.kubernetes.io/aws-load-balancer-subnets": "subnet-0da9983ec3e64f47f, subnet-0436dde985afc8b56, subnet-0c5cb7f238883763d"
      "service.beta.kubernetes.io/aws-load-balancer-type": "external"
      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports": "443"
    }
  }

  spec {
    port {
      port        = 443
      target_port = 80
    }

    selector = {
      test = "MyExampleApp"
    }

    type = "LoadBalancer"
    load_balancer_class               = "service.k8s.aws/nlb"
  }
}

output "load_balancer_hostname" {
  value = kubernetes_service.asp-web-svc.status.0.load_balancer.0.ingress.0.hostname
}

resource "aws_route53_record" "nadertarek-tech" {
  zone_id = "Z079026035LKLVWDVQ4EH"
  name    = "www.nadertarek.tech"
  type    = "CNAME"
  ttl     = "6"
  records = [kubernetes_service.asp-web-svc.status.0.load_balancer.0.ingress.0.hostname]
}