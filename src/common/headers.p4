// ###### H E A D E R S ######

typedef bit<48> mac_addr_t;
typedef bit<32> ipv4_addr_t;

typedef bit<16> ether_type_t;
const ether_type_t ETHERTYPE_IPV4 = 16w0x0800;
const bit<16> TYPE_RESUBMIT = 16w0x9;
const bit<16> TYPE_FRR = 16w0x255;

typedef bit<8> ip_protocol_t;
//const ip_protocol_t IP_PROTOCOLS_ICMP = 1;
const ip_protocol_t IP_PROTOCOLS_TCP = 6;
//const ip_protocol_t IP_PROTOCOLS_UDP = 17;

//126bits|14bytes header ethernet
header frr_h {
    bit<4> loop;
    bit<9> idx_port_down;
    bit<9> idx_0;
    bit<9> idx_1_or_cp_1_0;
    bit<9> idx_2_or_cp_2_1;
    bit<9> idx_3_or_cp_3_2;
    bit<9> idx_4_or_cp_4_3;
    bit<9> idx_5_or_cp_5_4;
    bit<5> update_bit;
// Ethernet Ether_type 0x255 (FRR), 0x800 (Ipv4)
    bit<16> ether_type_eth;
    bit<24> first_failure;
}

/*
header frr_ipv4_inner_h {
   bit<32> dst_ip;
   bit<32> src_ip;
   bit<8> ip_protocol;
}
*/

header ethernet_h {
    mac_addr_t dst_addr;
    mac_addr_t src_addr;
    bit<16> ether_type;
}

//32bits - Tofino requires byte-aligned headers EX: 32bit


header ipv4_h {
    bit<4> version;
    bit<4> ihl;
    bit<8> diffserv;
    bit<16> total_len;
    bit<16> identification;
    bit<3> flags;
    bit<13> frag_offset;
    bit<8> ttl;
    bit<8> protocol;
    bit<16> hdr_checksum;
    bit<32> src_addr;
    bit<32> dst_addr;
}


header tcp_h {
    bit<16> src_port;
    bit<16> dst_port;
    bit<32> seq_no;
    bit<32> ack_no;
    bit<4> data_offset;
    bit<4> res;
    bit<8> flags;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgent_ptr;
}

header udp_h {
    bit<16> src_port;
    bit<16> dst_port;
    bit<16> hdr_length;
    bit<16> checksum;
}

header icmp_h {
    bit<8> type_;
    bit<8> code;
    bit<16> hdr_checksum;
}


struct header_t {
    frr_h frr;
// future
//    frr_ipv4_inner_h     frr_ipv4_inner;
    ethernet_h ethernet;
    ipv4_h ipv4;
    tcp_h tcp;
    udp_h udp;
    icmp_h icmp;
    // Add more headers here
}

struct empty_header_t {}

struct empty_metadata_t {}
