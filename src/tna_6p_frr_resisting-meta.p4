
// #### M E T A D A T A ####

typedef bit<16> dst_id_t;
typedef bit<32> idx_reg_t;


struct metadata_t {
    bit<1> link_state;
    bit<1> link_local;
    bit<1> link_network;
    bit<9> ecmp_path_selector;
//    bit<48> dst_id;
    bit<16> dst_id;
    bit<9> egress_spec_port;
    bit<1> port_status_up_down;
    bit<32> dst_id_ecmp_path_selector;
    bit<32> ecmp_link_count;
    bit<8> ecmp_path_selector_add_1;
    bit<1> copy_next_port_to_act_idx;
    bit<1> loop_on_off;
    bit<1> check_rerouting_up_down;
    bit<8> loop_resubmit;
    bit<8> idx_resubmit;
    bit<1> recirculation;
    bit<16> loop_port;
    bit<9> copy_port_out_3_to_2;
    bit<9> copy_port_out_2_to_1;
    bit<9> copy_port_out_1_to_0;


    //resubmit_h resubmit;

}

struct egress_headers_t {
    ethernet_h ethernet;
    ipv4_h ipv4;

}
