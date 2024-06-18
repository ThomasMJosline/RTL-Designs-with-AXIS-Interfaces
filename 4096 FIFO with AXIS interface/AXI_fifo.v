module AXI_fifo (
    input aclk, 
    input aresetn,  //! active low reset

    input s_axis_tvalid, //! VALID signal for input data
    input s_axis_tlast,  //! LAST signal for input data
    input [7:0] s_axis_tdata, //! input data
    output s_axis_tready,     //! signal that shows the slave(FIFO) is ready to accept data

    output [7:0] m_axis_tdata, //! Output data
    output m_axis_tvalid,      //! VALID signal for the output data
    output m_axis_tlast,       //! LAST signal for the output data
    input m_axis_tready       //! signal that shows downstream slave module is ready to accept data
);

wire empty_0; //! shows whether fifo0 is empty
wire full_0; //! shows whether fifo0 is full
wire empty_1; //! shows whether fifo1 is empty
wire full_1; //! shows whether fifo is full
wire empty; //! shows the main fifo is empty (empty_0 && empty_1)
wire full; //! shows the main fifo is full (full_0 && full_1)

wire [7:0] DATA_in_0; //!input data to fifo0
wire [7:0] DATA_in_1; //!input data to fifo1
wire [7:0] DATA_out_0; //!output data from fifo0
wire [7:0] DATA_out_1; //!output data from fifo1
wire tlast_in_0; //! input LAST signal to fifo0
wire tlast_in_1; //! input LAST signal to fifo1
wire tlast_out_0;//! output LAST signal from fifo0
wire tlast_out_1;//! output LAST signal from fifo1

wire wr_en_0; //! write enable signal for fifo0
wire wr_en_1; //! write enable signal for fifo1
wire re_en_0; //! read enable signal for fifo0
wire re_en_1; //! read enable signal for fifo1

reg [12:0] wr_ptr; //! write pointer
reg [12:0] re_ptr; //! read pointer


fifo fifo0(.aclk(aclk), .aresetn(aresetn), .data_in(DATA_in_0), .wr_en(wr_en_0), .re_en(re_en_0), .data_out(DATA_out_0), .full(full_0), .empty(empty_0), .last_in(tlast_in_0), .last_out(tlast_out_0));
fifo fifo1(.aclk(aclk), .aresetn(aresetn), .data_in(DATA_in_1), .wr_en(wr_en_1), .re_en(re_en_1), .data_out(DATA_out_1), .full(full_1), .empty(empty_1), .last_in(tlast_in_1), .last_out(tlast_out_1));

//-------write ptr
always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        wr_ptr <= 0;
    end
    else if( s_axis_tready && s_axis_tvalid ) begin
        wr_ptr <= wr_ptr + 1'b1;
    end
end
//-------write ptr
always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        re_ptr <= 0;
    end
    else if( m_axis_tready && m_axis_tvalid ) begin
        re_ptr <= re_ptr + 1'b1;
    end
end

//--------------selecting between fifo1 or fifo2
assign DATA_in_0 = (wr_ptr < 13'd2048) ? s_axis_tdata : 8'd0;
assign tlast_in_0 = (wr_ptr < 13'd2048) ? s_axis_tlast : 1'd0;

assign DATA_in_1 = (wr_ptr >= 13'd2048) ? s_axis_tdata : 8'd0;
assign tlast_in_1 = (wr_ptr >= 13'd2048) ? s_axis_tlast : 1'd0;

//---------FIFO-output-selection-------
assign m_axis_tdata = (re_ptr < 13'd2048) ? DATA_out_0 : DATA_out_1;
assign m_axis_tlast = (re_ptr < 13'd2048) ? tlast_out_0 : tlast_out_1;

//---------write-enable----
assign wr_en_0 = (wr_ptr < 13'd2048) ? (s_axis_tready && s_axis_tvalid) : 1'd0;
assign wr_en_1 = (wr_ptr >= 13'd2048) ? (s_axis_tready && s_axis_tvalid) : 1'd0;
//---------read-enable-------
assign re_en_0 = (re_ptr < 13'd2048) ? (m_axis_tready && m_axis_tvalid) : 1'd0;
assign re_en_1 = (re_ptr >= 13'd2048 ) ? (m_axis_tready && m_axis_tvalid) : 1'd0;

//-------empty and full
assign empty = empty_0 && empty_1;
assign full = full_0 && full_1;

assign s_axis_tready = (!full) ? 1'd1 : 1'd0;

assign m_axis_tvalid = (!empty) ? 1'd1 : 1'd0;


endmodule
