`timescale 1ns / 1ps
module AXI_reg_tb;

reg aclk;
reg aresetn;
reg [7:0] s_axis_tdata;
reg s_axis_tvalid;
reg s_axis_tlast;
wire s_axis_tready;

wire m_axis_tvalid;
wire [7:0] m_axis_tdata;
wire m_axis_tlast;
reg m_axis_tready;

reg [3:0] count;

AXI_register reg_dut (.aclk(aclk), .aresetn(aresetn), .s_axis_tdata(s_axis_tdata), .s_axis_tvalid(s_axis_tvalid), .s_axis_tlast(s_axis_tlast), .s_axis_tready(s_axis_tready),
.m_axis_tvalid(m_axis_tvalid), .m_axis_tdata(m_axis_tdata), .m_axis_tlast(m_axis_tlast), .m_axis_tready(m_axis_tready));

always #(5) aclk = ~aclk;


initial begin

    aclk = 0; aresetn = 1;  s_axis_tvalid = 0; m_axis_tready = 0; count = 0; s_axis_tlast = 0; s_axis_tdata = 0;
    
    #10 aresetn = 0;
                                                    // ----------on reset s_axis_tready is high as the reg is empty
                                                    //            it is ready to accept data 
    #10 aresetn = 1;

    s_axis_tvalid = 1;   s_axis_tdata = $random;    // -------- s_axis_tvalid becomes high 
                                                     //           data is stored into the reg
                                                     //            s_axis_tready becomes low

    #20
    s_axis_tvalid = 0;   s_axis_tdata = $random;     //------data Transfer  to downstream slave happens
    m_axis_tready = 1;

    #10
    s_axis_tvalid = 0;                                //---------no data stored
    m_axis_tready = 0;

    #10
    s_axis_tvalid = 1;                                //--------data is stored

    #10
                        s_axis_tdata = $random;       // ------s_axis_tready is low, so no storing of new data

    #20
                                                        
    m_axis_tready = 1;                                 // ------data Transfer  to downstream slave happens

    #10

    m_axis_tready = 0;                                 // ----------- As s_axis_tvalid was high, data is stored in to reg

    $stop;                                              //----next posedge it comes to m_axis_tdata with m_axis_tvalid being high


end

always #(10) begin
    if (count == 4'd6) begin
        s_axis_tlast <= 1;
        count <= 0;
    end
    else begin
        s_axis_tlast <= 0;
        count <= count + 1'b1;
    end
end

endmodule
