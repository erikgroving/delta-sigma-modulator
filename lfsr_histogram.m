lfsr_file = fopen('lfsr_out.txt');
lfsr = textscan(lfsr_file, '%f64');
lfsr_arr = lfsr{1}/(2^14);

lfsr_var = var(lfsr_arr)
h = histogram(lfsr_arr)
fclose(lfsr_file);