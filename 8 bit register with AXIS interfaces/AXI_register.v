module AXI_register (
    input aclk,
    input aresetn, //!active low reset
    input [7:0] s_axis_tdata, //! input data
    input s_axis_tvalid,//! VALID signal for the input data
    input s_axis_tlast,//! Signal goes high when last signal arrives 
    output reg s_axis_tready,//! Signal that shows the module is ready to receive data

    input m_axis_tready, //! signal that shows that the downstream slave module is ready to receive data for the register module
    output reg m_axis_tvalid,//! VALID signal for the output data
    output reg [7:0] m_axis_tdata, //! output data
    output reg m_axis_tlast       //! LAST signal at output side
);


reg [7:0] data_reg;
reg last_reg;

always @(posedge aclk) begin
    if (!aresetn) begin
        data_reg <= 8'b0;
        last_reg <= 1'b0;
        s_axis_tready <= 1'b1;
        m_axis_tdata <= 8'b0;
        m_axis_tvalid <= 1'b0;
        m_axis_tlast <= 1'b0;
    end else begin
        if (s_axis_tvalid && s_axis_tready) begin
            data_reg <= s_axis_tdata;
            last_reg <= s_axis_tlast;
            s_axis_tready <= 1'b0;
        end else begin               
            if (m_axis_tvalid && m_axis_tready)
                s_axis_tready <= 1'b1;                                                     // if there is no data in register and the data transfer have finished
        end                                                     // s_axis_tready is made high, else it is low


        if (m_axis_tvalid && m_axis_tready) begin               
            m_axis_tvalid <= 1'b0;                              //if a transfer is over, m_axis_tvalid becomes zero
            m_axis_tlast <= 1'b0;
        end else if (!m_axis_tvalid && !s_axis_tready) begin      // if there is data in the register m_axis_tvalid is made high      
            m_axis_tdata <= data_reg;                               //     and that data is moved to the output line
            m_axis_tvalid <= 1'b1;
            m_axis_tlast <= last_reg;
        end
    end
end


endmodule
