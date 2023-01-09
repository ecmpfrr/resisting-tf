#
# REGAS PARA TESTAR TRAFICO DO NECOS P0(S1-128(1/0)) para o NECOS P1(S2-129(1/1))
# Loop 196 pipe 1
# Uplinks
# S1-25(20/1) - S2-41(22/1)
# S1-26(20/2) - S2-42(22/2)
# S1-27(20/3) - S2-43(22/3)
# S1-180(26/0) - S2-172(27/0)
# S1-181(26/1) - S2-173(27/1)
# S1-182(26/2) - S2-174(27/2)
# S1-128 - Necos-Trex-T1
# S2-129 - Necos-Trex-T2
# S1-136 - H1
# S2-131 - 2


from ipaddress import ip_address

p4 = bfrt.tna_6p_frr_v1_resisting.pipe

#filter_pkt = p4.Ingress.filter_pkt
#filter_pkt.dump(table=True,from_hw=1)
#filter_pkt.add_with_no_act(0x800)
#filter_pkt.add_with_no_act(0x255)
#filter_pkt.dump(table=True,from_hw=1)

ipv4_lpm = p4.Ingress.ipv4_lpm
ipv4_lpm.clear()
ipv4_lpm.add_with_set_nhop_local(0x800,'25','10.0.0.11',32,'001b:21a0:52d4','136')
ipv4_lpm.add_with_set_nhop_local(0x800,'26','10.0.0.11',32,'001b:21a0:52d4','136')
ipv4_lpm.add_with_set_nhop_local(0x800,'27','10.0.0.11',32,'001b:21a0:52d4','136')
ipv4_lpm.add_with_set_nhop_local(0x800,'180','10.0.0.11',32,'001b:21a0:52d4','136')
ipv4_lpm.add_with_set_nhop_local(0x800,'181','10.0.0.11',32,'001b:21a0:52d4','136')
ipv4_lpm.add_with_set_nhop_local(0x800,'182','10.0.0.11',32,'001b:21a0:52d4','136')
ipv4_lpm.add_with_set_nhop_network(0x800,'131','10.0.0.11',32,'10')

ipv4_lpm.add_with_set_nhop_local(0x800,'41','20.0.0.12',32,'ac1f:6b67:0671','131')
ipv4_lpm.add_with_set_nhop_local(0x800,'42','20.0.0.12',32,'ac1f:6b67:0671','131')
ipv4_lpm.add_with_set_nhop_local(0x800,'43','20.0.0.12',32,'ac1f:6b67:0671','131')
ipv4_lpm.add_with_set_nhop_local(0x800,'172','20.0.0.12',32,'ac1f:6b67:0671','131')
ipv4_lpm.add_with_set_nhop_local(0x800,'173','20.0.0.12',32,'ac1f:6b67:0671','131')
ipv4_lpm.add_with_set_nhop_local(0x800,'174','20.0.0.12',32,'ac1f:6b67:0671','131')

ipv4_lpm.add_with_set_nhop_network(0x800,'136','20.0.0.12',32,'20')
ipv4_lpm.add_with_set_nhop_network(0x800,'40','20.0.0.12',32,'20')

ipv4_lpm.add_with_set_nhop_network(0x800,'64','20.0.0.12',32,'20')
ipv4_lpm.add_with_set_nhop_network(0x800,'196','20.0.0.12',32,'20')
ipv4_lpm.add_with_set_nhop_network(0x800,'324','20.0.0.12',32,'20')
ipv4_lpm.add_with_set_nhop_network(0x800,'448','20.0.0.12',32,'20')


