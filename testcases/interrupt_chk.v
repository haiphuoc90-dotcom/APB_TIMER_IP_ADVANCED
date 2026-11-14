task run_test();
    reg[31:0] val_tisr;
    begin
        $display("=================================================");
        $display("=====             TEST CASE: INTERRUPT      =====");
        $display("=================================================");

// ID 1: Interrupt pending - set condition
$display("\n--- ID1: Interrupt pending (set condition) ---");
test_bench.reset_dut();

// 1. set compare value via TCMP0 to 0xFF ( 255 )
test_bench.apb_wr(ADDR_TCMP0, 32'h0000_00FF);
test_bench.apb_wr(ADDR_TCMP1, 32'h0000_0000);

// 2. keep TIER.int_en = 0 (disabled by default after reset)
test_bench.apb_wr(ADDR_TIER, 32'h0000_0000);
// 3. Enable Timer (timer_en = 1)
test_bench.apb_wr(ADDR_TCR, 32'h0000_0001);

// wait until counter reaches compare match (wait 260 cycles to be safe)
#(CLK_PERIOD * 260);

// 4. Read TISR,int_st
test_bench.apb_rd(ADDR_TISR, val_tisr);

// pass condition: tim_int is 0, but TISR.int_st is 1
if (test_bench.tim_int == 1'b0 && val_tisr[0] == 1'b1) begin
    $display("[PASS] ID1: tim_int is NOT asserted, but TISR.int_st is set to 1.");
end else begin
    $display("[FAIL] ID1: tim_int = %b, but TISR.int_st = %b (expected 0, 1).", test_bench.tim_int, val_tisr[0]);
    test_bench.err = test_bench.err + 1;
end

// ID 2: Interrupt pending - clear condition (RW1C - Write 0)
$display("\n--- ID2: Interrupt pending (clear condition RW1C - WRITE 0 ) ---");
// continue from ID 1: TISR.int_st is currently 1

// 1. Write 0 to TISR.int_st
test_bench.apb_wr(ADDR_TISR, 32'h0000_0000);

// 2. Read back TISR
test_bench.apb_rd(ADDR_TISR, val_tisr);

// pass condition: writing 0 has no effect, TISR.int_st remains 1
if (val_tisr[0] == 1'b1) begin
    $display("[PASS] ID2: Writing 0 has no effect, TISR.int_st remains 1 .");
end else begin
    $display("[FAIL] ID2: TISR.int_st was cleared by writing 0! (val = %b) .", val_tisr[0]);
    test_bench.err = test_bench.err + 1;
end

// ID 3: Interrupt pending - clear condition (RW1C - Write 1)
$display("\n--- ID3: Interrupt pending (clear condition RW1C - WRITE 1 ) ---");
// continue from ID 2: TISR.int_st is currently 1

// 1. Write 1 to TISR.int_st
test_bench.apb_wr(ADDR_TISR, 32'h0000_0001);

// 2. read back TISR
test_bench.apb_rd(ADDR_TISR, val_tisr);

// pass condition: writing 1 has effect, TISR.int_st = 0
if (val_tisr[0] == 1'b0) begin
    $display("[PASS] ID3: Writing 0 successfully clears TISR.int_st to 0 .");
end else begin
    $display("[FAIL] ID3: TISR.int_st was NOT cleared by writing 1! (val = %b) .", val_tisr[0]);
    test_bench.err = test_bench.err + 1;
end

// ID 4: Interrupt enable - set and mask condition
$display("\n--- ID4: Interrupt enable (set and mask condition) ---");
test_bench.reset_dut();

// 1. set compare value TCMP0 to 0xFF ( 255 ), set TIER.int_en = 1
test_bench.apb_wr(ADDR_TCMP0, 32'h0000_00FF);
test_bench.apb_wr(ADDR_TCMP1, 32'h0000_0000);
test_bench.apb_wr(ADDR_TIER,  32'h0000_0001);

// 2. Enable Timer (timer_en = 1)
test_bench.apb_wr(ADDR_TCR, 32'h0000_0001);

// wait until counter reaches compare match (wait 260 cycles to be safe)
#(CLK_PERIOD * 260);

// check output tim_int
test_bench.apb_rd(ADDR_TISR, val_tisr);

if (test_bench.tim_int == 1'b1 && val_tisr[0] == 1'b1) begin
    $display("[PASS] ID4a: Output tim_int is asserted when int_en = 1.");
end else begin
    $display("[FAIL] ID4a: tim_int = %b, TISR.int_st = %b (expected 1, 1).", test_bench.tim_int, val_tisr[0]);
    test_bench.err = test_bench.err + 1;
end

// 3. Write 0 to TIER.int_en (masking)
test_bench.apb_wr(ADDR_TIER, 32'h0000_0000);
// wait a few cycles for logic to update
#(CLK_PERIOD * 5);

// check output tim_int
test_bench.apb_rd(ADDR_TISR, val_tisr);

if (test_bench.tim_int == 1'b0 && val_tisr[0] == 1'b1) begin
    $display("[PASS] ID4b: Setting int_en = 0 deasserts tim_int, while TISR.int_st stays 1.");
end else begin
    $display("[FAIL] ID4b: Masking failed tim_int = %b, TISR.int_st = %b (expected 0, 1).", test_bench.tim_int, val_tisr[0]);
    test_bench.err = test_bench.err + 1;
end

// ID 5: Persistence - Hold after disable
$display("\n--- ID5: Persistance (Hold after disable) ---");
test_bench.reset_dut();

// 1. set compare value TCMP0 to 80, set TIER.int_en = 1
test_bench.apb_wr(ADDR_TCMP0, 32'd80);
test_bench.apb_wr(ADDR_TCMP1, 32'h0000_0000);
test_bench.apb_wr(ADDR_TIER,  32'h0000_0001);

// Enable Timer (timer_en = 1)
test_bench.apb_wr(ADDR_TCR, 32'h0000_0001);

// wait until counter reaches compare match (wait 260 cycles to be safe)
#(CLK_PERIOD * 260);

// 2. Disable timer
test_bench.apb_wr(ADDR_TCR, 32'h0000_0000);
#(CLK_PERIOD * 10);

// check output tim_int
test_bench.apb_rd(ADDR_TISR, val_tisr);

if (test_bench.tim_int == 1'b1 && val_tisr[0] == 1'b1) begin
    $display("[PASS] ID5: Interrupt output and status are kept unchanged when timer is disabled ");
end else begin
    $display("[FAIL] ID5: Interrupt lost ! tim_int = %b, TISR.int_st = %b .", test_bench.tim_int, val_tisr[0]);
    test_bench.err = test_bench.err + 1;
end

// ID 6: Reset Behavior - Clear on reset
$display("\n--- ID6: Reset Behavior (clear on reset ---");
// 1. Interrupt is currently active from ID 5

// 2. Assert active-low reset
test_bench.reset_dut();

// 3. release reset and read TISR
test_bench.apb_rd(ADDR_TISR, val_tisr);
if (test_bench.tim_int == 1'b0 && val_tisr[0] == 1'b0) begin
    $display("[PASS] ID6: Interrupt status and output are cleared to 0 after reset. ");
end else begin
    $display("[FAIL] ID6: NOT cleared by reset ! tim_int = %b, TISR.int_st = %b .", test_bench.tim_int, val_tisr[0]);
    test_bench.err = test_bench.err + 1;
end

    end
endtask
