module counter (
// SYSTEM CLOCK and RESET
    input wire              sys_clk       ,
    input wire              sys_rst_n     ,
// CONTROL SIGNALS ( from COUNTER CONTROL )
    input wire              cnt_en        ,// enable counter increment
    input wire              counter_clr   ,// synchronous clear to 0
// REGISTER <-> COUNTER
    input wire[31:0]        wdata         ,// 32-bit write data from APB
    input wire[1:0]         counter_wsel  ,// write select: [1] for upper 32b, [0] for lower 32b
    output wire[63:0]       cnt            // counter 64-bit value
);

// Internal registers and wire
reg  [63:0] cnt_q           ;
wire [63:0] next_cnt_val    ;
wire [31:0] next_cnt_high   ;
wire [31:0] next_cnt_low    ;
wire [63:0] muxed_data      ;
wire [63:0] dff_d_input     ;

// Assign internal register to output port
assign cnt = cnt_q ;

// 1. INCREMENT LOGIC ( lowest priority )
assign next_cnt_val = cnt_en ? (cnt_q + 64'd1) : cnt_q ;

// 2. WRITE/DATA MASKING LOGIC ( medium priority )
// UPPER 32-bit {TDR1}: select wdata if counter_wsel[1] is active
assign next_cnt_high = counter_wsel[1] ? wdata : next_cnt_val[63:32] ;
// LOWER 32-bit {TDR0}: select wdata if counter_wsel[0] is active
assign next_cnt_low = counter_wsel[0] ? wdata : next_cnt_val[31:0] ;
// CONCATENATE THE UPPER AND LOWER 32-bit chunks back into 64-bit
assign muxed_data = {next_cnt_high, next_cnt_low} ;

// 3. SYNCHRONOUS CLEAR LOGIC ( highest priority )
// if counter_clr is active, force the input to 0, ignoring increments/writes
assign dff_d_input = counter_clr ? 64'd0 : muxed_data ;

// 4. SEQUENTIAL LOGIC ( 64-bit REGISTER )
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        cnt_q <= 64'b0 ;
    end else begin
        cnt_q <= dff_d_input ;
    end
end

endmodule
