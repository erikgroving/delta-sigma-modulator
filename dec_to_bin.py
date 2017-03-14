import os
import math
total_bits = 8
frac_bits = 7
f = open('interp_in.txt', 'r')
out = open('interp_in_bin.txt', 'w')
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
	out.write(bin_val)
	out.write('\n')
f.close()
out.close()