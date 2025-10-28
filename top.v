`include "alu.v"
`include "register.v"
`include "uart_tx.v"

module top(
    input clk,
    input rst,
    input init,
    input [3:0] a,
    input [3:0] b,
    input [2:0] op,
    input [2:0] addr,
    input write_en,
    input read_en,
    input [2:0] sel,
    input cin,
    output [7:0] data_out,
    output serial_data
);

    // ========================================
    // Señales internas
    // ========================================
    wire [6:0] result_wire;  // resultado de la ALU
    wire carry_;
    wire done_;
    wire overflow_;

    reg [7:0] selected_data;  // dato que se escribirá en el registro

    // ========================================
    // Instancia de la ALU
    // ========================================
    alu alu_inst (
        .clk(clk),
        .a(a),
        .b(b),
        .op(op),
        .init(init),
        .cin(cin),
        .result(result_wire),
        .carry(carry_),
        .done(done_),
        .overflow(overflow_)
    );

    // ========================================
    // Multiplexor para seleccionar qué dato guardar/leer
    // ========================================
    always @(*) begin
        case (sel)
            3'b000: selected_data = {4'b0, a};          // Mostrar A
            3'b001: selected_data = {4'b0, b};          // Mostrar B
            3'b010: selected_data = {1'b0, result_wire};         // Mostrar resultado de la ALU
            3'b011: selected_data = {7'b0, overflow_};   // Mostrar bit de overflow
            default: selected_data = 8'b0;
        endcase
    end

    // ========================================
    // Instancia del bloque de registros
    // ========================================
    register reg_block (
        .clk(clk),
        .rst(rst),
        .data_in(selected_data),
        .addr(addr),
        .write_en(write_en),
        .read_en(read_en),
        .data_out(data_out)
    );
    uart_tx uart(
    .clk(clk),
    .reset(rst),
    .init_tx(read_en),
    .data(selected_data),
    .serial_data(serial_data)
    );
    

endmodule