ipv4_lpm.add_with_set_nhop_local(0x800,'41','20.0.0.13',32,'ac1f:6b67:0601','129')
ipv4_lpm.add_with_set_nhop_local(0x800,'42','20.0.0.13',32,'ac1f:6b67:0601','129')
ipv4_lpm.add_with_set_nhop_local(0x800,'43','20.0.0.13',32,'ac1f:6b67:0601','129')
ipv4_lpm.add_with_set_nhop_local(0x800,'172','20.0.0.13',32,'ac1f:6b67:0601','129')
ipv4_lpm.add_with_set_nhop_local(0x800,'173','20.0.0.13',32,'ac1f:6b67:0601','129')
ipv4_lpm.add_with_set_nhop_local(0x800,'174','20.0.0.13',32,'ac1f:6b67:0601','129')

ipv4_lpm.add_with_set_nhop_network(0x800,'128','20.0.0.13',32,'20')
ipv4_lpm.add_with_set_nhop_network(0x800,'196','20.0.0.13',32,'20')

ipv4_lpm.add_with_set_nhop_direct(0x800,'136','224.0.0.0',8,'131')
ipv4_lpm.add_with_set_nhop_direct(0x800,'131','224.0.0.0',8,'136')


ipv4_lpm.add_with_drop_act(0x800,'128','0.0.0.0',0)
ipv4_lpm.add_with_drop_act(0x800,'8','0.0.0.0',0)
ipv4_lpm.add_with_drop_act(0x800,'129','0.0.0.0',0)
ipv4_lpm.add_with_drop_act(0x800,'18','0.0.0.0',0)


ipv4_lpm.add_with_drop_act(0x800,'40','0.0.0.0',32,'0')
ipv4_lpm.dump(table=True,from_hw=1)


rg_port_out_5 = p4.Ingress.rg_port_out_5
rg_port_out_5.clear()
rg_port_out_5.add(0,182)
rg_port_out_5.dump(table=True,from_hw=1)


rg_port_out_4 = p4.Ingress.rg_port_out_4
rg_port_out_4.clear()
rg_port_out_4.add(0,181)
rg_port_out_4.dump(table=True,from_hw=1)


rg_port_out_3 = p4.Ingress.rg_port_out_3
rg_port_out_3.clear()
rg_port_out_3.add(0,180)
rg_port_out_3.dump(table=True,from_hw=1)


rg_port_out_2 = p4.Ingress.rg_port_out_2
rg_port_out_2.clear()
rg_port_out_2.add(0,27)
rg_port_out_2.dump(table=True,from_hw=1)


rg_port_out_1 = p4.Ingress.rg_port_out_1
rg_port_out_1.clear()
rg_port_out_1.add(0,26)
rg_port_out_1.dump(table=True,from_hw=1)


#Registro de porta de saida, egress port
# Adiciona (posicao, port)
rg_port_out = p4.Ingress.rg_port_out

#rg_port_out.dump(table=True,from_hw=1)
rg_port_out.clear()
rg_port_out.add(0,25)

#Registro Default path, pacotes com destino a porta 255 sao encaminhandos para a porta
# deste registro
rg_default_path = p4.Ingress.rg_default_path

rg_default_path.dump(table=True,from_hw=1)
rg_default_path.clear()
rg_default_path.add(0,25)


#A tabela update_port executa o registro rg_port_out_wr para atualizar o index com a
# nova porta. A porta é recebida do campo hdr.frr.idx_port_down do header FRR
#update_port_out = p4.Ingress.update_port_out
#Se for estiver em loop (bit=1), atualiza a porta na posicao do idx

update_port_out_5 = p4.Ingress.update_port_out_5
update_port_out_5.dump(table=True,from_hw=1)
update_port_out_5.clear()
update_port_out_5.add_with_set_add_port_out_5(5,1)

update_port_out_5.add_with_set_add_port_out_5(4,1)
update_port_out_5.add_with_set_add_port_out_5(3,1)
update_port_out_5.add_with_set_add_port_out_5(2,1)
update_port_out_5.add_with_set_add_port_out_5(1,1)
update_port_out_5.add_with_set_add_port_out_5(0,1)


