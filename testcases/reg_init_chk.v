task run_test();
    reg[31:0] rdata;
    begin
        $display("=================================================");
        $display("====  TEST CASE: REGISTER RESET VALUE CHECK ======");
        $display("=================================================");

// ID1
test_bench.apb_rd(ADDR_TCR, rdata);
test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0100, 32'hFFFF_FFFF);

// ID 4 and 7
test_bench.apb_rd(ADDR_TDR0, rdata);
test_bench.cmp_data(ADDR_TDR0, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_rd(ADDR_TDR1, rdata);
test_bench.cmp_data(ADDR_TDR1, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

// ID 10 and 13
test_bench.apb_rd(ADDR_TCMP0, rdata);
test_bench.cmp_data(ADDR_TCMP0, rdata, 32'hFFFF_FFFF, 32'hFFFF_FFFF);

test_bench.apb_rd(ADDR_TCMP1, rdata);
test_bench.cmp_data(ADDR_TCMP1, rdata, 32'hFFFF_FFFF, 32'hFFFF_FFFF);

// ID 16, 19, 22: TIER, TISR, THCSR
test_bench.apb_rd(ADDR_TIER, rdata);
test_bench.cmp_data(ADDR_TIER, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_rd(ADDR_TISR, rdata);
test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_rd(ADDR_THCSR, rdata);
test_bench.cmp_data(ADDR_THCSR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

    end
endtask
