module test_bench;

localparam CLK_PERIOD       = 10;

localparam ADDR_TCR         = 12'h000;
localparam ADDR_TDR0        = 12'h004;
localparam ADDR_TDR1        = 12'h008;
localparam ADDR_TCMP0       = 12'h00C;
localparam ADDR_TCMP1       = 12'h010;
localparam ADDR_TIER        = 12'h014;
localparam ADDR_TISR        = 12'h018;
localparam ADDR_THCSR       = 12'h01C;

localparam BYTE0            = 4'b0001;
localparam BYTE1            = 4'b0010;
localparam BYTE2            = 4'b0100;
localparam BYTE3            = 4'b1000;
localparam HALF_WORD0       = 4'b0011;
localparam HALF_WORD1       = 4'b1100;

reg                     sys_clk;
reg                     sys_rst_n;
reg                     dbg_mode;

reg                     tim_psel;
reg                     tim_penable;
reg                     tim_pwrite;
reg [11:0]              tim_paddr;
reg [31:0]              tim_pwdata;
reg [3:0]               tim_pstrb;
wire                    tim_pready;
wire [31:0]             tim_prdata;
wire                    tim_pslverr;

wire                    tim_int;
integer                 timeout_cnt;
integer                 err;
    reg cnt_chk_en;
    reg [31:0] cnt_chk_cycle;
    reg [3:0] div_val;
    reg [63:0] exp_cnt;

    reg golden_cnt_cfg_en   ;
    reg [63:0] golden_cnt_cfg;
    wire [63:0] golden_cnt;

    reg apb_err_psel;
    reg apb_err_penable;
    reg pslverr_chk_fail, pready_chk_fail;

    reg pslverr_exp;
    reg pslverr_high;

timer_top dut(
    .sys_clk            (sys_clk)           ,
    .sys_rst_n          (sys_rst_n)         ,
    .dbg_mode           (dbg_mode)          ,
    .tim_psel           (tim_psel)          ,
    .tim_penable        (tim_penable)       ,
    .tim_pwrite         (tim_pwrite)        ,
    .tim_paddr          (tim_paddr)         ,
    .tim_pwdata         (tim_pwdata)        ,
    .tim_pstrb          (tim_pstrb)         ,
    .tim_pready         (tim_pready)        ,
    .tim_prdata         (tim_prdata)        ,
    .tim_pslverr        (tim_pslverr)       ,
    .tim_int            (tim_int)
    );

