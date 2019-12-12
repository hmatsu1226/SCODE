using CSV
using DataFrames
using LinearAlgebra

println("a")

fdata = ARGS[1]
ftime = ARGS[2]
dir = ARGS[3]
tfnum = parse(Int32,ARGS[4])
pnum = parse(Int32,ARGS[5])
cnum = parse(Int32,ARGS[6])
maxite = parse(Int32,ARGS[7])

maxB = 2.0
minB = -10.0

if !(isdir(dir))
    mkdir(dir)
end

#X = readtable(fdata, separator='\t', header=false)[1:tfnum,1:cnum]
X = CSV.read(fdata, header=false)
X = convert(Matrix, X)
W = zeros(tfnum, pnum)
Z = zeros(pnum, cnum)
WZ = zeros(tfnum, cnum)

pseudotime = CSV.read(ftime, header=false)[1:cnum,2]
pseudotime = pseudotime/maximum(pseudotime)

new_B = zeros(pnum)
old_B = zeros(pnum)

#initialization
RSS = Inf
for i in 1:pnum
    new_B[i] = rand()*(maxB-minB)+minB
    old_B[i] = new_B[i]
end

function sample_Z()
    for i in 1:pnum
        for j in 1:cnum
            Z[i,j] = exp(new_B[i]*pseudotime[j]) + (rand()*0.002-0.001)
        end
    end
end

#optimization
for ite in 1:maxite
    #sampling B
    target = rand(1:pnum)
    global new_B[target] = rand()*(maxB-minB)+minB

    #for last calc
    if ite==maxite
        global new_B = copy(old_B)
    end

    #sample Z from new B
    sample_Z()

    #regression
    for i in 1:tfnum
        W[i,:] = (Z * Z')^-1 * (Z * X[i,:])
    end
    #prediction
    WZ = W * Z

    #RSS
    tmp_RSS = 0
    for i in 1:tfnum
        tmp_RSS += sum((X[i,:]-WZ[i,:]).*(X[i,:]-WZ[i,:]))
    end

    if tmp_RSS < RSS
        global RSS = tmp_RSS
        global old_B[target] = new_B[target]
    else
        global new_B[target] = old_B[target]
    end
end

#output RSS
open(dir*"/RSS.txt", "w") do f
    println(f, RSS)
end

#output W
#writetable(dir*"/W.txt", convert(DataFrame, W), separator = '\t', header = false)
DataFrame(W) |> CSV.write(dir*"/W.txt", delim='\t', writeheader=false)

#infer A
B = zeros(pnum, pnum)
for i in 1:pnum
    B[i,i] = new_B[i]
end
invW = pinv(W)
A = W * B * invW

#write A and B
#writetable(dir*"/A.txt", convert(DataFrame, A), separator = '\t', header = false)
#writetable(dir*"/B.txt", convert(DataFrame, B), separator = '\t', header = false)
DataFrame(A) |> CSV.write(dir*"/A.txt", delim='\t', writeheader=false)
DataFrame(B) |> CSV.write(dir*"/B.txt", delim='\t', writeheader=false)
