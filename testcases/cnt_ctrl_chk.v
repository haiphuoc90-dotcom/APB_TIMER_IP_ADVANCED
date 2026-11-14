task run_test();
    reg[31:0] val_tdr0;
    reg[63:0] expected_val;
    integer i;
    integer expected_period;
    integer wait_cycles;
    begin
        $display("=================================================");
        $display("====   TEST CASE: COUNTER CONTROL         =======");
        $display("=================================================");

// ID1: Normal Mode (div_en = 0, ignore div_val)
$display("\n--- ID1: Normal Mode ( div_en = 0 ) ---");
test_bench.reset_dut();
test_bench.tsk_cfg_golden_cnt(64'h0); //reset the golden counter to 0

// TCR = 32'h0000_0101 (div_val = 1, div_en = 0, timer_en = 1)
test_bench.apb_wr(ADDR_TCR, 32'h0000_0101);
#(CLK_PERIOD * 100);
test_bench.apb_rd(ADDR_TDR0, val_tdr0);

expected_val = test_bench.golden_cnt; // Because the divide factor is 1

if (val_tdr0 == expected_val) begin
    $display("[PASS] ID1: Counter increments correctly by 1. (TDR0 = %0d, Golden = %0d", val_tdr0, expected_val);
end else begin
    $display("[FAIL] ID1: Incorrect rate. (TDR0 = %0d, Golden = %0d.", val_tdr0, expected_val);
    test_bench.err = test_bench.err + 1;
end

// ID1.5: Dividor Mode (div_val = 0)
$display("\n--- ID1.5: Dividor mode ( div_val = 0, div_en = 1 ) ---");
test_bench.reset_dut();
test_bench.tsk_cfg_golden_cnt(64'h0); //reset the golden counter to 0

// TCR = 32'h0000_0003 (div_val = 0, div_en = 1, timer_en = 1)
test_bench.apb_wr(ADDR_TCR, 32'h0000_0003);
#(CLK_PERIOD * 100);
test_bench.apb_rd(ADDR_TDR0, val_tdr0);

expected_val = test_bench.golden_cnt; // the divide factor is 2^0 = 1
if (val_tdr0 == expected_val) begin
    $display("[PASS] ID 1.5: Counter increments correctly (factor 1). (TDR0 = %0d, Golden = %0d.", val_tdr0, expected_val);
end else begin
    $display("[FAIL] ID 1.5: Incorrect rate. (TDR0 = %0d, Golden = %0d.", val_tdr0, expected_val);
    test_bench.err = test_bench.err + 1;
end

// ID2: Divider Mode (div_val = 1 to 4)
$display("\n--- ID2: Divider Mode (div_val = 1 to 4) ---");
for (i = 1; i <= 4; i = i + 1) begin
    test_bench.reset_dut();
    test_bench.tsk_cfg_golden_cnt(64'h0);
    expected_period = 1 << i; // Calculate period: 2^i
    // Shift variable i into the div_val position (bits 11:8)
    test_bench.apb_wr(ADDR_TCR, (i << 8) | 32'h0000_0003);

    // Wait long enough to count approximately 20 increments
    wait_cycles = expected_period * 20;
    #(CLK_PERIOD * wait_cycles);
    test_bench.apb_rd(ADDR_TDR0, val_tdr0);

    // Utilize golden_cnt to calculate the expected count extremely accurately
    expected_val = test_bench.golden_cnt / expected_period;

    if (val_tdr0 == expected_val) begin
        $display("[PASS] ID 2: div_val = %0d (period /%0d) increments correctly. (TDR0 = %0d, Exp = %0d).", i, expected_period, val_tdr0, expected_val);
    end else begin
        $display("[FAIL] ID 2: div_val = %0d . (TDR0 = %0d, Exp = %0d).", i, val_tdr0, expected_val);
        test_bench.err = test_bench.err + 1;
    end
end

// ID3: Divider Mode (div_val = 5 to 8)
$display("\n--- ID3: Divider Mode (div_val = 5 to 8) ---");
for (i = 5; i <= 8; i = i + 1) begin
    test_bench.reset_dut();
    test_bench.tsk_cfg_golden_cnt(64'h0);
    expected_period = 1 << i; // Calculate period: 2^i
    // Shift variable i into the div_val position (bits 11:8)
    test_bench.apb_wr(ADDR_TCR, (i << 8) | 32'h0000_0003);

    // Wait long enough to count approximately 10 increments
    wait_cycles = expected_period * 10;
    #(CLK_PERIOD * wait_cycles);
    test_bench.apb_rd(ADDR_TDR0, val_tdr0);

    // Utilize golden_cnt to calculate the expected count extremely accurately
    expected_val = test_bench.golden_cnt / expected_period;

    if (val_tdr0 == expected_val) begin
        $display("[PASS] ID 3: div_val = %0d (period /%0d) increments correctly. (TDR0 = %0d, Exp = %0d).", i, expected_period, val_tdr0, expected_val);
    end else begin
        $display("[FAIL] ID 3: div_val = %0d . (TDR0 = %0d, Exp = %0d).", i, val_tdr0, expected_val);
        test_bench.err = test_bench.err + 1;
    end
end

// ID4: Prescaler Reset (Clear on disable)
$display("\n--- ID4: Prescaler Reset (Clear on disable) ---");
test_bench.reset_dut();

// 1. Set div_val = 8 (period 256), enable timer
test_bench.apb_wr(ADDR_TCR, 32'h0000_0803);

// 2. wait 100 cycles
#(CLK_PERIOD * 100);

// 3. Disable timer (to force the prescaler to reset to 0)
test_bench.apb_wr(ADDR_TCR, 32'h0000_0802);

// Re-enable the timer immediately
test_bench.apb_wr(ADDR_TCR, 32'h0000_0803);

// 4. Wait another 160 cycles ( running 260 cycles in total)
#(CLK_PERIOD * 160);
test_bench.apb_rd(ADDR_TDR0, val_tdr0);

// if the prescaler resets correctly, it counts to 100 then counts to 160
// again, never reaching the 256 mark => TDR0 must remain 0.
if (val_tdr0 == 32'h0000_0000) begin
    $display("[PASS] ID4: Prescaler automatically reset when disabled.");
end else begin
    $display("[FAIL] ID4: Prescaler did NOT reset !! TDR0 = %0d.", val_tdr0);
    test_bench.err = test_bench.err + 1;
end

    end
endtask
