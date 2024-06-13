module AXI_register (
    input aclk,
    input aresetn, //!active low reset
    input [7:0] s_axis_tdata, //! input data
    input s_axis_tvalid,//! VALID signal for the input data
    input s_axis_tlast,//! Signal goes high when last signal arrives 
    output s_axis_tready,//! Signal that shows the module is ready to receive data

    input m_axis_tready, //! signal that shows that the downstream slave module is ready to receive data for the register module
    output  m_axis_tvalid,//! VALID signal for the output data
    output reg [7:0] m_axis_tdata, //! output data
    output reg m_axis_tlast       //! LAST signal at output side
);

reg [7:0] mem;
reg last;
reg full;


//----------read-or-write---------
always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        mem <= 8'd0;
        last <= 1'd0;
        m_axis_tdata <= 8'd0;
        m_axis_tlast <= 1'd0;
    end
    else begin
        if (s_axis_tvalid && s_axis_tready) begin
            mem <= s_axis_tdata;
            last <= s_axis_tlast;
        end
        if (m_axis_tready && m_axis_tvalid) begin
            m_axis_tdata <= mem;
            m_axis_tlast <= last;
        end
end
end

//-----handling-full--------
always @(posedge aclk or negedge aresetn) begin
    if (!aresetn)
        full <= 0;
    else begin
        if (s_axis_tvalid && s_axis_tready && m_axis_tready && m_axis_tvalid) begin
            full <= 1;
        end
        if (s_axis_tvalid && s_axis_tready && !(m_axis_tready && m_axis_tvalid)) begin
            full <= 1;
        end
        if (m_axis_tready && m_axis_tvalid && !(s_axis_tvalid && s_axis_tready)) begin
            full <= 0;
        end
    end
end

//-----handling-AXIS-signals--
assign s_axis_tready = (m_axis_tready && full) ? 1'b1 : !full;
assign m_axis_tvalid = (s_axis_tvalid && !full) ? 1'b1 : full;


endmodule
