module timer_top(
// SYSTEM SIGNALS
    input wire              sys_clk       ,
    input wire              sys_rst_n     ,
    input wire              dbg_mode      ,
// APB BUS INTERFACE (Target/Slave)
    input wire              tim_psel      ,
    input wire              tim_penable   ,
    input wire              tim_pwrite    ,
    input wire[11:0]        tim_paddr     ,
    input wire[31:0]        tim_pwdata    ,
    input wire[3:0]         tim_pstrb     ,

    output wire             tim_pready    ,
    output wire[31:0]       tim_prdata    ,
    output wire             tim_pslverr   ,
// INTERRUPT OUTPUT
    output wire             tim_int
);

// INTERNAL WIRES DECLARATION

// APB SLAVE <-> REGISTER WIRES
wire        wr_en;
wire        rd_en;
wire[11:0]  addr;
wire[31:0]  wdata;
wire[31:0]  rdata;
wire        reg_error_flag;

// REGISTER <-> COUNTER CONTROL WIRES
wire        timer_en;
wire        div_en;
wire[3:0]   div_val;
wire        halt_req;
wire        halt_ack;

// COUNTER CONTROL <-> COUNTER WIRES
wire        cnt_en;
wire        counter_clr;

// REGISTER <-> COUNTER WIRES
wire[63:0]  cnt;
wire[1:0]   counter_wsel;
wire[31:0]  counter_wdata;

// REGISTERS <-> INTERRUPT WIRES
wire[63:0]  comp_val;
wire        interrupt_status;
wire        interrupt_clear;
wire        interrupt_en;

// MODULE INSTANTIATIONS

// 1. APB SLAVE MODULE
apb_slave u_apb_slave (
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .tim_psel       (tim_psel),
    .tim_penable    (tim_penable),
    .tim_pwrite     (tim_pwrite),
    .tim_paddr      (tim_paddr),
    .tim_pwdata     (tim_pwdata),
    .tim_pready     (tim_pready),
    .tim_prdata     (tim_prdata),
    .tim_pslverr    (tim_pslverr),
    .reg_error_flag (reg_error_flag),
    .rdata          (rdata),
    .wr_en          (wr_en),
    .rd_en          (rd_en),
    .addr           (addr),
    .wdata          (wdata)
);

// 2. REGISTER MODULE
register u_register(
    .sys_clk          (sys_clk),
    .sys_rst_n        (sys_rst_n),
    .wr_en            (wr_en),
    .rd_en            (rd_en),
    .addr             (addr),
    .wdata            (wdata),
    .rdata            (rdata),
    .tim_pstrb        (tim_pstrb),
    .reg_error_flag   (reg_error_flag),
    .timer_en         (timer_en),
    .div_en           (div_en),
    .div_val          (div_val),
    .halt_req         (halt_req),
    .halt_ack         (halt_ack),
    .cnt              (cnt),
    .counter_wsel     (counter_wsel),
    .counter_wdata    (counter_wdata),
    .comp_val         (comp_val),
    .interrupt_status (interrupt_status),
    .interrupt_clear  (interrupt_clear),
    .interrupt_en     (interrupt_en)
);

// 3. COUNTER CONTROL MODULE
counter_control u_counter_control(
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .timer_en       (timer_en),
    .div_en         (div_en),
    .div_val        (div_val),
    .halt_req       (halt_req),
    .dbg_mode       (dbg_mode),
    .halt_ack       (halt_ack),
    .cnt_en         (cnt_en),
    .counter_clr    (counter_clr)
);

// COUNTER MODULE
counter u_counter(
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .cnt_en         (cnt_en),
    .counter_clr    (counter_clr),
    .wdata          (counter_wdata),
    .cnt            (cnt),
    .counter_wsel   (counter_wsel)
);

// INTERRUPT MODULE
interrupt u_interrupt(
    .sys_clk          (sys_clk),
    .sys_rst_n        (sys_rst_n),
    .cnt              (cnt),
    .comp_val         (comp_val),
    .interrupt_status (interrupt_status),
    .interrupt_clear  (interrupt_clear),
    .interrupt_en     (interrupt_en),
    .tim_int          (tim_int)
);

endmodule
