task run_test();
    reg[31:0] rdata;
    begin
        $display("=================================================");
        $display("====   TEST CASE: REGISTER BYTE ACCESS (PSTRB) =====");
        $display("=================================================");

$display("--- TCR Byte Access ( Invalid & Valid data) ----");
// ID 3: INVALID DATA
test_bench.apb_wr(ADDR_TCR, 32'h0000_0100);

test_bench.apb_wr_pstrb(ADDR_TCR, 32'hFFFF_FFFF, BYTE0);
test_bench.apb_rd(ADDR_TCR, rdata);
test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0103, 32'hFFFF_FFFF);

test_bench.tsk_set_pslverr_exp(1);
test_bench.apb_wr_pstrb(ADDR_TCR, 32'hFFFF_FFFF, BYTE1);
test_bench.tsk_set_pslverr_exp(0);
test_bench.apb_rd(ADDR_TCR, rdata);
test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0103, 32'hFFFF_FFFF);

test_bench.apb_wr_pstrb(ADDR_TCR, 32'hFFFF_FFFF, BYTE2);
test_bench.apb_rd(ADDR_TCR, rdata);
test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0103, 32'hFFFF_FFFF);

test_bench.apb_wr_pstrb(ADDR_TCR, 32'hFFFF_FFFF, BYTE3);
test_bench.apb_rd(ADDR_TCR, rdata);
test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0103, 32'hFFFF_FFFF);

test_bench.tsk_set_pslverr_exp(1);
test_bench.apb_wr_pstrb(ADDR_TCR, 32'hFFFF_FFFF, HALF_WORD0);
test_bench.tsk_set_pslverr_exp(0);
test_bench.apb_rd(ADDR_TCR, rdata);
test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0103, 32'hFFFF_FFFF);

test_bench.apb_wr_pstrb(ADDR_TCR, 32'hFFFF_FFFF, HALF_WORD1);
test_bench.apb_rd(ADDR_TCR, rdata);
test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0103, 32'hFFFF_FFFF);

test_bench.tsk_set_pslverr_exp(1);
test_bench.apb_wr_pstrb(ADDR_TCR, 32'hFFFF_FFFF, 4'hF);
test_bench.tsk_set_pslverr_exp(0);
test_bench.apb_rd(ADDR_TCR, rdata);
test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0103, 32'hFFFF_FFFF);

test_bench.apb_wr_pstrb(ADDR_TCR, 32'hFFFF_FFFF, 4'h0);
test_bench.apb_rd(ADDR_TCR, rdata);
test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0103, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCR, 32'h0000_0102);

// ID 3.5: VALID DATA (AAAA 0855)
test_bench.apb_wr(ADDR_TCR, 32'h0000_0100);

test_bench.apb_wr_pstrb(ADDR_TCR, 32'hAAAA_0855, BYTE0);
test_bench.apb_rd(ADDR_TCR, rdata);
test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0101, 32'hFFFF_FFFF);
test_bench.apb_wr(ADDR_TCR, 32'h0000_0100); // CLEAN UP: TURN OFF TIMER_EN

test_bench.apb_wr(ADDR_TCR, 32'h0000_0100);
test_bench.apb_wr_pstrb(ADDR_TCR, 32'hAAAA_0855, BYTE1);
test_bench.apb_rd(ADDR_TCR, rdata);
test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0800, 32'hFFFF_FFFF);
test_bench.apb_wr(ADDR_TCR, 32'h0000_0100); // recover reset state 0100 for the next tests

test_bench.apb_wr_pstrb(ADDR_TCR, 32'hAAAA_0855, BYTE2);
test_bench.apb_rd(ADDR_TCR, rdata);
test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0100, 32'hFFFF_FFFF);

test_bench.apb_wr_pstrb(ADDR_TCR, 32'hAAAA_0855, BYTE3);
test_bench.apb_rd(ADDR_TCR, rdata);
test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0100, 32'hFFFF_FFFF);

test_bench.apb_wr_pstrb(ADDR_TCR, 32'hAAAA_0855, HALF_WORD0);
test_bench.apb_rd(ADDR_TCR, rdata);
test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0801, 32'hFFFF_FFFF);
test_bench.apb_wr(ADDR_TCR, 32'h0000_0800); // CLEAN UP: TURN OFF TIMER_EN
test_bench.apb_wr(ADDR_TCR, 32'h0000_0100); // recover reset state 0100 for the next tests

test_bench.apb_wr_pstrb(ADDR_TCR, 32'hAAAA_0855, HALF_WORD1);
test_bench.apb_rd(ADDR_TCR, rdata);
test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0100, 32'hFFFF_FFFF);

test_bench.apb_wr_pstrb(ADDR_TCR, 32'hAAAA_0855, 4'hF);
test_bench.apb_rd(ADDR_TCR, rdata);
test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0801, 32'hFFFF_FFFF);
test_bench.apb_wr(ADDR_TCR, 32'h0000_0800); // CLEAN UP: TURN OFF TIMER_EN
test_bench.apb_wr(ADDR_TCR, 32'h0000_0100); // recover reset state 0100 for the next tests

test_bench.apb_wr_pstrb(ADDR_TCR, 32'hAAAA_0855, 4'h0);
test_bench.apb_rd(ADDR_TCR, rdata);
test_bench.cmp_data(ADDR_TCR, rdata, 32'h0000_0100, 32'hFFFF_FFFF);

// TDR0 Byte Access
$display("--- TDR0 Byte Access ----");
test_bench.apb_wr(ADDR_TDR0, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TDR0, 32'hFFFF_FFFF, BYTE0);
test_bench.apb_rd(ADDR_TDR0, rdata);
test_bench.cmp_data(ADDR_TDR0, rdata, 32'h0000_00FF, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TDR0, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TDR0, 32'hFFFF_FFFF, BYTE1);
test_bench.apb_rd(ADDR_TDR0, rdata);
test_bench.cmp_data(ADDR_TDR0, rdata, 32'h0000_FF00, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TDR0, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TDR0, 32'hFFFF_FFFF, BYTE2);
test_bench.apb_rd(ADDR_TDR0, rdata);
test_bench.cmp_data(ADDR_TDR0, rdata, 32'h00FF_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TDR0, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TDR0, 32'hFFFF_FFFF, BYTE3);
test_bench.apb_rd(ADDR_TDR0, rdata);
test_bench.cmp_data(ADDR_TDR0, rdata, 32'hFF00_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TDR0, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TDR0, 32'hFFFF_FFFF, HALF_WORD0);
test_bench.apb_rd(ADDR_TDR0, rdata);
test_bench.cmp_data(ADDR_TDR0, rdata, 32'h0000_FFFF, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TDR0, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TDR0, 32'hFFFF_FFFF, HALF_WORD1);
test_bench.apb_rd(ADDR_TDR0, rdata);
test_bench.cmp_data(ADDR_TDR0, rdata, 32'hFFFF_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TDR0, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TDR0, 32'hFFFF_FFFF, 4'hF);
test_bench.apb_rd(ADDR_TDR0, rdata);
test_bench.cmp_data(ADDR_TDR0, rdata, 32'hFFFF_FFFF, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TDR0, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TDR0, 32'hFFFF_FFFF, 4'h0);
test_bench.apb_rd(ADDR_TDR0, rdata);
test_bench.cmp_data(ADDR_TDR0, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

// TDR1 Byte Access
$display("--- TDR1 Byte Access ----");
test_bench.apb_wr(ADDR_TDR1, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TDR1, 32'hFFFF_FFFF, BYTE0);
test_bench.apb_rd(ADDR_TDR1, rdata);
test_bench.cmp_data(ADDR_TDR1, rdata, 32'h0000_00FF, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TDR1, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TDR1, 32'hFFFF_FFFF, BYTE1);
test_bench.apb_rd(ADDR_TDR1, rdata);
test_bench.cmp_data(ADDR_TDR1, rdata, 32'h0000_FF00, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TDR1, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TDR1, 32'hFFFF_FFFF, BYTE2);
test_bench.apb_rd(ADDR_TDR1, rdata);
test_bench.cmp_data(ADDR_TDR1, rdata, 32'h00FF_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TDR1, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TDR1, 32'hFFFF_FFFF, BYTE3);
test_bench.apb_rd(ADDR_TDR1, rdata);
test_bench.cmp_data(ADDR_TDR1, rdata, 32'hFF00_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TDR1, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TDR1, 32'hFFFF_FFFF, HALF_WORD0);
test_bench.apb_rd(ADDR_TDR1, rdata);
test_bench.cmp_data(ADDR_TDR1, rdata, 32'h0000_FFFF, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TDR1, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TDR1, 32'hFFFF_FFFF, HALF_WORD1);
test_bench.apb_rd(ADDR_TDR1, rdata);
test_bench.cmp_data(ADDR_TDR1, rdata, 32'hFFFF_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TDR1, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TDR1, 32'hFFFF_FFFF, 4'hF);
test_bench.apb_rd(ADDR_TDR1, rdata);
test_bench.cmp_data(ADDR_TDR1, rdata, 32'hFFFF_FFFF, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TDR1, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TDR1, 32'hFFFF_FFFF, 4'h0);
test_bench.apb_rd(ADDR_TDR1, rdata);
test_bench.cmp_data(ADDR_TDR1, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

// TCMP0 Byte Access
$display("--- TCMP0 Byte Access ----");
test_bench.apb_wr(ADDR_TCMP0, 32'hFFFF_FFFF);
test_bench.apb_wr_pstrb(ADDR_TCMP0, 32'h5555_5555, BYTE0);
test_bench.apb_rd(ADDR_TCMP0, rdata);
test_bench.cmp_data(ADDR_TCMP0, rdata, 32'hFFFF_FF55, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCMP0, 32'hFFFF_FFFF);
test_bench.apb_wr_pstrb(ADDR_TCMP0, 32'h5555_5555, BYTE1);
test_bench.apb_rd(ADDR_TCMP0, rdata);
test_bench.cmp_data(ADDR_TCMP0, rdata, 32'hFFFF_55FF, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCMP0, 32'hFFFF_FFFF);
test_bench.apb_wr_pstrb(ADDR_TCMP0, 32'h5555_5555, BYTE2);
test_bench.apb_rd(ADDR_TCMP0, rdata);
test_bench.cmp_data(ADDR_TCMP0, rdata, 32'hFF55_FFFF, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCMP0, 32'hFFFF_FFFF);
test_bench.apb_wr_pstrb(ADDR_TCMP0, 32'h5555_5555, BYTE3);
test_bench.apb_rd(ADDR_TCMP0, rdata);
test_bench.cmp_data(ADDR_TCMP0, rdata, 32'h55FF_FFFF, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCMP0, 32'hFFFF_FFFF);
test_bench.apb_wr_pstrb(ADDR_TCMP0, 32'h5555_5555, HALF_WORD0);
test_bench.apb_rd(ADDR_TCMP0, rdata);
test_bench.cmp_data(ADDR_TCMP0, rdata, 32'hFFFF_5555, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCMP0, 32'hFFFF_FFFF);
test_bench.apb_wr_pstrb(ADDR_TCMP0, 32'h5555_5555, HALF_WORD1);
test_bench.apb_rd(ADDR_TCMP0, rdata);
test_bench.cmp_data(ADDR_TCMP0, rdata, 32'h5555_FFFF, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCMP0, 32'hFFFF_FFFF);
test_bench.apb_wr_pstrb(ADDR_TCMP0, 32'h5555_5555, 4'hF);
test_bench.apb_rd(ADDR_TCMP0, rdata);
test_bench.cmp_data(ADDR_TCMP0, rdata, 32'h5555_5555, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCMP0, 32'hFFFF_FFFF);
test_bench.apb_wr_pstrb(ADDR_TCMP0, 32'h5555_5555, 4'h0);
test_bench.apb_rd(ADDR_TCMP0, rdata);
test_bench.cmp_data(ADDR_TCMP0, rdata, 32'hFFFF_FFFF, 32'hFFFF_FFFF);

// TCMP1 Byte Access
$display("--- TCMP1 Byte Access ----");
test_bench.apb_wr(ADDR_TCMP1, 32'hFFFF_FFFF);
test_bench.apb_wr_pstrb(ADDR_TCMP1, 32'h5555_5555, BYTE0);
test_bench.apb_rd(ADDR_TCMP1, rdata);
test_bench.cmp_data(ADDR_TCMP1, rdata, 32'hFFFF_FF55, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCMP1, 32'hFFFF_FFFF);
test_bench.apb_wr_pstrb(ADDR_TCMP1, 32'h5555_5555, BYTE1);
test_bench.apb_rd(ADDR_TCMP1, rdata);
test_bench.cmp_data(ADDR_TCMP1, rdata, 32'hFFFF_55FF, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCMP1, 32'hFFFF_FFFF);
test_bench.apb_wr_pstrb(ADDR_TCMP1, 32'h5555_5555, BYTE2);
test_bench.apb_rd(ADDR_TCMP1, rdata);
test_bench.cmp_data(ADDR_TCMP1, rdata, 32'hFF55_FFFF, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCMP1, 32'hFFFF_FFFF);
test_bench.apb_wr_pstrb(ADDR_TCMP1, 32'h5555_5555, BYTE3);
test_bench.apb_rd(ADDR_TCMP1, rdata);
test_bench.cmp_data(ADDR_TCMP1, rdata, 32'h55FF_FFFF, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCMP1, 32'hFFFF_FFFF);
test_bench.apb_wr_pstrb(ADDR_TCMP1, 32'h5555_5555, HALF_WORD0);
test_bench.apb_rd(ADDR_TCMP1, rdata);
test_bench.cmp_data(ADDR_TCMP1, rdata, 32'hFFFF_5555, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCMP1, 32'hFFFF_FFFF);
test_bench.apb_wr_pstrb(ADDR_TCMP1, 32'h5555_5555, HALF_WORD1);
test_bench.apb_rd(ADDR_TCMP1, rdata);
test_bench.cmp_data(ADDR_TCMP1, rdata, 32'h5555_FFFF, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCMP1, 32'hFFFF_FFFF);
test_bench.apb_wr_pstrb(ADDR_TCMP1, 32'h5555_5555, 4'hF);
test_bench.apb_rd(ADDR_TCMP1, rdata);
test_bench.cmp_data(ADDR_TCMP1, rdata, 32'h5555_5555, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCMP1, 32'hFFFF_FFFF);
test_bench.apb_wr_pstrb(ADDR_TCMP1, 32'h5555_5555, 4'h0);
test_bench.apb_rd(ADDR_TCMP1, rdata);
test_bench.cmp_data(ADDR_TCMP1, rdata, 32'hFFFF_FFFF, 32'hFFFF_FFFF);

// TIER Byte Access
$display("--- TIER Byte Access ----");
test_bench.apb_wr(ADDR_TIER, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TIER, 32'hFFFF_FFFF, BYTE0);
test_bench.apb_rd(ADDR_TIER, rdata);
test_bench.cmp_data(ADDR_TIER, rdata, 32'h0000_0001, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TIER, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TIER, 32'hFFFF_FFFF, BYTE1);
test_bench.apb_rd(ADDR_TIER, rdata);
test_bench.cmp_data(ADDR_TIER, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TIER, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TIER, 32'hFFFF_FFFF, BYTE2);
test_bench.apb_rd(ADDR_TIER, rdata);
test_bench.cmp_data(ADDR_TIER, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TIER, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TIER, 32'hFFFF_FFFF, BYTE3);
test_bench.apb_rd(ADDR_TIER, rdata);
test_bench.cmp_data(ADDR_TIER, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TIER, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TIER, 32'hFFFF_FFFF, HALF_WORD0);
test_bench.apb_rd(ADDR_TIER, rdata);
test_bench.cmp_data(ADDR_TIER, rdata, 32'h0000_0001, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TIER, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TIER, 32'hFFFF_FFFF, HALF_WORD1);
test_bench.apb_rd(ADDR_TIER, rdata);
test_bench.cmp_data(ADDR_TIER, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TIER, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TIER, 32'hFFFF_FFFF, 4'hF);
test_bench.apb_rd(ADDR_TIER, rdata);
test_bench.cmp_data(ADDR_TIER, rdata, 32'h0000_0001, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TIER, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TIER, 32'hFFFF_FFFF, 4'h0);
test_bench.apb_rd(ADDR_TIER, rdata);
test_bench.cmp_data(ADDR_TIER, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

// TISR Byte Access
$display("--- TISR Byte Access ----");
test_bench.apb_wr(ADDR_TISR, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TISR, 32'hFFFF_FFFF, BYTE0);
test_bench.apb_rd(ADDR_TISR, rdata);
test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TISR, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TISR, 32'hFFFF_FFFF, BYTE1);
test_bench.apb_rd(ADDR_TISR, rdata);
test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TISR, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TISR, 32'hFFFF_FFFF, BYTE2);
test_bench.apb_rd(ADDR_TISR, rdata);
test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TISR, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TISR, 32'hFFFF_FFFF, BYTE3);
test_bench.apb_rd(ADDR_TISR, rdata);
test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TISR, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TISR, 32'hFFFF_FFFF, HALF_WORD0);
test_bench.apb_rd(ADDR_TISR, rdata);
test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TISR, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TISR, 32'hFFFF_FFFF, HALF_WORD1);
test_bench.apb_rd(ADDR_TISR, rdata);
test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TISR, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TISR, 32'hFFFF_FFFF, 4'hF);
test_bench.apb_rd(ADDR_TISR, rdata);
test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TISR, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_TISR, 32'hFFFF_FFFF, 4'h0);
test_bench.apb_rd(ADDR_TISR, rdata);
test_bench.cmp_data(ADDR_TISR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

// THCSR Byte Access
$display("--- THCSR Byte Access ----");
test_bench.apb_wr(ADDR_THCSR, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_THCSR, 32'hFFFF_FFFF, BYTE0);
test_bench.apb_rd(ADDR_THCSR, rdata);
test_bench.cmp_data(ADDR_THCSR, rdata, 32'h0000_0001, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_THCSR, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_THCSR, 32'hFFFF_FFFF, BYTE1);
test_bench.apb_rd(ADDR_THCSR, rdata);
test_bench.cmp_data(ADDR_THCSR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_THCSR, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_THCSR, 32'hFFFF_FFFF, BYTE2);
test_bench.apb_rd(ADDR_THCSR, rdata);
test_bench.cmp_data(ADDR_THCSR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_THCSR, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_THCSR, 32'hFFFF_FFFF, BYTE3);
test_bench.apb_rd(ADDR_THCSR, rdata);
test_bench.cmp_data(ADDR_THCSR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_THCSR, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_THCSR, 32'hFFFF_FFFF, HALF_WORD0);
test_bench.apb_rd(ADDR_THCSR, rdata);
test_bench.cmp_data(ADDR_THCSR, rdata, 32'h0000_0001, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_THCSR, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_THCSR, 32'hFFFF_FFFF, HALF_WORD1);
test_bench.apb_rd(ADDR_THCSR, rdata);
test_bench.cmp_data(ADDR_THCSR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_THCSR, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_THCSR, 32'hFFFF_FFFF, 4'hF);
test_bench.apb_rd(ADDR_THCSR, rdata);
test_bench.cmp_data(ADDR_THCSR, rdata, 32'h0000_0001, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_THCSR, 32'h0000_0000);
test_bench.apb_wr_pstrb(ADDR_THCSR, 32'hFFFF_FFFF, 4'h0);
test_bench.apb_rd(ADDR_THCSR, rdata);
test_bench.cmp_data(ADDR_THCSR, rdata, 32'h0000_0000, 32'hFFFF_FFFF);

    end
endtask
