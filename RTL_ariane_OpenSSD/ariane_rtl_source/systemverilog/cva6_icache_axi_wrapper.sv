// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Author: Nils Wistoff <nwistoff@iis.ee.ethz.ch>, ETH Zurich
// Date: 07.09.2020
// Description: wrapper module to connect the L1I$ to a 64bit AXI bus.
//

module cva6_icache_axi_wrapper import ariane_pkg::*; import wt_cache_pkg::*; #(
  parameter ariane_cfg_t ArianeCfg = ArianeDefaultConfig  // contains cacheable regions
) (
  input  logic              clk_i,
  input  logic              rst_ni,
  input riscv::priv_lvl_t   priv_lvl_i,

  input  logic              flush_i,     
  input  logic              en_i,        
  output logic              miss_o,      
  // address translation requests
  input  icache_areq_i_t    areq_i,
  output icache_areq_o_t    areq_o,
  // data requests
  input  icache_dreq_i_t    dreq_i,
  output icache_dreq_o_t    dreq_o,
  // AXI refill port
  output ariane_axi::req_t  axi_req_o,
  input  ariane_axi::resp_t axi_resp_i
);

  localparam AxiNumWords = (ICACHE_LINE_WIDTH/64) * (ICACHE_LINE_WIDTH  > DCACHE_LINE_WIDTH)  +
                           (DCACHE_LINE_WIDTH/64) * (ICACHE_LINE_WIDTH <= DCACHE_LINE_WIDTH) ;

  logic                                  icache_mem_rtrn_vld;   // valid signal for the icache refill
  icache_rtrn_t                          icache_mem_rtrn;       // refill data
  logic                                  icache_mem_data_req;   // request signal for the icache refill
  logic                                  icache_mem_data_ack;   // acknowledge signal for the icache refill
  icache_req_t                           icache_mem_data;       // request data for the icache refill

  logic                                  axi_rd_req;            // request signal for the AXI read
  logic                                  axi_rd_gnt;            // grant signal for the AXI read
  logic [63:0]                           axi_rd_addr;           // address signal for the AXI read
  logic [$clog2(AxiNumWords)-1:0]        axi_rd_blen;           // burst length signal for the AXI read
  logic [1:0]                            axi_rd_size;           // size signal for the AXI read
  logic [$size(axi_resp_i.r.id)-1:0]     axi_rd_id_in;          // id signal for the AXI read
  logic                                  axi_rd_rdy;            // ready signal for the AXI read
  logic                                  axi_rd_lock;           // lock signal for the AXI read
  logic                                  axi_rd_last;           // last signal for the AXI read
  logic                                  axi_rd_valid;          // valid signal for the AXI read
  logic [63:0]                           axi_rd_data;           // data signal for the AXI read
  logic [$size(axi_resp_i.r.id)-1:0]     axi_rd_id_out;         // id signal for the AXI read
  logic                                  axi_rd_exokay;         // exclusive okay signal for the AXI read

  logic                                  req_valid_d, req_valid_q;
  icache_req_t                           req_data_d,  req_data_q;
  logic                                  first_d,     first_q;
  logic [ICACHE_LINE_WIDTH/64-1:0][63:0] rd_shift_d,  rd_shift_q;

  assign req_valid_d           = ~axi_rd_gnt & (icache_mem_data_req | req_valid_q);           // only request if we have no pending request
  assign req_data_d            = (icache_mem_data_req) ? icache_mem_data : req_data_q;        // if we have a refill request, use the refill data
  assign axi_rd_req            = icache_mem_data_req | req_valid_q;                           // request if we have a refill request or a pending request
  assign axi_rd_addr           = {{64-riscv::PLEN{1'b0}}, req_data_d.paddr};
  assign axi_rd_blen           = (req_data_d.nc) ? '0 : ariane_pkg::ICACHE_LINE_WIDTH/64-1;
  assign axi_rd_size           = 2'b11; 
  assign axi_rd_id_in          = req_data_d.tid;
  assign axi_rd_rdy            = 1'b1;                                                        // always ready
  assign axi_rd_lock           = 1'b0;                                                        // no locking
  assign icache_mem_data_ack   = icache_mem_data_req;                                         // acknowledge the refill request
  assign icache_mem_rtrn_vld   = axi_rd_valid & axi_rd_last;                                  // valid if we have a valid AXI response and it is the last word
  assign icache_mem_rtrn.data  = rd_shift_d;                                                  // data is the shift register
  assign icache_mem_rtrn.tid   = req_data_q.tid;                                              // transaction id is the same as the request
  assign icache_mem_rtrn.rtype = wt_cache_pkg::ICACHE_IFILL_ACK;                              // refill type is an instruction fill
  assign icache_mem_rtrn.inv   = '0;

  // -------
  // I-Cache
  // -------
  cva6_icache #(
    // use ID 0 for icache reads
    .RdTxId             ( 0             ),
    .ArianeCfg          ( ArianeCfg     )
  ) i_cva6_icache (
    .clk_i              ( clk_i               ),
    .rst_ni             ( rst_ni              ),
    .flush_i            ( flush_i             ),
    .en_i               ( en_i                ),
    .miss_o             ( miss_o              ),
    .areq_i             ( areq_i              ),
    .areq_o             ( areq_o              ),
    .dreq_i             ( dreq_i              ),
    .dreq_o             ( dreq_o              ),
    .mem_rtrn_vld_i     ( icache_mem_rtrn_vld ),
    .mem_rtrn_i         ( icache_mem_rtrn     ),
    .mem_data_req_o     ( icache_mem_data_req ),
    .mem_data_ack_i     ( icache_mem_data_ack ),
    .mem_data_o         ( icache_mem_data     )
  );

  // --------
  // AXI shim
  // --------
    axi_shim #(
    .AxiNumWords     ( AxiNumWords            ),
    .AxiIdWidth      ( $size(axi_resp_i.r.id) )
  ) i_axi_shim (
    .clk_i           ( clk_i             ),
    .rst_ni          ( rst_ni            ),
    .rd_req_i        ( axi_rd_req        ),
    .rd_gnt_o        ( axi_rd_gnt        ),
    .rd_addr_i       ( axi_rd_addr       ),
    .rd_blen_i       ( axi_rd_blen       ),
    .rd_size_i       ( axi_rd_size       ),
    .rd_id_i         ( axi_rd_id_in      ),
    .rd_rdy_i        ( axi_rd_rdy        ),
    .rd_lock_i       ( axi_rd_lock       ),
    .rd_last_o       ( axi_rd_last       ),
    .rd_valid_o      ( axi_rd_valid      ),
    .rd_data_o       ( axi_rd_data       ),
    .rd_id_o         ( axi_rd_id_out     ),
    .rd_exokay_o     ( axi_rd_exokay     ),
    .wr_req_i        ( '0                ),
    .wr_gnt_o        (                   ),
    .wr_addr_i       ( '0                ),
    .wr_data_i       ( '0                ),
    .wr_be_i         ( '0                ),
    .wr_blen_i       ( '0                ),
    .wr_size_i       ( '0                ),
    .wr_id_i         ( '0                ),
    .wr_lock_i       ( '0                ),
    .wr_atop_i       ( '0                ),
    .wr_rdy_i        ( '0                ),
    .wr_valid_o      (                   ),
    .wr_id_o         (                   ),
    .wr_exokay_o     (                   ),
    .axi_req_o       ( axi_req_o         ),
    .axi_resp_i      ( axi_resp_i        )
  );

  // Buffer burst data in shift register
  always_comb begin : p_axi_rtrn_shift
    first_d    = first_q;
    rd_shift_d = rd_shift_q;

    if (axi_rd_valid) begin
      first_d    = axi_rd_last;
      rd_shift_d = {axi_rd_data, rd_shift_q[ICACHE_LINE_WIDTH/64-1:1]};

      // If this is a single word transaction, we need to make sure that word is placed at offset 0
      if (first_q) begin
        rd_shift_d[0] = axi_rd_data;
      end
    end
  end

  // Registers
  always_ff @(posedge clk_i or negedge rst_ni) begin : p_rd_buf
    if (!rst_ni) begin
      req_valid_q <= 1'b0;
      req_data_q  <= '0;
      first_q     <= 1'b1;
      rd_shift_q  <= '0;
    end else begin
      req_valid_q <= req_valid_d;
      req_data_q  <= req_data_d;
      first_q     <= first_d;
      rd_shift_q  <= rd_shift_d;
    end
  end

endmodule // cva6_icache_axi_wrapper