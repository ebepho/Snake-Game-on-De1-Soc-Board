

module count (input iClock, iReset, input [11:0] size, input count_on, output reg [11:0] counter);
	always@(posedge iClock)
	begin
		if(!iReset) begin
			counter <= 'd1;			
		end else if(counter == 'b0) begin
			counter <= size;
		end else if(count_on) begin
			counter <= counter - 'b1;
		end
	end
endmodule