update_port_out_4 = p4.Ingress.update_port_out_4
update_port_out_4.dump(table=True,from_hw=1)
update_port_out_4.clear()
update_port_out_4.add_with_set_add_port_out_4(4,1)
update_port_out_4.add_with_set_add_port_out_4(3,1)
update_port_out_4.add_with_set_add_port_out_4(2,1)
update_port_out_4.add_with_set_add_port_out_4(1,1)
update_port_out_4.add_with_set_add_port_out_4(0,1)

update_port_out_3 = p4.Ingress.update_port_out_3
update_port_out_3.dump(table=True,from_hw=1)
update_port_out_3.clear()
update_port_out_3.add_with_set_add_port_out_3(3,1)
update_port_out_3.add_with_set_add_port_out_3(2,1)
update_port_out_3.add_with_set_add_port_out_3(1,1)
update_port_out_3.add_with_set_add_port_out_3(0,1)

update_port_out_2 = p4.Ingress.update_port_out_2
update_port_out_2.dump(table=True,from_hw=1)
update_port_out_2.clear()
update_port_out_2.add_with_set_add_port_out_2(2,1)
update_port_out_2.add_with_set_add_port_out_2(1,1)
update_port_out_2.add_with_set_add_port_out_2(0,1)

update_port_out_1 = p4.Ingress.update_port_out_1
update_port_out_1.dump(table=True,from_hw=1)
update_port_out_1.clear()
update_port_out_1.add_with_set_add_port_out_1(1,1)
update_port_out_1.add_with_set_add_port_out_1(0,1)


#A tabela update_port executa o registro rg_port_out_wr para atualizar o index com a
# nova porta. A porta é recebida do campo hdr.frr.idx_port_down do header FRR
update_port_out = p4.Ingress.update_port_out
#Se for estiver em loop (bit=1), atualiza a porta na posicao do idx
update_port_out.dump(table=True,from_hw=1)
update_port_out.clear()
update_port_out.add_with_set_add_port_out(0,1)

# A tabela update_default_path executa o registro rg_default_path_wr e atualiza o
#index da porta default (igual a tabela update_port)
update_default_path = p4.Ingress.update_default_path
#Se for estiver em loop (bit=1), atualiza o default_path com a mesma porta do idx 0
update_default_path.dump(table=True,from_hw=1)
update_default_path.clear()
#update_default_path.add_with_set_add_default_path(0,1)
update_default_path.add_with_set_add_default_path(0,1)


fowarding_tag_5 = p4.Ingress.fowarding_tag_5
fowarding_tag_5.dump(table=True,from_hw=1)
fowarding_tag_5.clear()
fowarding_tag_5.add_with_set_fowarding_port_out_5(20,5,0)

fowarding_tag_4 = p4.Ingress.fowarding_tag_4
fowarding_tag_4.dump(table=True,from_hw=1)
fowarding_tag_4.clear()
fowarding_tag_4.add_with_set_fowarding_port_out_4(20,4,0)

fowarding_tag_3 = p4.Ingress.fowarding_tag_3
fowarding_tag_3.dump(table=True,from_hw=1)
fowarding_tag_3.clear()
fowarding_tag_3.add_with_set_fowarding_port_out_3(20,3,0)

fowarding_tag_2 = p4.Ingress.fowarding_tag_2
fowarding_tag_2.dump(table=True,from_hw=1)
fowarding_tag_2.clear()
fowarding_tag_2.add_with_set_fowarding_port_out_2(20,2,0)

fowarding_tag_1 = p4.Ingress.fowarding_tag_1
fowarding_tag_1.dump(table=True,from_hw=1)
fowarding_tag_1.clear()
fowarding_tag_1.add_with_set_fowarding_port_out_1(20,1,0)

fowarding_tag = p4.Ingress.fowarding_tag
fowarding_tag.dump(table=True,from_hw=1)
fowarding_tag.clear()
fowarding_tag.add_with_set_fowarding_port_out(20,0,0)

