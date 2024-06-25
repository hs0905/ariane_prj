module rst_cntl(
  input clk,
  input rst_n,
  input state_idle_pin_i,
  output reg user_rst_n_o
);

reg [3:0] counter; // 4비트 카운터, 10까지 세기 충분
reg pending_rst;

always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    pending_rst   <= 1'b1;
    counter       <= 4'd0;
    user_rst_n_o  <= 1'b1;
  end else if (pending_rst && state_idle_pin_i) begin
    if (counter < 4'd10) begin
      user_rst_n_o  <= 1'b0; 
      counter       <= counter + 1'b1;
    end else begin
      user_rst_n_o  <= 1'b1; 
      pending_rst   <= 1'b0;
    end
  end else begin
    counter         <= 4'd0; 
    user_rst_n_o    <= 1'b1; 
  end
end

endmodule
