module mlkem_modsub #(
    parameter WIDTH = 12,
    parameter Q     = 3329
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output wire [WIDTH-1:0] result
);

wire [WIDTH:0] diff_pos = {1'b0, a} - {1'b0, b};
wire [WIDTH:0] diff_neg = ({1'b0, a} + {1'b0, Q[WIDTH-1:0]}) - {1'b0, b};

assign result = (a >= b) ? diff_pos[WIDTH-1:0] : diff_neg[WIDTH-1:0];

endmodule