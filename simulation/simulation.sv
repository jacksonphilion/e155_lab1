/*
Jackson Philion, Sep.5.2024, jphilion@g.hmc.edu. Code to run a 7 segment display with an FPGA,
at Harvey Mudd College for E155: Microprocessors, taught by Prof Josh Brake.
*/
module top(
input logic clk,
input logic reset,
input logic [3:0]   s,
output logic   [6:0]   seg,
    output  logic   [2:0]   led
);


    // Oscillator-based Counter which divides by 20million to get frequency 2.4Hz
logic [4:0] counter = 0;
    always_ff @(posedge clk)
if (~(reset)) counter <= 0;
else if (counter < 5'd20) counter <= counter + 1;
        else    counter <= 0;

    // LED Output Logic
    assign led[0] = s[1] ^ s[0];
    assign led[1] = s[3] & s[2];
    always_comb
if (counter > 5'd10) led[2] = 1;
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

module testbench();

  // Instantiate variables from across the modules that you need to use in testbench
  logic        clk;
  logic        reset;
  logic [3:0]	s;
  logic [6:0]	seg;
  logic [1:0]	led;

  logic [31:0] vectornum, errors;
  logic [25:0] testvectors[10000:0];
  
  logic        new_error;
  logic [8:0] expected;

  // instantiate device to be tested
  top dut(clk, reset, s, seg, led);
  
  // generate clock
  always 
    begin
      clk = 1; #5; clk = 0; #5;
    end

  // at start of test, load vectors and pulse reset
  initial
    begin
      $readmemb("testvectors.tv", testvectors);
      vectornum = 0; errors = 0;
      reset = 1; #5; reset = 0;
    end
	 
  // apply test vectors on rising edge of clk
  always @(posedge clk)
    begin
      #1; {s, expected} = testvectors[vectornum];
    end

  // check results on falling edge of clk
  always @(negedge clk)
    if (~reset) begin // skip cycles during reset
      new_error=0; 

      if ((led!==expected[1:0])&&(expected[1:0]!==2'bxx)) begin
        $display("   led = %b     Expected %b", led,    expected[1:0]);
        new_error=1;
      end
      if ((seg!==expected[8:2])&&(expected[8:2]!==7'bxxxxxxx)) begin
        $display("   seg = %b     Expected %b", seg,    expected[8:2]);
        new_error=1;
      end

      if (new_error) begin
        $display("Error on vector %d: inputs: s = %h seg = %h led = %h", vectornum, s, seg, led);
        errors = errors + 1;
      end
      vectornum = vectornum + 1;
      if (testvectors[vectornum] === 48'bx) begin 
        $display("%d tests completed with %d errors", vectornum, errors);
        $stop;
      end
    end
endmodule