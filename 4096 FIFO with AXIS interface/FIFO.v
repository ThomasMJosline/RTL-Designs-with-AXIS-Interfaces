module FIFO (
    input aclk,
    input aresetn, 

    input [7:0] data_in,
    input wr_en,
    input re_en,
    input tlast_in,

    output reg [7:0] data_out,
    output reg tlast_out,
    output full,
    output empty
);



reg [7:0] mem [0:2047];
reg tlast_mem [0:2047];

reg [10:0] Wr_ptr, Re_ptr;
reg [12:0] count;

assign full = (count == 13'd2048) ? 1'b1 : 1'b0;
assign empty = (count == 13'd0 ) ? 1'b1 : 1'b0;


//----------write---------
always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        Wr_ptr <= 11'd0;
    end
    else begin
        if (wr_en == 1 ) begin
            if (~full || re_en) begin
                mem[Wr_ptr] <= data_in;
                tlast_mem[Wr_ptr] <= tlast_in;
                Wr_ptr <= Wr_ptr + 1'b1;
            end
        end
        end
end 
 

//----------read---------
always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        Re_ptr <= 11'd0;
        data_out <= 8'd0;
        tlast_out <= 0;
    end
    else if (re_en == 1) begin
            if (~empty || wr_en) begin
                if (wr_en && (Wr_ptr == Re_ptr)) begin
                    // If writing to the same address as reading, prioritize read
                    data_out <= data_in;
                    tlast_out <= tlast_in;
                end 
                else begin
                    data_out <= mem[Re_ptr];
                    tlast_out <= tlast_mem[Re_ptr];
                end
                Re_ptr <= Re_ptr + 1'b1;
            end
        end
end


//---------count---------
always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        count <= 12'd0;
    end
    else begin
        case ({wr_en, re_en})
            2'b10 : count <=(~full) ? count + 1'b1 : count;
            2'b01 : count <= (~empty) ? count - 1'b1 : count;
            2'b11 : count <= count;
            2'b00 : count <= count;
            default: count <= count;
        endcase
    end
end

endmodule
