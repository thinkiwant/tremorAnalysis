# 代码说明
本仓库为用来处理EMG数据的matlab代码，将代码分别放在几个目录下。在运行该仓库下的代码时，有必要先把该仓库目录下所有的目录添加到MATLAB搜索路径中。同时由于一些脚本代码对数据的加载依赖于预定的实验数据路径，所以如果运行时不成功请检查报错处的硬编码配置是否正确。不同代码间的依赖关系可以用MATLAB打开仓库中的工程文件(.prj)，然后使用依存关系分析器功能来查看。
下面对各一级目录进行简要说明。

---

## batch code
该目录下的代码为用来处理数据的脚本代码。代码的功能见文件名，主要用到的文件：
1. `ISI_tremor_psd.m`用来画不同条件下两肌肉的放电间隔的频率直方图
2. `metrics_batch.m`用来从实验数据中计算各受试者在不同不同试次下的指标
3. `multi_group_bar.m`画6种相干性和震颤强度在三种条件下的均值与标准差，同时对三种条件两两间进行统计检验
4. `condition_lined_metrics.m`用来显示不同被试在不同条件下的某个指标的水平
5. `track.m`MU追踪相关代码
## sessantaquattro
该目录下包含特定基础功能的函数，如计算相干性、读取被试数据（`dataLoader.m`)、消除工频干扰（`removePowerFreq.m`）等
1. `Convert_BIO_File.m`将EMG和IMU的原始数据进行分段、整合生成试次数据（实验数据中的integrated files目录下的数据）
2. `calCoherLong.m`, `Coher.m`计算相干性的函数
3. `PoolCST.m`合并脉冲序列
## smallfunctions
该目录下存放一些小功能的函数。
## others
未分类的代码
## MUDecinposition
MU分解代码的示例
## Sessantaquattro Matlab
OT EMG 采集装置的官方Demo
`Open_sessa_bio_file`从BIO文件中读数据
`READ_sessantaquattro`从sessantaquattro在线读数据
## Helen's Phd
生成MUAP的Demo代码
## cbrewer-master
用于生成色盘编码的第三方模块

---

The codes have been controled with git and the remote repository can be found at:
https://github.com/thinkiwant/tremorAnalysis
