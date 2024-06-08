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
![YC](https://github.com/EVolgina/diplom/blob/main/yc%20terraform.png)
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
![YC1]()

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
