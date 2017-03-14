// Okay, so I'm doing the bitwise representation this way:
// 11 bits: 
// [10] 	-- saturation bit (I hope output can't become greater than 2 times input)
// [9] 		-- the voltage bit (if high: 1 Volt, if low: -1 Volt)
// [8: 0] 	-- fractional bits that aren't used in final output 
`ifndef PARAMETERS_VH
`define PARAMETERS_VH

`define VIN_FS				14'h1000	// bit 9 is high, 1 volt
`define VIN_FS_RECIPROCAL	14'h1000	// 1/1 is still 1
`define VIN_FS_HALF			14'h800		// half of VIN_FS (bit 14 is high)
`define VIN_FS_HALF_NEG		14'h3800	// -0.5
`define QUANT_LOW			14'h400		// 0.25
`define QUANT_HIGH			14'hC00		// 0.75
`define QUANT_OFF			14'h800		// 0.5

`define F_BITS				12	//fractional bits
`define T_BITS				14	// total bits
`define I_BITS				24	// interpolation bits, this is addition, 24 bits won't be a problem

`define I_BITS_SUB_VIN_BITS	10

`define I_L_LIM				11	// bottom limit for interp out
`define I_U_LIM				23	// upper limit for interp out

`endif