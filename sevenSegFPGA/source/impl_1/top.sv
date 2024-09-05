module top(
input logic reset,
input logic [3:0]   s,
output logic   [6:0]   seg,
    output  logic   [2:0]   led
);

// High Frequency 48MHz Oscillator
logic int_osc;
    HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
   
    // Oscillator-based Counter which divides by 20million to get frequency 2.4Hz
logic [24:0] counter = 0;
    always_ff @(posedge int_osc)
if (~(reset)) counter <= 0;
else if (counter < 25'd20_000_000) counter <= counter + 1;
        else    counter <= 0;

    // LED Output Logic
    assign led[0] = s[1] ^ s[0];
    assign led[1] = s[3] & s[2];
    always_comb
if (counter > 25'd10_000_000) led[2] = 1;
else led[2] = 0;

    // Segment Logic
    always_comb
        case (s)
            4'h0: seg <= ~7'b1111110;
            4'h1: seg <= ~7'b1001000;
            4'h2: seg <= ~7'b0111101;
            4'h3: seg <= ~7'b1101101;
            4'h4: seg <= ~7'b1001011;
            4'h5: seg <= ~7'b1100111;
            4'h6: seg <= ~7'b1110111;
            4'h7: seg <= ~7'b1001100;
            4'h8: seg <= ~7'b1111111;
            4'h9: seg <= ~7'b1001111;
            4'ha: seg <= ~7'b1011111;
            4'hb: seg <= ~7'b1110011;
            4'hc: seg <= ~7'b0110001;
            4'hd: seg <= ~7'b1111001;
            4'he: seg <= ~7'b0110111;
            4'hf: seg <= ~7'b0010111;
            default: seg <= ~7'b0000001;
        endcase


endmodule