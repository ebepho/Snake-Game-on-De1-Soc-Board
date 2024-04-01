

module memory_counter (input iClock, iReset, plot, output reg [7:0] counter_X, output reg [6:0] counter_Y, output reg [14:0] address, output reg done);
	always @ (posedge iClock)
	begin
		done <= 0;
		if(!iReset) begin
			counter_X <= 0;
			counter_Y <= 0;
			address <= 0;
		end else if(plot) begin
			counter_X <= counter_X + 1;
			address <= address + 1;
			
			
			if(counter_X == 'd159) begin
				counter_Y <= counter_Y + 1;
				counter_X <= 0;	
			end		
		
			if(counter_Y == 'd119 && counter_X == 'd159) begin
				counter_Y <= 0;
				counter_X <= 0;
				address <= 0;
				done <= 1;
			end
	
		end
	end
endmodule	