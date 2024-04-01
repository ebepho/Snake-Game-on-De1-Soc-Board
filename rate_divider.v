module rate_divider (input iClock, iReset, input [1:0] speed, output DelayCounter);	
	parameter CLOCKS_PER_SECOND = 5000000;
	parameter CLOCKS_PER_HALF_SECOND = 2500000; 
	parameter CLOCKS_PER_QAURTER_SECOND = 1250000;
	parameter CLOCKS_PER_EIGTH_SECOND = 625000;
	
	reg [23:0] time_clock;
	
	
	reg [23:0] counter;
	
	
	always @ (posedge iClock)
	begin
		case(speed) 
			2'b00: time_clock <= CLOCKS_PER_SECOND;
			2'b01: time_clock <= CLOCKS_PER_HALF_SECOND;
			2'b10: time_clock <= CLOCKS_PER_QAURTER_SECOND;
			2'b11: time_clock <= CLOCKS_PER_EIGTH_SECOND;
		endcase
		
		
		if(!iReset) begin
			counter <= time_clock - 1;
		end else begin
			if(counter == 0)begin
				counter <= time_clock - 1;
			end
			
			counter <= counter - 1;
		end 
	end
	
	assign DelayCounter = (counter == 'b0)? 'b1:'b0;	
endmodule
