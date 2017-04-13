import csv
import os
period = 0.75
setup_hold_time = 0.01
with open('dsm_pos.csv', 'w', newline='') as csvfile:
	f = open('dsm_out.txt', 'r')		
	dsm_csv = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
	x = 0;
	for line in f:
		t1 = x + setup_hold_time
		x += period
		t2 = x - setup_hold_time
		dsm = float(line)
		if (dsm == -1):
			dsm = 0
		dsm_csv.writerow([str(t1) + "n", str(dsm)])
		dsm_csv.writerow([str(t2) + "n", str(dsm)])
		
with open('dsm_neg.csv', 'w', newline='') as csvfile:
	f = open('dsm_out.txt', 'r')		
	dsm_csv = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
	x = 0;
	for line in f:
		t1 = x + setup_hold_time
		x += period
		t2 = x - setup_hold_time
		dsm = float(line)
		if (dsm == 1):
			dsm = 0
		elif (dsm == -1):
			dsm = 1
		dsm_csv.writerow([str(t1) + "n", str(dsm)])
		dsm_csv.writerow([str(t2) + "n", str(dsm)])
		