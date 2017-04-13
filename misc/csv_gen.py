import csv
import os
with open('dsm_pos.csv', 'w', newline='') as csvfile:
	f = open('dsm_out.txt', 'r')		
	dsm_csv = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
	x = 0;
	period = 0.72
	for line in f:
		t1 = x + 0.01
		x += period
		t2 = x - 0.01
		dsm = float(line)
		if (dsm == -1):
			dsm = 0
		dsm_csv.writerow([str(t1), str(dsm)])
		dsm_csv.writerow([str(t2), str(dsm)])
		
with open('dsm_neg.csv', 'w', newline='') as csvfile:
	f = open('dsm_out.txt', 'r')		
	dsm_csv = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
	x = 0;
	period = 0.72
	for line in f:
		t1 = x + 0.01
		x += period
		t2 = x - 0.01
		dsm = float(line)
		if (dsm == 1):
			dsm = 0
		elif (dsm == -1):
			dsm = 1
		dsm_csv.writerow([str(t1), str(dsm)])
		dsm_csv.writerow([str(t2), str(dsm)])
		