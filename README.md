# **You should know this before using it:**

  该项目利用preload.so提权漏洞，暂时不清楚能存活多久，思路及preload.so来源于酷安

  项目内置adb工具包，Hybrid Mount-v4.2.0项目（挂载编排元模块，是apex_su_fix的必要前置），apex_su_fix（自己写的小烂玩意，用于修复vivo胡乱改su及偶现的因KSUD狗带导致的su释放异常问题）

  可能存在BUG，我自己测试下来感觉貌似没什么问题

  另，因KernelSU的守护进程KSUD在临时提权的环境下会因为热重启而可能狗带，而我又怎么也找不出怎么重新启动这个KSUD守护进程的办法，遂选择直接封一个su进去

  这个su甚至是直接掏的termux的

  怎么会有这么垃圾的手机啊🤣👉🏻🤡

  再插一嘴：如果能稳定用就尽量不要更新系统，这个漏洞估计很快就会下发系统补丁堵上，到时候估计很难搞。


# **有问题CLICK ME AT：**
  佛曰：咩那菩哆谨钵南啰谨驮阿伽室南度娑他沙南咩萨那唎唵南佛唎迦墀那阿罚驮咩遮佛那穆卢卢输哆钵写地那参诃烁烁唵萨罚蒙


# **Operation process:**
  ~~这一部分和下面的更新日志不会在zip里更新。别问，问就是懒~~

  在开始操作之前，请确保你已经知晓root可能对手机带来的风险以及损害。之后，让我们开始操作流程。以下是shell纯享

·电脑端操作：

 adb reboot                                                              #手机重启之后会恢复到还没开始加载preload.so的阶段。这一阶段持续到手机解锁。
 
 adb shell rm -f /data/local/tmp/preload.so                              #清除手机内的preload.so
 
 adb push ~\Resource_file\preload.so /data/local/tmp/                    #推送有提权漏洞的preload.so
 
 adb shell "LD_PRELOAD=/data/local/tmp/preload.so /system/bin/id"        #加载有漏洞的preload.so，开始提权。这一步需要等待比较久，且preload.so不能再次提权。提权之后一旦解锁手机，会导致shell的临时root权限丢失（connected refused）。
 
 adb shell su                                                            #进入临时提权的adb shell
 
 $(find /data/app -name libksud.so | grep "me.weishu.kernelsu" | head -n 1) late-load --allow-shell --package-name me.weishu.kernelsu                    #使用LKM模式激活kernelSU，正式接管root权限。此时临时root不会随解锁而丢失。
 
 adb shell su -c "ps -A | grep ksud"                                     #检查KSUD是否运行，这一步能帮助你确认KernelSU是否真的拿到权限。


·进阶:

  ·apex_su_fix模块激活原理
  
   提权的临时su位于apex/com.android/virt目录，这一目录的su为系统变量默认指向位置。解开屏保锁后，临时su会丢失root权限，对其所有的访问都会被 connected refused。
   
   而有些应用比如shizuku，scene等，它们不支持自定义su，只能对着这个死了的su干瞪眼。apex_su_fix 模块就是为了解决这个问题。
   
   原理上，apex_su_fix 以 Hybrid Mount 为前置模块，先把su文件overlays到/system/bin/su（为了解决偶发性的KSUD发病导致kernelSU不释放su文件使得没有root访问点），
   
   之后把/system/bin/su 的快捷方式overlays到/apex/com.android.virt/bin/su，直接偷天换日路由到可以使用的su。不过，在这之前，你还需要一些操作。


 ·apex_su_fix模块激活方法
 
   安装Hybrid Mount模块，选择配置，额外分区添加apex，保存。
   
   是的，就这么简单。在我的设备上它是好使的。
   
   如果不好使呢？别慌，还有命令！
   
   在root shell下输入 /system/bin/su -c mount --bind /data/adb/modules/apex_su_fix/system/bin/su /apex/com.android.virt/bin/su
   
   注意一定要是root（比如命令行前面写的 PD2463:/ #  ，一定是 # 而不是 $ ！），否则这个mount可能并不生效。
   
   ~~再插一嘴：如果你选择直接在开机时用模块内的post-fs-data.sh进行mount，会导致找不到相机。我并不知道这和相机有什么关系，但是就是这样。~~
   

·正常使用：

  因为是LKM加载方式，root会在重启后丢失。所以，KernelSU模块的加载及部分需要hook系统框架的LSPosed APK 想加载只能通过热重启办法。而热重启有概率死机，一旦死机了你就只能冷重启然后重新走提权了（悲
  
  Zygisk在激活KernelSU之后必须进行热重启才能加载，甚至可能你热重启都加载不上。多试几下（
  
  实测KernelSU Grant Toast模块会在报错提示未初始化的情况下正常运行，原因不明。bat我懒得改了，就那样吧。
  

# **Changelog:** 

 ·2026.8.3  15:02
    修复了apex_su_fix模块可能导致无法打开相机的异常情况。
    ~~（因为当时就是选择直接在开机时用模块内的post-fs-data.sh进行mount，结果手机直接找不到相机设备了。甚至不是相机崩溃而是直接找不到相机设备XD）~~
