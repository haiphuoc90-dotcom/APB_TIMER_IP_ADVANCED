module apb_slave(
// SYSTEM SIGNALS
    input wire              sys_clk       ,
    input wire              sys_rst_n     ,

// APB BUS INTERFACE
    input wire              tim_psel      ,
    input wire              tim_penable   ,
    input wire              tim_pwrite    ,
    input wire[11:0]        tim_paddr     ,
    input wire[31:0]        tim_pwdata    ,

// OUTPUTS Slave -> Master
    output wire             tim_pready    ,
    output wire[31:0]       tim_prdata    ,
    output wire             tim_pslverr   ,

// APB SLAVE <-> REGISTER
//REGISTER -> APB SLAVE
    input wire              reg_error_flag,
    input wire[31:0]        rdata         ,
// REGISTER <- APB SLAVE
    output wire             wr_en         ,
    output wire             rd_en         ,
    output wire[11:0]       addr          ,
    output wire[31:0]       wdata
);

wire wait_req                   ;
wire wr_en_raw                  ;
reg  tim_pready_q               ;

assign addr                     = tim_paddr       ;
assign wdata                    = tim_pwdata      ;
assign tim_prdata               = rdata           ;
assign tim_pready               = tim_pready_q    ;

// WAIT STATE LOGIC (1 CYCLE)
assign wait_req = tim_psel & tim_penable & (~tim_pready_q);

always @(posedge sys_clk, negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        tim_pready_q <= 1'b0              ;
    end else begin
        tim_pready_q <= wait_req          ;
    end
end

// ERROR HANDLING AND REGISTER PROTECTION
assign wr_en_raw = tim_pready & tim_penable & tim_psel & tim_pwrite           ;
assign tim_pslverr = wr_en_raw & reg_error_flag                                ;

// READ/WRITE ENABLE GENERATION
assign wr_en = wr_en_raw & (~reg_error_flag)                                  ;
assign rd_en = tim_pready & tim_penable & tim_psel & (~tim_pwrite)            ;

endmodule
