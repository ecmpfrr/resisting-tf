
#ifndef _INGRESS_P4_
#define _INGRESS_P4_

//const bit<16> TYPE_RESUBMIT = 0x9;

/*************************************************************************
   *********************** P A R S E R  *******************************
*************************************************************************/
// Ingress parser

parser TofinoIngressParser(
        //packet_in pkt, out header_t hdr,
        packet_in pkt,
        inout metadata_t ig_md,
       // inout ingress_intrinsic_metadata_t ig_intr_md) {
        out ingress_intrinsic_metadata_t ig_intr_md) {

    state start {
        pkt.extract(ig_intr_md);
        transition select(ig_intr_md.resubmit_flag) {
            1 : parse_resubmit;
            0 : parse_port_metadata;
        }
    }

    state parse_resubmit {
        // Parse resubmitted packet here.
        pkt.advance(64);
         transition accept;
    }

    state parse_port_metadata {
        pkt.advance(64);  //tofino 1 port metadata size
        transition accept;
    }
}


parser IngressParser(
      packet_in pkt,
      out header_t hdr,
      out metadata_t ig_md,
      out ingress_intrinsic_metadata_t ig_intr_md)

{



      TofinoIngressParser() tofino_parser;

//Barefoot Tofino BFN-T10-032 32 x 100GE QSFP28 has 2x 100G recirculation ports. 
//bfrt.tf1.dev.device_configuration> dump
//recirc_port_list: [68, 69, 70, 71, 196, 197, 198, 199]

      state start {
          tofino_parser.apply(pkt, ig_md, ig_intr_md);
          transition select(ig_intr_md.ingress_port) {
            40:         parse_frr;
            196:        parse_frr;
            68:         parse_frr;
            default:    parse_ethernet;
          }
      }




      state parse_ethernet {
          pkt.extract(hdr.ethernet);
          ig_md.dst_id = (bit<16>)hdr.ethernet.dst_addr;
          transition select (hdr.ethernet.ether_type) {
               ETHERTYPE_IPV4 : parse_ipv4;
                     TYPE_FRR: parse_frr;
//                     0x86dd: parser_ipv6;
              default : reject;
           }
      }
      state parse_frr {
          pkt.extract(hdr.frr);
          hdr.ethernet.ether_type = hdr.frr.ether_type_eth;
          transition select (hdr.frr.update_bit) {
                0: parse_ipv4;
                default : accept;
          }
       }
/*
      state parser_frr_ipv4_inner {
          pkt.extract(hdr.frr_ipv4_inner);
        }
*/

      state parse_ipv4 {
          pkt.extract(hdr.ipv4);
          //hdr.ethernet.ether_type = 0x800;
          transition select (hdr.ipv4.protocol) {
              IP_PROTOCOLS_TCP : parse_tcp;

              default : accept;
         }
     }

     state parse_frr_ipv4 {
          pkt.extract(hdr.ipv4);
          hdr.ethernet.ether_type = 0x255;
          transition select (hdr.ipv4.protocol) {
              IP_PROTOCOLS_TCP : parse_tcp;

              default : accept;
         }
     }

     state parser_ipv6 {
         transition reject;
      }

     state parse_tcp {
          pkt.extract(hdr.tcp);
          transition accept;
       //   default : accept;
    }



}


  control Ingress(
      inout header_t hdr,
      inout metadata_t ig_md,
      in ingress_intrinsic_metadata_t ig_intr_md,
      in ingress_intrinsic_metadata_from_parser_t ig_intr_prsr_md,
      inout ingress_intrinsic_metadata_for_deparser_t ig_intr_dprsr_md,
      inout ingress_intrinsic_metadata_for_tm_t ig_intr_tm_md) {


     action drop_act() {
        ig_intr_dprsr_md.drop_ctl = 0x1; // Drop packet.
      }

       action no_act() {
      }

/*
       table filter_pkt {
        key = {
            hdr.ethernet.ether_type: exact;
        }
        actions = {
            no_act;
            drop_act;
        }
        const default_action = drop_act;
        size = 64;

     }
*/



     action set_nhop_direct(PortId_t port) {
      hdr.ethernet.setValid();
      hdr.ethernet.ether_type = 0x0800;
      hdr.ethernet.src_addr = ig_intr_md.ingress_mac_tstamp;
      hdr.ipv4.setValid();
      ig_md.dst_id = 0;
      ig_intr_tm_md.ucast_egress_port = port;
      ig_intr_tm_md.bypass_egress = 1w1;  
   }


     action set_nhop_local(mac_addr_t dstAddr, PortId_t port) {
        hdr.ethernet.setValid();
        hdr.ethernet.ether_type = 0x0800;
        hdr.ethernet.dst_addr = dstAddr;
        hdr.ipv4.setValid();
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
        ig_intr_tm_md.ucast_egress_port = port;
        ig_md.dst_id = 0;
        ig_intr_tm_md.bypass_egress = 1w1;
   }


     action set_nhop_network(dst_id_t dst_id) {
        ig_md.dst_id = dst_id;
     }


     table ipv4_lpm {
        key = {
            hdr.ethernet.ether_type: exact;
            ig_intr_md.ingress_port: exact;
            hdr.ipv4.dst_addr: lpm;
        }
        actions = {
            set_nhop_network;
            set_nhop_local;
            set_nhop_direct;
            drop_act;
        }
        //const default_action = drop_act;
        size = 64;

     }


    action set_ecmp_path_selector(bit<9> idx){
       ig_md.ecmp_path_selector = idx;
    }
     action set_ecmp_path_selector_with_port_out(bit<9> port){
       ig_intr_tm_md.ucast_egress_port = port;
       ig_intr_tm_md.bypass_egress = 1w1;
    }



   Hash<bit<16>>(HashAlgorithm_t.CRC32) ecmp_hash_path;
  // # Hash<bit<16>>(HashAlgorithm_t.CRC16) ecmp_hash_path;
    ActionProfile(2048) hash_path_selector_action_profile;
    ActionSelector(hash_path_selector_action_profile, // action profile
                   ecmp_hash_path, // hash extern
                   SelectorMode_t.FAIR, // Selector algorithm
                   12, // max group size
                   256 // max number of groups
                   ) hash_path_action_selector;

     table ecmp_hash_selector {
        key = {

            ig_md.dst_id: exact;
            hdr.ipv4.src_addr: selector;
            hdr.ipv4.dst_addr: selector;
            hdr.ipv4.protocol: selector;
            hdr.tcp.src_port: selector;
            hdr.tcp.dst_port: selector;

        }
        actions = {
            drop_act;
            set_ecmp_path_selector;
            set_ecmp_path_selector_with_port_out;

        }
      //  const default_action = drop_act;
        size = 512;
        implementation = hash_path_action_selector;

    }


Register<bit<16>,bit<4>>(1) rg_default_path;
RegisterAction<bit<16>, bit<1>, bit<16>>(rg_default_path) rg_default_path_wr ={
    void apply(inout bit<16>  register_data, out bit<16> result_port){

           if (hdr.frr.loop == 1){
               register_data = (bit<16>)hdr.frr.idx_0;
            }
               result_port = register_data;
  }
};

  action set_add_default_path() {
         rg_default_path_wr.execute((bit<1>)hdr.frr.idx_port_down);
      }

    table update_default_path {
        key = {
            hdr.frr.idx_port_down : exact;
            hdr.frr.loop : exact;

        }

        actions = {
            set_add_default_path;
        }

        size = 64;
    }



Register<bit<16>,bit<16>>(1)rg_count;
RegisterAction<bit<16>, bit<1>, bit<16>>(rg_count)rg_count_wr ={
    void apply(inout bit<16> register_data, out bit<16> result_port){


         register_data =  (bit<16>)hdr.frr.idx_port_down + 1;
         result_port =  register_data;

  }
};


 action set_count_idx_port_down(bit<9> idx) {
          hdr.frr.setValid();
          hdr.frr.idx_port_down = (bit<9>)rg_count_wr.execute(0);
      }


    table count_idx_port_down {
        key = {
            hdr.frr.loop : exact;
        }

        actions = {
            set_count_idx_port_down();
        }

        size = 64;
    }



Register<bit<16>,bit<4>>(1) rg_port_out_5;
RegisterAction<bit<16>, bit<1>, bit<16>>(rg_port_out_5) rg_port_out_5_wr ={
    void apply(inout bit<16>  register_data, out bit<16> result_port){

      if (hdr.frr.loop == 1){

           register_data = 255;

      }else{

           result_port = register_data;
      }

  }
};


Register<bit<16>,bit<4>>(1) rg_port_out_4;
RegisterAction<bit<16>, bit<1>, bit<16>>(rg_port_out_4) rg_port_out_4_wr ={
    void apply(inout bit<16>  register_data, out bit<16> result_port){

      if (hdr.frr.loop == 1){

           register_data = (bit<16>)hdr.frr.idx_5_or_cp_5_4;

      }else{

           result_port = register_data;
     }

  }
};


RegisterAction<bit<16>, bit<1>, bit<16>>(rg_port_out_4) rg_port_out_4_r ={
   void apply(inout bit<16>  register_data, out bit<16> result_port){

            register_data = (bit<16>)hdr.frr.idx_5_or_cp_5_4;

     }


};

Register<bit<16>,bit<4>>(1) rg_port_out_3;
RegisterAction<bit<16>, bit<1>, bit<16>>(rg_port_out_3) rg_port_out_3_wr ={
    void apply(inout bit<16>  register_data, out bit<16> result_port){

      if (hdr.frr.loop == 1){

           register_data = (bit<16>)hdr.frr.idx_4_or_cp_4_3;

      }else{

           result_port = register_data;
      }

  }
};



Register<bit<16>,bit<4>>(1) rg_port_out_2;
RegisterAction<bit<16>, bit<1>, bit<16>>(rg_port_out_2) rg_port_out_2_wr ={
    void apply(inout bit<16>  register_data, out bit<16> result_port){
      if (hdr.frr.loop == 1){

           register_data = (bit<16>)hdr.frr.idx_3_or_cp_3_2;

      }else{

           result_port = register_data;
      }

  }
};


Register<bit<16>,bit<4>>(1) rg_port_out_1;
RegisterAction<bit<16>, bit<1>, bit<16>>(rg_port_out_1) rg_port_out_1_wr ={
    void apply(inout bit<16>  register_data, out bit<16> result_port){

      if (hdr.frr.loop == 1){

           register_data =  (bit<16>)hdr.frr.idx_2_or_cp_2_1;

      }else{

           result_port = register_data;
     }

  }
};


Register<bit<16>,bit<4>>(1) rg_port_out;
RegisterAction<bit<16>, bit<1>, bit<16>>(rg_port_out) rg_port_out_wr ={
    void apply(inout bit<16>  register_data, out bit<16> result_port){

      if (hdr.frr.loop == 1){

           register_data = (bit<16>)hdr.frr.idx_0;

      }else{

           result_port = register_data;
     }

  }
};


action set_add_port_out_5() {
         rg_port_out_5_wr.execute(0);
      }

    table update_port_out_5 {
        key = {
            hdr.frr.idx_port_down : exact;
            hdr.frr.loop : exact;
        }

        actions = {
            set_add_port_out_5;
        }

        size = 64;
     }


 action set_add_port_out_4() {
         rg_port_out_4_wr.execute(0);
      }

    table update_port_out_4 {
        key = {
            hdr.frr.idx_port_down : exact;
            hdr.frr.loop : exact;
        }

        actions = {
            set_add_port_out_4;
        }

        size = 64;
    }


 action set_add_port_out_3() {
         rg_port_out_3_wr.execute(0);
      }

    table update_port_out_3 {
        key = {
            hdr.frr.idx_port_down : exact;
            hdr.frr.loop : exact;
        }

        actions = {
            set_add_port_out_3;
        }

        size = 64;
    }


 action set_add_port_out_2() {
         rg_port_out_2_wr.execute(0);
      }

    table update_port_out_2 {
        key = {
            hdr.frr.idx_port_down : exact;
            hdr.frr.loop : exact;
        }

        actions = {
            set_add_port_out_2;
        }

        size = 64;
    }


 action set_add_port_out_1() {
         rg_port_out_1_wr.execute(0);
      }

    table update_port_out_1 {
        key = {
            hdr.frr.idx_port_down : exact;
            hdr.frr.loop : exact;
        }

        actions = {
            set_add_port_out_1;
        }

        size = 64;
    }


 action set_add_port_out() {
        rg_port_out_wr.execute(0);
      }

    table update_port_out {
        key = {
            hdr.frr.idx_port_down : exact;
            hdr.frr.loop : exact;
        }

        actions = {
            set_add_port_out;
        }

        size = 64;
    }

   action set_fowarding_port_out_without_reg(bit<9> port_out) {
        // hdr.ethernet.ether_type = 0x255;
         hdr.ethernet.dst_addr = (bit<48>)ig_md.dst_id;
         hdr.ethernet.ether_type = 0x800;
         ig_intr_tm_md.ucast_egress_port = port_out;
      }

 action set_fowarding_port_out_5() {
         hdr.ethernet.dst_addr = (bit<48>)ig_md.dst_id;
         hdr.ethernet.ether_type = 0x800;
         ig_intr_tm_md.ucast_egress_port =  (bit<9>)rg_port_out_5_wr.execute(0);
      }

   table fowarding_tag_5 {
       actions = {
             set_fowarding_port_out_5();
             set_fowarding_port_out_without_reg();
        }
         key = {
             ig_md.dst_id : exact;
             ig_md.ecmp_path_selector : exact;
             hdr.frr.loop : exact;
          }
         size = 64;
      //   default_action = drop_act;
    }





 action set_fowarding_port_out_4() {
         // hdr.ethernet.ether_type = 0x255;
         hdr.ethernet.dst_addr = (bit<48>)ig_md.dst_id;
         hdr.ethernet.ether_type = 0x800;
         ig_intr_tm_md.ucast_egress_port =  (bit<9>)rg_port_out_4_wr.execute(0);
      }

   table fowarding_tag_4 {
       actions = {
             set_fowarding_port_out_4();
             set_fowarding_port_out_without_reg();
        }
         key = {
             ig_md.dst_id : exact;
             ig_md.ecmp_path_selector : exact;
             hdr.frr.loop : exact;
          }
         size = 64;
      //   default_action = drop_act;
    }




 action set_fowarding_port_out_3() {
         // hdr.ethernet.ether_type = 0x255;
         hdr.ethernet.dst_addr = (bit<48>)ig_md.dst_id;
         hdr.ethernet.ether_type = 0x800;
         ig_intr_tm_md.ucast_egress_port =  (bit<9>)rg_port_out_3_wr.execute(0);
      }

   table fowarding_tag_3 {
       actions = {
             set_fowarding_port_out_3();
             set_fowarding_port_out_without_reg();
        }
         key = {
             ig_md.dst_id : exact;
             ig_md.ecmp_path_selector : exact;
             hdr.frr.loop : exact;
          }
         size = 64;
      //   default_action = drop_act;
    }




  action set_fowarding_port_out_2() {
         // hdr.ethernet.ether_type = 0x255;
         hdr.ethernet.dst_addr = (bit<48>)ig_md.dst_id;
         hdr.ethernet.ether_type = 0x800;
         ig_intr_tm_md.ucast_egress_port =  (bit<9>)rg_port_out_2_wr.execute(0);
      }

   table fowarding_tag_2 {
       actions = {
             set_fowarding_port_out_2();
             set_fowarding_port_out_without_reg();
        }
         key = {
             ig_md.dst_id : exact;
             ig_md.ecmp_path_selector : exact;
             hdr.frr.loop : exact;
          }
         size = 64;
      //   default_action = drop_act;
    }


  action set_fowarding_port_out_1() {
         // hdr.ethernet.ether_type = 0x255;
         hdr.ethernet.dst_addr = (bit<48>)ig_md.dst_id;
         hdr.ethernet.ether_type = 0x800;
         ig_intr_tm_md.ucast_egress_port =  (bit<9>)rg_port_out_1_wr.execute(0);
  }

   table fowarding_tag_1 {
       actions = {
             set_fowarding_port_out_1();
             set_fowarding_port_out_without_reg();
        }
         key = {
             ig_md.dst_id : exact;
             ig_md.ecmp_path_selector : exact;
             hdr.frr.loop : exact;
          }
         size = 64;
      //   default_action = drop_act;
    }



  action set_fowarding_port_out() {
         // hdr.ethernet.ether_type = 0x255;
         hdr.ethernet.dst_addr = (bit<48>)ig_md.dst_id;
         hdr.ethernet.ether_type = 0x800;
         ig_intr_tm_md.ucast_egress_port =  (bit<9>)rg_port_out_wr.execute(0);
      }


    table fowarding_tag {
       actions = {
             set_fowarding_port_out();
             set_fowarding_port_out_without_reg();
        }
         key = {
             ig_md.dst_id : exact;
             ig_md.ecmp_path_selector : exact;
             hdr.frr.loop : exact;
          }
         size = 64;
      //   default_action = drop_act;
    }


 action set_default_path(){
         ig_intr_tm_md.ucast_egress_port =  (bit<9>)rg_default_path_wr.execute(0);
         ig_md.ecmp_path_selector = 0;
    }

   table default_path {
        key = {
            ig_intr_tm_md.ucast_egress_port : exact;
            hdr.frr.loop : exact;
        }

        actions = {
            set_default_path;
            drop_act;
        }

        size = 64;
       // const default_action = drop_act;
    }


 action set_port_status_down(bit<16> bit_down){
         ig_md.port_status_up_down = (bit<1>)bit_down;
    }

    table port_status {
        key = {
            ig_intr_tm_md.ucast_egress_port : exact;
            hdr.frr.loop : exact;
            hdr.ethernet.ether_type: exact;
    }

        actions = {
            set_port_status_down;
            drop_act;
        }

        size = 64;
        const default_action = drop_act;
    }



DirectRegister<bit<16>>(16w1) dr_rg_first_failure;


    // A simple dual-width 32-bit register action that will increment the two
    // 32-bit sections independently and return the value of one half before the
    // modification.

DirectRegisterAction<bit<16>,bit<16>>(dr_rg_first_failure) dr_rg_first_failure_count_wr = {
        void apply(inout bit<16> register_data, out bit<16> result_data){

                  if (hdr.frr.loop  == 1){

                     register_data = 0;

                  } else {

                   register_data = register_data + 1;
                  }

                  result_data = register_data;
        }
};


Register<bit<16>,bit<4>>(1) rg_first_failure;
RegisterAction<bit<16>, bit<1>, bit<16>>(rg_first_failure)  rg_first_failure_count_wr ={
    void apply(inout bit<16>  register_data, out bit<16> result_port){

      if (hdr.frr.loop == 0){
         register_data =  register_data + 1;
         result_port = register_data;
      }

      if (hdr.frr.loop == 1){

          register_data = 0;
      }
  }
};


 action set_frr_recirculation_first_failure_port_pipe_0(){
         hdr.ethernet.setInvalid();
         hdr.frr.setValid();
// adiciona a posicao do index/posicao que armazena a porta down de saida
         hdr.frr.idx_port_down =  ig_md.ecmp_path_selector;
         hdr.frr.update_bit = 1;
         hdr.frr.ether_type_eth = 0x255;
         hdr.frr.first_failure = (bit<24>)dr_rg_first_failure_count_wr.execute();
// 68 Pipe 0 Recirc
         ig_intr_tm_md.ucast_egress_port = 68;
  }


 action set_frr_recirculation_first_failure_port_pipe_1(){
         hdr.ethernet.setInvalid();
         hdr.frr.setValid();
// adiciona a posicao do index/posicao que armazena a porta down de saida
         hdr.frr.idx_port_down =  ig_md.ecmp_path_selector;
         hdr.frr.update_bit = 1;
         hdr.frr.ether_type_eth = 0x255;
         hdr.frr.first_failure = (bit<24>)dr_rg_first_failure_count_wr.execute();
// 196 Pipe 1 Recirc
         ig_intr_tm_md.ucast_egress_port = 196;
  }


    table frr_recirculation {
        key = {
            ig_md.port_status_up_down : exact;
            ig_intr_md.ingress_port: range;
    }

        actions = {
            set_frr_recirculation_first_failure_port_pipe_1;
            set_frr_recirculation_first_failure_port_pipe_0;
           // drop_act;
        }

        size = 6;
       // const default_action = drop_act;

    }


   action set_frr_no_recovery(){
         hdr.frr.setInvalid();
         hdr.ethernet.setValid();
         hdr.ethernet.ether_type = 0x800;
         ig_intr_tm_md.bypass_egress = 1w1;
   }

    table frr_no_recovery {
        key = {
            ig_md.port_status_up_down : exact;
            hdr.frr.loop : exact;
            hdr.ethernet.ether_type: exact;
    }

        actions = {
            set_frr_no_recovery;
       }

        size = 64;

    }




  apply {
       // filter_pkt.apply();
        ipv4_lpm.apply();
        ecmp_hash_selector.apply();

// Cada falha de porta causa 2 x recirculacoes, uma para atualizar os registros update_XXX, a outra para
// encaminhar o pacote apos reordenacao das portas.
        update_port_out_5.apply();
        update_port_out_4.apply();
        update_port_out_3.apply();
        update_port_out_2.apply();
        update_port_out_1.apply();
        update_port_out.apply();
        update_default_path.apply();

// Cada forwading_tag_X representa um link que armazena uma porta de saida.
// o campo ig_md.ecmp_path_selector resultante do hash determina qual tabela forwarding
// e registro sera usado para escolha da porta de saida
        fowarding_tag_5.apply();
        fowarding_tag_4.apply();
        fowarding_tag_3.apply();
        fowarding_tag_2.apply();
        fowarding_tag_1.apply();
        fowarding_tag.apply();
        default_path.apply();

        port_status.apply();

        frr_recirculation.apply();

        frr_no_recovery.apply();



// Se a porta de saida esta Down (status_up_down = 1 e loop = 0) pela primeia vez ou se existe uma proxima porta Down
// simultanea apos recuperacao da primeira falha (status_up_down = 1 e loop = 1). Entao o programa deve acionar
// recuperacao FRR

// Se a porta de saida esta Up (= 0) enquanto o pacote recircula (loop = 1), significa que o programa
//esta em modo de escrita, ou seja, escrevendo nos registros e, consequentemente, a recirculacao
// deve ser mantida, entao o pacote sera enviado para o link de loop com o header FRR

// Se ja ocorreu a recuperacao e atualizacao dos registros (loop = 1) e a porta de saida esta UP, entao
// significa que os registros foram atualizados. Portanto, o header FRR deve ser removido, o pacote que foi recirculado
// deve ser recirculado pela ultimas vez para iniciar o processo de encaminhanto para nova porta de saida.


  }


}



/*************************************************************************
***********************  D E P A R S E R  *******************************
************************************************************************
*/
// Ingress Deparser

   control IngressDeparser(
        packet_out pkt,
        inout header_t hdr,
        in metadata_t ig_md,
        in ingress_intrinsic_metadata_for_deparser_t ig_intr_dprsr_md) {

      Checksum() ipv4_checksum;


    apply {

           hdr.ipv4.hdr_checksum = ipv4_checksum.update({
            hdr.ipv4.version,
            hdr.ipv4.ihl,
            hdr.ipv4.diffserv,
            hdr.ipv4.total_len,
            hdr.ipv4.identification,
            hdr.ipv4.flags,
            hdr.ipv4.frag_offset,
            hdr.ipv4.ttl,
            hdr.ipv4.protocol,
            hdr.ipv4.src_addr,
            hdr.ipv4.dst_addr
        });


          pkt.emit(hdr.ethernet);
          pkt.emit(hdr.frr);
          pkt.emit(hdr.ipv4);
          pkt.emit(hdr.tcp);







    }
}


#endif




