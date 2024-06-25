module auto_reset_timer(
  input   clk,
  input   rstn,
  input   Inner_counter_reset,
  input   Inner_counter_start,
  output  System_reset
  );

  localparam CLOCK_FREQ     = 50_000_000;  // 50 MHz
  localparam TIMEOUT_SEC    = 1;           
  localparam MAX_COUNT      = CLOCK_FREQ * TIMEOUT_SEC; 
  localparam RESET_DURATION = 100000; // ?? ?? ?? ?? ??? ?

  logic [31:0]  count;
  logic         system_reset_reg;
  logic [15:0]  reset_signal_duration; 

  always_ff @(posedge clk) begin
    if (!rstn) begin
      count                 <= 0;
      system_reset_reg      <= 0;
      reset_signal_duration <= 0;
    end else begin
      if (reset_signal_duration > 0) begin
        reset_signal_duration <= reset_signal_duration - 1;
        system_reset_reg      <= 1;
        count                 <= 0;
      end else begin
        system_reset_reg      <= 0; // ?? ??? ??? ?? ?? ??
      end

      if(Inner_counter_start) begin
        if(!Inner_counter_reset) begin
          if(count < MAX_COUNT - 1) begin
            count <= count + 1;
          end else begin
            count <= 0;
            reset_signal_duration <= RESET_DURATION; // ?? ?? ?? ?? ??
          end
        end else begin
          count <= 0;
        end 
      end else begin
        count <= 0;
      end
    end
  end

  assign System_reset = system_reset_reg; // copied
endmodule