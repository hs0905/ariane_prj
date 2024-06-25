module std_nbdcache import std_cache_pkg::*; import ariane_pkg::*; #( 
    parameter ariane_cfg_t ArianeCfg        = ArianeDefaultConfig // contains cacheable regions
)(
    input  logic                           clk_i,      
    input  logic                           rst_ni,     
    // Cache management
    input  logic                           enable_i,    // dcache enable 
    input  logic                           flush_i,     // flush cache request
    output logic                           flush_ack_o, // flush cache acknowledge response
    output logic                           miss_o,      // notify cache miss
    // AMOs
    input  amo_req_t                       amo_req_i,   // AMO request
    output amo_resp_t                      amo_resp_o,  // AMO response
    // Request ports
    input  dcache_req_i_t [2:0]            req_ports_i, // cache request ports
    output dcache_req_o_t [2:0]            req_ports_o, // cache response ports
    // Cache AXI refill port
    output ariane_axi::req_t               axi_data_o,  // AXI request
    input  ariane_axi::resp_t              axi_data_i,  // AXI response
    output ariane_axi::req_t               axi_bypass_o,// AXI bypass request
    input  ariane_axi::resp_t              axi_bypass_i, // AXI bypass response

    output logic                           state_idle_pin

);

// main component
// 1. Miss handler      : 캐시 미스를 관리하고 메모리 시스템으로부터 데이터를 리필합니다.
// 2. cache controller  : 캐시 동작을 제어하고, 캐시 라인의 유효성 및 데이터를 관리합니다.
// 3. SRAM blocks       : 실제 데이터와 태그를 저장하는 SRAM입니다. 데이터 블록과 태그 블록으로 구분됩니다.

