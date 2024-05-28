# P4-RESISTING-tofino

The RESISTING is a new FRR-ECMP mechanism for P4 programmable switches. This repository contains the P4 implementation for the Tofino switch and running scripts.


### Network Topology 
<img src="top-tofino.png" alt="Topologia Tofino"  width="550" height="400"/>

### Installation and Compiling
clone P4-RESISTING-tofino
```
git clone https://github.com/danielbl1000/P4-RESISTING-tofino.git
```
<img src="/figs/fig01.JPG" alt="Clone">

To compile RESISTING code:
```
cd P4-RESISTING-tofino/src/
```
```
p4_build.sh tna_6p_frr_v1_resisting.p4
```
<img src="/figs/fig03.JPG" alt="Compiling">

