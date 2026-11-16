module mlkem_tf_mem_hexload #(
    parameter WIDTH = 12,
    parameter DEPTH = 128,
    parameter ADDR_WIDTH = 7,
    parameter ZETAS_FILE = "mlkem_zetas.hex",
    parameter GAMMAS_FILE = "mlkem_gammas.hex"
)(
    input wire [ADDR_WIDTH-1:0] addr,
    input wire sel_gamma,
    output wire [WIDTH-1:0] data
);

reg [WIDTH-1:0] zetas_rom [0:DEPTH-1];
reg [WIDTH-1:0] gammas_rom [0:DEPTH-1];

initial begin
    $readmemh(ZETAS_FILE, zetas_rom);
    $readmemh(GAMMAS_FILE, gammas_rom);
end

assign data = sel_gamma ? gammas_rom[addr] : zetas_rom[addr];

endmodule