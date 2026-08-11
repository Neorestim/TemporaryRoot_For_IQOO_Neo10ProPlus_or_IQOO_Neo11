# **You should know this before using it:**

  该项目利用preload.so提权漏洞，暂时不清楚能存活多久，思路及preload.so来源于酷安

  项目内置adb工具包，可以直接adb调用

  可能存在BUG，我自己测试下来感觉貌似没什么问题

  另，因KernelSU的守护进程KSUD在临时提权的环境下会因为热重启而可能狗带，而我又怎么也找不出怎么重新启动这个KSUD守护进程的办法，遂选择直接封一个su进去

  这个su甚至是直接掏的termux的

  怎么会有这么垃圾的手机啊🤣👉🏻🤡

  再插一嘴：如果能稳定用就尽量不要更新系统，这个漏洞估计很快就会下发系统补丁堵上，到时候估计很难搞。


# **有问题CLICK ME AT：**
  佛曰：咩那菩哆谨钵南啰谨驮阿伽室南度娑他沙南咩萨那唎唵南佛唎迦墀那阿罚驮咩遮佛那穆卢卢输哆钵写地那参诃烁烁唵萨罚蒙


# **Operation process:**

  在开始操作之前，请确保你已经知晓root可能对手机带来的风险以及损害。之后，让我们开始操作流程。以下是shell纯享

·电脑端操作：

 adb reboot                                                              #手机重启之后会恢复到还没开始加载preload.so的阶段。这一阶段持续到手机解锁。
 
 adb shell rm -f /data/local/tmp/preload.so                              #清除手机内的preload.so
 
 adb push Resource_file\preload.so /data/local/tmp/                    #推送有提权漏洞的preload.so
 
 adb shell "LD_PRELOAD=/data/local/tmp/preload.so /system/bin/id"        #加载有漏洞的preload.so，开始提权。这一步需要等待比较久，且preload.so不能再次提权。提权之后一旦解锁手机，会导致shell的临时root权限丢失（connected refused）。
 
 adb shell su                                                            #进入临时提权的adb shell
 
 $(find /data/app -name libksud.so | grep "me.weishu.kernelsu" | head -n 1) late-load --allow-shell --package-name me.weishu.kernelsu                    #使用LKM模式激活kernelSU，正式接管root权限。此时临时root不会随解锁而丢失。
 
 adb shell su -c "ps -A | grep ksud"                                     #检查KSUD是否运行，这一步能帮助你确认KernelSU是否真的拿到权限。


·进阶:

  ·关于其他

   ~\Resource_file下放了一些东西
   
   比如方便你在已有root的情况下直接激活KernelSU的bat，
   
   以及KernelSU的安装包，
   
   适用于IQOO Neo10 Pro+ /IQOO Neo11 的preload.so文件与kernelsu.ko核心（目前截至到neo10proplus:PD2463D_A_16.1.19.1.W10.V000L1可用，再新的不敢更新），

   理论来说，你可以通过把kernelsu.ko直接insmod进Selinux宽容的环境里。 ~~（但是你直接用一键脚本自动激活或者 $(find /data/app -name libksud.so | grep "me.weishu.kernelsu" | head -n 1) late-load --allow-shell --package-name me.weishu.kernelsu 激活不好吗？）~~

   另，如果需要 IQOO Neo10 Pro+的全分区备份可以Cue我。我也许会试着做一个救砖包？
   
  
  ~~·apex_su_fix模块~~现已移除
   

·正常使用：

  因为是LKM加载方式，root会在重启后丢失。所以，KernelSU模块的加载及部分需要hook系统框架的LSPosed APK 想加载只能通过热重启办法。而热重启有概率死机，一旦死机了你就只能冷重启然后重新走提权了（悲
  
  Zygisk在激活KernelSU之后必须进行热重启才能加载，甚至可能你热重启都加载不上。多试几下（
  
  实测KernelSU Grant Toast模块在绝大部分情况下会无法运行。
  

# **Changelog:** 

 ·2026.8.3  15:02
    修复了apex_su_fix模块可能导致无法打开相机的异常情况。
    ~~（因为当时就是选择直接在开机时用模块内的post-fs-data.sh进行mount，结果手机直接找不到相机设备了。甚至不是相机崩溃而是直接找不到相机设备XD）~~

 ·2026.8.7  19:04
    移除了apex_su_fix模块。
      经实测，对apex的挂载会导致相机功能异常，就算短时间不会出问题，时间长了之后也会掉设备，遂移除

 ·2026.8.11  23:09
   修复了存在的命令错误
