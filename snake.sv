

/*****************************************************************************
 *                              Top Level Modul                              *
 *****************************************************************************/
 
module fsm(
	input iClock, iReset, 
	
	// Signals from keyboard
	input iStartGame, iRestart, 
	
	// From keyboard
	input [3:0] direction, 
	
	// From counter
	input DelayCounter, 

	// Game play variables
	output [11:0] size,
	output [7:0] apple_pos_X, 
	output [6:0] apple_pos_Y, 
	output [7:0] snake_body_pos_X[/*4096*/10:0],
	output [6:0] snake_body_pos_Y[/*4096*/10:0],
		
	// Signals to entire game
	output game_start, game_play, game_over,	
	
	// From memory from game state
	input start_build_done, running_build_done, end_build_done,
	
	// To memory from game state
	output ld_build_start, ld_build_running, ld_build_end,
	 
	// From VGA
	input draw_done,
	 
	// To VGA from game play
	output ld_draw, ld_erase, ld_apple_draw, ld_game_snake, ld_game_apple 
);

	// Signals for GameState FSM
	wire ld_start, ld_running, ld_end;
	
	// Signals for GamePlay FSM
	wire ld_static, ld_update, ld_move_body, ld_move_head, ld_wall_coll, ld_apple_coll, ld_body_coll, ld_check_collision;
	wire wall_coll, apple_coll, body_coll, move_snake, move_done, apple_done;
	
	// Signals between FSMs
	wire play_game, end_game;
	
	// ----------------- FSM for game state -----------------
	control_game_state c0(
		.iClock(iClock), 
		.iReset(iReset), 
		
		// From keyboard module
		.iStartGame(iStartGame), 
		.iRestart(iRestart),
		
		// From game play fsm
		.end_game(end_game), 
		
		// From memory
		.start_build_done(start_build_done),
		.running_build_done(running_build_done),
		.end_build_done(end_build_done),
		
		// To datapath
		.ld_start(ld_start), 
		.ld_running(ld_running), 
		.ld_end(ld_end),
		
		// To memory
		.ld_build_start(ld_build_start),
		.ld_build_running(ld_build_running),
		.ld_build_end(ld_build_end)
		);
		



	datapath_game_state d0(
		.iClock(iClock), 
		.iReset(iReset), 
		
		// from control
		.ld_start(ld_start), 
		.ld_running(ld_running), 
		.ld_end(ld_end),
		
		// To entire game
		.game_start(game_start), 
		.game_play(game_play), 
		.game_over(game_over),
		
		// To game play fsm
		.play_game(play_game)
	);
	



	// ----------------- FSM for game logic -----------------
	control_gameplay c1(
		.iClock(iClock), 
		.iReset(iReset),
		.DelayCounter(DelayCounter), 
		
		// From game state fsm
		.play_game(play_game),
		.iRestart(iRestart),
		
		// From datapath
		.apple_coll(apple_coll), 
		.wall_coll(wall_coll),  
		.body_coll(body_coll),
		.move_snake(move_snake), 
		.move_done(move_done), 	
		.apple_done(apple_done),
		
		// From VGA
		.draw_done(draw_done),
		
		// To datapath
		.ld_static(ld_static), 
		.ld_update(ld_update), 
		.ld_move_body(ld_move_body), 
		.ld_move_head(ld_move_head), 
		.ld_wall_coll(ld_wall_coll), 
		.ld_apple_coll(ld_apple_coll),
		.ld_body_coll(ld_body_coll),
		.ld_check_collision(ld_check_collision),
		
		// To VGA
		.ld_game_snake(ld_game_snake),
		.ld_game_apple(ld_game_apple),
		.ld_apple_draw(ld_apple_draw),
		.ld_draw(ld_draw), 
		.ld_erase(ld_erase)
		
	);	


	datapath_gameplay d1(
		.iClock(iClock), 
		.iReset(iReset),
		
		// From control
		.ld_static(ld_static), 
		.ld_update(ld_update), 
		.ld_check_collision(ld_check_collision),
		.ld_move_body(ld_move_body), 
		.ld_move_head(ld_move_head), 
		.ld_wall_coll(ld_wall_coll), 
		.ld_apple_coll(ld_apple_coll), 
		.ld_body_coll(ld_body_coll),

		// Game inputs		
		.direction(direction),	
		
		// To control
		.apple_coll(apple_coll), 
		.wall_coll(wall_coll),
		.body_coll(body_coll),
		.move_snake(move_snake),
		.move_done(move_done),
		.apple_done(apple_done),
		
		// To game state fsm
		.end_game(end_game),
		
		// Game outputs
		.size(size), 
		.snake_body_pos_X(snake_body_pos_X), 
		.snake_body_pos_Y(snake_body_pos_Y),
		.apple_pos_X(apple_pos_X), 
		.apple_pos_Y(apple_pos_Y)		
	);
