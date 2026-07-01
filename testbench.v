`timescale 1ns/1ps

module traffic_light_tb;

    // Inputs
    reg clk;
    reg Sa;
    reg Sb;

    // Outputs
    wire Ra;
    wire Rb;
    wire Ga;
    wire Gb;
    wire Ya;
    wire Yb;

    // Instantiate the DUT (Device Under Test)
    traffic_light uut (
        .clk(clk),
        .Sa(Sa),
        .Sb(Sb),
        .Ra(Ra),
        .Rb(Rb),
        .Ga(Ga),
        .Gb(Gb),
        .Ya(Ya),
        .Yb(Yb)
    );

    // Clock generation (10 ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin

        // Initialize inputs
        Sa = 0;
        Sb = 0;

        // Display simulation results
        $display("Time\tState\tSa Sb | RA YA GA | RB YB GB");
        $monitor("%0t\t%d\t%b  %b |  %b  %b  %b |  %b  %b  %b",
                 $time,
                 uut.state,
                 Sa, Sb,
                 Ra, Ya, Ga,
                 Rb, Yb, Gb);

        // Run with no vehicles on Road B
        #60;

        // Vehicle arrives on Road B
        Sb = 1;
        #40;

        // Vehicle leaves Road B
        Sb = 0;
        #20;

        // Vehicle arrives on Road A
        Sa = 1;
        #40;

        // Vehicle leaves Road A
        Sa = 0;
        #40;

        // Vehicles on both roads
        Sa = 1;
        Sb = 1;
        #60;

        // Clear sensors
        Sa = 0;
        Sb = 0;
        #40;

        $finish;
    end

endmodule