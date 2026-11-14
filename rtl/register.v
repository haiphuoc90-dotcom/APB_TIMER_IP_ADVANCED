module register(
// SYSTEM CLOCK AND RESET
    input wire              sys_clk,
    input wire              sys_rst_n,
// APB SLAVE INTERFACE
    input wire              wr_en,
    input wire              rd_en,
    input wire[11:0]        addr,
    input wire[31:0]        wdata,
    input wire[3:0]         tim_pstrb,

    output wire[31:0]       rdata,
    output wire             reg_error_flag,
// COUNTER CONTROL INTERFACE
    output wire             timer_en,
    output wire             div_en,
    output wire[3:0]        div_val,
    output wire             halt_req,
    input wire              halt_ack,
// COUNTER INTERFACE
    input wire[63:0]        cnt,
    output wire[1:0]        counter_wsel,
    output wire[31:0]       counter_wdata,
// INTERRUPT INTERFACE
    output wire[63:0]       comp_val,
    input wire              interrupt_status,
    output wire             interrupt_clear,
    output wire             interrupt_en
);

//========================================================================================

// MEMORY MAP DEFINITIONS (REGISTER OFFSETS)
localparam TCR_ADDR   = 12'h000;
localparam TDR0_ADDR  = 12'h004;
localparam TDR1_ADDR  = 12'h008;
localparam TCMP0_ADDR = 12'h00C;
localparam TCMP1_ADDR = 12'h010;
localparam TIER_ADDR  = 12'h014;
localparam TISR_ADDR  = 12'h018;
localparam THCSR_ADDR = 12'h01C;

//========================================================================================

// ALL INTERNAL WIRES and REGISTER DECLARATION
// 1. ADDRESS DECODER WIRES
wire tcr_wr   ;
wire tdr0_wr  ;
wire tdr1_wr  ;
wire tcmp0_wr ;
wire tcmp1_wr ;
wire tier_wr  ;
wire tisr_wr  ;
wire thcsr_wr ;

// 2. ERROR GENERATION WIRES
wire is_tcr_addr    ;
wire err_prohibit   ;
wire err_div_val    ;
wire err_div_en     ;

// 3. TCR LOGIC WIRES and REGISTERS
wire tcr_safe_wr    ;
wire tcr_byte0_wr   ;
wire tcr_byte1_wr   ;

reg                 timer_en_q  ;
reg                 div_en_q    ;
reg[3:0]            div_val_q   ;

// 4. TDR0/1 LOGIC WIRES
wire[31:0]          wdata_tdr0;
wire[31:0]          wdata_tdr1;

// 5. TCMP0/1 LOGIC WIRES and REGISTERS
reg[31:0]           tcmp0_q;
reg[31:0]           tcmp1_q;
wire[31:0]          next_tcmp0;
wire[31:0]          next_tcmp1;

// 6. TISR, TIER, THCSR LOGIC WIRES and REGISTERS
reg                 int_en_q    ;
wire                tier_b0_wr  ;
reg                 halt_req_q  ;
wire                thcsr_b0_wr ;

// 7. READ MULTIPLEXER REGISTERS
reg[31:0]           read_mux_out ;

//========================================================================================

// 1. ADDRESS DECODER & WRITE CONTROL
assign tcr_wr   = (addr == TCR_ADDR)   & wr_en;
assign tdr0_wr  = (addr == TDR0_ADDR)  & wr_en;
assign tdr1_wr  = (addr == TDR1_ADDR)  & wr_en;
assign tcmp0_wr = (addr == TCMP0_ADDR) & wr_en;
assign tcmp1_wr = (addr == TCMP1_ADDR) & wr_en;
assign tier_wr  = (addr == TIER_ADDR)  & wr_en;
assign tisr_wr  = (addr == TISR_ADDR)  & wr_en;
assign thcsr_wr = (addr == THCSR_ADDR) & wr_en;

