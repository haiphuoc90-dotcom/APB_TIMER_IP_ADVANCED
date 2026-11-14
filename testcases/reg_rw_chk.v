task run_test();
    reg[31:0] rdata;
    begin
        $display("=================================================");
        $display("====   TEST CASE: REGISTER R/W ACCESS CHECK   ====");
        $display("=================================================");

// 1. TCR
$display("--- TCR R/W ACCESS ---");

test_bench.apb_wr(ADDR_TCR, 32'h0000_0000);
test_bench.apb_rd(ADDR_TCR, rdata);
test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.tsk_set_pslverr_exp(1);
test_bench.apb_wr(ADDR_TCR, 32'hFFFF_FFFF);
test_bench.tsk_set_pslverr_exp(0);
test_bench.apb_rd(ADDR_TCR, rdata);
test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.tsk_set_pslverr_exp(1);
test_bench.apb_wr(ADDR_TCR, 32'hAAAA_AAAA);
test_bench.tsk_set_pslverr_exp(0);
test_bench.apb_rd(ADDR_TCR, rdata);
test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCR, 32'h5555_5555);
test_bench.apb_rd(ADDR_TCR, rdata);
test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0501, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCR, 32'h0000_0500);
test_bench.apb_wr(ADDR_TCR, 32'h0000_0100);

// 2. TDR0
$display("--- TDR0 R/W ACCESS ---");

test_bench.apb_wr(ADDR_TDR0, 32'h0000_0000);
test_bench.apb_rd(ADDR_TDR0, rdata);
test_bench.cmp_data(ADDR_TDR0, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TDR0, 32'hFFFF_FFFF);
test_bench.apb_rd(ADDR_TDR0, rdata);
test_bench.cmp_data(ADDR_TDR0, rdata, 32'hFFFF_FFFF, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TDR0, 32'hAAAA_AAAA);
test_bench.apb_rd(ADDR_TDR0, rdata);
test_bench.cmp_data(ADDR_TDR0, rdata, 32'hAAAA_AAAA, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TDR0, 32'h5555_5555);
test_bench.apb_rd(ADDR_TDR0, rdata);
test_bench.cmp_data(ADDR_TDR0, rdata, 32'h5555_5555, 32'hFFFF_FFFF);

// 3. TDR1
$display("--- TDR1 R/W ACCESS ---");

test_bench.apb_wr(ADDR_TDR1, 32'h0000_0000);
test_bench.apb_rd(ADDR_TDR1, rdata);
test_bench.cmp_data(ADDR_TDR1, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TDR1, 32'hFFFF_FFFF);
test_bench.apb_rd(ADDR_TDR1, rdata);
test_bench.cmp_data(ADDR_TDR1, rdata, 32'hFFFF_FFFF, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TDR1, 32'hAAAA_AAAA);
test_bench.apb_rd(ADDR_TDR1, rdata);
test_bench.cmp_data(ADDR_TDR1, rdata, 32'hAAAA_AAAA, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TDR1, 32'h5555_5555);
test_bench.apb_rd(ADDR_TDR1, rdata);
test_bench.cmp_data(ADDR_TDR1, rdata, 32'h5555_5555, 32'hFFFF_FFFF);

// 4. TCMP0
$display("--- TCMP0 R/W ACCESS ---");

test_bench.apb_wr(ADDR_TCMP0, 32'h0000_0000);
test_bench.apb_rd(ADDR_TCMP0, rdata);
test_bench.cmp_data(ADDR_TCMP0, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCMP0, 32'hFFFF_FFFF);
test_bench.apb_rd(ADDR_TCMP0, rdata);
test_bench.cmp_data(ADDR_TCMP0, rdata, 32'hFFFF_FFFF, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCMP0, 32'hAAAA_AAAA);
test_bench.apb_rd(ADDR_TCMP0, rdata);
test_bench.cmp_data(ADDR_TCMP0, rdata, 32'hAAAA_AAAA, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCMP0, 32'h5555_5555);
test_bench.apb_rd(ADDR_TCMP0, rdata);
test_bench.cmp_data(ADDR_TCMP0, rdata, 32'h5555_5555, 32'hFFFF_FFFF);

// 5. TCMP1
$display("--- TCMP1 R/W ACCESS ---");

test_bench.apb_wr(ADDR_TCMP1, 32'h0000_0000);
test_bench.apb_rd(ADDR_TCMP1, rdata);
test_bench.cmp_data(ADDR_TCMP1, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCMP1, 32'hFFFF_FFFF);
test_bench.apb_rd(ADDR_TCMP1, rdata);
test_bench.cmp_data(ADDR_TCMP1, rdata, 32'hFFFF_FFFF, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCMP1, 32'hAAAA_AAAA);
test_bench.apb_rd(ADDR_TCMP1, rdata);
test_bench.cmp_data(ADDR_TCMP1, rdata, 32'hAAAA_AAAA, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCMP1, 32'h5555_5555);
test_bench.apb_rd(ADDR_TCMP1, rdata);
test_bench.cmp_data(ADDR_TCMP1, rdata, 32'h5555_5555, 32'hFFFF_FFFF);

// 6. TIER
$display("--- TIER R/W ACCESS ---");

test_bench.apb_wr(ADDR_TIER, 32'h0000_0000);
test_bench.apb_rd(ADDR_TIER, rdata);
test_bench.cmp_data(ADDR_TIER, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TIER, 32'hFFFF_FFFF);
test_bench.apb_rd(ADDR_TIER, rdata);
test_bench.cmp_data(ADDR_TIER, rdata, 32'h0000_0001, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TIER, 32'hAAAA_AAAA);
test_bench.apb_rd(ADDR_TIER, rdata);
test_bench.cmp_data(ADDR_TIER, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TIER, 32'h5555_5555);
test_bench.apb_rd(ADDR_TIER, rdata);
test_bench.cmp_data(ADDR_TIER, rdata, 32'h0000_0001, 32'hFFFF_FFFF);

reset_dut(); // CLEAN UP: reset toan bo thiet bi de ngat ket noi TDR0 va TCMP0

// 7. TISR
$display("--- TISR R/W ACCESS ---");

test_bench.apb_wr(ADDR_TISR, 32'h0000_0000);
test_bench.apb_rd(ADDR_TISR, rdata);
test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TISR, 32'hFFFF_FFFF);
test_bench.apb_rd(ADDR_TISR, rdata);
test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TISR, 32'hAAAA_AAAA);
test_bench.apb_rd(ADDR_TISR, rdata);
test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TISR, 32'h5555_5555);
test_bench.apb_rd(ADDR_TISR, rdata);
test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

// 8. THCSR
$display("--- THCSR R/W ACCESS ---");

test_bench.apb_wr(ADDR_THCSR, 32'h0000_0000);
test_bench.apb_rd(ADDR_THCSR, rdata);
test_bench.cmp_data(ADDR_THCSR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_THCSR, 32'hFFFF_FFFF);
test_bench.apb_rd(ADDR_THCSR, rdata);
test_bench.cmp_data(ADDR_THCSR, rdata, 32'h0000_0001, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_THCSR, 32'hAAAA_AAAA);
test_bench.apb_rd(ADDR_THCSR, rdata);
test_bench.cmp_data(ADDR_THCSR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_THCSR, 32'h5555_5555);
test_bench.apb_rd(ADDR_THCSR, rdata);
test_bench.cmp_data(ADDR_THCSR, rdata, 32'h0000_0001, 32'hFFFF_FFFF);

    end
endtask
