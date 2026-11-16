module mlkem_modsub_tb;

parameter WIDTH = 12;
parameter Q = 3329;

reg [WIDTH-1:0] a;
reg [WIDTH-1:0] b;
wire [WIDTH-1:0] result;

integer errors;
integer i;
integer j;
integer expected;

mlkem_modsub #(
    .WIDTH(WIDTH),
    .Q(Q)
) dut (
    .a(a),
    .b(b),
    .result(result)
);

initial begin
    errors = 0;

    for (i = 0; i < Q; i = i + 1) begin
        for (j = 0; j < Q; j = j + 1) begin
            a = i;
            b = j;
            #1;

            expected = ((i - j) % Q + Q) % Q;

            if (result !== expected) begin
                errors = errors + 1;

                if (errors < 10) begin
                    $display("MISMATCH a=%0d b=%0d got=%0d expected=%0d",
                             i, j, result, expected);
                end
            end
        end
    end

    if (errors == 0)
        $display("PASS all %0d cases correct", Q*Q);
    else
        $display("FAIL %0d mismatches", errors);

    $finish;
end

endmodule