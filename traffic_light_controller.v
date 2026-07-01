module traffic_light (
    input  clk,
    input  Sa,
    input  Sb,
    output Ra,
    output Rb,
    output Ga,
    output Gb,
    output Ya,
    output Yb
);

    // Output registers
    reg Ra_tmp, Rb_tmp;
    reg Ga_tmp, Gb_tmp;
    reg Ya_tmp, Yb_tmp;

    // State registers
    reg [3:0] state;
    reg [3:0] nextstate;

    // Light encoding
    parameter [1:0] R = 2'b00;
    parameter [1:0] Y = 2'b01;
    parameter [1:0] G = 2'b10;

    wire [1:0] lightA;
    wire [1:0] lightB;

    // Connect internal registers to outputs
    assign Ra = Ra_tmp;
    assign Rb = Rb_tmp;
    assign Ga = Ga_tmp;
    assign Gb = Gb_tmp;
    assign Ya = Ya_tmp;
    assign Yb = Yb_tmp;

    // Initial state
    initial begin
        state = 4'd0;
    end

    // Next-state and output logic
    always @(state or Sa or Sb) begin

        // Default outputs
        Ra_tmp = 1'b0;
        Rb_tmp = 1'b0;
        Ga_tmp = 1'b0;
        Gb_tmp = 1'b0;
        Ya_tmp = 1'b0;
        Yb_tmp = 1'b0;

        nextstate = 4'd0;

        case (state)

            // States 0–4: Road A Green, Road B Red
            0,1,2,3,4: begin
                Ga_tmp = 1'b1;
                Rb_tmp = 1'b1;
                nextstate = state + 1;
            end

            // Wait until vehicle detected on Road B
            5: begin
                Ga_tmp = 1'b1;
                Rb_tmp = 1'b1;

                if (Sb == 1'b1)
                    nextstate = 6;
                else
                    nextstate = 5;
            end

            // Yellow on Road A
            6: begin
                Ya_tmp = 1'b1;
                Rb_tmp = 1'b1;
                nextstate = 7;
            end

            // States 7–10: Road B Green, Road A Red
            7,8,9,10: begin
                Ra_tmp = 1'b1;
                Gb_tmp = 1'b1;
                nextstate = state + 1;
            end

            // Wait until vehicle detected on Road A
            11: begin
                Ra_tmp = 1'b1;
                Gb_tmp = 1'b1;

                if ((Sa == 1'b1) || (Sb == 1'b0))
                    nextstate = 12;
                else
                    nextstate = 11;
            end

            // Yellow on Road B
            12: begin
                Ra_tmp = 1'b1;
                Yb_tmp = 1'b1;
                nextstate = 0;
            end

            default: begin
                nextstate = 0;
            end

        endcase
    end

    // State register
    always @(posedge clk) begin
        state <= nextstate;
    end

    // Light encoding
    assign lightA = (Ra == 1'b1) ? R :
                    (Ya == 1'b1) ? Y :
                    (Ga == 1'b1) ? G : 2'b00;

    assign lightB = (Rb == 1'b1) ? R :
                    (Yb == 1'b1) ? Y :
                    (Gb == 1'b1) ? G : 2'b00;

endmodule