# blake2b_compress 

This repository includes a project which implements **compress** function in the **Blake2b** Hash algorithm based on the **Verilog** hardware description language. The **compress** function is the main part of the **blake2b** and most of its calculation is done by **compress** function. The hardware circuit proposed in this project used the pipeline structure to accelerate the calculation process of **compress** function.



## Brief Of Compress

### The Input And Output Of The Compress：

Input variables include：

1. a 64-byte chain value h = h0; ...... ; h7
2. a 128-byte message block m = m0; ...... ; m15
3. a counter t = t0; t1, and finalization flags f0; f1  

The width of h, m, t and f is 64 bit.

Output variables include 8 64-bit words: h0‘;......; h7’, corresponding to the input variable: h0; ...... ; h7；

### Computation Process：

1. **compress** initializes a 16-word internal state: v0;......v15; that is：

<img src="doc\v-state.PNG" style="zoom: 67%;" />

2. The internal state v is then transformed through a sequence of 12 rounds, where a round
   does: 

<img src="doc\round.PNG" style="zoom: 67%;" />

3. The **G** function of blake2b is defined as below:

<img src="doc\G.PNG" style="zoom:67%;" />

4. After the 12 rounds, the output values: h0'......h7'is defined as  below:

<img src="doc\h.PNG" style="zoom:67%;" />

The specification of **blake2b** and **compress** is described in the official document.

## Architecture Of Circuit:

According to the calculation process of **compress**, the architecture of the overall circuit is as follows:

<img src="doc\compress.jpg" alt="compress" style="zoom: 25%;" />

In this architecture, **blake2b_round_a** and **blake2b_round_b** modules combine to realize the conversion of internal state **v**. The **blake2b_round_a** module implements G0 to G3 in a round and the **blake2b_round_b** module implements G4 to G7 in the same round. The output of **blake2b_round_a/b** is both buffered by registers, and so the total circuit has 24 pipeline stages.

The **hm_reg** module is mainly composed of registers, which temporarily store the input h and m for each pipeline stage.

**v generation** is a combinational logic path, which realizes the conversion of input signal to intermediate state **v**. And **output generation** is the combinational logic path, which realizes the conversion from intermediate state V to output H.

### The Specific Architecture Of blake2b_round_a/b：

<img src="doc\round_arch.jpg" style="zoom: 33%;" />

The input and output signals of **blake2b_round_a/b** module includes:

1. **round_i** and **round_o: ** **round_i** indicates the round number of this module and **round_o** indicates the round number of the next module;
2. **v_i** and **v_o:** the input internal state **v** and the output internal state **v**；
3. **mindex_bus_o** and **m_bus_i**: are the index of m and the corresponding m value of this value; these two signals are designed to obtain the required m data from the **mh_reg** in the calculation process of the **G** function.
4. **sigma** module is the lookup table of sigma values, and the mindex value is obtained through the lookup table during the calculation process of the **G** function.



### The Specific Architecture of G ：

<img src="doc\G-arch.jpg" style="zoom: 50%;" />

The output of the **blake2b_G** module is registered, and the blake2b_G module also includes signals to get the sigma value from the lookup table and the m value from **hm_reg** module.



## Verification Of The Design:

The generation of test cases in this project is based on the blake2b algorithm officially implemented. The part of **compress** function is separated from blake2b implementation in C language, and generates corresponding h' after specifying the input values of h, m, t and f.

The output of **compress** function implemented in C language:

<img src="doc\c-out.PNG" style="zoom: 67%;" />

The output of **compress** function implemented in Verilog with the same input:

<img src="doc\verilog-out.JPG" style="zoom:67%;" />

Execute ./run.sh and it will generate a random test case automatically, and then it will run testbench.v and check whether the output of **blake2b_compress** module is consistent with the standard output:

<img src="D:doc\run.JPG" style="zoom: 67%;" />