mod_golden_cnt u_tb_cnt
(
    .cnt_cfg_en (   golden_cnt_cfg_en   ),
    .cnt_cfg    (   golden_cnt_cfg      ),
    .cnt        (   golden_cnt          ),
    .clk        (   sys_clk             ),
    .rst_n      (   sys_rst_n           ),
    .psel       (   tim_psel            ),
    .penable    (   tim_penable         ),
    .pwrite     (   tim_pwrite          ),
    .paddr      (   tim_paddr           ),
    .pwdata     (   tim_pwdata          ),
    .dbg_mode   (   dbg_mode            )
);

    initial begin
        sys_clk = 0;
        forever #(CLK_PERIOD/2) sys_clk = ~sys_clk;
    end

    task reset_dut();
    begin
        sys_rst_n                   = 0;
        dbg_mode                    = 0;
        tim_psel                    = 0;
        tim_penable                 = 0;
        tim_pwrite                  = 0;
        tim_pstrb                   = 4'hf;
        tim_paddr                   = 0;
        err                         = 0;
        cnt_chk_cycle               = 0;
        div_val                     = 0;
        golden_cnt_cfg_en           = 0;
        golden_cnt_cfg              = 0;
        apb_err_psel                = 0;
        apb_err_penable             = 0;
        pslverr_chk_fail            = 0;
        pready_chk_fail             = 0;
        pslverr_exp                 = 0;


        #(CLK_PERIOD * 5);
        sys_rst_n                   = 1;
        #(CLK_PERIOD * 2);
    end
    endtask

    task tsk_set_pslverr_exp(input val);
        begin
            if(val)
                $display("Pslverr check is ON");
            else
                $display("Pslverr check is ON");

            pslverr_exp = val;
        end
    endtask

    task apb_wr;
        input   [31:0]  in_addr;
        input   [31:0]  in_data;

        begin
            tim_pstrb = 4'b1111;
            pslverr_high = 0;
                        $display("t=%10d [TB_WRITE]: addr=%x data=%x", $time, in_addr, in_data);

            @(posedge sys_clk);
            #1;
            tim_psel = 1 & !apb_err_psel;   //setup phase
            tim_pwrite = 1;
            tim_paddr = in_addr;
            tim_pwdata = in_data; //cnt_en
            @(posedge sys_clk);
            #1;
            tim_penable = 1 & !apb_err_penable; //access phase
            if( apb_err_penable || apb_err_psel ) begin
                //donothing
            end else begin
                #1;
                if( tim_pready == 1) begin
                        $display("----------------------------------------------------------------------------------------------------------");
                        $display("t=%10d FAIL: pready asserts same time with penable", $time);
                        $display("----------------------------------------------------------------------------------------------------------");
                    err=err+1;
                end
                wait( tim_pready == 1); //wait accept
                #1;
                if( tim_pslverr ) begin
                    if( pslverr_exp ) begin
                        pslverr_high = 1;
                    end else begin
                        $display("----------------------------------------------------------------------------------------------------------");
                        $display("t=%10d FAIL: pslverr asserts unexpectedly", $time);
                        $display("----------------------------------------------------------------------------------------------------------");
                        err=err+1;
                    end
                end
            end
            @(posedge sys_clk);
            #1;
            tim_pwrite = 0; //idle
            tim_psel = 0;
            tim_penable = 0;
            tim_paddr = 0;
            tim_pwdata = 0;
        end
    endtask

    task apb_wr_pstrb;
        input   [31:0]  in_addr;
        input   [31:0]  in_data;
        input   [3:0]   in_pstrb;

        begin
            tim_pstrb = in_pstrb;
            pslverr_high = 0;
                        $display("t=%10d [TB_WRITE STRB]: addr=%x data=%x pstrb=%x ", $time, in_addr, in_data, in_pstrb);

            @(posedge sys_clk);
            #1;
            tim_psel = 1 & !apb_err_psel;   //setup phase
            tim_pwrite = 1;
            tim_paddr = in_addr;
            tim_pwdata = in_data; //cnt_en
            @(posedge sys_clk);
            #1;
            tim_penable = 1 & !apb_err_penable; //access phase
            if( apb_err_penable || apb_err_psel ) begin
                //donothing
            end else begin
                #1;
                if( tim_pready == 1) begin
                        $display("----------------------------------------------------------------------------------------------------------");
                        $display("t=%10d FAIL: pready asserts same time with penable", $time);
                        $display("----------------------------------------------------------------------------------------------------------");
                    err=err+1;
                end
                wait( tim_pready == 1); //wait accept
                #1;
                if( tim_pslverr ) begin
                    if( pslverr_exp ) begin
                        pslverr_high = 1;
                    end else begin
                        $display("----------------------------------------------------------------------------------------------------------");
                        $display("t=%10d FAIL: pslverr asserts unexpectedly", $time);
                        $display("----------------------------------------------------------------------------------------------------------");
                        err=err+1;
                    end
                end
            end
            @(posedge sys_clk);
            #1;
            tim_pwrite = 0; //idle
            tim_psel = 0;
            tim_penable = 0;
            tim_paddr = 0;
            tim_pwdata = 0;

        end
    endtask

    task apb_rd;

        input   [31:0]  in_addr;
        output  [31:0]  out_rdata;

        begin
            pslverr_high = 0;

            @(posedge sys_clk);
            #1;
            tim_psel = 1 & !apb_err_psel;   //setup phase
            tim_pwrite = 0;
            tim_paddr = in_addr;
            @(posedge sys_clk);
            #1;
            tim_penable = 1 & !apb_err_penable; //access phase
            if( apb_err_penable || apb_err_psel ) begin
                //donothing
            end else begin
                #1;
                if( tim_pready == 1) begin
                        $display("----------------------------------------------------------------------------------------------------------");
                        $display("t=%10d FAIL: pready asserts same time with penable", $time);
                        $display("----------------------------------------------------------------------------------------------------------");
                    err=err+1;
                end
                wait( tim_pready == 1); //wait accept
                #1;
                out_rdata = tim_prdata;
                if( tim_pslverr && !pslverr_exp ) begin
                    if( pslverr_exp ) begin
                        pslverr_high = 1;
                    end else begin
                        $display("----------------------------------------------------------------------------------------------------------");
                        $display("t=%10d FAIL: pslverr asserts unexpectedly", $time);
                        $display("----------------------------------------------------------------------------------------------------------");
                        err=err+1;
                    end
                end
            end
            @(posedge sys_clk);
            #1;
            tim_pwrite = 0; //idle
            tim_psel = 0;
            tim_penable = 0;
            tim_paddr = 0;
            tim_pwdata = 0;

                        $display("t=%10d [TB_READ]: addr=%x rdata=%x", $time, in_addr, out_rdata);
        end
    endtask


    task cmp_data;
        input [31:0]    in_addr ;
        input [31:0]    in_data ;
        input [31:0]    exp_data;
        input [31:0]    mask;

        begin
            if( (in_data & mask) !== (exp_data & mask) ) begin
                $display("----------------------------------------------------------------------------------------------------------");
                $display("t=%10d FAIL: rdata at addr %x is not correct", $time, in_addr);
                $display("Exp: %x Actual:%x", exp_data & mask, in_data & mask);
                $display("----------------------------------------------------------------------------------------------------------");
                #100;
                err=err+1;
            end else begin
                $display("----------------------------------------------------------------------------------------------------------");
                $display("t=%10d PASS: rdata = %x at addr %x is correct", $time, in_data, in_addr);
                $display("----------------------------------------------------------------------------------------------------------");
            end
        end
    endtask

    task tsk_cfg_golden_cnt;
        input [63:0] val;

        begin
            @(posedge sys_clk);
            #1;
            golden_cnt_cfg_en = 1;
            golden_cnt_cfg      = val;
            @(posedge sys_clk);
            #1;
            golden_cnt_cfg_en = 0;
            golden_cnt_cfg      = 0;
            @(posedge sys_clk);
        end
    endtask

    task tsk_set_dbg_mode;
        input val;

        begin
            if( val )
                $display("DBG MODE IS ON");
            else
                $display("DBG MODE IS OFF");

            dbg_mode = val;
        end
    endtask

    task tsk_rd_pslverr;
        output status;

        begin
            status = pslverr_high;
        end
    endtask

