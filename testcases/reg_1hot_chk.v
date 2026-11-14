task run_test();
    reg[31:0] rdata;
    begin
        $display("=================================================");
        $display("===== TEST CASE: ONE-HOT ADDRESS DECODER CHECK =====");
        $display("=================================================");

// 1. PHASE WRITE
test_bench.apb_wr(ADDR_TCR,   32'h1111_1110);
test_bench.apb_wr(ADDR_TDR0,  32'h2222_2222);
test_bench.apb_wr(ADDR_TDR1,  32'h3333_3333);
test_bench.apb_wr(ADDR_TCMP0, 32'h4444_4444);
test_bench.apb_wr(ADDR_TCMP1, 32'h5555_5555);
test_bench.apb_wr(ADDR_TIER,  32'h8888_8888);
test_bench.apb_wr(ADDR_TISR,  32'h9999_9999);
test_bench.apb_wr(ADDR_THCSR, 32'hA5A5_A5A5);

// 2. PHASE READ AND COMPARE
test_bench.apb_rd(ADDR_TCR, rdata);
test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0100, 32'hFFFF_FFFF);

test_bench.apb_rd(ADDR_TDR0, rdata);
test_bench.cmp_data(ADDR_TDR0, rdata, 32'h2222_2222, 32'hFFFF_FFFF);
test_bench.apb_rd(ADDR_TDR1, rdata);
test_bench.cmp_data(ADDR_TDR1, rdata, 32'h3333_3333, 32'hFFFF_FFFF);
test_bench.apb_rd(ADDR_TCMP0, rdata);
test_bench.cmp_data(ADDR_TCMP0, rdata, 32'h4444_4444, 32'hFFFF_FFFF);
test_bench.apb_rd(ADDR_TCMP1, rdata);
test_bench.cmp_data(ADDR_TCMP1, rdata, 32'h5555_5555, 32'hFFFF_FFFF);

test_bench.apb_rd(ADDR_TIER, rdata);
test_bench.cmp_data(ADDR_TIER, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_rd(ADDR_TISR, rdata);
test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_rd(ADDR_THCSR, rdata);
test_bench.cmp_data(ADDR_THCSR, rdata, 32'h0000_0001, 32'hFFFF_FFFF);

    end
endtask
