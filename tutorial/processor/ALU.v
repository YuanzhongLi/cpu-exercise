`include "Types.v"

module ALU(
  output `DataPath aluOut,

  input `DataPath aluInA,
  input `DataPath aluInB,
  input `ALUcodePath code
);
  always_comb begin
    case ( code )

    `ALU_CODE_SLL: // `ALU_CODE_SLL: AをBbit左シフト
      aluOut = aluInA << `GET_SHIFT( aluInB );

    `ALU_CODE_SRL: // `ALU_CODE_SRL: AをBbit右シフト
      aluOut = aluInA >> `GET_SHIFT( aluInB );

    `ALU_CODE_ADD: // `ALU_CODE_ADD
      aluOut = aluInA + aluInB;

    `ALU_CODE_SUB:
      aluOut = aluInA - aluInB;

    `ALU_CODE_OR:
			aluOut = aluInA | aluInB;

		`ALU_CODE_XOR:
			aluOut = aluInA ^ aluInB;

		`ALU_CODE_AND:
			aluOut = aluInA & aluInB;

		`ALU_CODE_SLT: // less than
			aluOut = aluInA < aluInB ? `TRUE : `FALSE;

    endcase
  end

endmodule