// 2. ERROR GENERATION
assign is_tcr_addr = (addr == TCR_ADDR);
// error 1: setting prohibit value (div_val > 8)
assign err_prohibit = is_tcr_addr & tim_pstrb[1] & (wdata[11:8] > 4'h8);
// error 2: changing div_val while timer is running
assign err_div_val = is_tcr_addr & timer_en & tim_pstrb[1] & (div_val != wdata[11:8]);
// error 3: changing div_en while timer is running
assign err_div_en = is_tcr_addr & timer_en & tim_pstrb[0] & (div_en != wdata[1]);

assign reg_error_flag = err_prohibit | err_div_val | err_div_en;

// 3. TCR LOGIC (Timer Control Register)
assign tcr_safe_wr = tcr_wr & (~reg_error_flag);
assign tcr_byte0_wr = tcr_safe_wr & tim_pstrb[0];
assign tcr_byte1_wr = tcr_safe_wr & tim_pstrb[1];

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        timer_en_q <= 1'b0;
        div_en_q   <= 1'b0;
        div_val_q  <= 4'b0001; // default divide by 2
    end else begin
        if (tcr_byte0_wr) begin
            timer_en_q <= wdata[0];
            div_en_q   <= wdata[1];
        end
        if (tcr_byte1_wr) begin
            div_val_q  <= wdata[11:8];
        end
    end
end

assign timer_en = timer_en_q;
assign div_en   = div_en_q;
assign div_val  = div_val_q;

// 4. TDR0/1 LOGIC (Data masking & MUX)
// TDR0 BYTE MASKING ( LOWER 32-bit)
assign wdata_tdr0[7:0]   = (tdr0_wr & tim_pstrb[0]) ? wdata[7:0]   : cnt[7:0]   ;
assign wdata_tdr0[15:8]  = (tdr0_wr & tim_pstrb[1]) ? wdata[15:8]  : cnt[15:8]  ;
assign wdata_tdr0[23:16] = (tdr0_wr & tim_pstrb[2]) ? wdata[23:16] : cnt[23:16] ;
assign wdata_tdr0[31:24] = (tdr0_wr & tim_pstrb[3]) ? wdata[31:24] : cnt[31:24] ;

// TDR1 BYTE MASKING ( UPPER 32-bit )
assign wdata_tdr1[7:0]   = (tdr1_wr & tim_pstrb[0]) ? wdata[7:0]   : cnt[39:32] ;
assign wdata_tdr1[15:8]  = (tdr1_wr & tim_pstrb[1]) ? wdata[15:8]  : cnt[47:40] ;
assign wdata_tdr1[23:16] = (tdr1_wr & tim_pstrb[2]) ? wdata[23:16] : cnt[55:48] ;
assign wdata_tdr1[31:24] = (tdr1_wr & tim_pstrb[3]) ? wdata[31:24] : cnt[63:56] ;

// OUTPUT TO COUNTER
assign counter_wsel = {tdr1_wr, tdr0_wr};
assign counter_wdata = tdr1_wr ? wdata_tdr1 : wdata_tdr0;

// 5. TCMP0/1 LOGIC (compare registers)
// TCMP0 BYTE MASKING
assign next_tcmp0[7:0]   = (tcmp0_wr & tim_pstrb[0]) ? wdata[7:0]   : tcmp0_q[7:0]   ;
assign next_tcmp0[15:8]  = (tcmp0_wr & tim_pstrb[1]) ? wdata[15:8]  : tcmp0_q[15:8]  ;
assign next_tcmp0[23:16] = (tcmp0_wr & tim_pstrb[2]) ? wdata[23:16] : tcmp0_q[23:16] ;
assign next_tcmp0[31:24] = (tcmp0_wr & tim_pstrb[3]) ? wdata[31:24] : tcmp0_q[31:24] ;

// TCMP1 BYTE MASKING
assign next_tcmp1[7:0]   = (tcmp1_wr & tim_pstrb[0]) ? wdata[7:0]   : tcmp1_q[7:0]   ;
assign next_tcmp1[15:8]  = (tcmp1_wr & tim_pstrb[1]) ? wdata[15:8]  : tcmp1_q[15:8]  ;
assign next_tcmp1[23:16] = (tcmp1_wr & tim_pstrb[2]) ? wdata[23:16] : tcmp1_q[23:16] ;
assign next_tcmp1[31:24] = (tcmp1_wr & tim_pstrb[3]) ? wdata[31:24] : tcmp1_q[31:24] ;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        tcmp0_q <= 32'hFFFF_FFFF;
        tcmp1_q <= 32'hFFFF_FFFF;
    end else begin
        tcmp0_q <= next_tcmp0;
        tcmp1_q <= next_tcmp1;
    end
end

assign comp_val = {tcmp1_q, tcmp0_q};

// 6. TISR, TIER, THCSR LOGIC
// TISR (combinational clear pulse)
assign interrupt_clear = tisr_wr & tim_pstrb[0] & wdata[0];

// TIER (Interrupt Enable Register)
assign tier_b0_wr = tier_wr & tim_pstrb[0];

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        int_en_q <= 1'b0;
    end else if (tier_b0_wr) begin
        int_en_q <= wdata[0];
    end
end

assign interrupt_en = int_en_q;

// THCSR (Halt Control Status Register)
assign thcsr_b0_wr = thcsr_wr & tim_pstrb[0];

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        halt_req_q <= 1'b0;
    end else if (thcsr_b0_wr) begin
        halt_req_q <= wdata[0];
    end
end

assign halt_req = halt_req_q;

// 7. READ MULTIPLEXER
always @(*) begin
    case (addr)
        TCR_ADDR:   read_mux_out = {20'b0, div_val_q, 6'd0, div_en_q, timer_en_q};
        TDR0_ADDR:  read_mux_out = cnt[31:0];
        TDR1_ADDR:  read_mux_out = cnt[63:32];
        TCMP0_ADDR: read_mux_out = tcmp0_q;
        TCMP1_ADDR: read_mux_out = tcmp1_q;
        TIER_ADDR:  read_mux_out = {31'd0, int_en_q};
        TISR_ADDR:  read_mux_out = {31'd0, interrupt_status};
        THCSR_ADDR: read_mux_out = {30'd0, halt_ack, halt_req_q};
        default:    read_mux_out = 32'h0000_0000;
    endcase
end

// Final security gate: output 0s if read is not enabled
assign rdata = rd_en ? read_mux_out : 32'h0000_0000;

endmodule
