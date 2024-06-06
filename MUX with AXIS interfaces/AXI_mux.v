module AXI_mux(
    input ACLK,
    input ARESETn,
    input [7:0] DATA_in_0, //! input data
    input [7:0] DATA_in_1, //! input data
    input sel,     //! select
    output reg [7:0] DATA_out, //!output data

    input TVALID_in_0,  // 
    input TVALID_in_1,
    input TLAST_in_0, 
    input TLAST_in_1,
    output TREADY_in,

    input TREADY_out,
    output reg TVALID_out, 
    output reg TLAST_out 
);


always @(posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) begin
        DATA_out = 0;
        TVALID_out = 0;
        TLAST_out = 0;
    end
    else begin
        // Default assignments
        DATA_out = 0;
        TVALID_out = 0;
        TLAST_out = 0;
        if (TREADY_in) begin
            if (sel==0) begin
                if (TVALID_in_0 == 1) begin
                    DATA_out = DATA_in_0;
                    TVALID_out = 1;
                    TLAST_out = TLAST_in_0;
                end
            end
            else begin
                if (TVALID_in_1 == 1) begin
                    DATA_out = DATA_in_1;
                    TVALID_out = 1;
                    TLAST_out = TLAST_in_1;
                end
            end
        end
    end
end


assign TREADY_in = TREADY_out;

endmodule
