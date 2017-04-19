import csv
import os
period = 0.75
setup_hold_time = 0.00125
with open('dsm_pos.csv', 'w', newline='') as csvfile:
	f = open('dsm_out.txt', 'r')		
	dsm_csv = csv.writer(csvfile, delimiter='\t', quotechar='|', quoting=csv.QUOTE_MINIMAL)
	x = 0
	dsm_csv.writerow(["0.0", "0.0"])
	for line in f:
		t1 = x + setup_hold_time
		x += period
		t2 = x - setup_hold_time
		dsm = float(line)
		if (dsm == -1):
			dsm = 0
		dsm_csv.writerow([str(t1) + "e-09", str(dsm)])
		dsm_csv.writerow([str(t2) + "e-09", str(dsm)])
		
with open('dsm_neg.csv', 'w', newline='') as csvfile:
	f = open('dsm_out.txt', 'r')		
	dsm_csv = csv.writer(csvfile, delimiter='\t', quotechar='|', quoting=csv.QUOTE_MINIMAL)
	x = 0
	dsm_csv.writerow(["0.0", "0.0"])
	for line in f:
		t1 = x + setup_hold_time
		x += period
		t2 = x - setup_hold_time
		dsm = float(line)
		if (dsm == 1):
			dsm = 0
		elif (dsm == -1):
			dsm = 1
		dsm_csv.writerow([str(t1) + "e-09", str(dsm)])
		dsm_csv.writerow([str(t2) + "e-09", str(dsm)])
		