endmodule









/*****************************************************************************
 *                           FSM for gamestate                               *
 *****************************************************************************/
module control_game_state(
	input  iClock, iReset, 
	
	// From keyboard module
	input iStartGame, iRestart,

	// From game play fsm
	input end_game,

	// From VGA
	input start_build_done, running_build_done, end_build_done,

	// to datapath
	output reg ld_start, ld_running, ld_end, ld_build_start, ld_build_running, ld_build_end 
);
	
	
	 // State
	 reg [5:0] current_state, next_state;
	
	 // States
    localparam 			BUILD_START				= 5'd0,
								START  	      	 	= 5'd1,
								
								BUILD_RUNNING			= 5'd2,
								RUNNING       			= 5'd3,
								
								BUILD_END				= 5'd4,
								END 						= 5'd5;
				
	 // State table
    always@(*)
    begin: state_table
		case (current_state)
			// Draw start screen
			BUILD_START:	next_state 	= (start_build_done)? 		START				:	BUILD_START;		
			
			// Triggers game when keyboard sends message
			START: 			next_state 	= (iStartGame)? 				BUILD_RUNNING 	: 	START;
			

			
			// Draw over with black
			BUILD_RUNNING:	next_state	=	(running_build_done)?	RUNNING			:	BUILD_RUNNING;
		
			// Triggers game over when game play datapath sends message that the game has ended
			RUNNING: 		next_state 	= (end_game)? 					BUILD_END		: 	RUNNING;
			
			
			
			
			// Draw end screen
			BUILD_END:		next_state	=	(end_build_done)?			END				:	BUILD_END;
			
			// Restarts game when keyboard sends message 
			END:				next_state 	= (iRestart)?					BUILD_START		: 	END;
			
			default: 		next_state 	=  BUILD_START;
		endcase
	end
	
	 // Output logic - datapath control signals
    always @(*)
    begin: enable_signals
		// By default make all our signals 0
		ld_start = 0;
		ld_running = 0;
		ld_end = 0;
		ld_build_start = 0;
		ld_build_running = 0;
		ld_build_end = 0;
		
		case (current_state)
			BUILD_START: begin
				ld_build_start = 1;
				end
			START: begin
				ld_start = 1;
				end
			
			BUILD_RUNNING: begin
				ld_build_running = 1;
				end
			RUNNING: begin
				ld_running = 1;
				end
			
			BUILD_END: begin
				ld_build_end = 1;
				end
			END: begin
				ld_end = 1;
				end
			default:;	
		endcase
	end 

	 // Current_state registers
    always@(posedge iClock)
    begin: state_FFs
        if(!iReset)begin
            current_state <= BUILD_START;	
        end else 
            current_state <= next_state;	
    end 
endmodule


module datapath_game_state(
	input  iClock, iReset,
	
	// From control
	input ld_start, ld_running, ld_end,   
	
	// Signals to entire game
	output reg game_start, game_play, game_over,
	
	// Signal to other fsm
	output reg play_game
);
	
	always@(posedge iClock) begin
        if(!iReset) begin
			game_start <= 0;
			game_play <= 0;
			game_over <= 0;
			play_game <= 0;
			
			end else begin
				game_start <= 0;
				game_play <= 0;
				game_over <= 0;
				play_game <= 0;
				
				if(ld_start)begin
					game_start <= 1;
				end

				if(ld_running)begin
					game_play <= 1;	
					play_game <= 1;
				end
				
				if(ld_end)begin
					game_over <= 1;			
				end
			
		end
	end	
endmodule








/*****************************************************************************
 *                           FSM for gameplay                                *
 *****************************************************************************/
