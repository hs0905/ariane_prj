import ariane_axi::*;
import RISA_PKG::*;

module AXI_LITE_INTF(
  input   logic clk,
  input   logic rst_n,
  input   logic[AXI_LITE_ARG_NUM-1:0][AXI_LITE_WORD_WIDTH-1:0]	kernel_engine_status,
  input   logic                                                 state_idle_pin,
  input   axi_lite_output                                       AXI_LITE_output,

  output  axi_lite_input                                        AXI_LITE_input,
  output  logic [7:0]	                                          kernel_command,
  output  logic	                                                kernel_command_new,
  output  logic[AXI_LITE_ARG_NUM-1:0][AXI_LITE_WORD_WIDTH-1:0]	kernel_engine_arg,

  output logic                                                  Inner_counter_reset,
  output logic                                                  Inner_counter_start
);

  typedef struct {
    logic arready;
    logic rvalid;
    logic awready;
    logic wready;
    logic waddr_received;
    logic wdata_received;
    logic raddr_recieved;
    logic rdata_prepared;
    logic bvalid;

    logic kernel_command_new;

    logic [$clog2(AXI_LITE_ARG_NUM)-1:0]                  write_reg_idx;
    logic [AXI_LITE_WORD_WIDTH-1:0]                       write_reg_data;
    logic [$clog2(AXI_LITE_ARG_NUM)-1:0]                  read_reg_idx;
    logic [AXI_LITE_WORD_WIDTH-1:0]                       read_reg_data;
    
    logic [AXI_LITE_ARG_NUM-1:0][AXI_LITE_WORD_WIDTH-1:0] kregs;

    logic                                                 counter_reset;
    logic                                                 counter_start;
  } reg_control;

  reg_control reg_ctrl, reg_ctrl_next;

  localparam REG_ADDR_IDX_LOW       = 2;    // $clog2(AXI_LITE_WORD_WIDTH/8) ;//3
  localparam REG_ADDR_IDX_HI        = 7;    //REG_ADDR_IDX_LOW + $clog2(AXI_LITE_ARG_NUM); //3+5 = 8

  localparam BASE_ADDR              = 32'h43C80000; // M_AXI_GP1 base address
  localparam COUNTER_RESET_OFFSET   = 32'h14;       // New register offset address
  localparam COUNTER_START_OFFSET   = 32'h18;       // New register offset address
  localparam ARIANE_STATE_OFFSET    = 32'h1C;       // New register offset address  

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg_ctrl.kregs[0] <= 32'hDEADBEEF;
        reg_ctrl.arready <= 1;
        reg_ctrl.rvalid <= 0;
        reg_ctrl.awready <= 1;
        reg_ctrl.wready <= 1;
        reg_ctrl.waddr_received <= 0;
        reg_ctrl.wdata_received <= 0;
        reg_ctrl.raddr_recieved <= 0;
        reg_ctrl.rdata_prepared <= 0;
        reg_ctrl.bvalid <= 0;
        reg_ctrl.kernel_command_new <= 0;
        reg_ctrl.counter_reset <= 0;
        reg_ctrl.counter_start <= 0;
    end else begin    
        reg_ctrl <= reg_ctrl_next;
    end
end
  always_comb begin
    reg_ctrl_next = reg_ctrl;
    
    if(reg_ctrl.arready) begin
      if(AXI_LITE_output.arvalid) begin
        reg_ctrl_next.arready         = 1'b0; // Acknowledge the address phase
        reg_ctrl_next.rvalid          = 1'b1; // Prepare to send data back
        reg_ctrl_next.read_reg_idx    = AXI_LITE_output.araddr[REG_ADDR_IDX_HI:REG_ADDR_IDX_LOW];
        reg_ctrl_next.raddr_recieved  = 1'b1;
      end
    end

    if(reg_ctrl.raddr_recieved) begin
      reg_ctrl_next.raddr_recieved = 1'b0;
      if(reg_ctrl.read_reg_idx == 7) begin
        reg_ctrl_next.read_reg_data = state_idle_pin;
      end else begin
        reg_ctrl_next.read_reg_data = kernel_engine_status[reg_ctrl.read_reg_idx];
      end
      reg_ctrl_next.rdata_prepared = 1'b1;
    end

    if(reg_ctrl.rvalid && reg_ctrl.rdata_prepared) begin
      if(AXI_LITE_output.rready) begin
        reg_ctrl_next.rvalid  = 1'b0;  // read valid 신호를 끈다.
        reg_ctrl_next.arready = 1'b1; // 다음 address를 받을 준비가 되었음을 알림
      end
    end

    if(reg_ctrl.awready) begin
      if(AXI_LITE_output.awvalid) begin
        reg_ctrl_next.awready         = 1'b0; // Acknowledge the address phase
        reg_ctrl_next.waddr_received  = 1'b1; // Address received
        reg_ctrl_next.write_reg_idx   = AXI_LITE_output.awaddr[REG_ADDR_IDX_HI:REG_ADDR_IDX_LOW];
      end
    end

    if(reg_ctrl.wready) begin
      if(AXI_LITE_output.wvalid) begin
        reg_ctrl_next.wready = 1'b0; // Acknowledge the write data phase
        reg_ctrl_next.wdata_received = 1'b1; // Data received
        reg_ctrl_next.write_reg_data = AXI_LITE_output.wdata;
      end
    end

    if(reg_ctrl.waddr_received && reg_ctrl.wdata_received) begin
      if(reg_ctrl_next.write_reg_idx == 5) begin
        reg_ctrl_next.counter_reset = reg_ctrl.write_reg_data;
      end else if(reg_ctrl.write_reg_idx == 6) begin
        reg_ctrl_next.counter_start = reg_ctrl.write_reg_data;
      end else begin
      reg_ctrl_next.kregs[reg_ctrl.write_reg_idx] = reg_ctrl.write_reg_data;
      end
      reg_ctrl_next.waddr_received = 1'b0;
      reg_ctrl_next.wdata_received = 1'b0;
      if(reg_ctrl.write_reg_idx == 0) begin
        reg_ctrl_next.kernel_command_new = 1;
      end
    end

    if(reg_ctrl.kernel_command_new) begin
      reg_ctrl_next.kernel_command_new = 0;
    end

    if (reg_ctrl.bvalid && AXI_LITE_output.bready) begin // 수정된 부분
      reg_ctrl_next.bvalid = 1'b0;
      reg_ctrl_next.awready = 1'b1;
      reg_ctrl_next.wready = 1'b1;
    end
  end

assign AXI_LITE_input.arready = reg_ctrl.arready;
assign AXI_LITE_input.awready = reg_ctrl.awready;
assign AXI_LITE_input.bresp   = 0;
assign AXI_LITE_input.bvalid  = reg_ctrl.bvalid;
assign AXI_LITE_input.rdata   = reg_ctrl.read_reg_data;
assign AXI_LITE_input.rresp   = 0;
assign AXI_LITE_input.rvalid  = reg_ctrl.rvalid;
assign AXI_LITE_input.wready  = reg_ctrl.wready;

assign kernel_engine_arg      = reg_ctrl.kregs;
assign kernel_command         = reg_ctrl.kregs[0];
assign kernel_command_new     = reg_ctrl.kernel_command_new;

assign Inner_counter_reset    = reg_ctrl.counter_reset;
assign Inner_counter_start    = reg_ctrl.counter_start;

endmodule