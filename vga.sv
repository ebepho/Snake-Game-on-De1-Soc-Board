

module vga (input iClock, iReset,
			input [7:0] snake_body_pos_X[/*4096*/10:0],
			input [6:0] snake_body_pos_Y[/*4096*/10:0],
			input [7:0] apple_pos_X,
			input [6:0] apple_pos_Y,
			input [11:0] size, 
			input iPlay, ld_draw, ld_erase, ld_apple_draw, ld_game_snake, ld_game_apple,
			
			output reg draw_done,
			output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, 
			output [7:0] VGA_R, VGA_G, VGA_B,
			
			
			// Signals from fsm for memory
			input ld_build_start, ld_build_running, ld_build_end, 
			
			// Signals too fsm for memory
			output start_build_done, running_build_done, end_build_done
			);
			
	wire [7:0] x;
	wire [6:0] y;
	wire [2:0] colour;
	wire writeEn;
	
	reg [7:0] vga_x;
	reg [6:0] vga_y;
	reg [2:0] vga_colour;
	reg vga_writeEn;
	
	wire [15:0] counter;
	
	wire [7:0] x_memory;
	wire [6:0] y_memory;
	wire [2:0] start_colour_memory, black_colour_memory, end_colour_memory;
	wire [14:0] address;
	wire done;

	always@(posedge iClock)
	begin
		// iReset high 
		if (!iReset) begin
			// draw border (screen size is 160 X 160)
			
		end else begin
			// By default, set signals to low
			vga_writeEn <= 0; 
			draw_done <= 0;
			
			// ------------------------- MEMORY -------------------------
			if(ld_build_start)begin
				vga_writeEn <= 1;
				vga_x <= x_memory;
				vga_y <= y_memory;
				vga_colour <= start_colour_memory;
			end
			
			if(ld_build_running )begin
				vga_writeEn <= 1;
				vga_x <= x_memory;
				vga_y <= y_memory;
				vga_colour <= black_colour_memory;
			end
			
			if(ld_build_end)begin
				vga_writeEn <= 1;
				vga_x <= x_memory;
				vga_y <= y_memory;
				vga_colour <= end_colour_memory;
			end
			// ---------------------------------------------------------
			
			
			// ------------------------- VGA -------------------------
			if(iPlay) begin
				// Load the start of the game by drawing snake and apple
				if(ld_game_snake) begin
					vga_x <= snake_body_pos_X [0];
					vga_y <= snake_body_pos_Y [0];
					
					vga_colour <= 3'b010;
					vga_writeEn <= 1;	
				end
				
				if(ld_game_apple) begin
					vga_x <= apple_pos_X;
					vga_y <= apple_pos_Y;
					
					vga_colour <= 3'b100;
					vga_writeEn <= 1;	
				end
				
				
				// erase tail 
				if(ld_erase)begin	
					vga_x <= snake_body_pos_X [size];
					vga_y <= snake_body_pos_Y [size];
					
					vga_colour <= 3'b000;
					vga_writeEn <= 1;					
				end  
				
				
				// draw snake
				if(ld_draw)begin
					if(counter < size) begin
						vga_x <= snake_body_pos_X [counter];
						vga_y <= snake_body_pos_Y [counter];	
						vga_colour <= 3'b010;
						vga_writeEn <= 1;	
					end
					
					draw_done <= (counter == 'b1)? 'b1:'b0;
				end 
				
				//draw apple
				if(ld_apple_draw)begin
					vga_x <= apple_pos_X;
					vga_y <= apple_pos_Y;
					
					vga_colour <= 3'b100;
					vga_writeEn <= 1;		
				end
			end
			// ------------------------------------------------------
			
		end
	end	
	
	assign x = vga_x;
	assign y = vga_y;
	assign colour = vga_colour;
	assign writeEn = vga_writeEn;
	
	assign start_build_done = done;
	assign running_build_done = done;
	assign end_build_done = done;
	
	vga_adapter VGA(
			.resetn(iReset),
			.clock(iClock),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			// Signals for the DAC to drive the monitor.
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
	
	
	
	
	
	// Counter for moving body
	count count_snake(
		.iClock(iClock), 
		.iReset(iReset), 
		.size(size), 
		.count_on(ld_draw), 
		.counter(counter)
		);
	
	
	// ------------------------- MEMORY -------------------------
	memory_counter mc( 
		.iClock(iClock), 
		.iReset(iReset), 
		.plot(ld_build_start | ld_build_running | ld_build_end), 
		.counter_X(x_memory), 
		.counter_Y(y_memory),
		.address(address),
		.done(done)
		);

		
	start start_colour(
		.address(address),
		.clock(iClock),
		.q(start_colour_memory)
		);
		
	black black_colour(
		.address(address),
		.clock(iClock),
		.q(black_colour_memory)
		);

		
	over over_colour(
		.address(address),
		.clock(iClock),
		.q(end_colour_memory)
		);

endmodule






