`define BYTE_SIZE_IN_BITS 8

module wb_uart 
#(
      parameter WB_DATA_WIDTH      = 32,
      parameter WB_ADDR_WIDTH      = 32,
      parameter WB_SEL_WIDTH       = (WB_DATA_WIDTH) / `BYTE_SIZE_IN_BITS
)
(
	output wire                       uart_tx_o,
	input wire                        clk_i,
	input wire                        rst_i,
   input wire [WB_ADDR_WIDTH - 1:0]  wb_addr_i,
   input wire [WB_DATA_WIDTH - 1:0]  wb_data_i,
   input wire [WB_SEL_WIDTH - 1:0]   wb_sel_i,
   input wire                        wb_we_i,
   input wire                        wb_cyc_i,
   input wire                        wb_stb_i,
   output wire                       wb_ack_o,
   output wire [WB_DATA_WIDTH - 1:0] wb_data_o
);
   /*verilator public_module*/ 

   localparam [1:0] UART_ADDR_DIVIDER          = 2'd0,
                    UART_ADDR_DATA_TO_TRANSMIT = 2'd1,
                    UART_ADDR_SANITY           = 2'd2;
   localparam [31:0] UART_SANITY_VALUE = 32'hA17EB0B0;
   
   wire uart_accessed = wb_cyc_i && wb_stb_i;

   reg ack;
   assign wb_ack_o = ack && wb_cyc_i;

   reg [WB_DATA_WIDTH - 1:0] data_out;
   assign wb_data_o = data_out;

   wire [1:0] uart_reg_sel = wb_addr_i[3:2];

	reg [31:0] cfg_divider;

   reg  tx_started;

   always @ (posedge clk_i) begin
      if (rst_i) begin
         ack <= 0;
         cfg_divider <= 1;
         data_out <= 0;
         tx_started <= 0;
      end else begin
         if (uart_accessed) begin
            case (uart_reg_sel)
               UART_ADDR_DIVIDER: begin
                  ack <= 1;
                  if (wb_we_i) begin
                     cfg_divider <= wb_data_i;
                  end else begin
                     data_out <= cfg_divider;
                  end
               end
               UART_ADDR_SANITY: begin
                  if (!wb_we_i) begin
                     data_out <= UART_SANITY_VALUE;
                  end
               end
               UART_ADDR_DATA_TO_TRANSMIT: begin
                  if (wb_we_i) begin
                     tx_started <= !tx_finished;
                     if (tx_finished) begin
                        tx_started <= 0;
                        ack <= 1;
                     end
                  end
               end
               default: begin
                  ack <= 1;
               end
            endcase
         end else begin
            ack <= 0;
            data_out <= 0;
            tx_started <= 0;
         end
      end
   end

	reg [9:0] send_pattern;
	reg [3:0] send_bitcnt;
	reg [31:0] send_divcnt;
	assign uart_tx_o = send_pattern[0];
   
   wire tx_finished = finished;

   reg in_prog;
   reg finished;

	always @(posedge clk_i) begin
		send_divcnt <= send_divcnt + 1;
		if (rst_i) begin
			send_pattern <= ~0;
			send_bitcnt <= 0;
			send_divcnt <= 0;
         in_prog <= 0;
         finished <= 0;
		end else begin
			if (tx_started && !(|send_bitcnt)) begin
				send_pattern <= {1'b1, wb_data_i[7:0], 1'b0};
				send_bitcnt <= 10;
				send_divcnt <= 0;
            in_prog <= 1;
            finished <= 0;
			end else
			if (send_divcnt > cfg_divider && |send_bitcnt) begin
				send_pattern <= {1'b1, send_pattern[9:1]};
				send_bitcnt <= send_bitcnt - 1;
				send_divcnt <= 0;
			end
         if (in_prog && (send_bitcnt == 4'd1)) begin
            in_prog <= 0;
            finished <= 1;
         end else begin
            finished <= 0;
         end
		end
	end
endmodule
