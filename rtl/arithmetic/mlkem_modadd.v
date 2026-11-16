module mlkem_modadd #(
    parameter WIDTH = 12,
    parameter Q = 3329
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output reg  [WIDTH-1:0] result
);

reg [WIDTH:0] sum;
reg [WIDTH:0] diff;

always @(*) begin
    sum = {1'b0, a} + {1'b0, b};
    diff = sum - Q[WIDTH:0];
    if (!diff[WIDTH])
        result = diff[WIDTH-1:0];
    else
        result = sum[WIDTH-1:0];
end

endmodule