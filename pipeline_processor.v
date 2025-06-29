module pipeline_processor(
    input clk,
    input reset
);

// Instruction Memory (8 instructions max for demo)
reg [15:0] IMEM [0:7];
initial begin
    // Sample program (opcode, rd, rs1, rs2/imm)
    // Format: [15:12] opcode, [11:8] rd, [7:4] rs1, [3:0] rs2/imm
    IMEM[0] = 16'b0001_0001_0010_0001; // ADD r1, r2, r1
    IMEM[1] = 16'b0010_0011_0001_0010; // SUB r3, r1, r2
    IMEM[2] = 16'b0011_0100_0011_0001; // AND r4, r3, r1
    IMEM[3] = 16'b0100_0101_0000_0011; // LOAD r5, 3(r0)
    IMEM[4] = 16'b0001_0010_0011_0100; // ADD r2, r3, r4
    IMEM[5] = 16'b0000_0000_0000_0000; // NOP
    IMEM[6] = 16'b0000_0000_0000_0000; // NOP
    IMEM[7] = 16'b0000_0000_0000_0000; // NOP
end

// Register File (8 registers)
reg [7:0] REG [0:7];

// Data Memory (8 locations)
reg [7:0] DMEM [0:7];
initial begin
    DMEM[3] = 8'hAA; // Data for LOAD demo
end

// Pipeline Registers
reg [15:0] IF_ID_instr;
reg [15:0] ID_EX_instr;
reg [7:0]  ID_EX_rs1_val, ID_EX_rs2_val;
reg [15:0] EX_MEM_instr;
reg [7:0]  EX_MEM_alu_out, EX_MEM_rs2_val;
reg [15:0] MEM_WB_instr;
reg [7:0]  MEM_WB_write_data;

reg [2:0] PC;

// Instruction decode outputs
reg [3:0] opcode, rd, rs1, rs2_imm;

