#!/usr/bin/ruby

fdata = ARGV[0]
ftime = ARGV[1]
dir = ARGV[2]
tfnum = ARGV[3]
pnum = ARGV[4]
cnum = ARGV[5]
maxite = ARGV[6]
repnum = ARGV[7].to_i

system("mkdir #{dir}")
for i in 1..repnum
	system("Rscript SCODE.R #{fdata} #{ftime} #{dir}/out_#{i} #{tfnum} #{pnum} #{cnum} #{maxite}")
end
system("Rscript averageA.R #{dir} #{repnum}")