fowarding_tag.add_with_set_fowarding_port_out_without_reg(10,11,0,41)
fowarding_tag.add_with_set_fowarding_port_out_without_reg(10,12,0,42)
fowarding_tag.add_with_set_fowarding_port_out_without_reg(10,13,0,43)
fowarding_tag.add_with_set_fowarding_port_out_without_reg(10,14,0,172)
fowarding_tag.add_with_set_fowarding_port_out_without_reg(10,15,0,173)
fowarding_tag.add_with_set_fowarding_port_out_without_reg(10,16,0,174)


default_path = p4.Ingress.default_path
default_path.clear()
default_path.add_with_set_default_path(255,0)
default_path.dump(table=True,from_hw=1)


port_status = p4.Ingress.port_status
port_status.dump(table=True,from_hw=1)
port_status.clear()
port_status.add_with_set_port_status_down(25,0,0x800,0)
port_status.add_with_set_port_status_down(26,0,0x800,0)
port_status.add_with_set_port_status_down(27,0,0x800,0)
port_status.add_with_set_port_status_down(180,0,0x800,0)
port_status.add_with_set_port_status_down(181,0,0x800,0)
port_status.add_with_set_port_status_down(182,0,0x800,0)
port_status.add_with_set_port_status_down(128,0,0x800,0)
port_status.add_with_set_port_status_down(8,0,0x800,0)
port_status.add_with_set_port_status_down(41,0,0x800,0)
port_status.add_with_set_port_status_down(42,0,0x800,0)
port_status.add_with_set_port_status_down(43,0,0x800,0)
port_status.add_with_set_port_status_down(172,0,0x800,0)
port_status.add_with_set_port_status_down(173,0,0x800,0)
port_status.add_with_set_port_status_down(174,0,0x800,0)
port_status.add_with_set_port_status_down(129,0,0x800,0)
port_status.add_with_set_port_status_down(18,0,0x800,0)

port_status.add_with_set_port_status_down(136,0,0x800,0)
port_status.add_with_set_port_status_down(131,0,0x800,0)

port_status.add_with_set_port_status_down(24,0,0x800,0)
port_status.add_with_set_port_status_down(40,0,0x800,0)

port_status.add_with_set_port_status_down(0,0,0x255,0)
port_status.add_with_set_port_status_down(0,1,0x255,1)

port_status.add_with_set_port_status_down(25,0,0x255,0)
port_status.add_with_set_port_status_down(26,0,0x255,0)
port_status.add_with_set_port_status_down(27,0,0x255,0)
port_status.add_with_set_port_status_down(180,0,0x255,0)
port_status.add_with_set_port_status_down(181,0,0x255,0)
port_status.add_with_set_port_status_down(182,0,0x255,0)
port_status.add_with_set_port_status_down(128,0,0x255,0)
port_status.add_with_set_port_status_down(8,0,0x255,0)
port_status.add_with_set_port_status_down(41,0,0x255,0)
port_status.add_with_set_port_status_down(42,0,0x255,0)
port_status.add_with_set_port_status_down(43,0,0x255,0)
port_status.add_with_set_port_status_down(172,0,0x255,0)
port_status.add_with_set_port_status_down(173,0,0x255,0)
port_status.add_with_set_port_status_down(174,0,0x255,0)
port_status.add_with_set_port_status_down(129,0,0x255,0)
port_status.add_with_set_port_status_down(18,0,0x255,0)

port_status.add_with_set_port_status_down(24,0,0x255,0)
port_status.add_with_set_port_status_down(40,0,0x255,0)



frr_recirculation = p4.Ingress.frr_recirculation
#antiga tabela frr_rec
# table frr_recirculation {
#        key = {
#            ig_md.port_status_up_down : exact;
#            hdr.frr.loop : exact;
#            hdr.ethernet.ether_type: exact;
#    }

