// ==============================================================================
// Testcase: apb_wait_state
// Description: Verify 1-cycle wait state protocol timing on APB transfer
// ==============================================================================
$display("------------------------------------------------------------");
$display("[TESTCASE] apb_wait_state: Starting APB wait state check");
$display("------------------------------------------------------------");

reset_dut();

// Perform APB write and verify tim_pready low for exactly 1 cycle
@(posedge tim_pclk);
tim_psel    <= 1'b1;
tim_pwrite  <= 1'b1;
tim_paddr   <= TCMP0_ADDR;
tim_pwdata  <= 32'h5555_AAAA;
tim_pstrb   <= 4'hF;
tim_penable <= 1'b0;

@(posedge tim_pclk);
tim_penable <= 1'b1;

// Cycle 1: pready must be 0 (Wait state)
if (tim_pready !== 1'b0) begin
    $display("[FAIL] tim_pready was high in first access cycle. Wait state missing!");
    err_cnt = err_cnt + 1;
end else begin
    $display("[PASS] 1-cycle wait state detected (pready = 0).");
end

@(posedge tim_pclk);
// Cycle 2: pready must be 1 (Ready)
if (tim_pready !== 1'b1) begin
    $display("[FAIL] tim_pready did not assert after 1 wait cycle!");
    err_cnt = err_cnt + 1;
end else begin
    $display("[PASS] tim_pready asserted after 1 wait cycle (pready = 1).");
end

@(posedge tim_pclk);
tim_psel    <= 1'b0;
tim_penable <= 1'b0;
tim_pwrite  <= 1'b0;

if (err_cnt == 0) begin
    $display("[RESULT: PASSED] APB wait state check passed.");
end else begin
    $display("[RESULT: FAILED] APB wait state check failed with %0d errors.", err_cnt);
end
$display("End time: %0t", $time);
$finish;
