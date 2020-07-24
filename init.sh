#!/bin/env bash

cat <<-'EOF'
+---------------------------------------+
|            基本配置                   |
|           1.全部                      |
|           2.换源并更新                |
|           3.配置zsh                   |
|           4.配置neovim                |
|           5.配置docker                |
|           6.安装annie                 |
|           7.安装ffmpeg                |
|           8.安装docker版-nextcloud    |
|           9.安装docker版-aria2        |
|          10.安装docker版-酷Q          |
|          11.安装docker版-mysql        |
|          12.升级git到2.9.5            |
|          13.安装Go语言环境            |
+---------------------------------------+

EOF
one(){ #换源
	if [ ! "$USER" = "root" ];then
		echo "请用root命令执行!"
		exit
	fi
	if [ $P_M == "yum" ];then
		$P_M install -y wget
		cp /etc/P_M.repos.d/CentOS-Base.repo /etc/P_M.repos.d/CentOS-Base.repo.bak
		wget -O /etc/P_M.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
		cp /etc/P_M.repos.d/epel.repo /etc/P_M.repos.d/epel.repo.bak
		wget -O /etc/P_M.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
		$P_M  clean  all
		$P_M  makecache
		$P_M -y update
	elif [ $P_M == "apt-get" ];then
		sudo cp /etc/apt/sources.list /etc/apt/sources.list_backup
		cat > /etc/apt/sources.list<<-'EOF'
	deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse \
	deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
	deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
	deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
	deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
	deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
	deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
	deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
	deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
	deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse

	EOF
		sudo $P_M update
		sudo $P_M upgrade
	fi
	#换源
}

two(){ # 配置zsh的
	cd ~ 
	if ! command -v git&>/dev/null ;then 
		$P_M install -y git
	fi 

	if ! command -v zsh&>/dev/null ;then 
		$P_M install -y zsh
	fi 

	if [ ! -d ~/my_zsh ];then
		git clone https://gitee.com/anlen123/my_zsh
	fi

	if [ $? -eq 0 ];then
		cp -r ~/my_zsh/.zshrc ~
		cp -r ~/my_zsh/.oh-my-zsh ~
		cd ~
		chsh -s /bin/zsh 
		if [ $? -eq 0 ];then 
			cd ~
			rm -rf -R my_zsh
		fi
	fi
	#以上是配置zsh的
}

three(){ #以下是配置nvim的
	cd ~ 
	if ! command -v nvim&>/dev/null ;then 
		if [[ $P_M == "yum" ]];then
			yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
			yum install -y neovim python3-neovim
		else
			$P_M install -y neovim
		fi
	fi 

	cd ~
	if [ ! -d ~/.config/nvim ];then 
		mkdir -p ~/.config 
		cd ~/.config  
		if [ $? -eq 0 ];then 
			git clone https://gitee.com/anlen123/nvim
		fi
		
		cd ~
		
	fi
	#以上是配置nvim的
}

four(){ #配置docker
	
	cd ~
	if ! command -v docker&>/dev/null ;then
		if [[ $P_M == "yum" ]];then
			#yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
			$P_M -y install docker
		else
			$P_M -y install docker
		fi
	fi

	sudo service docker start
	sudo systemctl daemon-reload
	sudo systemctl restart docker.service
	sudo systemctl enable docker

	sudo mkdir -p /etc/docker
	sudo tee /etc/docker/daemon.json <<-'EOF'
	{
	  "registry-mirrors": ["https://gr51o72c.mirror.aliyuncs.com"]
	}
	EOF
	sudo systemctl daemon-reload
	sudo systemctl restart docker
	
	if [ "$(docker ps -a | awk '{print$2}'| grep portainer/portainer)" == "portainer/portainer" ] ;then
		echo "docker可视化已存在"
	else 
		docker run -d -p 9000:9000 --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data --name prtainer-test portainer/portainer
	fi

	if [ $? -eq 0 ];then
		docker ps -a 
	fi
}

os_check() { #检查系统
    if [ -e /etc/redhat-release ] ; then
        REDHAT=`cat /etc/redhat-release | cut -d' '  -f1 `
    else
        DEBIAN=`cat /etc/issue | cut -d' '  -f1 `
    fi

    if [ "$REDHAT" == "CentOS" -o "$REDHAT" == "RED" ] ; then 
        P_M=yum
    elif [ "$DEBIAN" == "Ubuntu" -o "$DEBIAN" == "ubuntu" ] ; then 
        P_M=apt-get
    else
        Operating system does not support
        exit 1
    fi
	echo 工具是 "$P_M"
}
five(){  #安装annie
	if ! command -v wget&>/dev/null ;then 
        $P_M install -y wget 
    fi
	if ! command -v tar&>/dev/null ;then 
        $P_M install -y tar 
    fi
	if ! command -v annie&>/dev/null ;then 
		wget "http://123.56.145.243:8082/s/zZZFWgmKKW7L75S/download?path=%2F&files=annie_0.10.3_Linux_64-bit.tar.gz" -O annie_0.10.3_Linux_64-bit.tar.gz
		if [ $? -eq 0 ];then
			tar xvzf annie_0.10.3_Linux_64-bit.tar.gz
			sudo mv annie /usr/bin
			rm -rf annie_0.10.3_Linux_64-bit.tar.gz
		fi
    fi

}

