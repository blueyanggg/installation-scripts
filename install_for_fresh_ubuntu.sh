
#第一步换源，阿里
cd /etc/apt/  
sudo cp sources.list sources.list.bak 
sudo gedit sources.list
‘’‘
第二步：替换源

阿里云源的文件
    deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse  
    deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse  
    deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse  
    deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse  
    ##测试版源  
    deb http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse  
    # 源码  
    deb-src http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse  
    deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse  
    deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse  
    deb-src http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse  
    ##测试版源  
    deb-src http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse  
    # Canonical 合作伙伴和附加  
    deb http://archive.canonical.com/ubuntu/ xenial partner  
    deb http://extras.ubuntu.com/ubuntu/ xenial main  
’‘’
sudo apt-get update #更新源 
sudo apt-get upgrade #更新软件
sudo apt-get install fcitx-googlepinyin
sudo apt-get install unity-tweak-tool 
# install chromium
sudo add-apt-repository ppa:a-v-shkop/chromium
sudo apt-get update
sudo apt-get install chromium-browser
