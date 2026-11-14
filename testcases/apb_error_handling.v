task run_test();
    reg[31:0] task_rdata;
    integer i;
    begin
        $display("==========================================================================================================");
        $display("===           TEST CASE: APB ERROR HANDLING          ===");
        $display("==========================================================================================================");

// // TEST ID 1
$display("--- ID 1: TEST TCR.div_val prohibit setting ---");

for(i=9; i <= 15; i = i + 1) begin

test_bench.tsk_set_pslverr_exp(1);
test_bench.apb_wr(ADDR_TCR, (i << 8));
test_bench.tsk_set_pslverr_exp(0);
test_bench.apb_rd(ADDR_TCR, task_rdata);

test_bench.cmp_data(ADDR_TCR, task_rdata, 32'h0000_0100, 32'hFFFF_FFFF);
end

// TEST ID 2
$display("--- ID 2: TEST changing div_en while timer_en = 1 ---");

test_bench.apb_wr(ADDR_TCR, 32'h0000_0101);

test_bench.tsk_set_pslverr_exp(1);
test_bench.apb_wr(ADDR_TCR, 32'h0000_0103);
test_bench.tsk_set_pslverr_exp(0);

test_bench.apb_rd(ADDR_TCR, task_rdata);
test_bench.cmp_data(ADDR_TCR, task_rdata, 32'h0000_0101, 32'hFFFF_FFFF);

// TEST ID 3

test_bench.tsk_set_pslverr_exp(1);
test_bench.apb_wr(ADDR_TCR, 32'h0000_0201);
test_bench.tsk_set_pslverr_exp(0);

test_bench.apb_rd(ADDR_TCR, task_rdata);
test_bench.cmp_data(ADDR_TCR, task_rdata, 32'h0000_0101, 32'hFFFF_FFFF);

test_bench.apb_wr(ADDR_TCR, 32'h0000_0100);

// TEST ID 4
$display("\n--- ID4: TEST APB INVALID/OUT OF bound address access ---");
test_bench.tsk_set_pslverr_exp(1);
test_bench.apb_wr(12'hFFC, 32'hDEAD_BEEF);
test_bench.apb_rd(12'hFFC, task_rdata);
test_bench.tsk_set_pslverr_exp(0);

// TEST ID 5
$display("\n--- ID5: TEST APB Un - aligned access(+1, +2, +3) ---");
test_bench.tsk_set_pslverr_exp(1);

test_bench.apb_wr(ADDR_TDR0 + 1, 32'hAAAA_5555);
test_bench.apb_rd(ADDR_TDR0 + 1, task_rdata);

test_bench.apb_wr(ADDR_TDR0 + 2, 32'h5555_AAAA);
test_bench.apb_rd(ADDR_TDR0 + 2, task_rdata);

test_bench.apb_wr(ADDR_TDR0 + 3, 32'hFFFF_0000);
test_bench.apb_rd(ADDR_TDR0 + 3, task_rdata);

test_bench.tsk_set_pslverr_exp(0);
$display("Un aligned checks completed successfully !");

// TEST ID 6
$display("\n--- ID6: TEST APB Invalid/unmapped address access ---");
test_bench.tsk_set_pslverr_exp(1);

test_bench.apb_wr(12'h020, 32'h1122_3344);
test_bench.apb_rd(12'h020, task_rdata);

test_bench.apb_wr(12'h040, 32'h5566_7788);
test_bench.apb_rd(12'h040, task_rdata);

test_bench.apb_wr(12'h080, 32'h99AA_BBCC);
test_bench.apb_rd(12'h080, task_rdata);

test_bench.tsk_set_pslverr_exp(0);
$display("Invalid address checks completed successfully !");

    end
endtask