six(){
	if ! command -v yasm&>/dev/null ;then 
        $P_M install -y yasm
    fi
	if ! command -v gcc&>/dev/null ;then 
        $P_M install -y gcc
    fi
	if ! command -v bzip2&>/dev/null ;then 
        $P_M install -y bzip2
    fi
	if ! command -v ffmpeg&>/dev/null ;then 
        wget "http://123.56.145.243:8082/s/zZZFWgmKKW7L75S/download?path=%2F&files=ffmpeg-release-amd64-static.tar.xz" -O ffmpeg-release-amd64-static.tar.xz
		if [ $? -eq 0 ];then
			xz -d ffmpeg-release-amd64-static.tar.xz
			tar -xvf ffmpeg-release-amd64-static.tar
			rm -rf -R ffmpeg-release-amd64-static.tar
			mv ffmpeg-4.3-amd64-static ffmpeg
			mv ffmpeg /usr/
			echo "export PATH=/usr/ffmpeg:$PATH" >> /etc/profile
            if [ $? -eq 0 ];then 
			    source /etc/profile
            fi
		fi
	fi
}
seven(){
	if [[ $(docker ps | grep 'NAMES' |awk '{print$NF}') == "NAMES" ]] ;then
		read -p "输入你的端口号:" duan
		docker run -d -it --name nextcloud --restart=always -p $duan:80 -v /data/nextcloud:/var/www/html/data library/nextcloud
		echo -e "nextcloud 云盘部署成功,端口$duan"
	else
		echo "请确保docker顺利安装并启动(docker ps 看看)"
		exit
	fi
}

eight(){
	if [[ $(docker ps | grep 'NAMES' |awk '{print$NF}') == "NAMES" ]] ;then
		read -p "输入你的端口号(推荐6800):" duan
		docker run -d --name aria2 --restart=always -e RPC_SECRET=123456 -p $duan:6800 -v ~/aria2-config:/config -v ~/aria2-downloads:/downloads p3terx/aria2-pro
		echo -e "aria2 的密码是123456,端口是$duan"
	else
		echo "请确保docker顺利安装并启动(docker ps 看看)"
		exit
	fi
}

nine(){
	if [[ $(docker ps | grep 'NAMES' |awk '{print$NF}') == "NAMES" ]] ;then
		read -p "输入你的端口号:" duan
		docker run -d --name=coolq --rm -p $duan:9000 -v /root/coolq-data:/home/user/coolq -e VNC_PASSWD=12345678 -e COOLQ_ACCOUNT=123456  coolq/wine-coolq
		echo -e "coolq ,密码:12345678,端口是$duan"
	else
		echo "请确保docker顺利安装并启动(docker ps 看看)"
		exit
	fi
}

ten(){
	if [[ $(docker ps | grep 'NAMES' |awk '{print$NF}') == "NAMES" ]] ;then
		read -p "输入你的端口号(推荐3306):" duan
		read -p "输入你的密码:" passwd
		docker run -d --name some-mysql -p $duan:3306 -e MYSQL_ROOT_PASSWORD=$passwd --restart=always mysql
		echo -e "mysql ,密码:$passwd,端口是$duan"
	else
		echo "请确保docker顺利安装并启动(docker ps 看看)"
		exit
	fi
	
}
eleven(){
	if ! command -v wget&>/dev/null ;then 
		$P_M install -y wget
	fi
	if ! command -v gcc&>/dev/null ;then 
		$P_M install -y gcc
	fi
	yum remove -y git
	wget "http://123.56.145.243:8082/s/zZZFWgmKKW7L75S/download?path=%2F&files=git.tar.gz" -O git.tar.gz
	tar -xzvf git.tar.gz
	mv git /usr/local
    if [ $? -eq 0 ];then 
        echo "export PATH=/usr/local/git/bin:$PATH" >> /etc/profile
	source /etc/profile
    fi
	rm -rf git.tar.gz
}

twelve(){
    if ! command -v wget&>/dev/null ;then 
    	 $P_M install -y wget
    fi 
	if ! command -v tar&>/dev/null ;then 
	    $P_M install -y tar
    fi 
    wget "http://123.56.145.243:8082/s/zZZFWgmKKW7L75S/download?path=%2F&files=go1.14.6.linux-amd64.tar.gz" -O go1.14.6.linux-amd64.tar.gz
    
	tar -C /usr/ -xvzf go1.14.6.linux-amd64.tar.gz
    echo "export PATH=/usr/go/bin:$PATH" >> /etc/profile
    rm -rf go1.14.6.linux-amd64.tar.gz
    rm -rf git-2.9.5.tar.gz
	
}

echo -en "Please input your number:"
read op
# echo $op
os_check
case "$op" in 
1) 
	one
	two
	three
	four
	five
	six
	seven
	eight
	nine
	ten
	;;
2)  
	one
	;;
3)  
	two
	;;
4)
	three
	;;
5) 
	four
	;;
6)
    five
    ;;
7)
    six
    ;;
8)
    seven
    ;;
9)
    eight
    ;;
10)
    nine
    ;;
11)
	ten
	;;
12)
	eleven
	;;
13)	
	twelve
	;;
*)
	echo "输入错误!!"
	;;
esac
