

/*************************************************************************
  ***********************   P A R S E R  *******************************
************************************************************************
*/
// egress parser


   parser EgressParser(
        packet_in pkt,
        out header_t hdr,
        out metadata_t eg_md,
        out egress_intrinsic_metadata_t eg_intr_md) {



      state start {
           pkt.extract(eg_intr_md);
           transition parser_frr;
       }


      state parser_frr {
           pkt.extract(hdr.frr);
           transition accept;
       }

       state parse_ipv4 {
           pkt.extract(hdr.ipv4);
           transition accept;
       }

        state parser_ipv6 {
           transition reject;
       }



   }



/*************************************************************************
  ***********************   E G R E S S  *******************************
************************************************************************
*/


   control Egress(
       inout header_t hdr,
       inout metadata_t eg_md,
       in egress_intrinsic_metadata_t eg_intr_md,
       in egress_intrinsic_metadata_from_parser_t eg_intr_prsr_md,
       inout egress_intrinsic_metadata_for_deparser_t eg_intr_dprsr_md,
       inout egress_intrinsic_metadata_for_output_port_t eg_intr_oport_md) {


Register<bit<16>,bit<1>>(1) rg_frr_port_out_5;
  RegisterAction<bit<16>, bit<1>, bit<16>>(rg_frr_port_out_5) rg_frr_port_out_5_wr ={
      void apply(inout bit<16>  register_data, out bit<16> result_port){
           result_port = register_data;
           register_data = 255;
    }
};


Register<bit<16>,bit<1>>(1) rg_frr_port_out_4;
 RegisterAction<bit<16>, bit<1> , bit<16>>(rg_frr_port_out_4) rg_frr_port_out_4_wr ={
      void apply(inout bit<16>  register_data, out bit<16> result_port){
            result_port = register_data;
            register_data =  (bit<16>)hdr.frr.idx_5_or_cp_5_4;


    }
};


Register<bit<16>,bit<1>>(1) rg_frr_port_out_3;
  RegisterAction<bit<16>, bit<1>, bit<16>>(rg_frr_port_out_3) rg_frr_port_out_3_wr ={
      void apply(inout bit<16>  register_data, out bit<16> result_port){
           result_port = register_data;
           register_data = (bit<16>)hdr.frr.idx_4_or_cp_4_3;

    }
};

Register<bit<16>,bit<1>>(1) rg_frr_port_out_2;
  RegisterAction<bit<16>, bit<1>, bit<16>>(rg_frr_port_out_2) rg_frr_port_out_2_wr ={
      void apply(inout bit<16>  register_data, out bit<16> result_port){
          result_port = register_data;
          register_data =  (bit<16>)hdr.frr.idx_3_or_cp_3_2;
  }
};


Register<bit<16>,bit<1>>(1) rg_frr_port_out_1;
  RegisterAction<bit<16>, bit<1>, bit<16>>(rg_frr_port_out_1) rg_frr_port_out_1_wr ={
       void apply(inout bit<16>  register_data, out bit<16> result_port){
          result_port = register_data;
          register_data =  (bit<16>)hdr.frr.idx_2_or_cp_2_1;
 }
};

Register<bit<16>,bit<1>>(1) rg_frr_port_out_0;
  RegisterAction<bit<16>, bit<1>, bit<16>>(rg_frr_port_out_0) rg_frr_port_out_0_wr ={
      void apply(inout bit<16>  register_data, out bit<16> result_port){
        if(hdr.frr.idx_port_down == 0){
           register_data =( bit<16>)hdr.frr.idx_1_or_cp_1_0;
        }
         result_port = register_data;

  }
};


// actions add_copy para falhas nas portas

   action set_add_copy_port_out_5_to_4(){
        hdr.frr.setValid();
        hdr.frr.idx_5_or_cp_5_4 = (bit<9>)rg_frr_port_out_5_wr.execute(0);
       }

   action set_add_copy_port_out_4_to_3(){
        hdr.frr.setValid();
        hdr.frr.idx_4_or_cp_4_3 = (bit<9>)rg_frr_port_out_4_wr.execute(0);
       }

    action set_add_copy_port_out_3_to_2(){
        hdr.frr.setValid();
        hdr.frr.idx_3_or_cp_3_2 = (bit<9>)rg_frr_port_out_3_wr.execute(0);
       }

    action set_add_copy_port_out_2_to_1(){
        hdr.frr.setValid();
        hdr.frr.idx_2_or_cp_2_1 = (bit<9>)rg_frr_port_out_2_wr.execute(0);
       }

    action set_add_copy_port_out_1_to_0(){
        hdr.frr.setValid();
        hdr.frr.idx_1_or_cp_1_0 = (bit<9>)rg_frr_port_out_1_wr.execute(0);
       }

    action set_add_port_out_1_to_0(){
         hdr.frr.idx_0 = (bit<9>)rg_frr_port_out_0_wr.execute(0);
      }

table frr_port_out_5 {
        key = {
            hdr.frr.loop : exact;
            hdr.frr.idx_port_down : exact;

        }

        actions = {
            set_add_copy_port_out_5_to_4();
        }

        size = 64;
    }


table frr_port_out_4 {
        key = {
            hdr.frr.loop : exact;
            hdr.frr.idx_port_down : exact;

        }

        actions = {
            set_add_copy_port_out_4_to_3();
        }

        size = 64;
    }


table frr_port_out_3 {
        key = {
            hdr.frr.loop : exact;
            hdr.frr.idx_port_down : exact;

        }

        actions = {
            set_add_copy_port_out_3_to_2();
        }

        size = 64;
    }

table frr_port_out_2 {
        key = {
            hdr.frr.loop : exact;
            hdr.frr.idx_port_down : exact;

        }

        actions = {
            set_add_copy_port_out_2_to_1();
        }

        size = 64;
    }

table frr_port_out_1 {
        key = {
            hdr.frr.loop : exact;
            hdr.frr.idx_port_down : exact;

        }

        actions = {
            set_add_copy_port_out_1_to_0();
        }

        size = 64;
    }

table frr_port_out_0 {
        key = {
            hdr.frr.loop : exact;
            hdr.frr.idx_port_down : exact;

        }

        actions = {
            set_add_port_out_1_to_0();
        }


        size = 64;
    }



       apply{


// Se o mecanismo de FRR foi acionado pela primeira (frr.first_failure=1) vez para fazer update (frr.update_bit=1), entao
// executa as operacoes de reordenacao nos registros FRR e escreve o conteudo no header FRR
// Se nao desabilita o uptade_bit, desabilita o loop modo e retornar o valor 0x800 para o ether_type do definitivo header ethernet

                 if(eg_intr_md.egress_port == 68 && hdr.frr.update_bit == 1 && hdr.frr.first_failure == 1 || eg_intr_md.egress_port == 196 &&  hdr.frr.update_bit == 1 && hdr.frr.first_failure == 1){


                  hdr.frr.setValid();
                  hdr.frr.loop = 4w1;

                  frr_port_out_5.apply();
                  frr_port_out_4.apply();
                  frr_port_out_3.apply();
                  frr_port_out_2.apply();
                  frr_port_out_1.apply();
                  frr_port_out_0.apply();

                  hdr.frr.setValid();

             }else {

                  hdr.frr.setValid();
                  hdr.frr.loop = 4w0;
                  hdr.frr.ether_type_eth = 0x800;
                  hdr.frr.update_bit = 0;

            }


      }



}


/*************************************************************************
***********************  D E P A R S E R  *******************************
************************************************************************
*/



control EgressDeparser(
    packet_out pkt,
    inout header_t hdr,
    in metadata_t eg_md,
    in egress_intrinsic_metadata_for_deparser_t eg_intr_dprsr_md) {


    apply {

          pkt.emit(hdr.frr);

    }
}



