/*
    LAB RESISTING 
    MAIN FUNCTION()
*/

#include <core.p4>
#include <tna.p4>

#include "common/headers.p4"
#include "tna_6p_frr_resisting-meta.p4"
#include "tna_6p_frr_tf_v1_resisting_ingress_recirculation.p4"
#include "tna_6p_frr_tf_v1_resisting_egress_recirculation.p4"

Pipeline(
    IngressParser(),
    Ingress(),
    IngressDeparser(),
    EgressParser(),
    Egress(),
    EgressDeparser()
) pipe;

Switch(pipe) main;
