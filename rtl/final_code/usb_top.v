module usb_top (
    input  wire clk,        // 48 MHz
    input  wire rst_n,      // active LOW reset

    // USB PHY interface
    input  wire rx_j,
    input  wire rx_se0,

    output wire tx_en,
    output wire tx_j,
    output wire tx_se0
);

// ---------------- INTERNAL SIGNALS ----------------
wire [6:0] usb_address = 7'd1;   // default device address

wire usb_rst;

wire transaction_active;
wire [3:0] endpoint;
wire direction_in;
wire setup;

wire data_toggle = 1'b0;

wire [1:0] handshake = 2'b00;

wire [7:0] data_out;
wire [7:0] data_in = 8'd0;
wire data_in_valid = 1'b0;

wire data_strobe;
wire success;

// ---------------- USB CORE ----------------
usb usb_core (
    .rst_n(rst_n),
    .clk_48(clk),

    .rx_j(rx_j),
    .rx_se0(rx_se0),

    .tx_en(tx_en),
    .tx_j(tx_j),
    .tx_se0(tx_se0),

    .usb_address(usb_address),

    .usb_rst(usb_rst),

    .transaction_active(transaction_active),
    .endpoint(endpoint),
    .direction_in(direction_in),
    .setup(setup),
    .data_toggle(data_toggle),

    .handshake(handshake),

    .data_out(data_out),
    .data_in(data_in),
    .data_in_valid(data_in_valid),
    .data_strobe(data_strobe),
    .success(success)
);

endmodule
