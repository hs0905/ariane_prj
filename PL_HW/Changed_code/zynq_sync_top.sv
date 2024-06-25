`timescale 1ns / 1ps
import ariane_axi::*;
import RISA_PKG::*;
`include "defines.vh"
module top(
  DDR_addr,
  DDR_ba,
  DDR_cas_n,
  DDR_ck_n,
  DDR_ck_p,
  DDR_cke,
  DDR_cs_n,
  DDR_dm,
  DDR_dq,
  DDR_dqs_n,
  DDR_dqs_p,
  DDR_odt,
  DDR_ras_n,
  DDR_reset_n,
  DDR_we_n,
  FIXED_IO_ddr_vrn,
  FIXED_IO_ddr_vrp,
  FIXED_IO_mio,
  FIXED_IO_ps_clk,
  FIXED_IO_ps_porb,
  FIXED_IO_ps_srstb,
  IO_NAND_CH0_DQ,
  IO_NAND_CH0_DQS_N,
  IO_NAND_CH0_DQS_P,
  IO_NAND_CH1_DQ,
  IO_NAND_CH1_DQS_N,
  IO_NAND_CH1_DQS_P,
  IO_NAND_CH2_DQ,
  IO_NAND_CH2_DQS_N,
  IO_NAND_CH2_DQS_P,
  IO_NAND_CH3_DQ,
  IO_NAND_CH3_DQS_N,
  IO_NAND_CH3_DQS_P,
  IO_NAND_CH4_DQ,
  IO_NAND_CH4_DQS_N,
  IO_NAND_CH4_DQS_P,
  IO_NAND_CH5_DQ,
  IO_NAND_CH5_DQS_N,
  IO_NAND_CH5_DQS_P,
  IO_NAND_CH6_DQ,
  IO_NAND_CH6_DQS_N,
  IO_NAND_CH6_DQS_P,
  IO_NAND_CH7_DQ,
  IO_NAND_CH7_DQS_N,
  IO_NAND_CH7_DQS_P,
  I_NAND_CH0_RB,
  I_NAND_CH1_RB,
  I_NAND_CH2_RB,
  I_NAND_CH3_RB,
  I_NAND_CH4_RB,
  I_NAND_CH5_RB,
  I_NAND_CH6_RB,
  I_NAND_CH7_RB,
  O_DEBUG,
  O_NAND_CH0_ALE,
  O_NAND_CH0_CE,
  O_NAND_CH0_CLE,
  O_NAND_CH0_RE_N,
  O_NAND_CH0_RE_P,
  O_NAND_CH0_WE,
  O_NAND_CH0_WP,
  O_NAND_CH1_ALE,
  O_NAND_CH1_CE,
  O_NAND_CH1_CLE,
  O_NAND_CH1_RE_N,
  O_NAND_CH1_RE_P,
  O_NAND_CH1_WE,
  O_NAND_CH1_WP,
  O_NAND_CH2_ALE,
  O_NAND_CH2_CE,
  O_NAND_CH2_CLE,
  O_NAND_CH2_RE_N,
  O_NAND_CH2_RE_P,
  O_NAND_CH2_WE,
  O_NAND_CH2_WP,
  O_NAND_CH3_ALE,
  O_NAND_CH3_CE,
  O_NAND_CH3_CLE,
  O_NAND_CH3_RE_N,
  O_NAND_CH3_RE_P,
  O_NAND_CH3_WE,
  O_NAND_CH3_WP,
  O_NAND_CH4_ALE,
  O_NAND_CH4_CE,
  O_NAND_CH4_CLE,
  O_NAND_CH4_RE_N,
  O_NAND_CH4_RE_P,
  O_NAND_CH4_WE,
  O_NAND_CH4_WP,
  O_NAND_CH5_ALE,
  O_NAND_CH5_CE,
  O_NAND_CH5_CLE,
  O_NAND_CH5_RE_N,
  O_NAND_CH5_RE_P,
  O_NAND_CH5_WE,
  O_NAND_CH5_WP,
  O_NAND_CH6_ALE,
  O_NAND_CH6_CE,
  O_NAND_CH6_CLE,
  O_NAND_CH6_RE_N,
  O_NAND_CH6_RE_P,
  O_NAND_CH6_WE,
  O_NAND_CH6_WP,
  O_NAND_CH7_ALE,
  O_NAND_CH7_CE,
  O_NAND_CH7_CLE,
  O_NAND_CH7_RE_N,
  O_NAND_CH7_RE_P,
  O_NAND_CH7_WE,
  O_NAND_CH7_WP,
  pcie_perst_n,
  pcie_ref_clk_n,
  pcie_ref_clk_p,
  pcie_rx_n,
  pcie_rx_p,
  pcie_tx_n,
  pcie_tx_p,
  io_switch_button
  );

  inout [14:0]  DDR_addr;
  inout [2:0]   DDR_ba;
  inout         DDR_cas_n;
  inout         DDR_ck_n;
  inout         DDR_ck_p;
  inout         DDR_cke;
  inout         DDR_cs_n;
  inout [3:0]   DDR_dm;
  inout [31:0]  DDR_dq;
  inout [3:0]   DDR_dqs_n;
  inout [3:0]   DDR_dqs_p;
  inout         DDR_odt;
  inout         DDR_ras_n;
  inout         DDR_reset_n;
  inout         DDR_we_n;
  inout         FIXED_IO_ddr_vrn;
  inout         FIXED_IO_ddr_vrp;
  inout [53:0]  FIXED_IO_mio;
  inout         FIXED_IO_ps_clk;
  inout         FIXED_IO_ps_porb;
  inout         FIXED_IO_ps_srstb;
  inout [7:0]   IO_NAND_CH0_DQ;
  inout         IO_NAND_CH0_DQS_N;
  inout         IO_NAND_CH0_DQS_P;
  inout [7:0]   IO_NAND_CH1_DQ;
  inout         IO_NAND_CH1_DQS_N;
  inout         IO_NAND_CH1_DQS_P;
  inout [7:0]   IO_NAND_CH2_DQ;
  inout         IO_NAND_CH2_DQS_N;
  inout         IO_NAND_CH2_DQS_P;
  inout [7:0]   IO_NAND_CH3_DQ;
  inout         IO_NAND_CH3_DQS_N;
  inout         IO_NAND_CH3_DQS_P;
  inout [7:0]   IO_NAND_CH4_DQ;
  inout         IO_NAND_CH4_DQS_N;
  inout         IO_NAND_CH4_DQS_P;
  inout [7:0]   IO_NAND_CH5_DQ;
  inout         IO_NAND_CH5_DQS_N;
  inout         IO_NAND_CH5_DQS_P;
  inout [7:0]   IO_NAND_CH6_DQ;
  inout         IO_NAND_CH6_DQS_N;
  inout         IO_NAND_CH6_DQS_P;
  inout [7:0]   IO_NAND_CH7_DQ;
  inout         IO_NAND_CH7_DQS_N;
  inout         IO_NAND_CH7_DQS_P;
  input [7:0]   I_NAND_CH0_RB;
  input [7:0]   I_NAND_CH1_RB;
  input [7:0]   I_NAND_CH2_RB;
  input [7:0]   I_NAND_CH3_RB;
  input [7:0]   I_NAND_CH4_RB;
  input [7:0]   I_NAND_CH5_RB;
  input [7:0]   I_NAND_CH6_RB;
  input [7:0]   I_NAND_CH7_RB;

  output [31:0] O_DEBUG;
  output        O_NAND_CH0_ALE;
  output [7:0]  O_NAND_CH0_CE;
  output        O_NAND_CH0_CLE;
  output        O_NAND_CH0_RE_N;
  output        O_NAND_CH0_RE_P;
  output        O_NAND_CH0_WE;
  output        O_NAND_CH0_WP;
  output        O_NAND_CH1_ALE;
  output [7:0]  O_NAND_CH1_CE;
  output        O_NAND_CH1_CLE;
  output        O_NAND_CH1_RE_N;
  output        O_NAND_CH1_RE_P;
  output        O_NAND_CH1_WE;
  output        O_NAND_CH1_WP;
  output        O_NAND_CH2_ALE;
  output [7:0]  O_NAND_CH2_CE;
  output        O_NAND_CH2_CLE;
  output        O_NAND_CH2_RE_N;
  output        O_NAND_CH2_RE_P;
  output        O_NAND_CH2_WE;
  output        O_NAND_CH2_WP;
  output        O_NAND_CH3_ALE;
  output [7:0]  O_NAND_CH3_CE;
  output        O_NAND_CH3_CLE;
  output        O_NAND_CH3_RE_N;
  output        O_NAND_CH3_RE_P;
  output        O_NAND_CH3_WE;
  output        O_NAND_CH3_WP;
  output        O_NAND_CH4_ALE;
  output [7:0]  O_NAND_CH4_CE;
  output        O_NAND_CH4_CLE;
  output        O_NAND_CH4_RE_N;
  output        O_NAND_CH4_RE_P;
  output        O_NAND_CH4_WE;
  output        O_NAND_CH4_WP;
  output        O_NAND_CH5_ALE;
  output [7:0]  O_NAND_CH5_CE;
  output        O_NAND_CH5_CLE;
  output        O_NAND_CH5_RE_N;
  output        O_NAND_CH5_RE_P;
  output        O_NAND_CH5_WE;
  output        O_NAND_CH5_WP;
  output        O_NAND_CH6_ALE;
  output [7:0]  O_NAND_CH6_CE;
  output        O_NAND_CH6_CLE;
  output        O_NAND_CH6_RE_N;
  output        O_NAND_CH6_RE_P;
  output        O_NAND_CH6_WE;
  output        O_NAND_CH6_WP;
  output        O_NAND_CH7_ALE;
  output [7:0]  O_NAND_CH7_CE;
  output        O_NAND_CH7_CLE;
  output        O_NAND_CH7_RE_N;
  output        O_NAND_CH7_RE_P;
  output        O_NAND_CH7_WE;
  output        O_NAND_CH7_WP;

  input         pcie_perst_n;
  input         pcie_ref_clk_n;
  input         pcie_ref_clk_p;
  input  [7:0]  pcie_rx_n;
  input  [7:0]  pcie_rx_p;
  output [7:0]  pcie_tx_n;
  output [7:0]  pcie_tx_p;

  input         io_switch_button;

  wire          user_clk;
  wire          user_rstn;
  wire          IRQ_F2P;
  logic         io_switch;
  
  // M_AXI for general purpose
  wire [31:0]   M_AXI_GP1_araddr;
  wire [2:0]    M_AXI_GP1_arprot;
  wire          M_AXI_GP1_arready;
  wire          M_AXI_GP1_arvalid;
  wire [31:0]   M_AXI_GP1_awaddr;
  wire [2:0]    M_AXI_GP1_awprot;
  wire          M_AXI_GP1_awready;
  wire          M_AXI_GP1_awvalid;
  wire          M_AXI_GP1_bready;
  wire [1:0]    M_AXI_GP1_bresp;
  wire          M_AXI_GP1_bvalid;
  wire [31:0]   M_AXI_GP1_rdata;
  wire          M_AXI_GP1_rready;
  wire [1:0]    M_AXI_GP1_rresp;
  wire          M_AXI_GP1_rvalid;
  wire [31:0]   M_AXI_GP1_wdata;
  wire          M_AXI_GP1_wready;
  wire [3:0]    M_AXI_GP1_wstrb;
  wire          M_AXI_GP1_wvalid;
  
  wire [31:0]   S_AXI_HP0_araddr;
  wire [1:0]    S_AXI_HP0_arburst;
  wire [3:0]    S_AXI_HP0_arcache;
  wire [3:0]    S_AXI_HP0_arid;
  wire [7:0]    S_AXI_HP0_arlen;
  wire [0:0]    S_AXI_HP0_arlock;
  wire [2:0]    S_AXI_HP0_arprot;
  wire [3:0]    S_AXI_HP0_arqos;
  wire          S_AXI_HP0_arready;
  wire [2:0]    S_AXI_HP0_arsize;
  wire          S_AXI_HP0_arvalid;
  wire [31:0]   S_AXI_HP0_awaddr;
  wire [1:0]    S_AXI_HP0_awburst;
  wire [3:0]    S_AXI_HP0_awcache;
  wire [3:0]    S_AXI_HP0_awid;
  wire [7:0]    S_AXI_HP0_awlen;
  wire [0:0]    S_AXI_HP0_awlock;
  wire [2:0]    S_AXI_HP0_awprot;
  wire [3:0]    S_AXI_HP0_awqos;
  wire          S_AXI_HP0_awready;
  wire [2:0]    S_AXI_HP0_awsize;
  wire          S_AXI_HP0_awvalid;
  wire [3:0]    S_AXI_HP0_bid;
  wire          S_AXI_HP0_bready;
  wire [1:0]    S_AXI_HP0_bresp;
  wire          S_AXI_HP0_bvalid;
  wire [63:0]   S_AXI_HP0_rdata;
  wire [3:0]    S_AXI_HP0_rid;
  wire          S_AXI_HP0_rlast;
  wire          S_AXI_HP0_rready;
  wire [1:0]    S_AXI_HP0_rresp;
  wire          S_AXI_HP0_rvalid;
  wire [63:0]   S_AXI_HP0_wdata;
  wire          S_AXI_HP0_wlast;
  wire          S_AXI_HP0_wready;
  wire [7:0]    S_AXI_HP0_wstrb;
  wire          S_AXI_HP0_wvalid;
  
  wire [15:0]   S_AXI_HP0_wuser;
  wire [15:0]   S_AXI_HP0_aruser;
  wire [15:0]   S_AXI_HP0_awuser;

  logic         state_idle_pin;
  logic         state_lock_cmd_wire;
  wire          zynq_rstn;

  typedef struct {
  logic         c_valid;
  logic [31:0]  counter;
  logic         io_switch_reg;
} reg_control;

  reg_control reg_ctrl, reg_ctrl_next;

  logic[AXI_LITE_ARG_NUM-1:0][AXI_LITE_WORD_WIDTH-1:0] kernel_engine_arg;
  logic[AXI_LITE_ARG_NUM-1:0][AXI_LITE_WORD_WIDTH-1:0] kernel_engine_status;	

  logic               kernel_command_reg_new;
  logic [7:0]         kernel_command_reg;
  logic [31:0]        counter;
  logic               Inner_counter_reset_wire;
  logic               Inner_counter_start_wire;

  ariane_axi::req_t   axi_req_o;  // (ariane -> zynq) 
  ariane_axi::resp_t  axi_resp_i; // (zynq -> ariane)

  logic               HP_AXI_reset;
  CommandDataPort     commanddataport;
  StatePort           stateport;
  axi_lite_output     AXI_LITE_output;    
  axi_lite_input      AXI_LITE_input;

  always_comb begin
  reg_ctrl_next = reg_ctrl;
  //read values for GP1
  kernel_engine_status[0] = kernel_engine_arg[0];
  kernel_engine_status[1] = stateport.state0;
  kernel_engine_status[2] = stateport.state1;
  kernel_engine_status[3] = stateport.state2;
  kernel_engine_status[4] = stateport.state3;
  kernel_engine_status[5] = 0;
  kernel_engine_status[6] = 0;
  kernel_engine_status[7] = 0;
  
  commanddataport.valid   = 0;
  commanddataport.command = kernel_engine_arg[1];
  commanddataport.data0   = kernel_engine_arg[2];
  commanddataport.data1   = kernel_engine_arg[3];
  counter                 = kernel_engine_arg[4];
  if(kernel_command_reg_new) begin
    reg_ctrl_next.counter = counter;
    reg_ctrl_next.c_valid = 1;
  end   
  if(reg_ctrl.c_valid == 1) begin
      reg_ctrl_next.counter = reg_ctrl.counter - 1;
      if(reg_ctrl.counter == 0) begin
          reg_ctrl_next.c_valid = 0;
          commanddataport.valid = 1;
      end
  end
  reg_ctrl_next.io_switch_reg = (io_switch | io_switch_button);
