module AXI_FIFO_4096 (
    input aclk, aresetn,

    output empty,
    output full,

    input s_axis_tvalid,
    input s_axis_tlast,
    input [7:0] s_axis_tdata,
    output s_axis_tready,
    input wr_en,

    output [7:0] m_axis_tdata,
    output m_axis_tvalid,
    output m_axis_tlast,
    input m_axis_tready,
    input re_en
);

wire empty_0, full_0;
wire empty_1, full_1;

wire wr_en_0, re_en_0;
wire wr_en_1, re_en_1;

wire [7:0] DATA_in_0, DATA_in_1;
wire [7:0] DATA_out_0, DATA_out_1;
wire tlast_in_0, tlast_in_1;
wire tlast_out_0, tlast_out_1;


reg [11:0] Wr_ptr, Re_ptr;
reg [13:0] counter;


FIFO fifo0(.aclk(aclk), .aresetn(aresetn), .data_in(DATA_in_0), .wr_en(wr_en_0), .re_en(re_en_0), .data_out(DATA_out_0), .full(full_0), .empty(empty_0), .tlast_in(tlast_in_0), .tlast_out(tlast_out_0));
FIFO fifo1(.aclk(aclk), .aresetn(aresetn), .data_in(DATA_in_1), .wr_en(wr_en_1), .re_en(re_en_1), .data_out(DATA_out_1), .full(full_1), .empty(empty_1), .tlast_in(tlast_in_1), .tlast_out(tlast_out_1));


//----------FIFO-input-selection-------
assign DATA_in_0 = (wr_en_0) ? s_axis_tdata : 8'd0;
assign tlast_in_0 = (wr_en_0) ? s_axis_tlast : 1'd0;

assign DATA_in_1 = (wr_en_1) ? s_axis_tdata : 8'd0;
assign tlast_in_1 = (wr_en_1) ? s_axis_tlast : 1'd0;

//---------FIFO-output-selection-------
assign m_axis_tdata = (re_en_0) ? DATA_out_0 : 
                      (re_en_1) ? DATA_out_1 :
                       8'd0;

assign m_axis_tlast = (re_en_0) ? tlast_out_0 :
                      (re_en_1) ? tlast_out_1 :
                      1'd0;

//----write-enable-for-FIFO-------
assign wr_en_0 = (wr_en && (~full || re_en) && (Wr_ptr < 12'd2048) && s_axis_tready && s_axis_tvalid) ? wr_en : 1'd0;
assign wr_en_1 = (wr_en && (~full || re_en) && (Wr_ptr >= 12'd2048) && s_axis_tready && s_axis_tvalid) ? wr_en :1'd0;

//----read-enable-for-FIFO------
assign re_en_0 = (re_en && (~empty || wr_en) && (Re_ptr <= 12'd2048) && m_axis_tready && m_axis_tvalid) ? re_en : 1'd0;
assign re_en_1 = (re_en && (~empty || wr_en) && (Re_ptr >= 12'd2048) && m_axis_tready && m_axis_tvalid) ? re_en : 1'd0;



//----------write-ptr---------
always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        Wr_ptr <= 12'd0;
    end
    else begin
        if (wr_en == 1 && s_axis_tready && s_axis_tvalid) begin
            if (~full || re_en) begin
                Wr_ptr <= Wr_ptr + 1'b1;       
            end
        end
        end
end 

//--------read-ptr----------
always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        Re_ptr <= 12'd0;
    end
    else begin
        if (re_en == 1 && m_axis_tready && m_axis_tvalid) begin
            if (~empty || wr_en) begin
                Re_ptr <= Re_ptr + 1'b1;       
            end
        end
        end
end 

//-----s_axis_tready-------
assign s_axis_tready = (~full);

//-----m_axis_tvalid------
assign m_axis_tvalid = (~empty) && re_en;

//------full--empty---------
assign full = full_0 && full_1;
assign empty = empty_0 && empty_1;

endmodule
