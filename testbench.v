module testbench;
reg clk = 0;
reg reset = 1;

pipeline_processor uut(.clk(clk), .reset(reset));

initial begin
    $dumpfile("pipeline_processor.vcd");
    $dumpvars(0, testbench);

    // Initial reset
    #5 reset = 0;

    // Run for 20 cycles
    repeat(20) begin
        #5 clk = ~clk;
        #5 clk = ~clk;
    end

    $finish;
end

endmodule
