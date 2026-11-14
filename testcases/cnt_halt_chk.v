task run_test();
    reg[31:0] rdata;
    reg[31:0] val_tdr0_1;
    reg[31:0] val_tdr0_2;
    reg[63:0] expected_val;
    begin
        $display("=================================================");
        $display("=======        TEST CASE: HALT MODE CHECK =======");
        $display("=================================================");

// ID1: Normal mode (dbg_mode = 0, halt_req = 1)
$display("\n--- ID1: Normal Mode (dbg_mode = 0) ---");
test_bench.reset_dut();
test_bench.dbg_mode = 1'b0;

test_bench.apb_wr(ADDR_TCR, 32'h0000_0001); // Turn on Timer
test_bench.apb_wr(ADDR_THCSR, 32'h0000_0001); // try to send the HALT request

#(CLK_PERIOD * 10); // wait 10 cycles
// Check the Halt Request was DENIED
test_bench.apb_rd(ADDR_THCSR, rdata);
test_bench.cmp_data(ADDR_THCSR, rdata, 32'h0000_0000, 32'h0000_0002);

// check the counter continues counting
test_bench.apb_rd(ADDR_TDR0, val_tdr0_1);
#(CLK_PERIOD * 10);
test_bench.apb_rd(ADDR_TDR0, val_tdr0_2);
if (val_tdr0_2 > val_tdr0_1) begin
    $display("[PASS] ID1: Counter continues counting.");
end else begin
    $display("[FAIL] ID1: Counter stopped incorrectly!");
    test_bench.err = test_bench.err + 1;
end

// ID2: Debug mode (dbg_mode = 1, halt_req = 0)
$display("\n--- ID2: Debug Mode (dbg_mode = 1) ---");
test_bench.reset_dut();
test_bench.dbg_mode = 1'b1;

test_bench.apb_wr(ADDR_TCR, 32'h0000_0001); // Turn on Timer
test_bench.apb_wr(ADDR_THCSR, 32'h0000_0000); // no requests are send to the HALT

#(CLK_PERIOD * 10); // wait 10 cycles
// check the counter continues counting
test_bench.apb_rd(ADDR_TDR0, val_tdr0_1);
#(CLK_PERIOD * 10);
test_bench.apb_rd(ADDR_TDR0, val_tdr0_2);
if (val_tdr0_2 > val_tdr0_1) begin
    $display("[PASS] ID2: Counter continues counting.");
end else begin
    $display("[FAIL] ID2: Counter stopped incorrectly!");
    test_bench.err = test_bench.err + 1;
end

// ID3: Debug mode (dbg_mode = 1, halt_req = 1)
$display("\n--- ID3: Debug Mode (dbg_mode = 1, halt_req = 1) ---");
test_bench.reset_dut();
test_bench.dbg_mode = 1'b1;
test_bench.apb_wr(ADDR_TCR, 32'h0000_0001); // Turn on Timer
test_bench.apb_wr(ADDR_THCSR, 32'h0000_0001); // turn on HALT

rdata = 0;
while((rdata & 32'h0000_0002) == 0) begin
    test_bench.apb_rd(ADDR_THCSR, rdata);
end
$display("[PASS] ID 3: halt_ack asserted");

#(CLK_PERIOD * 10); // wait 10 cycles
// check the counter continues counting
test_bench.apb_rd(ADDR_TDR0, val_tdr0_1);
#(CLK_PERIOD * 10);
test_bench.apb_rd(ADDR_TDR0, val_tdr0_2);
if (val_tdr0_2 == val_tdr0_1) begin
    $display("[PASS] ID3: Counter is completely frozen.");
end else begin
    $display("[FAIL] ID3: Counter did not freeze!");
    test_bench.err = test_bench.err + 1;
end

// ID 4: PHASE PRESERVATION
$display("\n--- ID4: Phase Preservation (div_val = 2) ---");
test_bench.reset_dut();
test_bench.dbg_mode = 1'b1;

// div_val = 2, div_en = 1, timer_en = 1
test_bench.apb_wr(ADDR_TCR, 32'h0000_0203);
#(CLK_PERIOD * 20);

// HALT
test_bench.apb_wr(ADDR_THCSR, 32'h0000_0001);
rdata = 0;
while ((rdata & 32'h0000_0002) == 0) begin
    test_bench.apb_rd(ADDR_THCSR, rdata);
end

// Check the frozen
test_bench.apb_rd(ADDR_TDR0, val_tdr0_1);
#(CLK_PERIOD * 10);
test_bench.apb_rd(ADDR_TDR0, val_tdr0_2);
if (val_tdr0_2 == val_tdr0_1) begin
    $display("[PASS] ID4: Counter frozen during divided mode.");
end else begin
    $display("[FAIL] ID4: Counter not frozen.");
    test_bench.err = test_bench.err + 1;
end

// Resume
test_bench.apb_wr(ADDR_THCSR, 32'h0000_0000);
rdata = 32'h0000_0002;
while ((rdata & 32'h0000_0002) != 0) begin
    test_bench.apb_rd(ADDR_THCSR, rdata);
end
$display("[PASS] ID4: halt_ack de-asserted, timer resumed.");

// Check timer resumes smoothly without losing its phase
#(CLK_PERIOD * 10);
test_bench.apb_rd(ADDR_TDR0, val_tdr0_2);
if (val_tdr0_2 >= val_tdr0_1) begin
    $display("[PASS] ID4: Counter resumed smoothly without phase loss.");
end else begin
    $display("[FAIL] ID4: Counter failed to resume.");
    test_bench.err = test_bench.err + 1;
end

// ID5: Coverage sweep for clr_condition ( is_limit & halt_ack)
$display("ID5: Coverage sweep for halt_ack vs is_limit --- ");
test_bench.reset_dut();
test_bench.dbg_mode = 1'b1;

// Turn on Timer at Dividor mode (div_val = 1 -> divide by 2)
// now is_limit is becoming 1 luan phien moi 2 chu ki nhip
test_bench.apb_wr(ADDR_TCR, 32'h0000_0103);

// repeat Halt/Resume 4 times to sweep
repeat (4) begin
    test_bench.apb_wr(ADDR_THCSR, 32'h0000_0001);
    #(CLK_PERIOD * 10);
    test_bench.apb_wr(ADDR_THCSR, 32'h0000_0000);
    #(CLK_PERIOD * 5);
end
$display("PASS");

    end
endtask
