`timescale 1ns/1ps

module mlkem_modmult_tb;

parameter WIDTH = 12;
parameter Q = 3329;

reg clk;
reg [WIDTH-1:0] a;
reg [WIDTH-1:0] b;
wire [WIDTH-1:0] result;
integer errors;
integer i, j;

mlkem_modmult #(.WIDTH(WIDTH), .Q(Q)) dut (
    .clk(clk),
    .a(a),
    .b(b),
    .result(result)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    errors = 0;
    a = 0;
    b = 0;
    @(posedge clk);
    #1;

    for (i = 0; i < 50; i = i + 1) begin
        for (j = 0; j < Q; j = j + 7) begin
            a = i;
            b = j;
            @(negedge clk);
            repeat (2) @(posedge clk);
            #1;
            if (result !== ((i * j) % Q)) begin
                errors = errors + 1;
                if (errors < 10) begin
                    $display("MISMATCH a=%0d b=%0d got=%0d expected=%0d", i, j, result, (i*j)%Q);
                end
            end
        end
    end
    if (errors == 0) begin
        $display("PASS modmult tests correct");
    end else begin
        $display("FAIL %0d mismatches", errors);
    end
    $finish;
end

endmodule

