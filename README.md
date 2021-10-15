# blake2b_compress 

本工程基于verilog硬件描述语言，对**blake2b**哈希(Hash)算法中的**blake2b_compress**函数进行了硬件实现。**blake2b**哈希算法的计算量主要集中在**compress**函数，本工程中所设计的硬件电路采用了流水线结构对**compress**函数的计算过程进行加速。



## compress 函数

### 函数输入输出：

输入信号包括：

1. a 64-byte chain value h = h0; ...... ; h7
2. a 128-byte message block m = m0; ...... ; m15
3. a counter t = t0; t1, and finalization flags f0; f1  

其中h、m、t、f 位宽均为64；

输出包括8个64位数据：h0‘;......; h7’, 对应输入的h0; ...... ; h7；

### 计算过程：

1. compress函数先初始化16个中间中间状态v0;......v15;具体的初始化方式如下：

<img src="doc\v-state.PNG" style="zoom: 67%;" />

2. 对16个中间状态进行连续12个round的转换，每个round的操作包括：

<img src="doc\round.PNG" style="zoom: 67%;" />

3. G()的具体操作包括：

<img src="doc\G.PNG" style="zoom:67%;" />

4. 经过12个round后的中间状态v和输入h进行逻辑运算得到输出h‘：

<img src="doc\h.PNG" style="zoom:67%;" />

blake2b和compress的详细算法介绍参见官方文档；

## 电路硬件架构

根据compress函数的具体计算过程，设计的整体电路架构如下：

<img src="doc\compress.jpg" alt="compress" style="zoom: 25%;" />

该架构中blake2b_round_a和blake2b_round_b组合实现了一个round中对v的所有转换，其中round_a实现了G0到G3，round_b实现了G4到G7，每个round_a/b模块的输出均有寄存器缓存，因此整个电路共有24级流水线；

hm_reg模块主要由寄存器组成，为每级流水线暂存了输入的h和m; 

v_generation为组合逻辑通路，实现了输入信号到中间状态v的转换；output generation 为组合逻辑通路，实现了中间态v到输出h的转换；

### round_a和round_b的电路架构如下：

<img src="doc\round_arch.jpg" style="zoom:25%;" />

round模块的输入输出包括：

1. round_i和round_o:round_i当前模块的轮数，round_o下一个模块的轮数；
2. v_i和v_o:输入和输出的中间态v；
3. mindex_bus_o和m_bus_i: 分别是m的索引和该索引对应的m值，这两个接口用于G()计算过程中从mh_reg索引获得所需的m数据；
4. sigma模块为sigma值的查找表，G()计算过程中需要通过查找表获得mindex的值；



### G模块的架构如下图所示：<img src="doc\G-arch.jpg" style="zoom: 50%;" />

blake2b_G模块的输出均通过寄存器打一拍，blake2b_G模块还包括从查找表中获取sigma值以及从hm_reg中获取m值的信号



## 验证

本工程中测试用例的生成基于官方实现的blake2b算法，从blake2b的C语言实现中分离出compress函数的部分，指定输入h、m、t、f的值生成对应的h';

C语言compress输出结果：

<img src="doc\c-out.PNG" style="zoom: 67%;" />

verilog实现compress输出结果：

<img src="doc\verilog-out.JPG" style="zoom:67%;" />