end

always_ff@(posedge user_clk) begin
  if(!user_rstn) begin
    reg_ctrl.c_valid        <= 0;
    reg_ctrl.counter        <= 0;
    reg_ctrl.io_switch_reg  <= 0;
  end else begin
    reg_ctrl <= reg_ctrl_next;
  end
end

  OpenSSD2_wrapper OpenSSD2_wrapper_i
  (
    .DDR_addr         (DDR_addr),
    .DDR_ba           (DDR_ba),
    .DDR_cas_n        (DDR_cas_n),
    .DDR_ck_n         (DDR_ck_n),
    .DDR_ck_p         (DDR_ck_p),
    .DDR_cke          (DDR_cke),
    .DDR_cs_n         (DDR_cs_n),
    .DDR_dm           (DDR_dm),
    .DDR_dq           (DDR_dq),
    .DDR_dqs_n        (DDR_dqs_n),
    .DDR_dqs_p        (DDR_dqs_p),
    .DDR_odt          (DDR_odt),
    .DDR_ras_n        (DDR_ras_n),
    .DDR_reset_n      (DDR_reset_n),
    .DDR_we_n         (DDR_we_n),
    .FIXED_IO_ddr_vrn (FIXED_IO_ddr_vrn),
    .FIXED_IO_ddr_vrp (FIXED_IO_ddr_vrp),
    .FIXED_IO_mio     (FIXED_IO_mio),
    .FIXED_IO_ps_clk  (FIXED_IO_ps_clk),
    .FIXED_IO_ps_porb (FIXED_IO_ps_porb),
    .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb), 
    .IO_NAND_CH0_DQ   (IO_NAND_CH0_DQ),
    .IO_NAND_CH0_DQS_N(IO_NAND_CH0_DQS_N),
    .IO_NAND_CH0_DQS_P(IO_NAND_CH0_DQS_P),
    .IO_NAND_CH1_DQ   (IO_NAND_CH1_DQ),
    .IO_NAND_CH1_DQS_N(IO_NAND_CH1_DQS_N),
    .IO_NAND_CH1_DQS_P(IO_NAND_CH1_DQS_P),
    .IO_NAND_CH2_DQ   (IO_NAND_CH2_DQ),
    .IO_NAND_CH2_DQS_N(IO_NAND_CH2_DQS_N),
    .IO_NAND_CH2_DQS_P(IO_NAND_CH2_DQS_P),
    .IO_NAND_CH3_DQ   (IO_NAND_CH3_DQ),
    .IO_NAND_CH3_DQS_N(IO_NAND_CH3_DQS_N),
    .IO_NAND_CH3_DQS_P(IO_NAND_CH3_DQS_P),
    .IO_NAND_CH4_DQ   (IO_NAND_CH4_DQ),
    .IO_NAND_CH4_DQS_N(IO_NAND_CH4_DQS_N),
    .IO_NAND_CH4_DQS_P(IO_NAND_CH4_DQS_P),
    .IO_NAND_CH5_DQ   (IO_NAND_CH5_DQ),
    .IO_NAND_CH5_DQS_N(IO_NAND_CH5_DQS_N),
    .IO_NAND_CH5_DQS_P(IO_NAND_CH5_DQS_P),
    .IO_NAND_CH6_DQ   (IO_NAND_CH6_DQ),
    .IO_NAND_CH6_DQS_N(IO_NAND_CH6_DQS_N),
    .IO_NAND_CH6_DQS_P(IO_NAND_CH6_DQS_P),
    .IO_NAND_CH7_DQ   (IO_NAND_CH7_DQ),
    .IO_NAND_CH7_DQS_N(IO_NAND_CH7_DQS_N),
    .IO_NAND_CH7_DQS_P(IO_NAND_CH7_DQS_P),
    .I_NAND_CH0_RB    (I_NAND_CH0_RB),
    .I_NAND_CH1_RB    (I_NAND_CH1_RB),
    .I_NAND_CH2_RB    (I_NAND_CH2_RB),
    .I_NAND_CH3_RB    (I_NAND_CH3_RB),
    .I_NAND_CH4_RB    (I_NAND_CH4_RB),
    .I_NAND_CH5_RB    (I_NAND_CH5_RB),
    .I_NAND_CH6_RB    (I_NAND_CH6_RB),
    .I_NAND_CH7_RB    (I_NAND_CH7_RB),
    .O_DEBUG          (O_DEBUG),
    .O_NAND_CH0_ALE   (O_NAND_CH0_ALE),
    .O_NAND_CH0_CE    (O_NAND_CH0_CE),
    .O_NAND_CH0_CLE   (O_NAND_CH0_CLE),
    .O_NAND_CH0_RE_N  (O_NAND_CH0_RE_N),
    .O_NAND_CH0_RE_P  (O_NAND_CH0_RE_P),
    .O_NAND_CH0_WE    (O_NAND_CH0_WE),
    .O_NAND_CH0_WP    (O_NAND_CH0_WP),
    .O_NAND_CH1_ALE   (O_NAND_CH1_ALE),
    .O_NAND_CH1_CE    (O_NAND_CH1_CE),
    .O_NAND_CH1_CLE   (O_NAND_CH1_CLE),
    .O_NAND_CH1_RE_N  (O_NAND_CH1_RE_N),
    .O_NAND_CH1_RE_P  (O_NAND_CH1_RE_P),
    .O_NAND_CH1_WE    (O_NAND_CH1_WE),
    .O_NAND_CH1_WP    (O_NAND_CH1_WP),
    .O_NAND_CH2_ALE   (O_NAND_CH2_ALE),
    .O_NAND_CH2_CE    (O_NAND_CH2_CE),
    .O_NAND_CH2_CLE   (O_NAND_CH2_CLE),
    .O_NAND_CH2_RE_N  (O_NAND_CH2_RE_N),
    .O_NAND_CH2_RE_P  (O_NAND_CH2_RE_P),
    .O_NAND_CH2_WE    (O_NAND_CH2_WE),
    .O_NAND_CH2_WP    (O_NAND_CH2_WP),
    .O_NAND_CH3_ALE   (O_NAND_CH3_ALE),
    .O_NAND_CH3_CE    (O_NAND_CH3_CE),
    .O_NAND_CH3_CLE   (O_NAND_CH3_CLE),
    .O_NAND_CH3_RE_N  (O_NAND_CH3_RE_N),
    .O_NAND_CH3_RE_P  (O_NAND_CH3_RE_P),
    .O_NAND_CH3_WE    (O_NAND_CH3_WE),
    .O_NAND_CH3_WP    (O_NAND_CH3_WP),
    .O_NAND_CH4_ALE   (O_NAND_CH4_ALE),
    .O_NAND_CH4_CE    (O_NAND_CH4_CE),
    .O_NAND_CH4_CLE   (O_NAND_CH4_CLE),
    .O_NAND_CH4_RE_N  (O_NAND_CH4_RE_N),
    .O_NAND_CH4_RE_P  (O_NAND_CH4_RE_P),
    .O_NAND_CH4_WE    (O_NAND_CH4_WE),
    .O_NAND_CH4_WP    (O_NAND_CH4_WP),
    .O_NAND_CH5_ALE   (O_NAND_CH5_ALE),
    .O_NAND_CH5_CE    (O_NAND_CH5_CE),
    .O_NAND_CH5_CLE   (O_NAND_CH5_CLE),
    .O_NAND_CH5_RE_N  (O_NAND_CH5_RE_N),
    .O_NAND_CH5_RE_P  (O_NAND_CH5_RE_P),
    .O_NAND_CH5_WE    (O_NAND_CH5_WE),
    .O_NAND_CH5_WP    (O_NAND_CH5_WP),
    .O_NAND_CH6_ALE   (O_NAND_CH6_ALE),
    .O_NAND_CH6_CE    (O_NAND_CH6_CE),
    .O_NAND_CH6_CLE   (O_NAND_CH6_CLE),
    .O_NAND_CH6_RE_N  (O_NAND_CH6_RE_N),
    .O_NAND_CH6_RE_P  (O_NAND_CH6_RE_P),
    .O_NAND_CH6_WE    (O_NAND_CH6_WE),
    .O_NAND_CH6_WP    (O_NAND_CH6_WP),
    .O_NAND_CH7_ALE   (O_NAND_CH7_ALE),
    .O_NAND_CH7_CE    (O_NAND_CH7_CE),
    .O_NAND_CH7_CLE   (O_NAND_CH7_CLE),
    .O_NAND_CH7_RE_N  (O_NAND_CH7_RE_N),
    .O_NAND_CH7_RE_P  (O_NAND_CH7_RE_P),
    .O_NAND_CH7_WE    (O_NAND_CH7_WE),
    .O_NAND_CH7_WP    (O_NAND_CH7_WP),
    .M_AXI_GP1_araddr (M_AXI_GP1_araddr ),
    .M_AXI_GP1_arprot (M_AXI_GP1_arprot ),
    .M_AXI_GP1_arready(M_AXI_GP1_arready),
    .M_AXI_GP1_arvalid(M_AXI_GP1_arvalid),
    .M_AXI_GP1_awaddr (M_AXI_GP1_awaddr ),
    .M_AXI_GP1_awprot (M_AXI_GP1_awprot ),
    .M_AXI_GP1_awready(M_AXI_GP1_awready),
    .M_AXI_GP1_awvalid(M_AXI_GP1_awvalid),
    .M_AXI_GP1_bready (M_AXI_GP1_bready ),
    .M_AXI_GP1_bresp  (M_AXI_GP1_bresp  ),
    .M_AXI_GP1_bvalid (M_AXI_GP1_bvalid ),
    .M_AXI_GP1_rdata  (M_AXI_GP1_rdata  ),
    .M_AXI_GP1_rready (M_AXI_GP1_rready ),
    .M_AXI_GP1_rresp  (M_AXI_GP1_rresp  ),
    .M_AXI_GP1_rvalid (M_AXI_GP1_rvalid ),
    .M_AXI_GP1_wdata  (M_AXI_GP1_wdata  ),
    .M_AXI_GP1_wready (M_AXI_GP1_wready ),
    .M_AXI_GP1_wstrb  (M_AXI_GP1_wstrb  ),
    .M_AXI_GP1_wvalid (M_AXI_GP1_wvalid ),
    .S_AXI_HP0_araddr (axi_req_o.ar.addr),
    .S_AXI_HP0_arburst(axi_req_o.ar.burst),
    .S_AXI_HP0_arcache(axi_req_o.ar.cache),
    .S_AXI_HP0_arlen  (axi_req_o.ar.len),
    .S_AXI_HP0_arlock (axi_req_o.ar.lock),
    .S_AXI_HP0_arprot (axi_req_o.ar.prot),
    .S_AXI_HP0_arqos  (axi_req_o.ar.qos),
    .S_AXI_HP0_arready(axi_req_o.ar.ready),
    //.S_AXI_HP0_arregion(S_AXI_HP0_arregion),
    .S_AXI_HP0_arsize (S_AXI_HP0_arsize),
    .S_AXI_HP0_arvalid(S_AXI_HP0_arvalid),
    .S_AXI_HP0_awaddr (S_AXI_HP0_awaddr),
    .S_AXI_HP0_awburst(S_AXI_HP0_awburst),
    .S_AXI_HP0_awcache(S_AXI_HP0_awcache),
    .S_AXI_HP0_awlen  (S_AXI_HP0_awlen),
    .S_AXI_HP0_awlock (S_AXI_HP0_awlock),
    .S_AXI_HP0_awprot (S_AXI_HP0_awprot),
    .S_AXI_HP0_awqos  (S_AXI_HP0_awqos),
    .S_AXI_HP0_awready(S_AXI_HP0_awready),
    //.S_AXI_HP0_awregion(S_AXI_HP0_awregion),
    .S_AXI_HP0_awsize (S_AXI_HP0_awsize),
    .S_AXI_HP0_awvalid(S_AXI_HP0_awvalid),
    .S_AXI_HP0_bready (S_AXI_HP0_bready),
    .S_AXI_HP0_bresp  (S_AXI_HP0_bresp),
    .S_AXI_HP0_bvalid (S_AXI_HP0_bvalid),
    .S_AXI_HP0_rdata  (S_AXI_HP0_rdata),
    .S_AXI_HP0_rlast  (S_AXI_HP0_rlast),
    .S_AXI_HP0_rready (S_AXI_HP0_rready),
    .S_AXI_HP0_rresp  (S_AXI_HP0_rresp),
    .S_AXI_HP0_rvalid (S_AXI_HP0_rvalid),
    .S_AXI_HP0_wdata  (S_AXI_HP0_wdata),
    .S_AXI_HP0_wlast  (S_AXI_HP0_wlast),
    .S_AXI_HP0_wready (S_AXI_HP0_wready),
    .S_AXI_HP0_wstrb  (S_AXI_HP0_wstrb),
    .S_AXI_HP0_wvalid (S_AXI_HP0_wvalid),
    .S_AXI_HP0_rid    (S_AXI_HP0_rid),
    .S_AXI_HP0_bid    (S_AXI_HP0_bid),
    .S_AXI_HP0_awid   (S_AXI_HP0_awid),
    .S_AXI_HP0_arid   (S_AXI_HP0_arid),
    .pcie_perst_n     (pcie_perst_n),
    .pcie_ref_clk_n   (pcie_ref_clk_n),
    .pcie_ref_clk_p   (pcie_ref_clk_p),
    .pcie_rx_n        (pcie_rx_n),
    .pcie_rx_p        (pcie_rx_p),
    .pcie_tx_n        (pcie_tx_n),
    .pcie_tx_p        (pcie_tx_p),
    .user_clk         (user_clk),
    .user_rstn        (user_rstn),
    .IRQ_F2P          (IRQ_F2P)
  );
    
  ariane ariane (
    .clk_i            (user_clk),
    .rst_ni           (user_rstn),
    .io_switch        (reg_ctrl.io_switch_reg),
    .boot_addr_i      (32'h0020_0000),  
    .hart_id_i        (0),              
    // Interrupt inputs
    .irq_i            ({1'b0,IRQ_F2P}), 
    .ipi_i            (0),              
    .time_irq_i       (0),              
    .debug_req_i      (0),              
    .axi_req_o        (axi_req_o),
    .axi_resp_i       (axi_resp_i),
    
    .stateport        (stateport),
    .commanddataport  (commanddataport),
    .state_lock_cmd_i   (state_lock_cmd_wire)
  );

  




  AXI_reg_intf axi_reg_intf (
  .clk                    (user_clk),
  .rstn                   (user_rstn),
  .AXI_LITE_output        (AXI_LITE_output),
  .AXI_LITE_input         (AXI_LITE_input),
  .kernel_command         (kernel_command_reg),
  .kernel_command_new     (kernel_command_reg_new),
  .kernel_engine_arg      (kernel_engine_arg),
  .kernel_engine_status   (kernel_engine_status),
  .Inner_counter_reset    (Inner_counter_reset_wire),
  .Inner_counter_start    (Inner_counter_start_wire),
  .state_lock_cmd_o       (state_lock_cmd_wire)
  );




  auto_reset_timer auto_reset_timer(
    .clk                (user_clk),
    .rstn               (user_rstn), // logic ?? ??
    .Inner_counter_reset(Inner_counter_reset_wire),
    .Inner_counter_start(Inner_counter_start_wire),
    .System_reset       (io_switch)
  );


  assign S_AXI_HP0_araddr         =  axi_req_o.ar.addr         ;
  assign S_AXI_HP0_arburst        =  axi_req_o.ar.burst        ;
  assign S_AXI_HP0_arcache        =  axi_req_o.ar.cache        ;
  assign S_AXI_HP0_arid           =  axi_req_o.ar.id           ;
  assign S_AXI_HP0_arlen          =  axi_req_o.ar.len          ;
  assign S_AXI_HP0_arlock         =  axi_req_o.ar.lock         ;
  assign S_AXI_HP0_arprot         =  axi_req_o.ar.prot         ;
  assign S_AXI_HP0_arqos          =  axi_req_o.ar.qos          ;
  assign S_AXI_HP0_arsize         =  axi_req_o.ar.size         ;
  assign S_AXI_HP0_arvalid        =  axi_req_o.ar_valid        ;
  assign S_AXI_HP0_aruser         =  axi_req_o.ar.user         ;

  assign S_AXI_HP0_awaddr         =  axi_req_o.aw.addr         ;
  assign S_AXI_HP0_awcache        =  axi_req_o.aw.cache        ;
  assign S_AXI_HP0_awburst        =  axi_req_o.aw.burst        ;
  assign S_AXI_HP0_awid           =  axi_req_o.aw.id           ;
  assign S_AXI_HP0_awlen          =  axi_req_o.aw.len          ;
  assign S_AXI_HP0_awlock         =  axi_req_o.aw.lock         ;
  assign S_AXI_HP0_awprot         =  axi_req_o.aw.prot         ;
  assign S_AXI_HP0_awqos          =  axi_req_o.aw.qos          ;
  assign S_AXI_HP0_awsize         =  axi_req_o.aw.size         ;
  assign S_AXI_HP0_awvalid        =  axi_req_o.aw_valid        ;
  assign S_AXI_HP0_awuser         =  axi_req_o.aw.user         ;

  assign S_AXI_HP0_bready         =  axi_req_o.b_ready         ;
  assign S_AXI_HP0_rready         =  axi_req_o.r_ready         ;
  assign S_AXI_HP0_wdata          =  axi_req_o.w.data          ;
  assign S_AXI_HP0_wlast          =  axi_req_o.w.last          ;
  assign S_AXI_HP0_wstrb          =  axi_req_o.w.strb          ;
  assign S_AXI_HP0_wuser          =  axi_req_o.w.user          ;
  assign S_AXI_HP0_wvalid         =  axi_req_o.w_valid         ;

  assign axi_resp_i.ar_ready      = S_AXI_HP0_arready        ;
  assign axi_resp_i.aw_ready      = S_AXI_HP0_awready        ;
  assign axi_resp_i.w_ready       = S_AXI_HP0_wready         ;

  assign axi_resp_i.b.id          = S_AXI_HP0_bid            ;
  assign axi_resp_i.b.resp        = S_AXI_HP0_bresp          ;
  assign axi_resp_i.b.user        = 0                        ;
  assign axi_resp_i.b_valid       = S_AXI_HP0_bvalid         ;

  assign axi_resp_i.r.data        = S_AXI_HP0_rdata          ;
  assign axi_resp_i.r.id          = S_AXI_HP0_rid            ;
  assign axi_resp_i.r.last        = S_AXI_HP0_rlast          ;   
  assign axi_resp_i.r.resp        = S_AXI_HP0_rresp          ;
  assign axi_resp_i.r_valid       = S_AXI_HP0_rvalid         ;
  assign axi_resp_i.r.user        = 0                        ;
              
  assign M_AXI_GP1_arready        = AXI_LITE_input.arready;
  assign M_AXI_GP1_awready        = AXI_LITE_input.awready;
  assign M_AXI_GP1_bresp          = AXI_LITE_input.bresp  ;
  assign M_AXI_GP1_bvalid         = AXI_LITE_input.bvalid ;
  assign M_AXI_GP1_rdata          = AXI_LITE_input.rdata  ;
  assign M_AXI_GP1_rresp          = AXI_LITE_input.rresp  ;
  assign M_AXI_GP1_rvalid         = AXI_LITE_input.rvalid ;
  assign M_AXI_GP1_wready         = AXI_LITE_input.wready ;

  assign AXI_LITE_output.araddr   = M_AXI_GP1_araddr ;
  assign AXI_LITE_output.arvalid  = M_AXI_GP1_arvalid;
  assign AXI_LITE_output.awaddr   = M_AXI_GP1_awaddr ;
  assign AXI_LITE_output.awvalid  = M_AXI_GP1_awvalid;
  assign AXI_LITE_output.bready   = M_AXI_GP1_bready ;
  assign AXI_LITE_output.rready   = M_AXI_GP1_rready ;
  assign AXI_LITE_output.wdata    = M_AXI_GP1_wdata  ;
  assign AXI_LITE_output.wstrb    = M_AXI_GP1_wstrb  ;
  assign AXI_LITE_output.wvalid   = M_AXI_GP1_wvalid ; 
endmodule
