# Дипломный практикум в Yandex.Cloud
## Цели:
- Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
- Запустить и сконфигурировать Kubernetes кластер.
- Установить и настроить систему мониторинга.
- Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
- Настроить CI для автоматической сборки и тестирования.
- Настроить CD для автоматического развёртывания приложения.
- Этапы выполнения:
- Создание облачной инфраструктуры
- Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи Terraform.
## Особенности выполнения:
- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов; Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.
- Следует использовать версию Terraform не старше 1.5.x .
### Предварительная подготовка к установке и запуску Kubernetes кластера.
- Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
- Подготовьте backend для Terraform:
- а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
- б. Альтернативный вариант: Terraform Cloud
- Создайте VPC с подсетями в разных зонах доступности.
- Убедитесь, что теперь вы можете выполнить команды terraform destroy и terraform apply без дополнительных ручных действий.
- В случае использования Terraform Cloud в качестве backend убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.
[main.tf](https://github.com/EVolgina/diplom/blob/main/main.tf)
```
yandex_vpc_network.netology-net: Creating...
yandex_vpc_network.netology-net: Creation complete after 4s [id=enp574hn21e49lro42lu]
yandex_vpc_subnet.subnet-a: Creating...
yandex_vpc_subnet.subnet-b: Creating...
yandex_vpc_subnet.subnet-b: Creation complete after 1s [id=e2lg089v5thgaocri3ub]
yandex_vpc_subnet.subnet-a: Creation complete after 2s [id=e9bho6ned3f0m86i5jr6]
yandex_lb_target_group.target-group: Creating...
yandex_compute_instance_group.lamp-group: Creating...
yandex_lb_target_group.target-group: Creation complete after 2s [id=enp1s16ahvqclg9i9j0p]
yandex_lb_network_load_balancer.vp-nlb-1: Creating...
yandex_lb_network_load_balancer.vp-nlb-1: Creation complete after 3s [id=enpu9l3p91q1tgr3nt2m]
yandex_compute_instance_group.lamp-group: Still creating... [10s elapsed]
yandex_compute_instance_group.lamp-group: Still creating... [20s elapsed]
yandex_compute_instance_group.lamp-group: Still creating... [30s elapsed]
yandex_compute_instance_group.lamp-group: Still creating... [40s elapsed]
yandex_compute_instance_group.lamp-group: Still creating... [50s elapsed]
yandex_compute_instance_group.lamp-group: Still creating... [1m0s elapsed]
yandex_compute_instance_group.lamp-group: Still creating... [1m10s elapsed]
yandex_compute_instance_group.lamp-group: Still creating... [1m20s elapsed]
yandex_compute_instance_group.lamp-group: Still creating... [1m30s elapsed]
yandex_compute_instance_group.lamp-group: Still creating... [1m40s elapsed]
yandex_compute_instance_group.lamp-group: Still creating... [1m50s elapsed]
yandex_compute_instance_group.lamp-group: Still creating... [2m0s elapsed]
yandex_compute_instance_group.lamp-group: Still creating... [2m10s elapsed]
yandex_compute_instance_group.lamp-group: Creation complete after 2m16s [id=cl1lbted00hkbv720d0v]
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.
Outputs:
bucket_access_key = <sensitive>
pic-url = "https://storage.yandexcloud.net/paint"
```
![YC](https://github.com/EVolgina/diplom/blob/main/VM14.png)
```
yandex_iam_service_account_static_access_key.sa-static-key: Destroying... [id=aje2vjsuj1i30etg7jvm]
yandex_lb_network_load_balancer.vp-nlb-1: Destroying... [id=enpu9l3p91q1tgr3nt2m]
yandex_compute_instance_group.lamp-group: Destroying... [id=cl1lbted00hkbv720d0v]
yandex_iam_service_account_static_access_key.sa-static-key: Destruction complete after 2s
yandex_lb_network_load_balancer.vp-nlb-1: Destruction complete after 4s
yandex_lb_target_group.target-group: Destroying... [id=enp1s16ahvqclg9i9j0p]
yandex_lb_target_group.target-group: Destruction complete after 2s
yandex_compute_instance_group.lamp-group: Still destroying... [id=cl1lbted00hkbv720d0v, 10s elapsed]
yandex_compute_instance_group.lamp-group: Still destroying... [id=cl1lbted00hkbv720d0v, 20s elapsed]
yandex_compute_instance_group.lamp-group: Still destroying... [id=cl1lbted00hkbv720d0v, 30s elapsed]
yandex_compute_instance_group.lamp-group: Still destroying... [id=cl1lbted00hkbv720d0v, 40s elapsed]
yandex_compute_instance_group.lamp-group: Still destroying... [id=cl1lbted00hkbv720d0v, 50s elapsed]
yandex_compute_instance_group.lamp-group: Still destroying... [id=cl1lbted00hkbv720d0v, 1m0s elapsed]
yandex_compute_instance_group.lamp-group: Destruction complete after 1m9s
yandex_vpc_subnet.subnet-b: Destroying... [id=e2lg089v5thgaocri3ub]
yandex_vpc_subnet.subnet-a: Destroying... [id=e9bho6ned3f0m86i5jr6]
yandex_vpc_subnet.subnet-b: Destruction complete after 2s
yandex_vpc_subnet.subnet-a: Destruction complete after 5s
yandex_vpc_network.netology-net: Destroying... [id=enp574hn21e49lro42lu]
yandex_vpc_network.netology-net: Destruction complete after 1s

Destroy complete! Resources: 7 destroyed.
```
![YC1](https://github.com/EVolgina/diplom/blob/main/destroy.png)

### Ожидаемые результаты:
- Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
- Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.
- Создание Kubernetes кластера
- На этом этапе необходимо создать Kubernetes кластер на базе предварительно созданной инфраструктуры. Требуется обеспечить доступ к ресурсам из Интернета.
## Это можно сделать двумя способами:
- Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.
- а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.
- б. Подготовить ansible конфигурации, можно воспользоваться, например Kubespray
- в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
  # Альтернативный вариант: воспользуйтесь сервисом Yandex Managed Service for Kubernetes
- а. С помощью terraform resource для kubernetes создать региональный мастер kubernetes с размещением нод в разных 3 подсетях
- б. С помощью terraform resource для kubernetes node group
## Ожидаемый результат:
- Работоспособный Kubernetes кластер.
- В файле ~/.kube/config находятся данные для доступа к кластеру.
- Команда kubectl get pods --all-namespaces отрабатывает без ошибок.
```  
vagrant@vagrant:~/diplom$ ssh ubuntu@158.160.66.21 - подключаемся к одной из ВМ  настраиваем все и проверяем
Welcome to Ubuntu 18.04.6 LTS (GNU/Linux 4.15.0-55-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro


#################################################################
This instance runs Yandex.Cloud Marketplace product
You can view generated credentials in /root/default_passwords.txt

Only 80, 443 and 22 tcp ports are open by default
To view all network permissions exec “sudo iptables-save” and “sudo ip6tables-save”

Documentation for Yandex Cloud Marketplace images available at https://cloud.yandex.ru/docs

#################################################################

Last login: Sun Jul 14 13:22:49 2024 from 95.164.33.154
ubuntu@cl1ald2puucg4gqoi8h6-apav:~$ curl -LO https://dl.k8s.io/release/`curl -LS https://dl.k8s.io/release/stable.txt`/bin/linux/amd64/kubectl
ubuntu@cl1ald2puucg4gqoi8h6-apav:~$ chmod +x ./kubectl
ubuntu@cl1ald2puucg4gqoi8h6-apav:~$ sudo mv ./kubectl /usr/local/bin/kubectl
ubuntu@cl1ald2puucg4gqoi8h6-apav:~$ kubectl version --client
Client Version: v1.30.2
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
ubuntu@cl1mfrel9uvdtfjp7mdf-inyb:~$ curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
Downloading yc 0.129.0
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 79.5M  100 79.5M    0     0   142M      0 --:--:-- --:--:-- --:--:--  142M
Yandex Cloud CLI 0.129.0 linux/amd64

yc PATH has been added to your '/home/ubuntu/.bashrc' profile
yc bash completion has been added to your '/home/ubuntu/.bashrc' profile.
Now we have zsh completion. Type "echo 'source /home/ubuntu/yandex-cloud/completion.zsh.inc' >>  ~/.zshrc" to install itTo complete installation, start a new shell (exec -l $SHELL) or type 'source "/home/ubuntu/.bashrc"' in the current one
ubuntu@cl1mfrel9uvdtfjp7mdf-inyb:~$ export PATH="$HOME/yandex-cloud/bin:$PATH"
ubuntu@cl1mfrel9uvdtfjp7mdf-inyb:~$ source ~/.bashrc
ubuntu@cl1mfrel9uvdtfjp7mdf-inyb:~$ yc init
Welcome! This command will take you through the configuration process.
Please go to https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb in order to obtain OAuth token.
 Please enter OAuth token: 
You have one cloud available: 'devops27' (id = b1g33d60o7ji59no0on4). It is going to be used by default.
Please choose folder to use:
 [1] doc (id = b1gpoeqn2q7if0pboa4u)
 [2] Create a new folder
Please enter your numeric choice: 1
Your current folder has been set to 'doc' (id = b1gpoeqn2q7if0pboa4u).
Do you want to configure a default Compute zone? [Y/n] y
Please enter 'yes' or 'no': yes
Which zone do you want to use as a profile default?
 [1] ru-central1-a
 [2] ru-central1-b
 [3] ru-central1-c
 [4] ru-central1-d
 [5] Don't set default zone
Please enter your numeric choice: 1
Your profile default Compute zone has been set to 'ru-central1-a'.
ubuntu@cl1ald2puucg4gqoi8h6-apav:~$ yc managed-kubernetes cluster get-credentials catta4q7s8kk7h0735g4 --internal --force
Context 'yc-k8s-regional' was added as default to kubeconfig '/home/ubuntu/.kube/config'.
Check connection to cluster using 'kubectl cluster-info --kubeconfig /home/ubuntu/.kube/config'.
Note, that authentication depends on 'yc' and its config profile 'default'.
To access clusters using the Kubernetes API, please use Kubernetes Service Account.
ubuntu@cl1mfrel9uvdtfjp7mdf-inyb:~$ curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 11694  100 11694    0     0  70872      0 --:--:-- --:--:-- --:--:-- 70872
[WARNING] Could not find git. It is required for plugin installation.
Downloading https://get.helm.sh/helm-v3.15.3-linux-amd64.tar.gz
Verifying checksum... Done.
Preparing to install helm into /usr/local/bin
helm installed into /usr/local/bin/helm
ubuntu@cl1mfrel9uvdtfjp7mdf-inyb:~$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
"prometheus-community" has been added to your repositories
ubuntu@cl1mfrel9uvdtfjp7mdf-inyb:~$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "prometheus-community" chart repository
Update Complete. ⎈Happy Helming!⎈
ubuntu@cl1ald2puucg4gqoi8h6-apav:~$ yc managed-kubernetes cluster list
+----------------------+--------------+---------------------+---------+---------+-------------------+-------------------+
|          ID          |     NAME     |     CREATED AT      | HEALTH  | STATUS  | EXTERNAL ENDPOINT | INTERNAL ENDPOINT |
+----------------------+--------------+---------------------+---------+---------+-------------------+-------------------+
| catta4q7s8kk7h0735g4 | k8s-regional | 2024-07-14 08:19:24 | HEALTHY | RUNNING |                   | https://10.5.0.14 |
+----------------------+--------------+---------------------+---------+---------+-------------------+-------------------+
yc managed-kubernetes cluster get-credentials  cat8vr85b8482faa506v --external --force --kubeconfig ~/.kube/config
ubuntu@cl1ald2puucg4gqoi8h6-apav:~$ kubectl cluster-info
Kubernetes control plane is running at https://10.5.0.14
CoreDNS is running at https://10.5.0.14/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

ubuntu@cl1ald2puucg4gqoi8h6-apav:~$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                  READY   STATUS    RESTARTS        AGE
kube-system   coredns-57b57bfc5b-sbgdg              1/1     Running   0               5h28m
kube-system   ip-masq-agent-lm9vl                   1/1     Running   0               5h24m
kube-system   kube-dns-autoscaler-bd7cc5977-cngmj   1/1     Running   0               5h28m
kube-system   kube-proxy-zqbfm                      1/1     Running   0               5h24m
kube-system   metrics-server-6f485d9c99-qsj4w       2/2     Running   1 (5h22m ago)   5h23m
kube-system   npd-v0.8.0-7mr2q                      1/1     Running   0               5h24m
kube-system   yc-disk-csi-node-v2-67wtx             6/6     Running   0               5h24m
ubuntu@cl1ald2puucg4gqoi8h6-apav:~$ kubectl get nodes -o wide
NAME                        STATUS   ROLES    AGE     VERSION   INTERNAL-IP   EXTERNAL-IP       OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
cl1d7h35ocdl5e26bres-apul   Ready    <none>   5h25m   v1.26.2   10.5.0.32     158.160.124.238   Ubuntu 20.04.6 LTS   5.4.0-177-generic   containerd://1.6.28
```
### Создание тестового приложения
- Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.
## Способ подготовки:
# Рекомендуемый вариант:
- а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.
- б. Подготовьте Dockerfile для создания образа приложения.
# Альтернативный вариант:
- а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.
## Ожидаемый результат:
- Git репозиторий с тестовым приложением и Dockerfile.
- Регистри с собранным docker image. В качестве регистри может быть DockerHub или Yandex Container Registry, созданный также с помощью terraform.
![git](https://github.com/EVolgina/diplom/blob/main/docker%20creaate.png)
![doc](https://github.com/EVolgina/diplom/blob/main/dockerhub.png)

## Подготовка cистемы мониторинга и деплой приложения
- Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.
- Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.
### Цель:
- Задеплоить в кластер prometheus, grafana, alertmanager, экспортер основных метрик Kubernetes.
- Задеплоить тестовое приложение, например, nginx сервер отдающий статическую страницу.
## Способ выполнения:
- Воспользовать пакетом kube-prometheus, который уже включает в себя Kubernetes оператор для grafana, prometheus, alertmanager и node_exporter. При желании можете собрать все эти приложения отдельно.
- Для организации конфигурации использовать qbec, основанный на jsonnet. Обратите внимание на имеющиеся функции для интеграции helm конфигов и helm charts
- Если на первом этапе вы не воспользовались Terraform Cloud, то задеплойте и настройте в кластере atlantis для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.
## Ожидаемый результат:
- Git репозиторий с конфигурационными файлами для настройки Kubernetes.
- Http доступ к web интерфейсу grafana.
- Дашборды в grafana отображающие состояние Kubernetes кластера.
- Http доступ к тестовому приложению.
```
ubuntu@cl1ald2puucg4gqoi8h6-apav:~$ curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 11694  100 11694    0     0  74012      0 --:--:-- --:--:-- --:--:-- 74012
[WARNING] Could not find git. It is required for plugin installation.
Downloading https://get.helm.sh/helm-v3.15.3-linux-amd64.tar.gz
Verifying checksum... Done.
Preparing to install helm into /usr/local/bin
helm installed into /usr/local/bin/helm
ubuntu@cl1ald2puucg4gqoi8h6-apav:~$  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
"prometheus-community" has been added to your repositories
ubuntu@cl1ald2puucg4gqoi8h6-apav:~$  helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "prometheus-community" chart repository
Update Complete. ⎈Happy Helming!⎈
ubuntu@cl1ald2puucg4gqoi8h6-apav:~$ sudo nano kub-prom.yaml
ubuntu@cl1ald2puucg4gqoi8h6-apav:~$ helm install kube-prometheus prometheus-community/kube-prometheus-stack -f kub-prom.yaml
NAME: kube-prometheus
LAST DEPLOYED: Sun Jul 14 14:37:02 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace default get pods -l "release=kube-prometheus"
Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
ubuntu@cl1ald2puucg4gqoi8h6-apav:~$ sudo nano deployment.yaml
ubuntu@cl1ald2puucg4gqoi8h6-apav:~$ kubectl apply -f deployment.yaml
deployment.apps/nginx-deployment created
ubuntu@cl1ald2puucg4gqoi8h6-apav:~$ curl -sL https://github.com/splunk/qbec/releases/download/v0.17.0/qbec-linux-amd64 -o qbec
ubuntu@cl1ald2puucg4gqoi8h6-apav:~$ chmod +x qbec
ubuntu@cl1ald2puucg4gqoi8h6-apav:~$ sudo nano gitlab-ci.yml
[gitlab-ci.yaml]()

ubuntu@cl1ald2puucg4gqoi8h6-apav:~$ kubectl get pods
NAME                                                     READY   STATUS    RESTARTS   AGE
alertmanager-kube-prometheus-kube-prome-alertmanager-0   2/2     Running   0          24m
kube-prometheus-grafana-5dd885c8c8-5l9j6                 3/3     Running   0          24m
kube-prometheus-kube-prome-operator-67b7d8dd89-hb4s2     1/1     Running   0          24m
kube-prometheus-kube-state-metrics-6cb5d64cbd-x74zx      1/1     Running   0          24m
kube-prometheus-prometheus-node-exporter-qpclg           1/1     Running   0          24m
nginx-deployment-57d84f57dc-2sxqg                        1/1     Running   0          21m
nginx-deployment-57d84f57dc-8j95z                        1/1     Running   0          21m
nginx-deployment-57d84f57dc-pkmd4                        1/1     Running   0          21m
prometheus-kube-prometheus-kube-prome-prometheus-0       2/2     Running   0          24m
ubuntu@cl1ald2puucg4gqoi8h6-apav:~$ kubectl get svc
NAME                                       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
alertmanager-operated                      ClusterIP   None            <none>        9093/TCP,9094/TCP,9094/UDP   24m
kube-prometheus-grafana                    ClusterIP   10.96.193.146   <none>        80/TCP                       25m
kube-prometheus-kube-prome-alertmanager    ClusterIP   10.96.152.142   <none>        9093/TCP,8080/TCP            25m
kube-prometheus-kube-prome-operator        ClusterIP   10.96.251.18    <none>        443/TCP                      25m
kube-prometheus-kube-prome-prometheus      ClusterIP   10.96.202.164   <none>        9090/TCP,8080/TCP            25m
kube-prometheus-kube-state-metrics         ClusterIP   10.96.249.31    <none>        8080/TCP                     25m
kube-prometheus-prometheus-node-exporter   ClusterIP   10.96.197.109   <none>        9100/TCP                     25m
kubernetes                                 ClusterIP   10.96.128.1     <none>        443/TCP                      6h40m
prometheus-operated                        ClusterIP   None            <none>        9090/TCP                     24m
```
```
ubuntu@cl1mfrel9uvdtfjp7mdf-inyb:~$ cat ~/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM1ekNDQWMrZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJME1EY3lNVEE1TlRBd05sb1hEVE0wTURjeE9UQTVOVEF3Tmxvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTGNQCnZ3ek52RXhzTXkycEpPTC9OczdXbHBSZmVEUFpGVlo4ZllPNmpxRkVMNkgxUXJlbXE2YWdhRUJka0NUaHRXSHAKYUo5Z1J3bmM0SVZnU2hUQ2wwRUxUWk8rRFVwKzNLd2I2elEyUzJiVDltU2ZxNXlhOUtUODhNWjNWdHFuMFJUYgpKK0xiUnZuRmJabjdhczNCV2xYWFVzZlJUVWtEVCsxcHJQaDUySTlLV2pIZEg3OXB5a3pZOGVyNHkyNk9KYTRZCkRoS2Z4VU5FcE9Ra0Fqek1Sd0Q1MVdrRTJWOTNiRzRUeVBGUWc3REdHc1VWSUQ0dkpmWUNMRkFqYU04Z2taYSsKSklxaGtCSHdmc0lCRWpQQnovZzd2WGpsSzhTTjk3VndSbFg2aFF6ZEFBTi96T2YxUmh6NmNBUnBDMHdzWWNseApZOWRmenplTUNRbUdhSERlK01VQ0F3RUFBYU5DTUVBd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZOLzkvL0lONk1NYzBLZ085ZG5DNit5Um1LWWtNQTBHQ1NxR1NJYjMKRFFFQkN3VUFBNElCQVFBYVludTdDUlJpbHc5bkhqc2d0MUtjdHVZS2I5RTFmQTk1aFBJWWdRaVAxbStTbFF2ZwpwaVpJN2psOUd4Zk9jcmNOVEY4cnl3aGlDdWZ5dE80dXBoZGdGVzhCUzlraVptY2lPNFppRVBCU1NrMXNTVjQ3CmxWbytzZmVKcE1yZUN6MUN0ZVdyczhCZ1Jrb3JLTDlsR21Sd3pjOHZaeGpJMFZ3S1JLcm1EUWsxWWJpSFR2R1kKN3l2QUdJQ3F0UURVRTNjbFR5eHVUYUt4NlF4ZWNkV245Y3AzVmxHaXhWT1F3WW1rd1FkZEtnM0Q1a3hjSUh1aAo4anVmWUxESm9YQVgrZWZXS1pORm5YdFp1TldZZis1VDU4QmhIc1RKVWt3ank3WEg0NFI0NjQ0TlVkaVhCbmw2CjlQUml2VnJzSWJqam5YNG1MZ3JoeWlvNzZvOWR3NGl5bXorcgotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    server: https://10.5.0.13
  name: yc-managed-k8s-cat64f79rcpm2u6n7d2i
contexts:
- context:
    cluster: yc-managed-k8s-cat64f79rcpm2u6n7d2i
    user: yc-managed-k8s-cat64f79rcpm2u6n7d2i
  name: yc-k8s-regional
current-context: yc-k8s-regional
kind: Config
preferences: {}
users:
- name: yc-managed-k8s-cat64f79rcpm2u6n7d2i
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args:
      - k8s
      - create-token
      - --profile=default
      command: /home/ubuntu/yandex-cloud/bin/yc
      env: null
      provideClusterInfo: false
ubuntu@cl1mfrel9uvdtfjp7mdf-inyb:~$ kubectl create serviceaccount github-deployer
serviceaccount/github-deployer created
ubuntu@cl1mfrel9uvdtfjp7mdf-inyb:~$ kubectl create secret generic github-deployer-token --from-literal=token=$(kubectl get secret $(kubectl get sa github-deployer -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode) -n default
secret/github-deployer-token created
```
```
ubuntu@cl1mfrel9uvdtfjp7mdf-inyb:~$ helm install kube-state-metrics prometheus-community/kube-state-metrics
NAME: kube-state-metrics
LAST DEPLOYED: Sun Jul 21 13:58:36 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
kube-state-metrics is a simple service that listens to the Kubernetes API server and generates metrics about the state of the objects.
The exposed metrics can be found here:
https://github.com/kubernetes/kube-state-metrics/blob/master/docs/README.md#exposed-metrics

The metrics are exported on the HTTP endpoint /metrics on the listening port.
In your case, kube-state-metrics.default.svc.cluster.local:8080/metrics

They are served either as plaintext or protobuf depending on the Accept header.
They are designed to be consumed either by Prometheus itself or by a scraper that is compatible with scraping a Prometheus client endpoint.
ubuntu@cl1mfrel9uvdtfjp7mdf-inyb:~$ helm install node-exporter prometheus-community/prometheus-node-exporter
NAME: node-exporter
LAST DEPLOYED: Sun Jul 21 13:59:02 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=prometheus-node-exporter,app.kubernetes.io/instance=node-exporter" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:9100 to use your application"
  kubectl port-forward --namespace default $POD_NAME 9100
ubuntu@cl1mfrel9uvdtfjp7mdf-inyb:~$ kubectl apply -f grafanalb.yaml
Warning: resource services/kube-prometheus-grafana is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
service/kube-prometheus-grafana configured
ubuntu@cl1mfrel9uvdtfjp7mdf-inyb:~$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                                     READY   STATUS    RESTARTS   AGE
default       alertmanager-kube-prometheus-kube-prome-alertmanager-0   2/2     Running   0          4h1m
default       kube-prometheus-grafana-5dd885c8c8-86f46                 3/3     Running   0          4h1m
default       kube-prometheus-kube-prome-operator-86b96c59dc-st4lk     1/1     Running   0          4h1m
default       kube-prometheus-kube-state-metrics-6cb5d64cbd-bkfbh      1/1     Running   0          4h1m
default       kube-prometheus-prometheus-node-exporter-xpttk           1/1     Running   0          4h1m
default       kube-state-metrics-79466d69bb-7zwck                      1/1     Running   0          61m
default       nginx-deployment-57d84f57dc-fbzgn                        1/1     Running   0          3h54m
default       nginx-deployment-57d84f57dc-rkh4v                        1/1     Running   0          3h54m
default       nginx-deployment-57d84f57dc-wfkzt                        1/1     Running   0          3h54m
default       node-exporter-prometheus-node-exporter-lltr4             0/1     Pending   0          60m
default       prometheus-kube-prometheus-kube-prome-prometheus-0       2/2     Running   0          4h1m
kube-system   coredns-57b57bfc5b-gzpm8                                 1/1     Running   0          5h6m
kube-system   ip-masq-agent-bzlj6                                      1/1     Running   0          4h31m
kube-system   kube-dns-autoscaler-bd7cc5977-wwk9h                      1/1     Running   0          5h6m
kube-system   kube-proxy-kcwb5                                         1/1     Running   0          4h31m
kube-system   metrics-server-6f485d9c99-47bt4                          2/2     Running   0          4h31m
kube-system   npd-v0.8.0-2c9mb                                         1/1     Running   0          4h31m
kube-system   yc-disk-csi-node-v2-wrrfb                                6/6     Running   0          4h31m
ubuntu@cl1mfrel9uvdtfjp7mdf-inyb:~$ kubectl get svc -o wide
NAME                                       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE    SELECTOR
alertmanager-operated                      ClusterIP   None            <none>        9093/TCP,9094/TCP,9094/UDP   4h3m   app.kubernetes.io/name=alertmanager
kube-prometheus-grafana                    NodePort    10.96.213.62    <none>        80:32001/TCP                 4h3m   app.kubernetes.io/instance=kube-prometheus,app.kubernetes.io/name=grafana
kube-prometheus-kube-prome-alertmanager    ClusterIP   10.96.175.198   <none>        9093/TCP,8080/TCP            4h3m   alertmanager=kube-prometheus-kube-prome-alertmanager,app.kubernetes.io/name=alertmanager
kube-prometheus-kube-prome-operator        ClusterIP   10.96.186.115   <none>        443/TCP                      4h3m   app=kube-prometheus-stack-operator,release=kube-prometheus
kube-prometheus-kube-prome-prometheus      ClusterIP   10.96.232.244   <none>        9090/TCP,8080/TCP            4h3m   app.kubernetes.io/name=prometheus,operator.prometheus.io/name=kube-prometheus-kube-prome-prometheus
kube-prometheus-kube-state-metrics         ClusterIP   10.96.129.110   <none>        8080/TCP                     4h3m   app.kubernetes.io/instance=kube-prometheus,app.kubernetes.io/name=kube-state-metrics
kube-prometheus-prometheus-node-exporter   ClusterIP   10.96.195.132   <none>        9100/TCP                     4h3m   app.kubernetes.io/instance=kube-prometheus,app.kubernetes.io/name=prometheus-node-exporter
kube-state-metrics                         ClusterIP   10.96.174.210   <none>        8080/TCP                     63m    app.kubernetes.io/instance=kube-state-metrics,app.kubernetes.io/name=kube-state-metrics
kubernetes                                 ClusterIP   10.96.128.1     <none>        443/TCP                      5h8m   <none>
nginx-service                              NodePort    10.96.142.159   <none>        80:32000/TCP                 57m    app=nginx
node-exporter-prometheus-node-exporter     ClusterIP   10.96.233.105   <none>        9100/TCP                     62m    app.kubernetes.io/instance=node-exporter,app.kubernetes.io/name=prometheus-node-exporter
prometheus-operated                        ClusterIP   None            <none>        9090/TCP                     4h3m   app.kubernetes.io/name=prometheus
```
### Установка и настройка CI/CD
- Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.
## Цель:
- Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
- Автоматический деплой нового docker образа.
- Можно использовать teamcity, jenkins, GitLab CI или GitHub Actions.
## Ожидаемый результат:
- Интерфейс ci/cd сервиса доступен по http.
- При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
- При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.
