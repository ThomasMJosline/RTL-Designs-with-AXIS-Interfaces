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


always #(10) begin
    s_axis_tdata = $random;
    if (count_last == 4'd6) begin
        s_axis_tlast <= 1;
        count_last <= 0;
    end
    else begin
        s_axis_tlast <= 0;
        count_last <= count_last + 1'b1;
    end
end


initial begin

aclk = 1; aresetn = 1; wr_en = 0; re_en = 0; s_axis_tdata = 0; s_axis_tvalid = 0; m_axis_tready = 0;
s_axis_tlast = 0; count_last = 0;

#5 aresetn = 0;                   // -----reseting using active low reset

#10 aresetn = 1; 

#500 wr_en = 1;       // -----write_enable is made high, but s_axis_tvalid is low
                                  //                so no writing to fifo happens

#2500 s_axis_tvalid = 1;          // -------s_axis_tvalid is made high,
                                  //                so writing to fifo happes

#25000 s_axis_tvalid = 0;          // -------s_axis_tvalid is made low 
                                  //             so writing to fifo stops

#10 re_en = 1; wr_en = 0;         // ------read_enable is made high, but m_axis_tready is low         write_enable made low
                                  //             so read doesnot happen                                

#1000 m_axis_tready = 1;          // --------m_axis_tready is made high 
                                  //         so reading starts

#20500 re_en = 0;                 // --------read_enable is made low
                                  //          reading stops

#6000 wr_en = 1;                    //-----write_enable is made high,  but s_axis_tvalid is low
                                  //                so no writing to fifo happens

#20500 re_en = 1;                    // ------read_enable is made high, m_axis_ready is high
                                  //         so reading starts

s_axis_tvalid = 1;                // -------s_axis_tvalid is made high,
                                  //                so writing to fifo happes


#6000 wr_en = 0;                     //-------write_enable is made low,
                                   //          writing stops

#20500

m_axis_tready = 0;                 //---------m_axis_tready is made low
                                   //          so reading stops        

#6500
wr_en = 1; re_en = 0;               //-----write_enable is made high, s_axis_tvalid is high
                                    //     so writing starts
#60500
$stop;

end

always #5 aclk=~aclk;

endmodule
