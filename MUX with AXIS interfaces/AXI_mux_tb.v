`timescale 1ns/1ps
module AXI_mux_tb;


reg aclk;
reg aresetn;
reg [7:0] s_axis_tdata_0, s_axis_tdata_1;
reg sel;

reg s_axis_tvalid_0, s_axis_tvalid_1;
reg s_axis_tlast_0, s_axis_tlast_1;
wire s_axis_tready;

reg m_axis_tready;
wire [7:0] m_axis_tdata;
wire m_axis_tvalid; 
wire m_axis_tlast ;


reg [3:0] count_0;
reg [4:0] count_1;



AXI_mux mux_dut (.aclk(aclk), .aresetn(aresetn), .s_axis_tdata_0(s_axis_tdata_0), .s_axis_tdata_1(s_axis_tdata_1), .sel(sel), .m_axis_tdata(m_axis_tdata),
.s_axis_tvalid_0(s_axis_tvalid_0), .s_axis_tvalid_1(s_axis_tvalid_1), .s_axis_tlast_0(s_axis_tlast_0), .s_axis_tlast_1(s_axis_tlast_1),
.m_axis_tready(m_axis_tready), .s_axis_tready(s_axis_tready), .m_axis_tvalid(m_axis_tvalid), .m_axis_tlast(m_axis_tlast));


always #5 aclk = ~aclk;

initial begin
     aclk=0;
     aresetn = 1; 
     s_axis_tdata_0 = 0; s_axis_tvalid_0 = 0; s_axis_tlast_0 = 0; count_0 = 0;
     s_axis_tdata_1 = 64; s_axis_tvalid_1 = 0; s_axis_tlast_1 = 0; count_1 = 0;
     sel = 0;
     m_axis_tready = 0;

    #5 aresetn = 0;

    #5 aresetn = 1;


    #10 s_axis_tvalid_0 =0 ; s_axis_tvalid_1 =0 ; m_axis_tready =1 ; sel =0;

    #10 s_axis_tvalid_0 =1 ; s_axis_tvalid_1 =0 ; m_axis_tready =1 ; sel = 0 ;

    #10 s_axis_tvalid_0 =0 ; s_axis_tvalid_1 =0 ; m_axis_tready =1 ; sel =0 ;

    #10 s_axis_tvalid_0 =1 ; s_axis_tvalid_1 =0 ; m_axis_tready =0 ; sel =0 ;

    #10 s_axis_tvalid_0 =1 ; s_axis_tvalid_1 =0 ; m_axis_tready =1 ; sel =0 ;

    #10 s_axis_tvalid_0 =1 ; s_axis_tvalid_1 =1 ; m_axis_tready =0 ; sel =0 ;

    #10 s_axis_tvalid_0 =0 ; s_axis_tvalid_1 =1 ; m_axis_tready =0 ; sel =1 ;

    #10 s_axis_tvalid_0 =0 ; s_axis_tvalid_1 =1 ; m_axis_tready =1 ; sel =1 ;

    #10 s_axis_tvalid_0 =0 ; s_axis_tvalid_1 =0 ; m_axis_tready =1 ; sel =1 ;

    #10 s_axis_tvalid_0 =0 ; s_axis_tvalid_1 =1 ; m_axis_tready =1 ; sel =1 ;

    #10 s_axis_tvalid_0 =1 ; s_axis_tvalid_1 =1 ; m_axis_tready =1 ; sel =0 ;


end

always @(posedge aclk) begin
    s_axis_tdata_0 <= $random;
    s_axis_tdata_1 <= $random;
    if (count_0 == 4'd7) begin
        s_axis_tlast_0 <= 1;
        count_0 <= 0;
    end
    else begin
        s_axis_tlast_0 <= 0;
        count_0 <= count_0 + 1'b1;
    end

    if (count_1 == 4'd15) begin
        s_axis_tlast_1 <= 1;
        count_1 <= 0;
    end
    else begin
        s_axis_tlast_1 <= 0;
        count_1 <= count_1 + 1'b1;
    end
end

endmodule