// Pipeline operation
always @(posedge clk or posedge reset) begin
    if (reset) begin
        PC <= 0;
        IF_ID_instr <= 0;
        ID_EX_instr <= 0;
        ID_EX_rs1_val <= 0;
        ID_EX_rs2_val <= 0;
        EX_MEM_instr <= 0;
        EX_MEM_alu_out <= 0;
        EX_MEM_rs2_val <= 0;
        MEM_WB_instr <= 0;
        MEM_WB_write_data <= 0;
    end else begin
        // WB Stage
        opcode = MEM_WB_instr[15:12];
        rd     = MEM_WB_instr[11:8];
        if (opcode == 4'b0001 || opcode == 4'b0010 || opcode == 4'b0011 || opcode == 4'b0100) begin
            REG[rd] <= MEM_WB_write_data;
        end

        // MEM Stage
        EX_MEM_instr <= ID_EX_instr;
        opcode = ID_EX_instr[15:12];
        rd     = ID_EX_instr[11:8];
        if (opcode == 4'b0100) begin // LOAD
            EX_MEM_alu_out <= DMEM[ID_EX_rs1_val + ID_EX_instr[3:0]];
        end else begin
            EX_MEM_alu_out <= EX_MEM_alu_out;
        end
        EX_MEM_rs2_val <= ID_EX_rs2_val;

        // EX Stage
        ID_EX_instr <= IF_ID_instr;
        opcode = IF_ID_instr[15:12];
        rd     = IF_ID_instr[11:8];
        rs1    = IF_ID_instr[7:4];
        rs2_imm= IF_ID_instr[3:0];
        ID_EX_rs1_val <= REG[rs1];
        ID_EX_rs2_val <= REG[rs2_imm];

        // IF Stage
        IF_ID_instr <= IMEM[PC];
        PC <= PC + 1;
    end
end

// ALU Operation and WB
always @(*) begin
    opcode = EX_MEM_instr[15:12];
    rd     = EX_MEM_instr[11:8];
    rs1    = EX_MEM_instr[7:4];
    rs2_imm= EX_MEM_instr[3:0];
    case (opcode)
        4'b0001: MEM_WB_write_data = REG[rs1] + REG[rs2_imm]; // ADD
        4'b0010: MEM_WB_write_data = REG[rs1] - REG[rs2_imm]; // SUB
        4'b0011: MEM_WB_write_data = REG[rs1] & REG[rs2_imm]; // AND
        4'b0100: MEM_WB_write_data = EX_MEM_alu_out; // LOAD from EX_MEM
        default: MEM_WB_write_data = 0;
    endcase
    MEM_WB_instr = EX_MEM_instr;
end

endmodulemodule pipeline_processor(
    input clk,
    input reset
);

// Instruction Memory (8 instructions max for demo)
reg [15:0] IMEM [0:7];
initial begin
    // Sample program (opcode, rd, rs1, rs2/imm)
    // Format: [15:12] opcode, [11:8] rd, [7:4] rs1, [3:0] rs2/imm
    IMEM[0] = 16'b0001_0001_0010_0001; // ADD r1, r2, r1
    IMEM[1] = 16'b0010_0011_0001_0010; // SUB r3, r1, r2
    IMEM[2] = 16'b0011_0100_0011_0001; // AND r4, r3, r1
    IMEM[3] = 16'b0100_0101_0000_0011; // LOAD r5, 3(r0)
    IMEM[4] = 16'b0001_0010_0011_0100; // ADD r2, r3, r4
    IMEM[5] = 16'b0000_0000_0000_0000; // NOP
    IMEM[6] = 16'b0000_0000_0000_0000; // NOP
    IMEM[7] = 16'b0000_0000_0000_0000; // NOP
end

// Register File (8 registers)
reg [7:0] REG [0:7];

// Data Memory (8 locations)
reg [7:0] DMEM [0:7];
initial begin
    DMEM[3] = 8'hAA; // Data for LOAD demo
end

// Pipeline Registers
reg [15:0] IF_ID_instr;
reg [15:0] ID_EX_instr;
reg [7:0]  ID_EX_rs1_val, ID_EX_rs2_val;
reg [15:0] EX_MEM_instr;
reg [7:0]  EX_MEM_alu_out, EX_MEM_rs2_val;
reg [15:0] MEM_WB_instr;
reg [7:0]  MEM_WB_write_data;

reg [2:0] PC;

// Instruction decode outputs
reg [3:0] opcode, rd, rs1, rs2_imm;

// Pipeline operation
always @(posedge clk or posedge reset) begin
    if (reset) begin
        PC <= 0;
        IF_ID_instr <= 0;
        ID_EX_instr <= 0;
        ID_EX_rs1_val <= 0;
        ID_EX_rs2_val <= 0;
        EX_MEM_instr <= 0;
        EX_MEM_alu_out <= 0;
        EX_MEM_rs2_val <= 0;
        MEM_WB_instr <= 0;
        MEM_WB_write_data <= 0;
    end else begin
        // WB Stage
        opcode = MEM_WB_instr[15:12];
        rd     = MEM_WB_instr[11:8];
        if (opcode == 4'b0001 || opcode == 4'b0010 || opcode == 4'b0011 || opcode == 4'b0100) begin
            REG[rd] <= MEM_WB_write_data;
        end

        // MEM Stage
        EX_MEM_instr <= ID_EX_instr;
        opcode = ID_EX_instr[15:12];
        rd     = ID_EX_instr[11:8];
        if (opcode == 4'b0100) begin // LOAD
            EX_MEM_alu_out <= DMEM[ID_EX_rs1_val + ID_EX_instr[3:0]];
        end else begin
            EX_MEM_alu_out <= EX_MEM_alu_out;
        end
        EX_MEM_rs2_val <= ID_EX_rs2_val;

        // EX Stage
        ID_EX_instr <= IF_ID_instr;
        opcode = IF_ID_instr[15:12];
        rd     = IF_ID_instr[11:8];
        rs1    = IF_ID_instr[7:4];
        rs2_imm= IF_ID_instr[3:0];
        ID_EX_rs1_val <= REG[rs1];
        ID_EX_rs2_val <= REG[rs2_imm];

        // IF Stage
        IF_ID_instr <= IMEM[PC];
        PC <= PC + 1;
    end
end

// ALU Operation and WB
always @(*) begin
    opcode = EX_MEM_instr[15:12];
    rd     = EX_MEM_instr[11:8];
    rs1    = EX_MEM_instr[7:4];
    rs2_imm= EX_MEM_instr[3:0];
    case (opcode)
        4'b0001: MEM_WB_write_data = REG[rs1] + REG[rs2_imm]; // ADD
        4'b0010: MEM_WB_write_data = REG[rs1] - REG[rs2_imm]; // SUB
        4'b0011: MEM_WB_write_data = REG[rs1] & REG[rs2_imm]; // AND
        4'b0100: MEM_WB_write_data = EX_MEM_alu_out; // LOAD from EX_MEM
        default: MEM_WB_write_data = 0;
    endcase
    MEM_WB_instr = EX_MEM_instr;
end

endmodule
