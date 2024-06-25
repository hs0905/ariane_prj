module fifo_v3 #(
    parameter bit          FALL_THROUGH = 1'b0, // fifo is in fall-through mode
    parameter int unsigned DATA_WIDTH   = 32,   // default data width if the fifo is of type logic
    parameter int unsigned DEPTH        = 8,    // depth can be arbitrary from 0 to 2**32
    parameter type dtype                = logic [DATA_WIDTH-1:0],
    parameter int unsigned ADDR_DEPTH   = (DEPTH > 1) ? $clog2(DEPTH) : 1
    // parameter ILA_EN                    = "no"
)(
    input  logic  clk_i,           
    input  logic  rst_ni,          
    input  logic  flush_i,         
    input  logic  testmode_i,      
    // status flags
    output logic  full_o,          
    output logic  empty_o,         
    output logic  [ADDR_DEPTH-1:0] usage_o,     // fill pointer

    //if queue is not full, we can push new elements
    input  dtype  data_i,                                                       // data to push into the queue
    input  logic  push_i,                                                       // data is valid and can be pushed to the queue

    // if queue is not empty, we can pop elements 
    output dtype  data_o,                                                       // output data
    input  logic  pop_i                                                         // pop head from queue
);
    localparam int unsigned FIFO_DEPTH = (DEPTH > 0) ? DEPTH : 1;
    logic                    gate_clock;
    logic [ADDR_DEPTH - 1:0] read_pointer_n, read_pointer_q;                    // read   pointer
    logic [ADDR_DEPTH - 1:0] write_pointer_n, write_pointer_q;                  // write  pointer
    logic [ADDR_DEPTH:0]     status_cnt_n, status_cnt_q;                        // status counter for check the amount of data in the queue
    
    dtype [FIFO_DEPTH - 1:0] mem_n, mem_q;

//   if(ILA_EN == "yes") begin
//     ila_reset_check ila_reset_check_i (
//       .clk_i(clk_i),
//       .rst_ni(rst_ni)
//     );
//   end

    assign usage_o = status_cnt_q[ADDR_DEPTH-1:0];

    if (DEPTH == 0) begin
        assign empty_o      = ~push_i;
        assign full_o       = ~pop_i;
    end else begin
        assign full_o       = (status_cnt_q == FIFO_DEPTH[ADDR_DEPTH:0]);       // if current  status_counter is equal to the depth of the fifo -> full
        assign empty_o      = (status_cnt_q == 0) & ~(FALL_THROUGH & push_i);   // if current status_counter is 0 -> empty
    end
    // status flags

    // read and write queue logic
    always_comb begin : read_write_comb
        read_pointer_n  = read_pointer_q;
        write_pointer_n = write_pointer_q;
        status_cnt_n    = status_cnt_q;
        data_o          = (DEPTH == 0) ? data_i : mem_q[read_pointer_q];        // depth 0 is pass through mode
        mem_n           = mem_q; 
        gate_clock      = 1'b1;                                                 // default is clock enabled

        if (push_i && ~full_o) begin                                            // push data op occured, no full condition
            mem_n[write_pointer_q] = data_i;                                    // write the data in the mem array
            gate_clock             = 1'b0;                                      // disable the clock for the mem array
            if (write_pointer_q == FIFO_DEPTH[ADDR_DEPTH-1:0] - 1)              // if write_ptr is at the end of the queue
                write_pointer_n = '0;                                           // wrap around
            else    write_pointer_n = write_pointer_q + 1;                      // increment the write pointer
            status_cnt_n    = status_cnt_q + 1;                                 // increment the status counter
        end

        if (pop_i && ~empty_o) begin                                            // pop data op occured, no empty condition
            if (read_pointer_n == FIFO_DEPTH[ADDR_DEPTH-1:0] - 1)               // if read_ptr is at the end of the queue
                read_pointer_n = '0;                                            // wrap around
            else    read_pointer_n = read_pointer_q + 1;                        // increment the read pointer
            status_cnt_n   = status_cnt_q - 1;                                  // decrement the status counter 
        end

        
        if (push_i && pop_i &&  ~full_o && ~empty_o)                            // if push and pop op occured
            status_cnt_n   = status_cnt_q;                                      // keep the status counter stable

        // FIFO is in pass through mode -> do not change the pointers
        if (FALL_THROUGH && (status_cnt_q == 0) && push_i) begin
            data_o = data_i;
            if (pop_i) begin
                status_cnt_n = status_cnt_q;                                    // keep the status counter stable
                read_pointer_n = read_pointer_q;                                // keep the read pointer stable
                write_pointer_n = write_pointer_q;                              // keep the write pointer stable
            end
        end
    end

    // sequential process
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(~rst_ni) begin
            read_pointer_q  <= '0;
            write_pointer_q <= '0;
            status_cnt_q    <= '0;
        end else begin
            if (flush_i) begin
                read_pointer_q  <= '0;
                write_pointer_q <= '0;
                status_cnt_q    <= '0;
             end else begin
                read_pointer_q  <= read_pointer_n;
                write_pointer_q <= write_pointer_n;
                status_cnt_q    <= status_cnt_n;
            end
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(~rst_ni) begin
            mem_q <= '0;
        end else if (!gate_clock) begin
            mem_q <= mem_n;
        end
    end

// pragma translate_off
`ifndef VERILATOR
    initial begin
        assert (DEPTH > 0)             else $error("DEPTH must be greater than 0.");
    end

    full_write : assert property(
        @(posedge clk_i) disable iff (~rst_ni) (full_o |-> ~push_i))
        else $fatal (1, "Trying to push new data although the FIFO is full.");

    empty_read : assert property(
        @(posedge clk_i) disable iff (~rst_ni) (empty_o |-> ~pop_i))
        else $fatal (1, "Trying to pop data although the FIFO is empty.");
`endif
// pragma translate_on

endmodule // fifo_v3
