module counter_control (
// SYSTEM CLOCK and RESET
    input wire              sys_clk       ,
    input wire              sys_rst_n     ,
// CONTROL INPUTS (from REGISTER)
    input wire              timer_en      ,
    input wire              div_en        ,
    input wire[3:0]         div_val       ,
    input wire              halt_req      ,
    input wire              dbg_mode      ,
// OUTPUTS
    output wire             halt_ack      ,// sent back to REGISTER
    output wire             cnt_en        ,// sent to COUNTER
    output wire             counter_clr    // sent to COUNTER
);

// Internal wires and register
reg[7:0]    divisor_counter     ;
reg         timer_en_delayed    ;
wire[7:0]   limit               ;
wire        is_limit            ;
wire        cnt_en_pre_halt     ;
wire[7:0]   next_divisor_counter;

// 1. HALT ACKNOWLEDGE LOGIC (combinational)
// acknowledge halt imeediately if debug mode is active
assign halt_ack = halt_req & dbg_mode;

// 2. FALLING EDGE DETECTOR (Auto-Clear logic)
// Delay timer_en by 1 clock cycle
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        timer_en_delayed <= 1'b0;
    end else begin
        timer_en_delayed <= timer_en;
    end
end
// trigger clear pulse only when timer_en drops from 1 to 0
assign counter_clr = (~timer_en) & timer_en_delayed;

// 3. LIMIT CALCULATION
// calculate threshold: (1 shifted left by div_val) - 1
// ex: div_val = 3 -> ( 1 << 3 ) - 1 = 8 - 1 = 7
assign limit = (8'd1 << div_val) - 8'd1;
// check if divisor counter has reached the calculated limit
assign is_limit = (divisor_counter == limit);

// 4. PRESCALER (Divisor Counter Logic)
// conditions for incrementing and clearing
wire inc_condition = timer_en & div_en & (~halt_ack) ;
wire clr_condition = (~timer_en) | (~div_en) | ( is_limit & (~halt_ack)) ;
// MUX logic cascade: clear has higher priority than the Increment
assign next_divisor_counter = clr_condition ? 8'd0:
                             inc_condition ? (divisor_counter + 8'd1) :
                             divisor_counter;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        divisor_counter <= 8'd0;
    end else begin
        divisor_counter <= next_divisor_counter;
    end
end

// 5. MAIN COUNTER ENBALE GENERATION
wire normal_mode_en = timer_en;
wire div_mode_en = timer_en & is_limit & (~halt_ack) ;
// select between normal mode and divided mode based on div_en
assign cnt_en_pre_halt = div_en ? div_mode_en : normal_mode_en;
// Final security gate: completely disable counting if halted
assign cnt_en = cnt_en_pre_halt & (~halt_ack) ;
endmodule
