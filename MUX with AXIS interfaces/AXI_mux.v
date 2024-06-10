module AXI_mux(
    input aclk,
    input aresetn,
    input [7:0] s_axis_tdata_0, //! input data
    input [7:0] s_axis_tdata_1, //! input data
    input sel,     //! select
    output reg [7:0] m_axis_tdata, //!output data

    input s_axis_tvalid_0,  //! VALID signal for s_axis_tdata_0
    input s_axis_tvalid_1,  //! VALID signal for s_axis_tdata_1
    input s_axis_tlast_0,  //! LAST signal for s_axis_tdata_0
    input s_axis_tlast_1,  //! LAST signal for s_axis_tdata_0
    output s_axis_tready,  //! signal that shows the slave(FIFO) is ready to accept data

    input m_axis_tready,   //! signal that shows the master is ready accept data
    output reg m_axis_tvalid, //! VALID signal for output data (m_axis_tdata)
    output reg m_axis_tlast   //! LAST signal for the output data
);


always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        m_axis_tdata = 0;
        m_axis_tvalid = 0;
        m_axis_tlast = 0;
    end
    else begin
        // Default assignments
        m_axis_tdata = 0;
        m_axis_tvalid = 0;
        m_axis_tlast = 0;
        if (s_axis_tready) begin
            if (sel==0) begin
                if (s_axis_tvalid_0 == 1) begin
                    m_axis_tdata = s_axis_tdata_0;
                    m_axis_tvalid = 1;
                    m_axis_tlast = s_axis_tlast_0;
                end
            end
            else begin
                if (s_axis_tvalid_1 == 1) begin
                    m_axis_tdata = s_axis_tdata_1;
                    m_axis_tvalid = 1;
                    m_axis_tlast = s_axis_tlast_1;
                end
            end
        end
    end
end


assign s_axis_tready = m_axis_tready;

endmodule
