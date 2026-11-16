module mlkem_coe_mem #(
    parameter WIDTH = 12,
    parameter DEPTH = 256,
    parameter ADDR_WIDTH = 8
)(
    input wire clk,
    input wire wr_en,
    input wire [ADDR_WIDTH-1:0] waddr,
    input wire [WIDTH-1:0] wdata,
    input wire [ADDR_WIDTH-1:0] raddr,
    output reg [WIDTH-1:0] rdata
);

reg [WIDTH-1:0] mem [0:DEPTH-1];

always @(posedge clk) begin
    if (wr_en) begin
        mem[waddr] <= wdata;
    end
    rdata <= mem[raddr];
end

endmodule