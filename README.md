# Дипломный практикум в Yandex.Cloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
- Следует использовать последнюю стабильную версию [Terraform](https://www.terraform.io/).

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя

>Создал:
![](screenshots/Снимок%20экрана%202023-07-27%20в%2016.54.16.png)

2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: [Terraform Cloud](https://app.terraform.io/)  
   ~~б. Альтернативный вариант: S3 bucket в созданном ЯО аккаунте~~  

>Использовал Terraform Cloud:
![](screenshots/Снимок%20экрана%202023-07-27%20в%2016.58.51.png)

3. Настройте [workspaces](https://www.terraform.io/docs/language/state/
workspaces.html)  
   ~~а. Рекомендуемый вариант: создайте два workspace: *stage* и *prod*. В случае выбора этого варианта все последующие шаги должны учитывать факт существования нескольких workspace.~~  
   б. Альтернативный вариант: используйте один workspace, назвав его *stage*. Пожалуйста, не используйте workspace, создаваемый Terraform-ом по-умолчанию (*default*).

>Создал workspace stage.
```
$ terraform workspace show
stage
```

4. Создайте VPC с подсетями в разных зонах доступности.

>Создал, код [тут](terraform/).
![](screenshots/Снимок%20экрана%202023-07-27%20в%2017.04.57.png)
5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.
>Все работает, проверил.
![](screenshots/Снимок%20экрана%202023-07-27%20в%2017.06.38.png)

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---
### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.  
>Выбрал этот вариант.   
>Создал с помощью terraform (код [тут](terraform/modules/vm_instance/main.tf)) 3 инстанса ВМ.  
![](screenshots/Снимок%20экрана%202023-07-27%20в%2022.22.41.png)
>Подготовил код ansible (kubespray). Изучить можно [тут](kubespray/):  
>* [Инвентарь](kubespray/inventory/yc-gw-cluster/hosts.yaml)  
>* [Настройки кластера](kubespray/inventory/yc-gw-cluster/group_vars/k8s_cluster/k8s-cluster.yml)  
  
>Выполняю команду установки python3 зависемостей, но так как я ранее уже ставил все зависимости, то нового ничего не установилось:
```
$ sudo pip3.11 install -r requirements.txt

Requirement already satisfied: ansible==7.6.0 in /opt/homebrew/lib/python3.11/site-packages (from -r requirements.txt (line 1)) (7.6.0)
Requirement already satisfied: ansible-core==2.14.6 in /opt/homebrew/lib/python3.11/site-packages (from -r requirements.txt (line 2)) (2.14.6)
Requirement already satisfied: cryptography==41.0.1 in /opt/homebrew/lib/python3.11/site-packages (from -r requirements.txt (line 3)) (41.0.1)
Requirement already satisfied: jinja2==3.1.2 in /opt/homebrew/lib/python3.11/site-packages (from -r requirements.txt (line 4)) (3.1.2)
Requirement already satisfied: jmespath==1.0.1 in /opt/homebrew/lib/python3.11/site-packages (from -r requirements.txt (line 5)) (1.0.1)
Requirement already satisfied: MarkupSafe==2.1.3 in /opt/homebrew/lib/python3.11/site-packages (from -r requirements.txt (line 6)) (2.1.3)
Requirement already satisfied: netaddr==0.8.0 in /opt/homebrew/lib/python3.11/site-packages (from -r requirements.txt (line 7)) (0.8.0)
Requirement already satisfied: pbr==5.11.1 in /opt/homebrew/lib/python3.11/site-packages (from -r requirements.txt (line 8)) (5.11.1)
Requirement already satisfied: ruamel.yaml==0.17.31 in /opt/homebrew/lib/python3.11/site-packages (from -r requirements.txt (line 9)) (0.17.31)
Requirement already satisfied: ruamel.yaml.clib==0.2.7 in /opt/homebrew/lib/python3.11/site-packages (from -r requirements.txt (line 10)) (0.2.7)
Requirement already satisfied: PyYAML>=5.1 in /opt/homebrew/lib/python3.11/site-packages (from ansible-core==2.14.6->-r requirements.txt (line 2)) (6.0)
Requirement already satisfied: packaging in /opt/homebrew/lib/python3.11/site-packages (from ansible-core==2.14.6->-r requirements.txt (line 2)) (23.1)
Requirement already satisfied: resolvelib<0.9.0,>=0.5.3 in /opt/homebrew/lib/python3.11/site-packages (from ansible-core==2.14.6->-r requirements.txt (line 2)) (0.8.1)
Requirement already satisfied: cffi>=1.12 in /opt/homebrew/lib/python3.11/site-packages (from cryptography==41.0.1->-r requirements.txt (line 3)) (1.15.1)
Requirement already satisfied: pycparser in /opt/homebrew/lib/python3.11/site-packages (from cffi>=1.12->cryptography==41.0.1->-r requirements.txt (line 3)) (2.21)
```
> Запускаю ansible:
```
$ ansible-playbook -i inventory/yc-gw-cluster/hosts.yaml -u ubuntu --become --become-user=root cluster.yml 
```
> Через 20 минут получаю вывод о завершении процедуры установки `kubernetes`:
```
PLAY RECAP ************************************************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
vm-instance-1              : ok=738  changed=148  unreachable=0    failed=0    skipped=1213 rescued=0    ignored=5   
vm-instance-2              : ok=505  changed=93   unreachable=0    failed=0    skipped=727  rescued=0    ignored=1   
vm-instance-3              : ok=505  changed=93   unreachable=0    failed=0    skipped=725  rescued=0    ignored=1   

четверг 27 июля 2023  22:13:23 +0300 (0:00:00.076)       0:19:26.395 ********** 
=============================================================================== 
kubernetes-apps/ingress_controller/ingress_nginx : NGINX Ingress Controller | Create manifests ---------------------------------------------------------------- 42.20s
kubernetes-apps/ansible : Kubernetes Apps | Lay Down CoreDNS templates ---------------------------------------------------------------------------------------- 37.16s
kubernetes-apps/metrics_server : Metrics Server | Create manifests -------------------------------------------------------------------------------------------- 34.05s
kubernetes/kubeadm : Join to cluster -------------------------------------------------------------------------------------------------------------------------- 32.56s
kubernetes/preinstall : Install packages requirements --------------------------------------------------------------------------------------------------------- 22.91s
kubernetes/control-plane : Kubeadm | Initialize first master -------------------------------------------------------------------------------------------------- 16.94s
download : Download_container | Download image if required ---------------------------------------------------------------------------------------------------- 16.55s
kubernetes-apps/ansible : Kubernetes Apps | Start Resources --------------------------------------------------------------------------------------------------- 15.39s
download : Download_container | Download image if required ---------------------------------------------------------------------------------------------------- 13.12s
kubernetes/preinstall : Update package management cache (APT) ------------------------------------------------------------------------------------------------- 11.73s
kubernetes-apps/ingress_controller/ingress_nginx : NGINX Ingress Controller | Apply manifests ----------------------------------------------------------------- 11.63s
kubernetes-apps/ansible : Kubernetes Apps | Lay Down nodelocaldns Template ------------------------------------------------------------------------------------ 11.31s
etcd : Reload etcd -------------------------------------------------------------------------------------------------------------------------------------------- 10.04s
download : Download_file | Download item ----------------------------------------------------------------------------------------------------------------------- 9.47s
network_plugin/flannel : Flannel | Create Flannel manifests ---------------------------------------------------------------------------------------------------- 9.14s
kubernetes-apps/metrics_server : Metrics Server | Apply manifests ---------------------------------------------------------------------------------------------- 9.01s
container-engine/containerd : Download_file | Download item ---------------------------------------------------------------------------------------------------- 8.23s
kubernetes/preinstall : Preinstall | wait for the apiserver to be running -------------------------------------------------------------------------------------- 8.18s
container-engine/containerd : Containerd | Unpack containerd archive ------------------------------------------------------------------------------------------- 8.03s
container-engine/crictl : Extract_file | Unpacking archive ----------------------------------------------------------------------------------------------------- 7.77s
```
>Прописал пользователю конфигурацию для `kubectl` на мастер ноде:
```
$ mkdir -p $HOME/.kube    
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config  
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
>Запрашиваю вывод из k8s:
```
$ kubectl get pods --all-namespaces
NAMESPACE       NAME                                    READY   STATUS    RESTARTS   AGE
ingress-nginx   ingress-nginx-controller-8zq62          1/1     Running   0          6m15s
ingress-nginx   ingress-nginx-controller-dwt5b          1/1     Running   0          6m15s
kube-system     coredns-645b46f4b6-265cs                1/1     Running   0          5m6s
kube-system     coredns-645b46f4b6-rwdbg                1/1     Running   0          5m14s
kube-system     dns-autoscaler-659b8c48cb-ljpmr         1/1     Running   0          5m7s
kube-system     kube-apiserver-vm-instance-1            1/1     Running   2          9m22s
kube-system     kube-controller-manager-vm-instance-1   1/1     Running   2          9m22s
kube-system     kube-flannel-fmtkw                      1/1     Running   0          7m16s
kube-system     kube-flannel-nd84g                      1/1     Running   0          7m16s
kube-system     kube-flannel-qpq77                      1/1     Running   0          7m16s
kube-system     kube-proxy-8jwvf                        1/1     Running   0          7m49s
kube-system     kube-proxy-gqc85                        1/1     Running   0          7m49s
kube-system     kube-proxy-sd47g                        1/1     Running   0          7m49s
kube-system     kube-scheduler-vm-instance-1            1/1     Running   1          9m22s
kube-system     metrics-server-79f59df77f-hm9ff         1/1     Running   0          3m56s
kube-system     nginx-proxy-vm-instance-2               1/1     Running   0          7m24s
kube-system     nginx-proxy-vm-instance-3               1/1     Running   0          7m24s
kube-system     nodelocaldns-j8bzv                      1/1     Running   0          5m5s
kube-system     nodelocaldns-nl9cs                      1/1     Running   0          5m5s
kube-system     nodelocaldns-pb2qk                      1/1     Running   0          5m5s
```

~~2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать региональный мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)~~
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   >https://github.com/sad1sm/test-app

   б. Подготовьте Dockerfile для создания образа приложения.  
>https://github.com/sad1sm/test-app/blob/main/Dockerfile
   
>Авторизовался в созданном Container Registry.
```
$ yc container registry configure-docker
docker configured to use yc --profile "tf-user" for authenticating "cr.yandex" container registries
Credential helper is configured in '~/.docker/config.json'
```
>Собрал образ из Dockerfile:

```
$ docker build -t cr.yandex/crpsnreaq2gmc5c5u615/test-app:latest .
[+] Building 12.0s (7/7) FINISHED                                                                                                     docker:desktop-linux
 => [internal] load build definition from Dockerfile                                                                                                  0.0s
 => => transferring dockerfile: 105B                                                                                                                  0.0s
 => [internal] load .dockerignore                                                                                                                     0.0s
 => => transferring context: 2B                                                                                                                       0.0s
 => [internal] load metadata for docker.io/library/nginx:latest                                                                                       3.4s
 => [internal] load build context                                                                                                                     0.0s
 => => transferring context: 550B                                                                                                                     0.0s
 => [1/2] FROM docker.io/library/nginx:latest@sha256:e67bce60872000987d2a86ea0c4338b7e941accfd2ffd1d62ceaf9a100396c97                                 8.2s
 => => resolve docker.io/library/nginx:latest@sha256:e67bce60872000987d2a86ea0c4338b7e941accfd2ffd1d62ceaf9a100396c97                                 0.0s
 => => sha256:a9b1bd25c37b23d4e043de84d6323fbffe475917d8c4d91dcb80843adbedbede 627B / 627B                                                            0.3s
 => => sha256:2002d33a54f72d1333751d4d1b4793a60a635eac6e94a98daf0acea501580c4f 8.17kB / 8.17kB                                                        0.0s
 => => sha256:efe5035ea617aed64565034f49744cf23328aa1203e920c3db7026e87cbcc277 38.13MB / 38.13MB                                                      6.2s
 => => sha256:3ae0c06b4d3aa97d7e0829233dd36cea1666b87074e55fea6bd1ecae066693c7 29.15MB / 29.15MB                                                      5.9s
 => => sha256:e67bce60872000987d2a86ea0c4338b7e941accfd2ffd1d62ceaf9a100396c97 1.86kB / 1.86kB                                                        0.0s
 => => sha256:b02b0565e769314abcf0be98f78cb473bcf0a2280c11fd01a13f0043a62e5059 1.78kB / 1.78kB                                                        0.0s
 => => sha256:f853dda6947e3bc42dcea26ae7236bdfd7523590eed8a79dd6ba637d81a56ede 958B / 958B                                                            0.5s
 => => sha256:38f44e054f7ba4152e79dc51ceb5aa73811ba9702d57c4e8d141ec45abb8b5b0 367B / 367B                                                            0.9s
 => => sha256:ed88a19ddb46d315df55e35b2e0a85beffa5de25d937c011bac3f040ac3b0480 1.21kB / 1.21kB                                                        1.8s
 => => sha256:495e6abbed484ab1ade6467bf5ef09b3f098c5edd7f2fc0afd0463ba3a4d309b 1.41kB / 1.41kB                                                        2.1s
 => => extracting sha256:3ae0c06b4d3aa97d7e0829233dd36cea1666b87074e55fea6bd1ecae066693c7                                                             1.3s
 => => extracting sha256:efe5035ea617aed64565034f49744cf23328aa1203e920c3db7026e87cbcc277                                                             0.8s
 => => extracting sha256:a9b1bd25c37b23d4e043de84d6323fbffe475917d8c4d91dcb80843adbedbede                                                             0.0s
 => => extracting sha256:f853dda6947e3bc42dcea26ae7236bdfd7523590eed8a79dd6ba637d81a56ede                                                             0.0s
 => => extracting sha256:38f44e054f7ba4152e79dc51ceb5aa73811ba9702d57c4e8d141ec45abb8b5b0                                                             0.0s
 => => extracting sha256:ed88a19ddb46d315df55e35b2e0a85beffa5de25d937c011bac3f040ac3b0480                                                             0.0s
 => => extracting sha256:495e6abbed484ab1ade6467bf5ef09b3f098c5edd7f2fc0afd0463ba3a4d309b                                                             0.0s
 => [2/2] COPY ./index.html /usr/share/nginx/html/index.html                                                                                          0.4s
 => exporting to image                                                                                                                                0.0s
 => => exporting layers                                                                                                                               0.0s
 => => writing image sha256:e3348b6973be216b1e75b9cefb1104bbb8a94f65f1cff6c3d1debc8bb0f8bedb                                                          0.0s
 => => naming to cr.yandex/crpsnreaq2gmc5c5u615/test-app:latest                                                                                       0.0s
```
>Запушил образ в registry:
```
$ docker push cr.yandex/crpsnreaq2gmc5c5u615/test-app:latest
The push refers to repository [cr.yandex/crpsnreaq2gmc5c5u615/test-app]
34c12c4fc620: Pushed 
0a13d2aaa54c: Pushed 
45437bbd87f2: Pushed 
7cd1e5cbf124: Pushed 
ad6517b0c914: Pushed 
4e6bef96e37e: Pushed 
c58d5a26ffa8: Pushed 
efd1965f1684: Pushed 
latest: digest: sha256:0a04aa00b05805b6161ccd0574a87a0b12362a438fab63035db6e597b08dc889 size: 1985
```

>Container Registry:  
cr.yandex/crpsnreaq2gmc5c5u615/test-app:latest
   
>Терраформ код [тут](terraform/modules/registry/main.tf).

>Успешный запуск terraform кода:
![](screenshots/Снимок%20экрана%202023-07-28%20в%2011.56.14.png)

~~2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.~~

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистр с собранным docker image. В качестве регистра может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Рекомендуемый способ выполнения:
1. Воспользовать пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). При желании можете собрать все эти приложения отдельно.
2. Для организации конфигурации использовать [qbec](https://qbec.io/), основанный на [jsonnet](https://jsonnet.org/). Обратите внимание на имеющиеся функции для интеграции helm конфигов и [helm charts](https://helm.sh/)
3. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте в кластер [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры.

Альтернативный вариант:
1. Для организации конфигурации можно использовать [helm charts](https://helm.sh/)

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ к тестовому приложению.

---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистр, а также деплой соответствующего Docker образа в кластер Kubernetes.

---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

---
## Как правильно задавать вопросы дипломному руководителю?

Что поможет решить большинство частых проблем:

1. Попробовать найти ответ сначала самостоятельно в интернете или в 
  материалах курса и ДЗ и только после этого спрашивать у дипломного 
  руководителя. Навык поиска ответов пригодится вам в профессиональной 
  деятельности.
2. Если вопросов больше одного, присылайте их в виде нумерованного 
  списка. Так дипломному руководителю будет проще отвечать на каждый из 
  них.
3. При необходимости прикрепите к вопросу скриншоты и стрелочкой 
  покажите, где не получается.

Что может стать источником проблем:

1. Вопросы вида «Ничего не работает. Не запускается. Всё сломалось». 
  Дипломный руководитель не сможет ответить на такой вопрос без 
  дополнительных уточнений. Цените своё время и время других.
2. Откладывание выполнения курсового проекта на последний момент.
3. Ожидание моментального ответа на свой вопрос. Дипломные руководители - практикующие специалисты, которые занимаются, кроме преподавания, 
  своими проектами. Их время ограничено, поэтому постарайтесь задавать правильные вопросы, чтобы получать быстрые ответы :)