# Cada regra usa um idx no direct-register
frr_recirculation.dump(table=True,from_hw=1)
frr_recirculation.clear()
frr_recirculation.add_with_set_frr_recirculation_first_failure_port_pipe_1(1,128,196)



frr_recirculation.dump(table=True,from_hw=1)
frr_no_recovery = p4.Ingress.frr_no_recovery
frr_no_recovery.dump(table=True,from_hw=1)
frr_no_recovery.clear()
frr_no_recovery.add_with_set_frr_no_recovery(0,0,0x255)
frr_no_recovery.add_with_set_frr_no_recovery(0,0,0x800)
frr_no_recovery.dump(table=True,from_hw=1)

#Os Registro frr_port_out são resposaveis pela exclusao da porta down, reordenacao das portas
#remanescentes ativas e atualizacao do regestro port_out (ingress) via header FRR/recirculacao
#
#
rg_frr_port_out_5 = p4.Egress.rg_frr_port_out_5
rg_frr_port_out_5.dump(table=True,from_hw=1)
rg_frr_port_out_5.clear()
rg_frr_port_out_5.add(0,182)

rg_frr_port_out_4 = p4.Egress.rg_frr_port_out_4
rg_frr_port_out_4.dump(table=True,from_hw=1)
rg_frr_port_out_4.clear()
rg_frr_port_out_4.add(0,181)

rg_frr_port_out_3 = p4.Egress.rg_frr_port_out_3
rg_frr_port_out_3.dump(table=True,from_hw=1)
rg_frr_port_out_3.clear()
rg_frr_port_out_3.add(0,180)

rg_frr_port_out_2 = p4.Egress.rg_frr_port_out_2
rg_frr_port_out_2.dump(table=True,from_hw=1)
rg_frr_port_out_2.clear()
rg_frr_port_out_2.add(0,27)

rg_frr_port_out_1 = p4.Egress.rg_frr_port_out_1
rg_frr_port_out_1.dump(table=True,from_hw=1)
rg_frr_port_out_1.clear()
rg_frr_port_out_1.add(0,26)

rg_frr_port_out_0 = p4.Egress.rg_frr_port_out_0
rg_frr_port_out_0.dump(table=True,from_hw=1)
rg_frr_port_out_0.clear()
rg_frr_port_out_0.add(0,25)


# As tabelas frr_port_out_X sao resposaveis pela execucao dos registro rg_frr_port
#Ex:
# Ingress
# Idx[2]= 3 down
# Egress
# frr_port_out_3: adiciona porta 255 e copia porta 4 para ser adicionada no frr_port_out_2
# frr_port_out_2: exclui a porta 2 substituindo pela porta recebida do frr_port_out_3
#
frr_port_out_5 = p4.Egress.frr_port_out_5
frr_port_out_5.dump(table=True,from_hw=1)
frr_port_out_5.clear()
frr_port_out_5.add_with_set_add_copy_port_out_5_to_4(1,5)
frr_port_out_5.add_with_set_add_copy_port_out_5_to_4(1,4)
frr_port_out_5.add_with_set_add_copy_port_out_5_to_4(1,3)
frr_port_out_5.add_with_set_add_copy_port_out_5_to_4(1,2)
frr_port_out_5.add_with_set_add_copy_port_out_5_to_4(1,1)
frr_port_out_5.add_with_set_add_copy_port_out_5_to_4(1,0)


frr_port_out_4 = p4.Egress.frr_port_out_4
frr_port_out_4.dump(table=True,from_hw=1)
frr_port_out_4.clear()
frr_port_out_4.add_with_set_add_copy_port_out_4_to_3(1,4)
frr_port_out_4.add_with_set_add_copy_port_out_4_to_3(1,3)
frr_port_out_4.add_with_set_add_copy_port_out_4_to_3(1,2)
frr_port_out_4.add_with_set_add_copy_port_out_4_to_3(1,1)
frr_port_out_4.add_with_set_add_copy_port_out_4_to_3(1,0)


