
module keyboard_input(input iClock, iReset,
					  input iStart, iPlay, iGameover,
					  input [7:0] Key,
					  output reg ld_start_game, ld_restart_game,
					  output reg [3:0] direction
					  );

	/*	Directions: 
		UP - 1000
		DOWN - 0100
		LEFT - 0010
		RIGHT - 0001
		DONT MOVE - 0000
	*/	
		
	always@(posedge iClock)
	begin
		if (!iReset) begin
			ld_start_game <= 0;
			ld_restart_game <= 0;
			direction <= 'b0;
		end else begin
			ld_start_game <= 0;
			ld_restart_game <= 0;
			
			
			// iStart high
			if (iStart) begin
				if (Key == 8'b00101001) // 8'h29 - space 
					ld_start_game <= 1;
			end
		
			// iPlay high
			if (iPlay)begin
				// down
				if (Key == 8'b00011101) //8'h1d
					direction <= 4'b0100;
					
				// up
				else if (Key == 8'b00011011) //8'h1b
					direction <= 4'b1000;
				
				//left 
				else if (Key == 8'b00011100) //8'h1c
					direction <= 4'b0010;

				//right
				else if (Key == 8'b00100011) //8'h23
					direction <= 4'b0001;
			end

			// iGameover high
			if(iGameover) begin
				if (Key == 8'b01011001)begin  // 8'h59 - shift
					ld_restart_game <= 1;
					direction <= 4'b0000;
				end
			end
		end
	end
endmodule
