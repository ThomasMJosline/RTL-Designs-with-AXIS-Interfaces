module fifo (
    input aclk,
    input aresetn, 

    input re_en,
    input wr_en,

    input [7:0] data_in,
    input last_in,

    output [7:0] data_out,
    output last_out,
    output full,
    output empty
);

(* ramstyle = "M9K" *) reg [7:0] mem [0:2047];
(* ramstyle = "M9K" *) reg tlast_mem [0:2047];

reg [11:0] Wr_ptr, Re_ptr;
reg [12:0] count;


assign full = (count == 13'd2048) ? 1'b1 : 1'b0;
assign empty = (count == 13'd0 ) ? 1'b1 : 1'b0;


//----------write---------
always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        Wr_ptr <= 12'd0;
    end
    else begin
        if (wr_en == 1) begin
            mem[Wr_ptr] <= data_in;
            tlast_mem[Wr_ptr] <= last_in;
            Wr_ptr <= Wr_ptr + 1'b1;
        end
    end
end 
 

//--------------dataout---------------------
assign data_out = mem[Re_ptr];
assign last_out = tlast_mem[Re_ptr];


//--------Read ptr updating and reading
always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        Re_ptr <= 12'd0;
    end
    else begin
        if (re_en == 1) begin
            Re_ptr <= Re_ptr + 1'b1;
        end
    end
end


//---------count---------
always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        count <= 13'd0;
    end
    else begin
    case ({wr_en == 1, re_en == 1})
        2'b10 : count <=(~full) ? count + 1'b1 : count;
        2'b01 : count <= (~empty) ? count - 1'b1 : count;
        2'b11 : count <= count;
        2'b00 : count <= count;
        default: count <= count;
    endcase
    end
end
endmodule
