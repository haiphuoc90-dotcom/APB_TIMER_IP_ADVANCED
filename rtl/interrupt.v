module interrupt(
// SYSTEM CLOCK AND RESET
    input wire              sys_clk       ,
    input wire              sys_rst_n     ,
// DATA INPUTS
    input wire[63:0]        cnt           ,// Current counter value (from COUNTER)
    input wire[63:0]        comp_val      ,// Compare value (from REGISTER)
// CONTROL INPUTS ( from REGISTER )
    input wire              interrupt_clear,// Hardware clear signal (RW1C LOGIC)
    input wire              interrupt_en  ,// Interrupt enable flag
// OUTPUTS
    output wire             interrupt_status,// Status flag back to REGISTER
    output wire             tim_int        // Final interrupt signal external system
);

// Internals wires and registers
wire        int_trigger;
wire        set_mux_out;
wire        clear_mux_out;
reg         int_status_q;

// 1. COMARATOR LOGIC
// Generates a trigger pulse when the counter matches the compare value
assign int_trigger = ( cnt == comp_val );

// 2. SET/RETAIN LOGIC (FIRST MUX)
// if triggered, set state to 1. Otherwise, loop back the current state.
assign set_mux_out = int_trigger ? 1'b1 : int_status_q;

// 3. CLEAR LOGIC ( SECOND MUX )
// if a clear request is received, force the D-input to 0
// This overrides any set condition, giving 'clear' the highest priority
assign clear_mux_out = interrupt_clear ? 1'b0 : set_mux_out;

// 4. SEQUENTIAL LOGIC (D-FF)
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        int_status_q <= 1'b0;
    else
        int_status_q <= clear_mux_out;
end

// 5. OUTPUT ASSIGNMENT
// Output the raw status back to the register for CPU reading
assign interrupt_status = int_status_q;
// Mask the raw status with the enable flag to generate the actual interrupt
assign tim_int = int_status_q & interrupt_en;

endmodule
