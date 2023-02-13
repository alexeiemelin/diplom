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
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: [Terraform Cloud](https://app.terraform.io/)  
   б. Альтернативный вариант: S3 bucket в созданном ЯО аккаунте
3. Настройте [workspaces](https://www.terraform.io/docs/language/state/workspaces.html)  
   а. Рекомендуемый вариант: создайте два workspace: *stage* и *prod*. В случае выбора этого варианта все последующие шаги должны учитывать факт существования нескольких workspace.  
   б. Альтернативный вариант: используйте один workspace, назвав его *stage*. Пожалуйста, не используйте workspace, создаваемый Terraform-ом по-умолчанию (*default*).
4. Создайте VPC с подсетями в разных зонах доступности.
5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

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
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать региональный мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
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
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

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

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/) либо [gitlab ci](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/)

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
  руководителя. Скилл поиска ответов пригодится вам в профессиональной 
  деятельности.
2. Если вопросов больше одного, то присылайте их в виде нумерованного 
  списка. Так дипломному руководителю будет проще отвечать на каждый из 
  них.
3. При необходимости прикрепите к вопросу скриншоты и стрелочкой 
  покажите, где не получается.

Что может стать источником проблем:

1. Вопросы вида «Ничего не работает. Не запускается. Всё сломалось». 
  Дипломный руководитель не сможет ответить на такой вопрос без 
  дополнительных уточнений. Цените своё время и время других.
2. Откладывание выполнения курсового проекта на последний момент.
3. Ожидание моментального ответа на свой вопрос. Дипломные руководители работающие разработчики, которые занимаются, кроме преподавания, 
  своими проектами. Их время ограничено, поэтому постарайтесь задавать правильные вопросы, чтобы получать быстрые ответы :)

Создаем сервисный аккаунт:
yc iam service-account create sa

user@user:~/PycharmProjects/diplom$ yc iam service-account create sa
id: aje2ac1v0gqi4mu633a3
folder_id: b1g259gr1ck7ejh9jd55
created_at: "2023-01-18T20:13:49.223846439Z"
name: sa

Даем ему права на редактирование(заменяем наш каталог):
yc resource-manager folder add-access-binding b1g259gr1ck7ejh9jd55 --role editor --subject serviceAccount:aje2ac1v0gqi4mu633a3

user@user:~/PycharmProjects/diplom$ yc resource-manager folder add-access-binding b1g259gr1ck7ejh9jd55 --role editor --subject serviceAccount:aje2ac1v0gqi4mu633a3
done (1s)

Генерируем access и secret key:
yc iam access-key create --service-account-name sa

user@user:~/PycharmProjects/diplom$ yc iam access-key create --service-account-name sa
access_key:
  id: ajedu2vupk2f4sm8p5nl
  service_account_id: aje2ac1v0gqi4mu633a3
  created_at: "2023-01-18T20:21:57.764510857Z"
  key_id: YCAJEzpfZSh39LMtx3ovgbdfM
secret: YCN8lI_sZI8zmzo_Nyg4InTDUjXjlVx9QeP_zbJ0

Добавляем ключи key_id и secret в main.tf

Создаем бакет:
yc storage bucket create --name my-storage

user@user:~/PycharmProjects/diplom$ yc storage bucket create --name my-storage
name: my-storage
folder_id: b1g259gr1ck7ejh9jd55
anonymous_access_flags:
  read: false
  list: false
default_storage_class: STANDARD
versioning: VERSIONING_DISABLED
acl: {}
created_at: "2023-01-18T20:26:55.771449Z"

Инициализируем backend:
terraform init

Создаем два workspaces:
terraform workspace new prod
terraform workspace new stage

user@user:~/PycharmProjects/diplom$ terraform workspace list
  default
  prod
* stage
___________________________________

Создаем наш docker image из Dockerfile
docker build -t alexeiemelin/nginx:v1 .

И загружаем его на hub.docker
docker push alexeiemelin/nginx:v1

https://hub.docker.com/r/alexeiemelin/nginx

Устанавливаем helm на пк для того, чтобы сделать наш chart

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

Далее создаем наш чарт
helm create my_nginx

