module traffic_light #(
    parameter integer CNT_WIDTH = 32,               // counter width
    parameter integer NS_GREEN_CYCLES = 50,         // NS green duration (clock cycles)
    parameter integer NS_YELLOW_CYCLES = 10,        // NS yellow duration
    parameter integer EW_GREEN_CYCLES = 50,         // EW green duration
    parameter integer EW_YELLOW_CYCLES = 10        // EW yellow duration
) (
    input  wire clk,
    input  wire rst,    // active-high synchronous reset
    // North-South outputs
    output reg ns_red,
    output reg ns_yellow,
    output reg ns_green,
    // East-West outputs
    output reg ew_red,
    output reg ew_yellow,
    output reg ew_green
);

    // FSM state encoding
    localparam [1:0]
        S_NS_GREEN  = 2'd0,
        S_NS_YELLOW = 2'd1,
        S_EW_GREEN  = 2'd2,
        S_EW_YELLOW = 2'd3;

    reg [1:0] state, next_state;
    reg [CNT_WIDTH-1:0] counter;
    reg [CNT_WIDTH-1:0] next_counter;

    // Synchronous state & counter update
    always @(posedge clk) begin
        if (rst) begin
            state   <= S_NS_GREEN;
            counter <= {CNT_WIDTH{1'b0}};
        end else begin
            state   <= next_state;
            counter <= next_counter;
        end
    end

    // Next-state logic and counter behavior
    always @(*) begin
        next_state = state;
        next_counter = counter;

        case (state)
            S_NS_GREEN: begin
                // outputs handled below (Moore)
                if (counter >= (NS_GREEN_CYCLES - 1)) begin
                    next_state = S_NS_YELLOW;
                    next_counter = 0;
                end else begin
                    next_counter = counter + 1;
                end
            end

            S_NS_YELLOW: begin
                if (counter >= (NS_YELLOW_CYCLES - 1)) begin
                    next_state = S_EW_GREEN;
                    next_counter = 0;
                end else begin
                    next_counter = counter + 1;
                end
            end

            S_EW_GREEN: begin
                if (counter >= (EW_GREEN_CYCLES - 1)) begin
                    next_state = S_EW_YELLOW;
                    next_counter = 0;
                end else begin
                    next_counter = counter + 1;
                end
            end

            S_EW_YELLOW: begin
                if (counter >= (EW_YELLOW_CYCLES - 1)) begin
                    next_state = S_NS_GREEN;
                    next_counter = 0;
                end else begin
                    next_counter = counter + 1;
                end
            end

            default: begin
                next_state = S_NS_GREEN;
                next_counter = 0;
            end
        endcase
    end

    // Output logic (Moore: outputs depend only on state)
    always @(*) begin
        // default all low
        ns_red    = 1'b0;
        ns_yellow = 1'b0;
        ns_green  = 1'b0;
        ew_red    = 1'b0;
        ew_yellow = 1'b0;
        ew_green  = 1'b0;

        case (state)
            S_NS_GREEN: begin
                ns_green = 1'b1;
                ew_red   = 1'b1;
            end

            S_NS_YELLOW: begin
                ns_yellow = 1'b1;
                ew_red    = 1'b1;
            end

            S_EW_GREEN: begin
                ew_green = 1'b1;
                ns_red   = 1'b1;
            end

            S_EW_YELLOW: begin
                ew_yellow = 1'b1;
                ns_red    = 1'b1;
            end

            default: begin
                ns_red = 1'b1;
                ew_red = 1'b1;
            end
        endcase
    end