`include "run_test.v"
// `include "test_case/apb_error_handling.v"
// `include "test_case/apb_wait_state.v"

initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, test_bench);
    $display("==========================================================================================================");
    $display("          STARTING TIMER IP VERIFICATION            ");
    $display("==========================================================================================================");
    err = 0;
    pslverr_exp = 0;

    apb_err_psel = 0;
    apb_err_penable = 0;
    pslverr_high = 0;

    reset_dut();
    run_test();
    if (err == 0) begin
        $display("==========================================================================================================");
        $display("          TEST RESULT: PASSED                       ");
        $display("==========================================================================================================");
    end else begin
        $display("==========================================================================================================");
        $display("          TEST RESULT: FAILED                       ");
        $display("          TOTAL ERRORS:     %0d                     ", err);
        $display("==========================================================================================================");
    end
    $finish;
end

endmodule

module mod_golden_cnt (
    input wire clk              ,
    input wire rst_n            ,
    input wire psel             ,
    input wire penable          ,
    input wire pwrite           ,
    input wire [11:0] paddr     ,
    input wire [31:0] pwdata    ,
    input wire cnt_cfg_en       ,
    input wire [63:0] cnt_cfg   ,
    input wire        dbg_mode  ,
    output reg [63:0] cnt
);
    parameter   ADDR_TCR    =   12'h0;
    parameter   ADDR_THCSR  =   12'h1C;
    wire [63:0] cnt_next;
    wire tim_en_wr_set;
    wire tim_en_wr_clr;
    wire halt_wr_set;
    wire halt_wr_clr;
    reg  tim_en;
    reg  halt;
    reg  tim_en_1d;
    reg  halt_1d;

    assign tim_en_wr_set = psel & penable & pwrite & (paddr == ADDR_TCR ) & pwdata[0];
    assign tim_en_wr_clr = psel & penable & pwrite & (paddr == ADDR_TCR ) & ~pwdata[0];
    assign halt_wr_set   = psel & penable & pwrite & (paddr == ADDR_THCSR ) & pwdata[0] & dbg_mode;
    assign halt_wr_clr   = psel & penable & pwrite & (paddr == ADDR_THCSR ) & ~pwdata[0];

    assign cnt_next = cnt_cfg_en        ? cnt_cfg   :
                      tim_en_1d & !halt_1d  ? cnt + 1'b1:
                      cnt               ;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            tim_en <= 1'b0;
        else if( tim_en_wr_clr )
            tim_en <= 1'b0;
        else if( tim_en_wr_set )
            tim_en <= 1'b1;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            halt <= 1'b0;
        else if( halt_wr_clr )
            halt <= 1'b0;
        else if( halt_wr_set )
            halt <= 1'b1;
    end

    always @(posedge clk or negedge rst_n) begin
        if( !rst_n ) begin
            cnt         <= 64'h0        ;
            tim_en_1d   <= 0            ;
            halt_1d     <= 0            ;
        end else begin
            cnt         <= cnt_next;
            tim_en_1d   <= tim_en       ;
            halt_1d     <= halt         ;
        end
    end
endmodule