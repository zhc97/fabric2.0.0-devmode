##  Readme
  fabric1.4的fabric chaincode devmode是一个单peer单orderer的网络，使用了solo共识，通过构建docker网络的时候将链码容器独立运行的方式使得cli可以实时与链码容器进行交互，从而便于开发链码。

  在1.4的基础上进行了些许配置文件和docker file的修改，使得可以在fabric2.0的镜像上进行devmode网络的运行，具体操作如下：
  
####  0.准备阶段
官网下载2.0.0的fabric-samples，binaries，docker images：

```
curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.0.0 1.4.4 0.4.18
```
下载完成后，会在fabric-samples目录中生成一个bin目录，其中放有二进制工具。

#### 1.启动dev-mode网络

```
cd simple-network
./generate.sh
./network.sh up
```
generate.sh脚本的作用是产生创世区块，通道文件以及锚节点配置文件；运行网络的时候会在启动时自动执行通道创建以及通道加入操作（script.sh）

#### 2.启动链码容器
这一步一定要在cli处理链码生命周期之前执行（因为在链码生命周期执行时会产生链码容器用于与peer节点的7052端口进行交互，而devmode要求peer节点需要与网络中预先设定的链码容器交互，所以链码容器必须在网络启动时就存在，否则会报与127.0.0.1：7052 connection refuse的错误）

在链码容器中执行链码之前，要先保证链码文件夹下依赖正常，go modules以及vendor配置没问题（这个有记录）。

然后确保链码文件夹的权限足够，否则在编译的时候会引发permission deny的问题。具体而言需要在主机里chmod：

```
chmod 777 -R go
```


最后设置go链码编译时需要的全局变量：

```
export GO111MODULE=on
export GOPROXY=https://goproxy.cn,direct
```
然后进入链码文件夹下进行编译：

```
cd abstore/go
go build -o abs
```
编译结束后，文件夹下出现可执行文件abs，执行它：

```
CORE_CHAINCODE_ID_NAME=myccv1:f3adce8d005f92570bdf1ca9af626b3f02498b74c660c651bb5d5b8a438bed00 CORE_PEER_TLS_ENABLED=false ./abs -p
eer.address=peer0.org1.example.com:7052
```
注意这里是与1.4的devmode的最大区别，1.4的devmode所设置的CORE_CHAINCODE_ID_NAME环境变量是链码名称：版本号，而2.0的链码容器启动指令中设置了这个环境变量为package-id。

上一步执行结束后，链码容器进入监听状态，可以根据链码调用情况来随时返回log信息。

#### 3.启动cli并执行链码生命周期
进入cli后，执行脚本cclifecycle.sh中的指令，执行完毕后链码就已经被成功提交到网络中，可以被cli所调用，调用示例（无tls）：

初始化：

```
peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n mycc --isInit -c '{"Args":["Init","a","100","b","200"]}'
```


invoke：

```
peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n mycc  -c '{"Args":["Invoke","a","b","10"]}'
```


query：

```
peer chaincode query  -C mychannel -n mycc  -c '{"Args":["Query","a"]}'
```
执行完对应的链码函数后，都会在chaincode容器运行的终端中返回log信息，便于开发和排错。