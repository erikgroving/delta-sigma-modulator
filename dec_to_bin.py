import os
import math
total_bits = int(input("how many total bits?\n"))
frac_bits = int(input("how many frac bits?\n"))
while(1):
	val = float(input("what value are you converting?\n"))
	bin_val = ""
	for i in range(total_bits):
#		print(i)
		exp = total_bits - (i + frac_bits + 1)
#		print('\n')
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
	print(bin_val)
	