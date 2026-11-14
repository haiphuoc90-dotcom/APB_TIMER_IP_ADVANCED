// ==============================================================================
// Testcase: apb_error_handling
// Description: Verify APB slave error response (tim_pslverr)
// ==============================================================================
$display("------------------------------------------------------------");
$display("[TESTCASE] apb_error_handling: Starting APB error handling check");
$display("------------------------------------------------------------");

reset_dut();

// Case 1: Prohibited div_val > 8 (e.g., div_val = 9)
tsk_set_pslverr_exp(1'b1);
apb_wr(TCR_ADDR, 32'h0000_0902);
tsk_set_pslverr_exp(1'b0);

// Case 2: Changing div_val while timer is running (timer_en = 1)
apb_wr(TCR_ADDR, 32'h0000_0203); // timer_en = 1, div_en = 1, div_val = 2
tsk_set_pslverr_exp(1'b1);
apb_wr(TCR_ADDR, 32'h0000_0303); // Try to change div_val to 3 while running
tsk_set_pslverr_exp(1'b0);

// Case 3: Changing div_en while timer is running (timer_en = 1)
tsk_set_pslverr_exp(1'b1);
apb_wr(TCR_ADDR, 32'h0000_0201); // Try to change div_en to 0 while running
tsk_set_pslverr_exp(1'b0);

if (err_cnt == 0) begin
    $display("[RESULT: PASSED] APB error handling check passed.");
end else begin
    $display("[RESULT: FAILED] APB error handling check failed with %0d errors.", err_cnt);
end
$display("End time: %0t", $time);
$finish;