frr_port_out_3 = p4.Egress.frr_port_out_3
frr_port_out_3.dump(table=True,from_hw=1)
frr_port_out_3.clear()
frr_port_out_3.add_with_set_add_copy_port_out_3_to_2(1,3)
frr_port_out_3.add_with_set_add_copy_port_out_3_to_2(1,2)
frr_port_out_3.add_with_set_add_copy_port_out_3_to_2(1,1)
frr_port_out_3.add_with_set_add_copy_port_out_3_to_2(1,0)

frr_port_out_2 = p4.Egress.frr_port_out_2
frr_port_out_2.dump(table=True,from_hw=1)
frr_port_out_2.clear()
frr_port_out_2.add_with_set_add_copy_port_out_2_to_1(1,2)
frr_port_out_2.add_with_set_add_copy_port_out_2_to_1(1,1)
frr_port_out_2.add_with_set_add_copy_port_out_2_to_1(1,0)

frr_port_out_1 = p4.Egress.frr_port_out_1
frr_port_out_1.dump(table=True,from_hw=1)
frr_port_out_1.clear()
frr_port_out_1.add_with_set_add_copy_port_out_1_to_0(1,1)
frr_port_out_1.add_with_set_add_copy_port_out_1_to_0(1,0)


frr_port_out_0 = p4.Egress.frr_port_out_0
frr_port_out_0.dump(table=True,from_hw=1)
frr_port_out_0.clear()
frr_port_out_0.add_with_set_add_port_out_1_to_0(1,0)


hash_path_selector_action_profile = p4.Ingress.hash_path_selector_action_profile #ACTION_PROFILE

hash_path_selector_action_profile.dump(table=True,from_hw=1)
hash_path_selector_action_profile.clear()
hash_path_selector_action_profile.add_with_set_ecmp_path_selector(0,0)#($ACTION_MEMBER_ID,idx)
hash_path_selector_action_profile.add_with_set_ecmp_path_selector(1,1)
hash_path_selector_action_profile.add_with_set_ecmp_path_selector(2,2)
hash_path_selector_action_profile.add_with_set_ecmp_path_selector(3,3)
hash_path_selector_action_profile.add_with_set_ecmp_path_selector(4,4)
hash_path_selector_action_profile.add_with_set_ecmp_path_selector(5,5)


hash_path_selector_action_profile.add_with_set_ecmp_path_selector(11,11)#($ACTION_MEMBER_ID,idx)
hash_path_selector_action_profile.add_with_set_ecmp_path_selector(12,12)
hash_path_selector_action_profile.add_with_set_ecmp_path_selector(13,13)
hash_path_selector_action_profile.add_with_set_ecmp_path_selector(14,14)
hash_path_selector_action_profile.add_with_set_ecmp_path_selector(15,15)
hash_path_selector_action_profile.add_with_set_ecmp_path_selector(16,16)

hash_path_selector_action_profile.dump(table=True,from_hw=1)


hash_path_action_selector = p4.Ingress.hash_path_action_selector # ACTION SELECTOR
hash_path_action_selector.dump(table=True,from_hw=1)
hash_path_action_selector.clear()

hash_path_action_selector.add(0,[0,1,2,3,4,5],[True,True,True,True,True,True],12)

hash_path_action_selector.add(1,[11,12,13,14,15,16],[True,True,True,True,True,True],12)
hash_path_action_selector.dump(table=True,from_hw=1)


ecmp_hash_selector = p4.Ingress.ecmp_hash_selector #MATCH_INDIRECT_SELECTOR

ecmp_hash_selector.clear()
ecmp_hash_selector.add(20, SELECTOR_GROUP_ID=0)
ecmp_hash_selector.add(10, SELECTOR_GROUP_ID=1)

ecmp_hash_selector.dump(table=True,from_hw=1)

