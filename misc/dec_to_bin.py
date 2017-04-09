import os
import math
total_bits = 10
frac_bits = 9
f = open('../input/q_input.txt', 'r')
out = open('../input/q_input_bin.txt', 'w')
int_out = open('../input/q_input_count.txt', 'w')
for line in f:
	val = float(line)
	bin_val = ""
	for i in range(total_bits):
		exp = total_bits - (i + frac_bits + 1)
		if (i == 0):
			x = -pow(2, exp)
		else:
			x = pow(2, exp)
		if (val < 0):
			if (i == 0):
				bin_val += '1'
				val -= x
			else:
				if (val + x <= 0):
					bin_val += '1'
					val += x
				else:
					bin_val += '0'
		else:
			if (i != 0):
				if (val - x >= 0):
					bin_val += '1'
					val -= x
				else:
					bin_val += '0'
			else:
				bin_val += '0'	
	int_val = int(bin_val, 2)
	int_out.write(str(int_val))
	int_out.write('\n')
	out.write(bin_val)
	out.write('\n')
f.close()
out.close()