module rr_arb_tree #(
  parameter int unsigned NumIn      = 64,
  parameter int unsigned DataWidth  = 32,
  parameter type         DataType   = logic [DataWidth-1:0],
  parameter bit          ExtPrio    = 1'b0, // set to 1'b1 to enable
  parameter bit          AxiVldRdy  = 1'b0, // treat req/gnt as vld/rdy
  parameter bit          LockIn     = 1'b0  // set to 1'b1 to enable
) (
  input  logic                             clk_i,
  input  logic                             rst_ni,
  input  logic                             flush_i, // clears the arbiter state
  input  logic [$clog2(NumIn)-1:0]         rr_i,    // external RR prio (needs to be enabled above)

  // input requests and data
  input  logic    [NumIn-1:0]         req_i,  // src_valid
  output logic    [NumIn-1:0]         gnt_o,  // src_ready
  input  DataType [NumIn-1:0]         data_i, // src_data
  // arbitrated output
  
  input  logic                        gnt_i,  // dst_ready
  output logic                        req_o,  // dst_valid
  output DataType                     data_o, // dst_data
  output logic [$clog2(NumIn)-1:0]    idx_o   
);

  if (NumIn == unsigned'(1)) begin  // if src num is 1, pass through(don't act like arbiter)
    assign req_o    = req_i [0];
    assign gnt_o[0] = gnt_i;
    assign data_o   = data_i[0];
    assign idx_o    = '0;
  end else begin
    localparam int unsigned NumLevels = $clog2(NumIn); // log2(3) : 2
    logic     [2**NumLevels-2:0][NumLevels-1:0]   index_nodes;  // index nodes
    DataType  [2**NumLevels-2:0]                  data_nodes;   // data nodes
    logic     [2**NumLevels-2:0]                  gnt_nodes;    // grant nodes
    logic     [2**NumLevels-2:0]                  req_nodes;    // request nodes
    logic     [NumLevels-1:0]                     rr_q;         // round robin counter
    logic     [NumIn-1:0]                         req_d;        // request queue

    assign req_o        = req_nodes[0];     // req_nodes[0] goes to req_o(dst_valid)
    assign data_o       = data_nodes[0];    // data_nodes[0] goes to data_o(dst_data)
    assign idx_o        = index_nodes[0];   // index_nodes[0] goes to idx_o 

    if (ExtPrio) begin
      assign rr_q       = rr_i;
      assign req_d      = req_i;
    end 
    else begin                                              
      logic [NumLevels-1:0] rr_d;                           
      if (LockIn) begin                                     
        logic             lock_d, lock_q;   
        logic [NumIn-1:0] req_q;                      // request queue                
        assign lock_d     = req_o & ~gnt_i;           // dst_valid & ~dst_ready                
        assign req_d      = (lock_q) ? req_q : req_i; // if locked, use the previous request queue

        // q means the current state, d means the next state

        always_ff @(posedge clk_i or negedge rst_ni) begin
          if (!rst_ni) begin
            lock_q <= '0;         
          end else begin
            if (flush_i) begin
              lock_q <= '0;       
            end else begin
              lock_q <= lock_d;
            end
          end
        end // flush or reset occured then lock_q value is 0 else lock_q value is updated to lock_d

        always_ff @(posedge clk_i or negedge rst_ni) begin
          if (!rst_ni) begin
            req_q  <= '0;
          end else begin
            if (flush_i) begin
              req_q  <= '0;
            end else begin
              req_q  <= req_d;
            end
          end
        end
      end else begin          // if lock is not enabled
        assign req_d = req_i; // next_request is the input request
      end

      assign rr_d = (gnt_i && req_o) ? ((rr_q == NumLevels'(NumIn-1)) ? '0 : rr_q + 1'b1) : rr_q; 


      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          rr_q   <= '0;
        end else begin
          if (flush_i) begin
            rr_q   <= '0;
          end else begin
            rr_q   <= rr_d;
          end
        end
      end
    end

    assign gnt_nodes[0] = gnt_i; // dst_ready signal

    for (genvar level = 0; unsigned'(level) < NumLevels; level++) begin
      for (genvar l = 0; l < 2**level; l++) begin           // l is the index of the node
        logic sel;
        localparam int unsigned idx0 = 2**level-1+l;        
        localparam int unsigned idx1 = 2**(level+1)-1+l*2;
        if (unsigned'(level) == NumLevels-1) begin
          if (unsigned'(l) * 2 < NumIn-1) begin
            assign req_nodes[idx0]   = req_d[l*2] | req_d[l*2+1];
            assign sel               = ~req_d[l*2] | req_d[l*2+1] & rr_q[NumLevels-1-level];
            assign index_nodes[idx0] = NumLevels'(sel);
            assign data_nodes[idx0]  = (sel) ? data_i[l*2+1] : data_i[l*2];
            assign gnt_o[l*2]        = gnt_nodes[idx0] & (AxiVldRdy | req_d[l*2])   & ~sel;
            assign gnt_o[l*2+1]      = gnt_nodes[idx0] & (AxiVldRdy | req_d[l*2+1]) & sel;
          end
          if (unsigned'(l) * 2 == NumIn-1) begin
            assign req_nodes[idx0]   = req_d[l*2];
            assign index_nodes[idx0] = '0;
            assign data_nodes[idx0]  = data_i[l*2];
            assign gnt_o[l*2]        = gnt_nodes[idx0] & (AxiVldRdy | req_d[l*2]);
          end
        end else begin
          assign req_nodes[idx0]   = req_nodes[idx1] | req_nodes[idx1+1];
          assign sel =  ~req_nodes[idx1] | req_nodes[idx1+1] & rr_q[NumLevels-1-level];
          assign index_nodes[idx0] = (sel) ? NumLevels'({1'b1, index_nodes[idx1+1][NumLevels-unsigned'(level)-2:0]}) :
                                             NumLevels'({1'b0, index_nodes[idx1][NumLevels-unsigned'(level)-2:0]});
          assign data_nodes[idx0]  = (sel) ? data_nodes[idx1+1] : data_nodes[idx1];
          assign gnt_nodes[idx1]   = gnt_nodes[idx0] & ~sel;
          assign gnt_nodes[idx1+1] = gnt_nodes[idx0] & sel;
        end
      end
    end
  end
endmodule : rr_arb_tree
