//
// IF/DC
//

`include "Types.v"

module FirstStage(
  input logic clk,
  input logic rst,
  input `InsnPath insnFromIMem,

  output `InsnPath insnToDecoder
);

  always_ff @( posedge clk or negedge rst ) begin
    if ( !rst ) begin
      insnToDecoder <= `FALSE;
    end
    else begin
      insnToDecoder <= insnFromIMem;
    end
  end

endmodule