import std_cache_pkg::*;

    // -------------------------------
    // Controller <-> Arbiter
    // -------------------------------
    // 1. Miss handler
    // 2. PTW
    // 3. Load Unit
    // 4. Store unit
    logic        [3:0][DCACHE_SET_ASSOC-1:0]  req;      
    logic        [3:0][DCACHE_INDEX_WIDTH-1:0]addr;     
    logic        [3:0]                        gnt;      // grant_signal about request
    cache_line_t [DCACHE_SET_ASSOC-1:0]       rdata;    
    logic        [3:0][DCACHE_TAG_WIDTH-1:0]  tag;      

    cache_line_t [3:0]                        wdata;    
    logic        [3:0]                        we;       // write enable
    cl_be_t      [3:0]                        be;       // byte enable
    logic        [DCACHE_SET_ASSOC-1:0]       hit_way;  // recognized where the cache hit occurred in the cache line
    // -------------------------------
    // Controller <-> Miss unit
    // -------------------------------
    logic [2:0]                        busy;                // cache controller is not ready(still running)
    logic [2:0][55:0]                  mshr_addr;           // address of the MSHR(miss status handling register)
    logic [2:0]                        mshr_addr_matches;   
    logic [2:0]                        mshr_index_matches;  
    logic [63:0]                       critical_word;       // important data within requested data(high priority data)
    logic                              critical_word_valid; // validity of ciritical word data

    logic [2:0][$bits(miss_req_t)-1:0] miss_req;            // miss request
    logic [2:0]                        miss_gnt;            // response to miss request
    logic [2:0]                        active_serving;      // processing miss request

    logic [2:0]                        bypass_gnt;          // bypass grant
    logic [2:0]                        bypass_valid;        // validity of bypass
    logic [2:0][63:0]                  bypass_data;         // bypass data
    // -------------------------------
    // Arbiter <-> Datram,
    // -------------------------------
    logic [DCACHE_SET_ASSOC-1:0]         req_ram;           // 
    logic [DCACHE_INDEX_WIDTH-1:0]       addr_ram;          // address of ram
    logic                                we_ram;            // write enable of ram
    cache_line_t                         wdata_ram;         // write data to ram
    cache_line_t [DCACHE_SET_ASSOC-1:0]  rdata_ram;         // read data from ram
    cl_be_t                              be_ram;            // byte enable of ram

    // ------------------
    // Cache Controller
    // ------------------
    generate
        for (genvar i = 0; i < 3; i++) begin : master_ports 
            cache_ctrl  #(
                .ArianeCfg             ( ArianeCfg            )
            ) i_cache_ctrl (
                .bypass_i              ( ~enable_i            ), // bypass cache : 
                .busy_o                ( busy            [i]  ), // busy signal
                // Core request ports
                .req_port_i            ( req_ports_i     [i]  ), // request from the core
                .req_port_o            ( req_ports_o     [i]  ), // response to the core
                // SRAM interface
                .req_o                 ( req            [i+1] ), // request to the SRAM
                .addr_o                ( addr           [i+1] ), // address to the SRAM
                .gnt_i                 ( gnt            [i+1] ), // grant from the SRAM
                .data_i                ( rdata                ), // data from the SRAM
                .tag_o                 ( tag            [i+1] ), // tag from the SRAM
                .data_o                ( wdata          [i+1] ), // data to the SRAM
                .we_o                  ( we             [i+1] ), // write enable to the SRAM
                .be_o                  ( be             [i+1] ), // byte enable to the SRAM
                .hit_way_i             ( hit_way              ), // recognized where the cache hit occurred
                // Miss handling
                .miss_req_o            ( miss_req        [i]  ), // miss request
                .miss_gnt_i            ( miss_gnt        [i]  ), // miss grant
                // Miss handling return
                .active_serving_i      ( active_serving  [i]  ), // active serving
                .critical_word_i       ( critical_word        ), // critical word
                .critical_word_valid_i ( critical_word_valid  ), // critical word valid
                // bypass ports
                .bypass_gnt_i          ( bypass_gnt      [i]  ), // bypass grant
                .bypass_valid_i        ( bypass_valid    [i]  ), // bypass valid
                .bypass_data_i         ( bypass_data     [i]  ), // bypass data
                // check MSHR for aliasing
                .mshr_addr_o           ( mshr_addr         [i] ), // mshr address
                .mshr_addr_matches_i   ( mshr_addr_matches [i] ), // mshr address matches
                .mshr_index_matches_i  ( mshr_index_matches[i] ), // mshr index matches
                .*
            );
        end
    endgenerate

    // ------------------
    // Miss Handling Unit
    // ------------------
    // Miss handling unit은 캐시 미스를 관리하고, 메모리 시스템으로부터 데이터를 리필합니다.
    miss_handler #(
        .NR_PORTS               ( 3                    )
    ) i_miss_handler (
        .flush_i                ( flush_i              ),
        .busy_i                 ( |busy                ),
        // AMOs
        .amo_req_i              ( amo_req_i            ),
        .amo_resp_o             ( amo_resp_o           ),
        .miss_req_i             ( miss_req             ),
        .miss_gnt_o             ( miss_gnt             ),
        .bypass_gnt_o           ( bypass_gnt           ),
        .bypass_valid_o         ( bypass_valid         ),
        .bypass_data_o          ( bypass_data          ),
        .critical_word_o        ( critical_word        ),
        .critical_word_valid_o  ( critical_word_valid  ),
        .mshr_addr_i            ( mshr_addr            ),
        .mshr_addr_matches_o    ( mshr_addr_matches    ),
        .mshr_index_matches_o   ( mshr_index_matches   ),
        .active_serving_o       ( active_serving       ),
        .req_o                  ( req             [0]  ),
        .addr_o                 ( addr            [0]  ),
        .data_i                 ( rdata                ),
        .be_o                   ( be              [0]  ),
        .data_o                 ( wdata           [0]  ),
        .we_o                   ( we              [0]  ),
        .state_idle_pin         ( state_idle_pin       ),
        .axi_bypass_o,
        .axi_bypass_i,
        .axi_data_o,
        .axi_data_i,
        .*
    );

    assign tag[0] = '0;

    // --------------
    // Memory Arrays
    // --------------
    for (genvar i = 0; i < DCACHE_SET_ASSOC; i++) begin : sram_block
        sram #(
            .DATA_WIDTH ( DCACHE_LINE_WIDTH                 ),
            .NUM_WORDS  ( DCACHE_NUM_WORDS                  )
        ) data_sram (
            .req_i   ( req_ram [i]                          ),
            .rst_ni  ( rst_ni                               ),
            .we_i    ( we_ram                               ),
            .addr_i  ( addr_ram[DCACHE_INDEX_WIDTH-1:DCACHE_BYTE_OFFSET]  ),
            .wdata_i ( wdata_ram.data                       ),
            .be_i    ( be_ram.data                          ),
            .rdata_o ( rdata_ram[i].data                    ),
            .*
        );

        sram #(
            .DATA_WIDTH ( DCACHE_TAG_WIDTH                  ),
            .NUM_WORDS  ( DCACHE_NUM_WORDS                  )
        ) tag_sram (
            .req_i   ( req_ram [i]                          ),
            .rst_ni  ( rst_ni                               ),
            .we_i    ( we_ram                               ),
            .addr_i  ( addr_ram[DCACHE_INDEX_WIDTH-1:DCACHE_BYTE_OFFSET]  ),
            .wdata_i ( wdata_ram.tag                        ),
            .be_i    ( be_ram.tag                           ),
            .rdata_o ( rdata_ram[i].tag                     ),
            .*
        );

    end

    // ----------------
    // Valid/Dirty Regs
    // ----------------

    // align each valid/dirty bit pair to a byte boundary in order to leverage byte enable signals.
    // note: if you have an SRAM that supports flat bit enables for your target technology,
    // you can use it here to save the extra 4x overhead introduced by this workaround.
    logic [4*DCACHE_DIRTY_WIDTH-1:0] dirty_wdata, dirty_rdata;

    for (genvar i = 0; i < DCACHE_SET_ASSOC; i++) begin
        assign dirty_wdata[8*i]   = wdata_ram.dirty;
        assign dirty_wdata[8*i+1] = wdata_ram.valid;
        assign rdata_ram[i].dirty = dirty_rdata[8*i];
        assign rdata_ram[i].valid = dirty_rdata[8*i+1];
    end

    sram #(
        .DATA_WIDTH ( 4*DCACHE_DIRTY_WIDTH             ),
        .NUM_WORDS  ( DCACHE_NUM_WORDS                 )
    ) valid_dirty_sram (
        .clk_i   ( clk_i                               ),
        .rst_ni  ( rst_ni                              ),
        .req_i   ( |req_ram                            ),
        .we_i    ( we_ram                              ),
        .addr_i  ( addr_ram[DCACHE_INDEX_WIDTH-1:DCACHE_BYTE_OFFSET] ),
        .wdata_i ( dirty_wdata                         ),
        .be_i    ( be_ram.vldrty                       ),
        .rdata_o ( dirty_rdata                         )
    );

    // ------------------------------------------------
    // Tag Comparison and memory arbitration
    // ------------------------------------------------
    tag_cmp #(
        .NR_PORTS           ( 4                  ),
        .ADDR_WIDTH         ( DCACHE_INDEX_WIDTH ),
        .DCACHE_SET_ASSOC   ( DCACHE_SET_ASSOC   )
    ) i_tag_cmp (
        .req_i              ( req         ),
        .gnt_o              ( gnt         ),
        .addr_i             ( addr        ),
        .wdata_i            ( wdata       ),
        .we_i               ( we          ),
        .be_i               ( be          ),
        .rdata_o            ( rdata       ),
        .tag_i              ( tag         ),
        .hit_way_o          ( hit_way     ),

        .req_o              ( req_ram     ),
        .addr_o             ( addr_ram    ),
        .wdata_o            ( wdata_ram   ),
        .we_o               ( we_ram      ),
        .be_o               ( be_ram      ),
        .rdata_i            ( rdata_ram   ),
        .*
    );


//pragma translate_off
    initial begin
        assert ($bits(axi_data_o.aw.addr) == 64) else $fatal(1, "Ariane needs a 64-bit bus");
        assert (DCACHE_LINE_WIDTH/64 inside {2, 4, 8, 16}) else $fatal(1, "Cache line size needs to be a power of two multiple of 64");
    end
//pragma translate_on
endmodule
