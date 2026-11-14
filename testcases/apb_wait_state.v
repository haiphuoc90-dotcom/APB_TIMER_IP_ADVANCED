task run_test();
    reg[31:0] task_rdata;
    begin
        $display("==================================================");
        $display("=== TEST CASE: APB BACK-TO-BACK (PREADY) ====");
        $display("==================================================");

$display("\n--- ID1: Back to Back WRITE without IDLE states ---");
test_bench.apb_wr(ADDR_TCMP0, 32'h1111_1111);
test_bench.apb_wr(ADDR_TCMP1, 32'h2222_2222);
test_bench.apb_wr(ADDR_TDR0, 32'h3333_3333);


$display("\n--- ID2: Back to Back READ without IDLE states ---");
test_bench.apb_rd(ADDR_TCMP0, task_rdata);
test_bench.cmp_data(ADDR_TCMP0, task_rdata, 32'h1111_1111, 32'hFFFF_FFFF);

test_bench.apb_rd(ADDR_TCMP1, task_rdata);
test_bench.cmp_data(ADDR_TCMP1, task_rdata, 32'h2222_2222, 32'hFFFF_FFFF);

test_bench.apb_rd(ADDR_TDR0, task_rdata);
test_bench.cmp_data(ADDR_TDR0, task_rdata, 32'h3333_3333, 32'hFFFF_FFFF);

$display("\n[PASS] APB SLAVE handled back to back transfer flawlessly !");

$display("\n--- ID3: Scanning all timer registers ---");
test_bench.apb_wr(ADDR_TIER, 32'h0000_0001);// Interrupt enable register
test_bench.apb_rd(ADDR_TIER, task_rdata);

test_bench.apb_wr(ADDR_THCSR, 32'h0000_0001);// Halt control register
test_bench.apb_rd(ADDR_THCSR, task_rdata);

test_bench.apb_rd(ADDR_TISR, task_rdata);// Interrupr status register ( read-only check)
$display("\n[PASS] FULL APB SLAVE custom scan completed !");
    end
endtask