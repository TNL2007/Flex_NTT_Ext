module mlkem_tf_mem_hexload_tb;

parameter WIDTH = 12;
parameter DEPTH = 128;
parameter ADDR_WIDTH = 7;

reg [ADDR_WIDTH-1:0] addr;
reg sel_gamma;
wire [WIDTH-1:0] data;
reg [WIDTH-1:0] expected_zetas [0:DEPTH-1];
reg [WIDTH-1:0] expected_gammas [0:DEPTH-1];
integer errors;
integer i;

mlkem_tf_mem_hexload #(.WIDTH(WIDTH), .DEPTH(DEPTH), .ADDR_WIDTH(ADDR_WIDTH), .ZETAS_FILE("../inputs/mlkem_zetas.hex"), .GAMMAS_FILE("../inputs/mlkem_gammas.hex")) dut (
    .addr(addr),
    .sel_gamma(sel_gamma),
    .data(data)
);

initial begin
    $dumpfile("mlkem_tf_mem_hexload_tb.vcd");
    $dumpvars(0, mlkem_tf_mem_hexload_tb);

    $readmemh("../inputs/mlkem_zetas.hex", expected_zetas);
    $readmemh("../inputs/mlkem_gammas.hex", expected_gammas);

    addr = 0; sel_gamma = 0; #10;
    $display("t=%0t addr=%0d sel_gamma=%0d data=%0d expected=%0d", $time, addr, sel_gamma, data, expected_zetas[0]);

    addr = 1; sel_gamma = 0; #10;
    $display("t=%0t addr=%0d sel_gamma=%0d data=%0d expected=%0d", $time, addr, sel_gamma, data, expected_zetas[1]);

    addr = 127; sel_gamma = 0; #10;
    $display("t=%0t addr=%0d sel_gamma=%0d data=%0d expected=%0d", $time, addr, sel_gamma, data, expected_zetas[127]);

    addr = 0; sel_gamma = 1; #10;
    $display("t=%0t addr=%0d sel_gamma=%0d data=%0d expected=%0d", $time, addr, sel_gamma, data, expected_gammas[0]);

    addr = 1; sel_gamma = 1; #10;
    $display("t=%0t addr=%0d sel_gamma=%0d data=%0d expected=%0d", $time, addr, sel_gamma, data, expected_gammas[1]);

    addr = 127; sel_gamma = 1; #10;
    $display("t=%0t addr=%0d sel_gamma=%0d data=%0d expected=%0d", $time, addr, sel_gamma, data, expected_gammas[127]);

    errors = 0;
    sel_gamma = 0;
    for (i = 0; i < DEPTH; i = i + 1) begin
        addr = i;
        #1;
        if (data !== expected_zetas[i]) begin
            errors = errors + 1;
            $display("ZETAS MISMATCH addr=%0d got=%0d expected=%0d", i, data, expected_zetas[i]);
        end
    end
    sel_gamma = 1;
    for (i = 0; i < DEPTH; i = i + 1) begin
        addr = i;
        #1;
        if (data !== expected_gammas[i]) begin
            errors = errors + 1;
            $display("GAMMAS MISMATCH addr=%0d got=%0d expected=%0d", i, data, expected_gammas[i]);
        end
    end
    if (errors == 0) begin
        $display("FULL ROM SWEEP PASS all %0d entries correct", DEPTH*2);
    end else begin
        $display("FULL ROM SWEEP FAIL %0d mismatches", errors);
    end

    $finish;
end

endmodule

