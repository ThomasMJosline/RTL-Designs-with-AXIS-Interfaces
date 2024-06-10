`timescale 1ns/1ps

module AXI_FIFO_tb;

reg aclk, aresetn, wr_en, re_en;
reg [7:0] s_axis_tdata;
reg s_axis_tlast;
reg s_axis_tvalid;
wire s_axis_tready;

wire full, empty;
wire [7:0] m_axis_tdata;
reg m_axis_tready;
wire m_axis_tlast;
wire m_axis_tvalid;

AXI_FIFO_4096 AXI_fifo_dut(.aclk(aclk), .aresetn(aresetn), .wr_en(wr_en), .re_en(re_en),
.s_axis_tdata(s_axis_tdata), .full(full), .empty(empty), .m_axis_tdata(m_axis_tdata), .s_axis_tlast(s_axis_tlast),
 .s_axis_tvalid(s_axis_tvalid), .s_axis_tready(s_axis_tready), .m_axis_tready(m_axis_tready), .m_axis_tlast(m_axis_tlast),
 .m_axis_tvalid(m_axis_tvalid));

integer i;
reg [3:0] count_last;


always @(posedge aclk) begin
    if (count_last == 4'd7) begin
        s_axis_tlast <= 1;
        count_last <= 0;
    end
    else begin
        s_axis_tlast <= 0;
        count_last <= count_last + 1'b1;
    end
end


initial begin

aclk = 0; aresetn = 1; wr_en = 0; re_en = 0; s_axis_tdata = 0; s_axis_tvalid = 0; m_axis_tready = 0; s_axis_tlast = 0; count_last = 0;

#5 aresetn = 0;

#10 aresetn = 1; wr_en = 1; 

#15 s_axis_tvalid = 1;

for (i = 0 ; i< 2060; i=i+1) begin
    s_axis_tdata = i;
    #10;
end

#10 re_en = 1; wr_en = 0;

#20 m_axis_tready = 1;

#20500 re_en = 0;

#5 wr_en = 1;

for (i = 0 ; i< 2000; i=i+1) begin
    s_axis_tdata = i;
    #10;
end

#5 re_en = 1;

#5 wr_en = 0;

for (i = 0 ; i< 2000; i=i+1) begin
    s_axis_tdata = i;
    #10;
end

#5 wr_en = 1;

for (i = 0 ; i< 2000; i=i+1) begin
    s_axis_tdata = i;
    #10;
end

$stop;

end

always #10 aclk=~aclk;

endmodule
