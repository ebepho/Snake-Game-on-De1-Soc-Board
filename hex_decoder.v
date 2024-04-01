
`timescale 1ns / 1ns // `timescale time_unit/time_precision

module hex_decoder(SW, HEX0);
	input [3:0]SW;
	output[6:0]HEX0;
	
	s0 u0(
		.c0(SW[0]),
		.c1(SW[1]),
		.c2(SW[2]),
		.c3(SW[3]),
		.m(HEX0[0])
	);
	
	s1 u1(
		.c0(SW[0]),
		.c1(SW[1]),
		.c2(SW[2]),
		.c3(SW[3]),
		.m(HEX0[1])
	);
	
	s2 u2(
		.c0(SW[0]),
		.c1(SW[1]),
		.c2(SW[2]),
		.c3(SW[3]),
		.m(HEX0[2])
	);
	
	s3 u3(
		.c0(SW[0]),
		.c1(SW[1]),
		.c2(SW[2]),
		.c3(SW[3]),
		.m(HEX0[3])
	);
	
	s4 u4(
		.c0(SW[0]),
		.c1(SW[1]),
		.c2(SW[2]),
		.c3(SW[3]),
		.m(HEX0[4])
	);
	
	s5 u5(
		.c0(SW[0]),
		.c1(SW[1]),
		.c2(SW[2]),
		.c3(SW[3]),
		.m(HEX0[5])
	);
	
	s6 u6(
		.c0(SW[0]),
		.c1(SW[1]),
		.c2(SW[2]),
		.c3(SW[3]),
		.m(HEX0[6])
	);
endmodule

module s6(c0, c1, c2, c3, m);
	input c0, c1, c2, c3;
	output m;
	assign m = ~((~c3 | ~c2 | c1 | c0) & (c3 | ~c2 | ~c1 | ~c0) & (c3 | c2 | c1 | ~c0) & (c3 | c2 | c1 | c0));
endmodule

module s5(c0, c1, c2, c3, m);
	input c0, c1, c2, c3;
	output m;
	assign m = ~((~c3 | ~c2 | c1 | ~c0) & (c3 | ~c2 | ~c1 | ~c0) & (c3 | c2 | ~c1 | ~c0) & (c3 | c2 | ~c1 | c0) & (c3 | c2 | c1 | ~c0));
endmodule

module s4(c0, c1, c2, c3, m);
	input c0, c1, c2, c3;
	output m;
	assign m = ~((c3 | c2 | ~c1 | ~c0) & (~c3 | c2 | c1 | ~c0) & (c3 | ~c2 | ~c1 | ~c0) & (c3 | ~c2 | c1 | ~c0) & (c3 |~c2 | c1 | c0) & (c3 | ~c2 | ~c1 | ~c0) & (c3 | c2 | c1 | ~c0));
endmodule

module s3(c0, c1, c2, c3, m);
	input c0, c1, c2, c3;
	output m;
	assign m = ~((~c3 | ~c2 | ~c1 | ~c0) & (~c3 | c2 | ~c1 | c0) & (c3 | ~c2 | ~c1 | ~c0) & (c3 | ~c2 | c1 | c0) & (c3 | c2 | c1 | ~c0));
endmodule

module s2(c0, c1, c2, c3, m);
	input c0, c1, c2, c3;
	output m;
	assign m = ~((~c3 | ~c2 | ~c1 | ~c0) & (~c3 | ~c2 | ~c1 | c0) & (~c3 | ~c2 | c1 | c0) & (c3 | c2 | ~c1 | c0));
endmodule

module s1(c0, c1, c2, c3, m);
	input c0, c1, c2, c3;
	output m;
	assign m = ~((~c3 | ~c2 | ~c1 | ~c0) & (~c3 |~ c2 | ~c1 | c0) & (~c3 | ~c2 | c1 | c0) & (~c3 | c2 | ~c1 | ~c0) &  (c3 | ~c2 | ~c1 | c0) & (c3 | ~c2 | c1 | ~c0));
endmodule

module s0(c0, c1, c2, c3, m);
	input c0, c1, c2, c3;
	output m;
	assign m = ~((~c3 | ~c2 | c1 | ~c0) & (~c3 | c2 | ~c1 | ~c0) & (c3 | ~c2 | c1 | c0) & (c3 | c2 | c1 | ~c0));
endmodule