module control_gameplay(
	input iClock, iReset, DelayCounter,
	
	// From game state fsm 
	input play_game, iRestart,

	// From datapath
	input wall_coll, apple_coll, body_coll, move_snake, move_done, apple_done, 

	// From VGA
	input draw_done,
	
	// To datapath
	output reg ld_game_apple, ld_game_snake, ld_static, ld_update, ld_check_collision, ld_move_body, ld_move_head, ld_wall_coll, ld_apple_coll, ld_body_coll, ld_apple_draw, ld_draw, ld_erase

	);

	// State
	reg [5:0] current_state, next_state;
	
	// States
    localparam      	LOAD_GAME_APPLE				= 5'd0,
							LOAD_GAME_SNAKE				= 5'd1,
							STATIC  	      				= 5'd2,					
							UPDATE							= 5'd3,
							CHECK_COLLISION				= 5'd4,
							MOVE_BODY       				= 5'd5,
							MOVE_HEAD       				= 5'd6,
							WALL_COLLISION					= 5'd7,
							APPLE_COLLISION				= 5'd8,
							BODY_COLLISION					= 5'd9,
							APPLE_DRAW						= 5'd10,
							DRAW								= 5'd11,
							ERASE								= 5'd12;
				
	// State table
    always@(*)
    begin: state_table
            case (current_state)
				STATIC: 			next_state = (play_game)? 			LOAD_GAME_SNAKE 	: 	STATIC;
				LOAD_GAME_SNAKE:	next_state = LOAD_GAME_APPLE;
				LOAD_GAME_APPLE:	next_state = UPDATE;
								
				// stay in the update state until a second has passed 
				UPDATE: next_state = (DelayCounter && play_game)? CHECK_COLLISION: UPDATE;
				
				// check for any kind of collision
				CHECK_COLLISION:  
				begin
						if(wall_coll) 
							next_state = WALL_COLLISION;
						else if(apple_coll) 
							next_state = APPLE_COLLISION;
						else if (body_coll)
							next_state = BODY_COLLISION;
						else if (move_snake) 
							next_state = MOVE_BODY;
						else
							next_state = CHECK_COLLISION;
				end
							
				// find a new position for the apple
				APPLE_COLLISION:	next_state = /*(apple_done)?*/ APPLE_DRAW	/*:	APPLE_COLLISION*/;
				
				// draw the apple in it's new position, 1 clock
				APPLE_DRAW:			next_state =  					MOVE_BODY;
				 
				
				// move the body of the snake
				MOVE_BODY: 			next_state = (move_done)? 	MOVE_HEAD 	: 	MOVE_BODY;
				
				
				// move the head of the snake, 1 clock
				MOVE_HEAD: 			next_state = ERASE;
					
				// erase the tail of the snake, 1 clock
				ERASE: 				next_state =  DRAW;
				
				// draw everything in it's new position
				DRAW:				next_state = (draw_done)?		UPDATE		:	DRAW;
						
				// when wall or body is hit, trigger game over
				WALL_COLLISION:		next_state = (iRestart)?	STATIC	:	WALL_COLLISION;
				BODY_COLLISION:		next_state = (iRestart)?	STATIC	:	BODY_COLLISION; 
				
            default: 				next_state = STATIC;
        endcase
    end 
	
	
	
	// Output logic - datapath control signals
    always @(*)
    begin: enable_signals
		// By default make all our signals 0
		ld_game_snake = 0;
		ld_game_apple = 0;
		ld_static = 0;
		ld_update = 0; 
		ld_check_collision = 0;
		ld_move_body = 0; 
		ld_move_head = 0;
		ld_wall_coll = 0; 
		ld_apple_coll  = 0;
		ld_body_coll = 0;
		ld_apple_draw = 0;
		ld_draw = 0;
		ld_erase = 0;
		
		case (current_state)
			STATIC: begin
				ld_static = 1;
				end
			LOAD_GAME_SNAKE: begin
				ld_game_snake = 1;
				end
			LOAD_GAME_APPLE: begin
				ld_game_apple = 1;
				end
			UPDATE: begin
				ld_update = 1;
				end
			CHECK_COLLISION: begin
				ld_check_collision = 1;
				end
			MOVE_BODY: begin
				ld_move_body = 1;
				end
			MOVE_HEAD: begin
				ld_move_head = 1;
				end
			WALL_COLLISION: begin
				ld_wall_coll = 1;
				end
			APPLE_COLLISION: begin
				ld_apple_coll = 1;
				end
			BODY_COLLISION: begin
				ld_body_coll = 1;
				end
			APPLE_DRAW: begin
				ld_apple_draw = 1;
				end
			DRAW: begin
				ld_draw = 1;
				end
			ERASE: begin
				ld_erase = 1;
				end
			default:;	
		endcase
	end 
	
	// Current_state registers
    always@(posedge iClock)
    begin: state_FFs
        if(!iReset)begin
            current_state <= STATIC;	
        end else begin
            current_state <= next_state;	
		end
    end
