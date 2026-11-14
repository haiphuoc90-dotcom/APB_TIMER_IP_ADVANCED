task run_test();
    reg[31:0] val_tdr0;
    reg[31:0] val_tdr1;
    reg[31:0] val_tisr;
    begin
        $display("=================================================");
        $display("=====        TEST CASE: COUNTER             =====");
        $display("=================================================");

// ID 1: TIMER ENABLE - VERIFY COUNTING
$display("\n--- ID 1: Timer Enable & Verify Counting ---");
test_bench.reset_dut();

// 1. Enable Timer (timer_en = 1)
test_bench.apb_wr(ADDR_TCR, 32'h0000_0001);
// 2. wait 10 system clock cycles
#(CLK_PERIOD * 10);
// 3. Read TDR0 register (offset = 0x04)
test_bench.apb_rd(ADDR_TDR0, val_tdr0);

// PASS CONDITION: TDR0 >= 10 and increments
if (val_tdr0 >= 32'h0000_000A) begin
    $display("[PASS] ID 1: Counter is counting. TDR0 = %0d (>=10)", val_tdr0);
end else begin
    $display("[FAIL] ID 1: Counter value too low. TDR0 = %0d (>=10)", val_tdr0);
    test_bench.err = test_bench.err + 1;
end

// ID 2: TIMER DISABLE - STOP AND HARDWARE AUTO-CLEAR
$display("\n--- ID 2: Timer Disable & Auto - Clear ---");
test_bench.reset_dut();

// 1. Enable Timer (timer_en = 1)
test_bench.apb_wr(ADDR_TCR, 32'h0000_0001);
// 2. wait 10 system clock cycles
#(CLK_PERIOD * 10);
// 3. Disable timer(timer_en = 0) -> triggers hardware auto-clear in advanced level
test_bench.apb_wr(ADDR_TCR, 32'h0000_0000);

// 4. Read TDR0 and TDR1 immediately
test_bench.apb_rd(ADDR_TDR0, val_tdr0);
test_bench.apb_rd(ADDR_TDR1, val_tdr1);

if (val_tdr0 == 32'h0000_0000 && val_tdr1 == 32'h0000_0000) begin
    $display("[PASS] ID 2a: Counter automatically cleared to 0 upon disable");
end else begin
    $display("[FAIL] ID 2a: Auto clear failed! TDR0 = %0h, TDR1 = %0h", val_tdr0, val_tdr1);
    test_bench.err = test_bench.err + 1;
end

// 2. wait 10 more system clock cycles and read again to ensure it stays stopped
#(CLK_PERIOD * 10);
test_bench.apb_rd(ADDR_TDR0, val_tdr0);
test_bench.apb_rd(ADDR_TDR1, val_tdr1);

if (val_tdr0 == 32'h0000_0000 && val_tdr1 == 32'h0000_0000) begin
    $display("[PASS] ID 2b: Counter remains stopped while disable");
end else begin
    $display("[FAIL] ID 2b: Counter kept counting while disabled! TDR0 = %0h", val_tdr0);
    test_bench.err = test_bench.err + 1;
end

// ID 3: ROLLOVER/CARRY - 32bit Overflow Check
$display("\n--- ID 3: ROLLOVER/CARRY - 32bit Overflow Check ---");
test_bench.reset_dut();

// 1 and 2. Preload TDR0 = 32'hFFFF_FF00, TDR1 = 0
test_bench.apb_wr(ADDR_TDR0, 32'hffff_ff00);
test_bench.apb_wr(ADDR_TDR1, 32'h0000_0000);

// 3. Enable Timer
test_bench.apb_wr(ADDR_TCR, 32'h0000_0001);

// 4. Wait 256 clock cycles (enough to cross FFFF_FFFF boundary)
#(CLK_PERIOD * 256);

// 5. read TDR0 and TDR1
test_bench.apb_rd(ADDR_TDR0, val_tdr0);
test_bench.apb_rd(ADDR_TDR1, val_tdr1);

// pass condition: TDR1 increments to 1, TDR0 rolls over to small value
if (val_tdr1 == 32'h0000_0001 && val_tdr0 < 32'h0000_0100) begin
    $display("[PASS] ID 3: 32-bit rollover successful. TDR1 = %0h, TDR0 = %0h", val_tdr1, val_tdr0);
end else begin
    $display("[FAIL] ID 3: 32-bit rollover failed ! TDR1 = %0h, TDR0 = %0h", val_tdr1, val_tdr0);
    test_bench.err = test_bench.err + 1;
end

// ID 4: FULL SCALE ROLLOVER - 64bit Overflow Check
$display("\n--- ID 4: 64-bit FULL SCALE ROLLOVER ---");
test_bench.reset_dut();

// 1. set TDR0 = 32'hFFFF_FFFF, TDR1 = FFFF_FFFF
test_bench.apb_wr(ADDR_TDR0, 32'hFFFF_FFFF);
test_bench.apb_wr(ADDR_TDR1, 32'hFFFF_FFFF);

// 2. Enable Timer
test_bench.apb_wr(ADDR_TCR, 32'h0000_0001);

// 3. Wait 10 clock cycles
#(CLK_PERIOD * 10);

// 4. read TDR0 and TDR1
test_bench.apb_rd(ADDR_TDR0, val_tdr0);
test_bench.apb_rd(ADDR_TDR1, val_tdr1);

// pass condition: wrap around to 0 without hanging
if (val_tdr1 == 32'h0000_0000 && val_tdr0 < 32'h0000_0020) begin
    $display("[PASS] ID 4: 64-bit full scale rollover wrapped around correctly. TDR1 = %0h, TDR0 = %0h", val_tdr1, val_tdr0);
end else begin
    $display("[FAIL] ID 4: Full scale rollover failed ! TDR1 = %0h, TDR0 = %0h", val_tdr1, val_tdr0);
    test_bench.err = test_bench.err + 1;
end

// ID 5: Counter Reload - Reload from TDR
$display("\n--- ID 4: Counter Reload - Reload from TDR ---");
test_bench.reset_dut();

// 1. write custom non-zero start value while timer_en = 0
test_bench.apb_wr(ADDR_TDR0, 32'h0000_1000);
test_bench.apb_wr(ADDR_TDR1, 32'h0000_0000);

// 2. Enable Timer (transition from 0 to 1)
test_bench.apb_wr(ADDR_TCR, 32'h0000_0001);

// 3. Wait 10 clock cycles
#(CLK_PERIOD * 5);

// 4. read TDR0
test_bench.apb_rd(ADDR_TDR0, val_tdr0);

// pass condition: resume counting from pre-loaded value (>=0x1005)
if (val_tdr0 >= 32'h0000_1005) begin
    $display("[PASS] ID 5: Counter reloaded and counted correctly. TDR0 = %0h", val_tdr0);
end else begin
    $display("[FAIL] ID 5: reloaded failed ! TDR0 = %0h", val_tdr0);
    test_bench.err = test_bench.err + 1;
end

// ID 6: Counter behavior after interrupt - Continue after interrupt
$display("\n--- ID5: Counter continue after interrupt ---");
test_bench.reset_dut();

// 1. set compare value TCMP0 to 20, TCMP1 = 0
test_bench.apb_wr(ADDR_TCMP0, 32'd20);
test_bench.apb_wr(ADDR_TCMP1, 32'h0000_0000);

// 2. Enable Timer (timer_en = 1) and wait until interrupt is triggered
test_bench.apb_wr(ADDR_TCR, 32'h0000_0001);

// Wait long enough to reach 20 and assert interrupt
#(CLK_PERIOD * 40);
test_bench.apb_rd(ADDR_TISR, val_tisr);

// 3. Let counter continue running for another 20 cycles
#(CLK_PERIOD * 20);

// 4. read TDR0
test_bench.apb_rd(ADDR_TDR0, val_tdr0);

// pass condition: interrupt triggered and counter continued past compare value without freezing
if (val_tisr[0] == 1'b1 && val_tdr0 >= 32'd60) begin
    $display("[PASS] ID 6: Interrupt triggered and counter continued past compare normally. TDR0 = %0h", val_tdr0);
end else begin
    $display("[FAIL] ID 6: failed ! TISR.int_st = %b, TDR0 = %0h", val_tisr[0], val_tdr0);
    test_bench.err = test_bench.err + 1;
end

    end
endtask
