`timescale 1ns/1ps
module AXI_mux_tb;


reg ACLK;
reg ARESETn;
reg [7:0] DATA_in_0, DATA_in_1;
reg sel;
reg TVALID_in_0, TVALID_in_1;
reg TLAST_in_0, TLAST_in_1;
reg TREADY_out;

wire TREADY_in;
wire [7:0] DATA_out;
wire TVALID_out; 
wire TLAST_out ;


reg [3:0] count_0;
reg [4:0] count_1;



AXI_mux mux_dut (.ACLK(ACLK), .ARESETn(ARESETn), .DATA_in_0(DATA_in_0), .DATA_in_0(DATA_in_1), .sel(sel), .DATA_out(DATA_out),
.TVALID_in_0(TVALID_in_0), .TVALID_in_1(TVALID_in_1), .TLAST_in_0(TLAST_in_0), .TLAST_in_1(TLAST_in_1),
.TREADY_in(TREADY_in), .TREADY_out(TREADY_out), .TVALID_out(TVALID_out), .TLAST_out(TLAST_out));


always #5 ACLK = ~ACLK;

initial begin
     ACLK=0;
     ARESETn = 1; 
     DATA_in_0 = 0; TVALID_in_0 = 0; TLAST_in_0 = 0; count_0 = 0;
     DATA_in_1 = 64; TVALID_in_1 = 0; TLAST_in_1 = 0; count_1 = 0;
     sel = 0;
     TREADY_out = 0;

    #5 ARESETn = 0;

    #5 ARESETn = 1;


    #5 TVALID_in_0 =0 ; TVALID_in_1 =0 ; TREADY_out =1 ; sel =1;

    
    #5 TVALID_in_0 =1 ; TVALID_in_1 =0 ; TREADY_out =1 ; sel = 0 ;

    
    #5 TVALID_in_0 =1 ; TVALID_in_1 =0 ; TREADY_out =0 ; sel =0 ;


    #5 TVALID_in_0 =0 ; TVALID_in_1 =1 ; TREADY_out =0 ; sel =1 ;


    #5 TVALID_in_0 =0 ; TVALID_in_1 =1 ; TREADY_out =1 ; sel =1 ;

    
    #5 TVALID_in_0 =1 ; TVALID_in_1 =1 ; TREADY_out =1 ; sel =0 ;

    
    #5 TVALID_in_0 =1 ; TVALID_in_1 =1 ; TREADY_out =0 ; sel =1 ;

    
    #5 TVALID_in_0 =1 ; TVALID_in_1 =0 ; TREADY_out =1 ; sel =0 ;


end

always @(posedge ACLK) begin
    DATA_in_0 <= $random;
    DATA_in_1 <= $random;
    if (count_0 == 4'd7) begin
        TLAST_in_0 <= 1;
        count_0 <= 0;
    end
    else begin
        TLAST_in_0 <= 0;
        count_0 <= count_0 + 1'b1;
    end

    if (count_1 == 4'd15) begin
        TLAST_in_1 <= 1;
        count_1 <= 0;
    end
    else begin
        TLAST_in_1 <= 0;
        count_1 <= count_1 + 1'b1;
    end
end

endmodule
