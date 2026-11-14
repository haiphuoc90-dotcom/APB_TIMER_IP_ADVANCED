// ==============================================================================
// Testcase: apb_protocol_chk
// Description: Verify standard APB write and read transfers handshake
// ==============================================================================
$display("------------------------------------------------------------");
$display("[TESTCASE] apb_protocol_chk: Starting APB protocol handshake check");
$display("------------------------------------------------------------");

reset_dut();

// Write transfer
apb_wr(TCMP0_ADDR, 32'h1234_5678);

// Read transfer
apb_rd(TCMP0_ADDR, rd_val);
cmp_data(rd_val, 32'h1234_5678, "TCMP0_APB_TRANSFER");

if (err_cnt == 0) begin
    $display("[RESULT: PASSED] APB protocol handshake check passed.");
end else begin
    $display("[RESULT: FAILED] APB protocol check failed with %0d errors.", err_cnt);
end
$display("End time: %0t", $time);
$finish;
