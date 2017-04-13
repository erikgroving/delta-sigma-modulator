import csv
import os
with open('dsm.csv', 'w', newline='') as csvfile:
	f = open('dsm_out.txt', 'r')		
	dsm_csv = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
	x = 0;
	period = 0.72
	dsm_csv.writerow(['Time', 'Value'])
	for line in f:
		t1 = x + 0.01
		x += period
		t2 = x - 0.01
		dsm = float(line)
		dsm_csv.writerow([str(t1), str(dsm)])
		dsm_csv.writerow([str(t2), str(dsm)])
		