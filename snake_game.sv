

module snake_game(
			input CLOCK_50, input [3:0] KEY, input [1:0] SW,
			inout PS2_CLK, PS2_DAT, 
			output [6:0]HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
			output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, 
			output [7:0] VGA_R, VGA_G, VGA_B
			);			
	wire iReset;
	
	assign iReset = KEY[0];
	
	// Values that will be changed by the keyboard & trigger a change in state
	wire ld_start_game;
	wire ld_restart_game;
	wire [7:0] last_data_received;
	
	// Wires to represent state of game
	wire start, play, gameover; 
			
	// Wires between vga and fsm
	wire ld_draw ,ld_erase, ld_apple_draw, ld_game_snake, ld_game_apple, draw_done;
	
	// wires between memory and fsm
	wire ld_build_start, ld_build_running, ld_build_end, start_build_done, running_build_done, end_build_done;
	
	// Slower clock to delay output
	wire DelayCounter;
	
	// Game variables
	wire [11:0] size;
	wire [7:0] apple_pos_X;
	wire [6:0] apple_pos_Y;
	
	wire [7:0] snake_body_pos_X[/*4096*/10:0];
	wire [6:0] snake_body_pos_Y[/*4096*/10:0];
	wire [3:0] direction;
	
	
	
	
	
	// KEYBOARD - PHOEBE
	keyboard_input keys(
		// Inputs
		.iClock(CLOCK_50), 
		.iReset(iReset),
		.iStart(start), 
		.iPlay(play), 
		.iGameover(gameover),
		.Key(last_data_received),
		
		// Outputs
		.ld_start_game(ld_start_game),
		.ld_restart_game(ld_restart_game),
		.direction(direction)
	);
	
	
	// KEYBOARD - UOFT
	PS2_Demo keyboard(
		// Inputs
		.CLOCK_50(CLOCK_50),
		.KEY(KEY),

		// Bidirectionals
		.PS2_CLK(PS2_CLK),
		.PS2_DAT(PS2_DAT),
		
		// Outputs
		.last_data_received(last_data_received)
		);
		

	// VGA datapath - PHOEBE
	vga draw(
		// Inputs
		.iClock(CLOCK_50), 
		.iReset(iReset),
		
		// Inputs - Game Variables
		.snake_body_pos_X(snake_body_pos_X),
		.snake_body_pos_Y(snake_body_pos_Y),
		.apple_pos_X(apple_pos_X), 
		.apple_pos_Y(apple_pos_Y),
		.size(size), 
		
		// Inputs - Draw signals
		.iPlay(play),
		.ld_draw(ld_draw),  
		.ld_erase(ld_erase), 
		.ld_apple_draw(ld_apple_draw), 
		.ld_game_snake(ld_game_snake), 
		.ld_game_apple(ld_game_apple),

		// Outputs - Draw signals
		.draw_done(draw_done),

		// Outputs - VGA outputs
		.VGA_CLK(VGA_CLK), 
		.VGA_HS(VGA_HS), 
		.VGA_VS(VGA_VS), 
		.VGA_BLANK_N(VGA_BLANK_N), 
		.VGA_SYNC_N(VGA_SYNC_N), 
		.VGA_R(VGA_R), 
		.VGA_G(VGA_G), 
		.VGA_B(VGA_B),
	
		// Inputs - Signals from fsm
		 .ld_build_start(ld_build_start), 
		 .ld_build_running(ld_build_running), 
		 .ld_build_end(ld_build_end), 
		
		// Outputs - Signals too fsm
		 .start_build_done(start_build_done), 
		 .running_build_done(running_build_done), 
		 .end_build_done(end_build_done)	
		);


	// RATE DIVIDER - PHOEBE
	rate_divider rd(
		// Inputs
		.iClock(CLOCK_50), 
		.iReset(iReset),  
		.speed(SW),
		
		// Outputs
		.DelayCounter(DelayCounter)
	);	

	

	// SNAKE GAME LOGIC - PHOEBE
	fsm snake(
		// Inputs
		.iClock(CLOCK_50), 
		.iReset(iReset), 
		
		// Inputs - Signals from keyboard
		.iStartGame(ld_start_game), 
		.iRestart(ld_restart_game), 		
		.direction(direction), 
		
		// Inputs - Time
		.DelayCounter(DelayCounter),
		
		// Inputs - Signals from VGA
		.draw_done(draw_done),
		
		// Outputs - Game Variables
		.size(size),
		.snake_body_pos_X(snake_body_pos_X), 
		.snake_body_pos_Y(snake_body_pos_Y),
		.apple_pos_X(apple_pos_X), 
		.apple_pos_Y(apple_pos_Y),
		
		// Outputs - Signals for game state
		.game_start(start), 
		.game_play(play), 
		.game_over(gameover),
		
		// Outputs - VGA signals
		.ld_draw(ld_draw),
		.ld_erase(ld_erase),
		.ld_apple_draw(ld_apple_draw),
		.ld_game_snake(ld_game_snake),
		.ld_game_apple(ld_game_apple),
		
		// Output - Signals to memory
		.ld_build_start(ld_build_start),
		.ld_build_running(ld_build_running),
		.ld_build_end(ld_build_end),
		
		// Inputs - Signals from memory
		// From VGA
		.start_build_done(start_build_done),
		.running_build_done(running_build_done),
		.end_build_done(end_build_done)
	);
	

	// PRINTING SCORE - PHOEBE
	hex_decoder b2(size[11:8], HEX2);
	hex_decoder b1(size[7:4], HEX1);
	hex_decoder b0(size[3:0], HEX0);

endmodule