endmodule



module datapath_gameplay(
		input  iClock, iReset,
		
		// From control
		input ld_static, ld_update, ld_check_collision, ld_move_body, ld_move_head, ld_wall_coll, ld_apple_coll, ld_body_coll, 
		
		// Game inputs
		input [3:0] direction,	
			
		// Game outputs
		output reg [11:0] size,  
		output reg [7:0] snake_body_pos_X[/*4096*/10:0], 
		output reg [6:0] snake_body_pos_Y[/*4096*/10:0],
		output [7:0] apple_pos_X,
		output [6:0] apple_pos_Y,
		
		// To control
		output reg wall_coll, apple_coll, body_coll, move_snake, move_done, apple_done,
		
		// To game state fsm
		output reg end_game
	);
	
	reg [7:0] tempX;
	reg [6:0] tempY;
	
	wire [11:0] counter;
	wire [11:0] counter_body;
	
	always@(posedge iClock) begin
        if(!iReset) begin
			// set signals to 0
			end_game <= 0;
			wall_coll <= 0;
			apple_coll <= 0;
			body_coll <= 0;
			move_snake <= 0;
			move_done <= 0;	

			// Starting game stats
			snake_body_pos_X[0] <= 'd80;
			snake_body_pos_Y[0] <= 'd60;
			size <= 'd1;	
			
		end else begin
			// By default, set signals to 0
			end_game <= 0;
			wall_coll <= 0;
			apple_coll <= 0;
			body_coll <= 0;
			move_snake <= 0;
			move_done <= 0;
					
			// dont move
			if(ld_static)begin
				tempX <= snake_body_pos_X[0];
				tempY <= snake_body_pos_Y[0];				
			end
			
			
			if (ld_update) begin	
				if (direction == 4'b1000) begin
					tempY <= snake_body_pos_Y[0] + 1'b1;
					tempX <= snake_body_pos_X[0];
				end
				
				else if (direction == 4'b0100) begin
					tempY <= snake_body_pos_Y[0] - 1'b1;
					tempX <= snake_body_pos_X[0];
				end
					
				else if (direction == 4'b0010)  begin
					tempX <= snake_body_pos_X[0] - 1'b1;
					tempY <= snake_body_pos_Y[0];
				end
				
				else if (direction == 4'b0001) begin
					tempX <= snake_body_pos_X[0] + 1'b1;
					tempY <= snake_body_pos_Y[0];
				end
					
				else begin
					tempY <= snake_body_pos_Y[0];
					tempX <= snake_body_pos_X[0];
				end	
			end	
			
			if(ld_check_collision)begin
				// Check for wall collision
				if(tempY > 8'd91 || tempY < 8'd28 || tempX > 8'd112 || tempX < 8'd49) begin
					wall_coll <= 1;
				end 
				
				// Check for apple collision
				else if ((tempX == apple_pos_X) && (tempY == apple_pos_Y)) begin
					apple_coll <= 1;
					size <= size + 1'b1;				
				end 
				
				
				// Check for body collisions		
				if(size != 'd1 && counter_body != (size - 1) && snake_body_pos_X[counter_body] == tempX && snake_body_pos_Y[counter_body] == tempY)begin
					body_coll <= 1;
				end
			
				
				// Safe to move snake	
				move_snake <= (counter_body == 'b1)? 'b1:'b0;
			end

			// Change body of snake
			if(ld_move_body)begin
				if(counter != 'b0) begin
					snake_body_pos_X[counter] <= snake_body_pos_X[(counter - 1)]; 
					snake_body_pos_Y[counter] <= snake_body_pos_Y[(counter - 1)]; 			
				end
				
				// stop when counter reaches the head
				move_done <= (counter == 'b1)? 'b1:'b0;				
			end
			
			// Change head of snake
			if(ld_move_head)begin				
				snake_body_pos_X[0] <= tempX;
				snake_body_pos_Y[0] <= tempY;
			end
		
			// End game
			if (ld_wall_coll || ld_body_coll) begin
				// turn game_over signal high
				end_game <= 1;
				
				// Reset stats
				snake_body_pos_X[0] <= 8'd80;
				snake_body_pos_Y[0] <= 8'd60;	
				size <= 1;
			end
			
			
			if(apple_done) begin
				size <= size + 1'b1;	
			end
		end		
	end
	
	
	// Counter for moving body
	count counter_snake(
		// Inputs
		.iClock(iClock), 
		.iReset(iReset), 
		.size(size), 
		.count_on(ld_move_body), 
		
		// Outputs
		.counter(counter)
	);
	
	// Counter for body collisions
	count counter_b(
		// Inputs
		.iClock(iClock), 
		.iReset(iReset), 
		.size(size), 
		.count_on(ld_check_collision), 
		
		// Outputs
		.counter(counter_body)
	);
	
	// Apple collision
	apple_position apple_pos(
		// inputs
		.iClock(iClock), 
		.iReset(iReset),
		.ld_apple_coll(ld_apple_coll),
		.ld_reset(ld_static),
		.snake_body_pos_X(snake_body_pos_X),
		.snake_body_pos_Y(snake_body_pos_Y),
		.size(size),
		
		// outputs
		.apple_pos_X(apple_pos_X), 
		.apple_pos_Y(apple_pos_Y),
		.apple_done(apple_done),
		
	);

endmodule




module apple_position(
	input iClock, iReset,
	input ld_apple_coll, ld_reset,
	input [7:0] snake_body_pos_X[/*4096*/10:0],
	input [6:0] snake_body_pos_Y[/*4096*/10:0],
	input [11:0] size, 
	
	output reg [7:0] apple_pos_X,
	output reg [6:0] apple_pos_Y,
	output reg apple_done
	);

	reg [7:0] available_positions_X [4095:0];
	reg [6:0] available_positions_Y [4095:0];
	reg [11:0] availabe_size;

	reg [11:0] counter_snake;
	reg [7:0] counter_X;
	reg [6:0] counter_Y;
	
	always@(posedge iClock) 
	begin
	
		apple_done <= 0;
		
		if(!iReset) begin
			counter_X <= 'd49;			
			counter_Y <= 'd28;
			counter_snake <= 0;
			availabe_size <= 1'b1;	
			apple_done <= 0;
			
			// Always start at this position
			apple_pos_X <= 'd96;
			apple_pos_Y <= 'd34;
			
		end begin
			// Increment
			counter_snake <= counter_snake + 1;
			
			// Reached last snake, move onto a new pixel to the right
			if(counter_snake == (size - 1)) begin
				if(((counter_X != snake_body_pos_X[counter_snake]) || (counter_Y != snake_body_pos_Y[counter_snake]))) begin
					available_positions_X [availabe_size] = counter_X;
					available_positions_Y [availabe_size] = counter_Y;
					availabe_size <= availabe_size + 1;
					
					
					if(availabe_size == 'd4094) begin
						availabe_size <= 0;
					end
				end
			
				counter_X <= counter_X + 1;
				counter_snake <= 0;
			end
		
			// Reached end of screen, move down
			if(counter_X > 'd111 && counter_snake == (size - 1))begin
				counter_Y <= counter_Y + 1;
				counter_X <= 'd49;
			end
			
			if((counter_Y > 'd90) && (counter_X > 'd111) && (counter_snake == (size - 1))) begin
				// Reset signals and counters
				counter_X <= 'd48;
				counter_Y <= 'd28;	
				counter_snake <= 0;
			end
			
			// Snake is here, not a vailid positions so move on
			if((counter_X == snake_body_pos_X[counter_snake]) && (counter_Y == snake_body_pos_Y[counter_snake]))begin
				counter_snake <= 0;
				counter_X <= counter_X + 1;
			end
			
			if(ld_reset) begin
				// Always start at this position
				apple_pos_X <= available_positions_X[24];
				apple_pos_Y <= available_positions_Y[60];
			end
			
			if(ld_apple_coll) begin
				apple_pos_X <= available_positions_X[45];
				apple_pos_Y <= available_positions_Y[37];
			end
		end
	end	

endmodule


