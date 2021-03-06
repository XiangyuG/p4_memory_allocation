#include <core.p4>
#include <v1model.p4>


register<bit<32>>(1) count;
register<bit<32>>(1) maxseq;

header H {
    /* empty */
}

struct metadata {
    bit<32> tcpseq;
}

struct headers {
    H   H_header;
}

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start {
        transition accept;
    }

}

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    apply {
        @atomic{
            bit<32> count_tmp;
            bit<32> maxseq_tmp;
            count.read(count_tmp, 0);
            maxseq.read(maxseq_tmp, 0);

            if (meta.tcpseq < maxseq_tmp) {
                count_tmp = count_tmp + 1;
            } else {
                maxseq_tmp = meta.tcpseq;
            }

            count.write(0, count_tmp);
            maxseq.write(0, maxseq_tmp);
        }
    }
}

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply {  }
}

control MyComputeChecksum(inout headers  hdr, inout metadata meta) {
     apply {  }
}

control MyDeparser(packet_out packet, in headers hdr) {
    apply { }
}

V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;