Удаляем лишние файлы, созданные автоматом и заменяем своими
rm -rf my_nginx/templates/*

Проверяем, что значения из файла values.yaml корректно подставляются: 
helm template my_nginx

Проверяем синтаксис:
helm lint my_nginx
 
Пакуем в архив наш chart:
helm package my_nginx -d charts
Successfully packaged chart and saved it to: charts/my_nginx-0.1.2.tgz

Генерируем индексный файл чарта, 
который содержит в себе перечень версий приложения, составленный на основе архива:
helm repo index charts

Создадим index.html файл, который будет лицевой страничкой нашего чарта:
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>my_site</title>
</head>
<body>
  <h2>Welcome to my Helm repository</h2>
  <p>Alexei Emelin</p>
</body>
</html>

Верифицируем наш репозиторий. Для этого изменим наше приложение и загрузим новую версию

Создаем наш docker image из Dockerfile
docker build -t alexeiemelin/nginx:0.0.3 .

И загружаем его на hub.docker
docker push alexeiemelin/nginx:0.0.3

Изменим значение версии 0.0.2 в values.yaml и Chart.yaml

Перезальем наш chart
Пакуем в архив наш chart:
helm package my_nginx -d charts
Successfully packaged chart and saved it to: charts/my_nginx-0.0.2.tgz

Добавляем на control node репозиторий helm и устанавливаем chart:
helm repo add my_nginx https://alexeiemelin.github.io/nginx_helm/charts/

ubuntu@cp1:~$ helm install nginx my_nginx/my_nginx
NAME: nginx
LAST DEPLOYED: Wed Feb  8 15:00:55 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None


Генерируем индексный файл чарта, 
который содержит в себе перечень версий приложения, составленный на основе архива:
helm repo index charts

user@user:~/PycharmProjects/diplom/terraform$ yc compute instance list
+----------------------+-------+---------------+---------+----------------+---------------+
|          ID          | NAME  |    ZONE ID    | STATUS  |  EXTERNAL IP   |  INTERNAL IP  |
+----------------------+-------+---------------+---------+----------------+---------------+
| fhm3m1rf2b5iu4du5vpr | node2 | ru-central1-a | RUNNING | 158.160.51.173 | 192.168.10.14 |
| fhm76hnqare7irr180hq | cp1   | ru-central1-a | RUNNING | 158.160.58.140 | 192.168.10.20 |
| fhmvmf3bco9ucqu24j55 | node1 | ru-central1-a | RUNNING | 158.160.32.29  | 192.168.10.4  |
+----------------------+-------+---------------+---------+----------------+---------------+

user@user:~/pycharm-community-2021.3/bin$ ssh ubuntu@158.160.58.140

Склонируйте себе репозиторий:
```shell script
git clone https://github.com/kubernetes-sigs/kubespray
```

sudo apt-get update

sudo apt install pip

# Установка зависимостей
cd kubespray
sudo pip3 install -r requirements.txt

# Копирование примера в папку с вашей конфигурацией
cp -rfp inventory/sample inventory/mycluster

```shell script
# Обновление Ansible inventory с помощью билдера 
declare -a IPS=(192.168.10.23 192.168.10.17 192.168.10.20)
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

# 192.168.10.20 192.168.10.4 192.168.10.14 - адреса ваших серверов
```
Билдер подготовит файл `inventory/mycluster/hosts.yaml`. Там будут прописаны адреса серверов, которые вы указали.
Остальные настройки нужно делать самостоятельно.

vim inventory/mycluster/hosts.yaml

ubuntu@fhm76hnqare7irr180hq:~/kubespray/inventory/mycluster$ cat hosts.yaml 
all:
  hosts:
    cp1:
      ansible_host: 192.168.10.23
      ip: 192.168.10.23
      access_ip: 192.168.10.23
      ansible_user: ubuntu
    node1:
      ansible_host: 192.168.10.17
      ip: 192.168.10.17
      access_ip: 192.168.10.17
      ansible_user: ubuntu
    node2:
      ansible_host: 192.168.10.20
      ip: 192.168.10.20
      access_ip: 192.168.10.20
      ansible_user: ubuntu
  children:
    kube_control_plane:
      hosts:
        cp1:
    kube_node:
      hosts:
        cp1:
        node1:
        node2:
    etcd:
      hosts:
        cp1:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}


Установка кластера занимает значительное количество времени.
Время установки кластер из двух нод может занять более 10 минут.
Чем больше нод, тем больше времени занимает установка.

копируем приватный ключ ssh с хостовой машины на cp1 
раздаем права
ubuntu@fhm76hnqare7irr180hq:~/kubespray$ chmod 0700 /home/ubuntu/.ssh/id_rsa
подключаемся к нодам и потом запускаем установку кластера

### Установка кластера после билдера 
```shell script
ansible-playbook -i inventory/mycluster/hosts.yaml cluster.yml -b -v
```

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


ubuntu@fhm76hnqare7irr180hq:~/kubespray$ kubectl version
WARNING: This version information is deprecated and will be replaced with the output from kubectl version --short.  Use --output=yaml|json to get the full version.
Client Version: version.Info{Major:"1", Minor:"25", GitVersion:"v1.25.6", GitCommit:"ff2c119726cc1f8926fb0585c74b25921e866a28", GitTreeState:"clean", BuildDate:"2023-01-18T19:22:09Z", GoVersion:"go1.19.5", Compiler:"gc", Platform:"linux/amd64"}
Kustomize Version: v4.5.7
Server Version: version.Info{Major:"1", Minor:"25", GitVersion:"v1.25.6", GitCommit:"ff2c119726cc1f8926fb0585c74b25921e866a28", GitTreeState:"clean", BuildDate:"2023-01-18T19:15:26Z", GoVersion:"go1.19.5", Compiler:"gc", Platform:"linux/amd64"}

ubuntu@fhm08hnsk5s9i8vq2nd3:~/kubespray$ kubectl get nodes
NAME    STATUS   ROLES           AGE     VERSION
cp1     Ready    control-plane   10m     v1.25.6
node1   Ready    <none>          8m38s   v1.25.6
node2   Ready    <none>          8m40s   v1.25.6

ubuntu@fhm08hnsk5s9i8vq2nd3:~/kubespray$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                       READY   STATUS    RESTARTS       AGE
kube-system   calico-kube-controllers-75748cc9fd-84zc2   1/1     Running   0              7m59s
kube-system   calico-node-p5blq                          1/1     Running   0              9m13s
kube-system   calico-node-q2mr5                          1/1     Running   0              9m13s
kube-system   calico-node-rg9ww                          1/1     Running   0              9m13s
kube-system   coredns-588bb58b94-ddtgn                   1/1     Running   0              7m26s
kube-system   coredns-588bb58b94-dl6ws                   1/1     Running   0              7m2s
kube-system   dns-autoscaler-5b9959d7fc-mz9nt            1/1     Running   0              7m18s
kube-system   kube-apiserver-cp1                         1/1     Running   1              11m
kube-system   kube-controller-manager-cp1                1/1     Running   2 (5m7s ago)   11m
kube-system   kube-proxy-4xtg2                           1/1     Running   0              10m
kube-system   kube-proxy-hk2q7                           1/1     Running   0              10m
kube-system   kube-proxy-klvbv                           1/1     Running   0              10m
kube-system   kube-scheduler-cp1                         1/1     Running   2 (5m7s ago)   11m
kube-system   nginx-proxy-node1                          1/1     Running   0              9m1s
kube-system   nginx-proxy-node2                          1/1     Running   0              9m2s
kube-system   nodelocaldns-jqxlq                         1/1     Running   0              7m17s
kube-system   nodelocaldns-shlcc                         1/1     Running   0              7m17s
kube-system   nodelocaldns-vxd6b                         1/1     Running   0              7m17s


ubuntu@cp1:~$ kubectl create deploy nginx --image=alexeiemelin/nginx:v1
deployment.apps/nginx created

ubuntu@cp1:~$ kubectl get po -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP               NODE    NOMINATED NODE   READINESS GATES
nginx-868dbbcfb9-ks74h   1/1     Running   0          19s   10.233.102.130   node1   <none>           <none>

Копируем адрес control node в:

ubuntu@cp1:~/kubespray$ vim inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

supplementary_addresses_in_ssl_keys: [10.0.0.1, 10.0.0.2, 10.0.0.3, 158.160.59.76]


добавим доступ к ноде с домашнего пк. Для этого создадим и заполним context

user@user:~/pycharm-community-2021.3/bin$ vim ~/.kube/config 

скопируем раздел cluster и user с ноды, поменяем адрес с localhost на внешний

apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: 
    server: https://158.160.59.76:6443
  name: kubespray
contexts:
- context:
    cluster: kubespray
    namespace: default
    user: kubespray
  name: kubespray

users:
- name: kubespray
  user:


user@user:~/pycharm-community-2021.3/bin$ kubectl config use-context kubespray
Switched to context "kubespray".

user@user:~/pycharm-community-2021.3/bin$ kubectl get nodes
NAME    STATUS   ROLES           AGE     VERSION
cp1     Ready    control-plane   3d23h   v1.25.6
node1   Ready    <none>          3d23h   v1.25.6
node2   Ready    <none>          3d23h   v1.25.6


Добавляем сервис для доступа из внешней сети и создаем pod:

ubuntu@cp1:~$ kubectl apply -f pod.yml 
pod/frontend created
service/nodeport created

ubuntu@cp1:~$ kubectl get po -o wide
NAME       READY   STATUS    RESTARTS   AGE     IP               NODE    NOMINATED NODE   READINESS GATES
frontend   1/1     Running   0          2m27s   10.233.102.136   node1   <none>           <none>

Проверяем доступность:
user@user:~/pycharm-community-2021.3/bin$ curl http://130.193.50.53:32180/
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>my_site</title>
</head>
<body>
  <h2>Welcome to my site</h2>
  <p>Alexei Emelin</p>
</body>


Деплоим стек grafana/prometheus/node-exporeter (https://github.com/prometheus-operator/kube-prometheus):
git clone git@github.com:prometheus-operator/kube-prometheus.git

cd kube-prometheus
kubectl apply --server-side -f manifests/setup
kubectl wait \
	--for condition=Established \
	--all CustomResourceDefinition \
	--namespace=monitoring
kubectl apply -f manifests/

Ставим стек для мониторинга через helm:
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install kube-monitoring prometheus-community/kube-prometheus-stack



На локальной машине запускаем проброс трафика для доступа к grafana:

kubectl --namespace monitoring port-forward svc/grafana 3000

Теперь можем зайти в админку через браузер:
http://localhost:3000/

Раскручиваем виртуалку с образом gitlab по инструкции от yandex cloud:
https://cloud.yandex.ru/docs/tutorials/testing/ci-for-snapshots
