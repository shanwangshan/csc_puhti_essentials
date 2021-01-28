#!/bin/bash
#This is a script to find the resources in Puhti cluster/CSC
#Developed in Tampere University, Computer-Vision Group.
####################################################################################
#sinfo -N -p gpu -o %a -O "nodehost,available,cpus,cpusload,cpusstate" --noheader
#sinfo -N -p gpu -o %a -O "nodehost,available,cpusstate" --noheader
# find the nodes with least CPU usage: in gpu partition: 1 in the cut command stands for allocated cpus in a node, 2 will stand for idle, 3 for other and 4 for total which is 40.
#echo
#echo 'Recommended node with least amount of CPU usages |N|S|Coresinuse|'
#CPU=`sinfo -N -p gpu -o %a -O "nodehost,available,cpusstate" --noheader | cut -d "/" -f 1 | sort -nr -k3 | tail -10`
#echo "$CPU"
#Total number of gpus in use


host=`hostname -s | awk -F'[-]' '{print $1}'`

if [ $host = "puhti" ]

   then
#####################################################################################
echo
echo '*** WELCOME TO DYNAMIC PUHTI-RESOURCE FINDER SYSTEM ***'
echo
#####################################################################################

# HEADER
printf '%10s %4s %3s %12s' "USER" "CPU" "GPU" "CPU/GPU"
echo

unique_users=`squeue -h -p gpu -o "%u" | sort | uniq`

for value in $unique_users
	do
	    gpu_in_use=`squeue -h -t R -p gpu --user $value -o "%.10b %10D" | awk -F'[: ]' '{print $3 * $4}' | awk '{s+=$1} END {print s}'`
		cpu_in_use=`squeue -h -t R -p gpu --user $value -o "%.10c %10D" | awk '{print $1 * $2}' | awk '{s+=$1} END {print s}'`

		# if $gpu_in_use is empty, then a user waits in the queue CPU/GPU is -1
		if [ -z "$gpu_in_use" ]
		then
			cpu_per_gpu=`echo PENDING`
		else
		    if [ $gpu_in_use = 0 ]
		    then
			cpu_per_gpu=`echo -1`
		    else
			cpu_per_gpu=`echo $(printf %.1f $(echo $cpu_in_use / $gpu_in_use | bc -l))`
		    fi
		fi

		while IFS= read -r -u2 u && read -r -u3 a && read -r -u4 b && read -r -u5 c; do
			printf '%10s %4d %3s %10s\n' "$u" "$a" "$b" "$c"
		done 2<<<"$value" 3<<<"$cpu_in_use" 4<<<"$gpu_in_use" 5<<<"$cpu_per_gpu"
	done

echo
echo

total_gpu_in_use=`squeue -h -t R -p gpu -o "%.10b %10D" | awk -F'[: ]' '{print $3 * $4}' | paste -sd+ | bc`
total_gpu=`sinfo -N -p gpu -o %a -O "gres" --noheader | wc -l`
mul_fac=4
total_gpu_in_csc=$(echo "${total_gpu}*${mul_fac}" | bc -l)

echo Total GPUs in CSC: "$total_gpu_in_csc "

echo Total GPUs are in use: "$total_gpu_in_use "

else
    if [ $host = 'narvi' ]
    then
echo
echo '*** WELCOME TO DYNAMIC NARVI-RESOURCE FINDER SYSTEM ***'
echo
#####################################################################################

# HEADER
printf '%10s %4s %3s %12s' "USER" "CPU" "GPU" "CPU/GPU"
echo

unique_users=`squeue -h -p gpu -o "%u" | sort | uniq`

for value in $unique_users
	do
	    gpu_in_use=`squeue -h -t R -p gpu --user $value -o "%.10b %10D" | awk -F'[: ]' '{print $3 * $4}' | awk '{s+=$1} END {print s}'`
		cpu_in_use=`squeue -h -t R -p gpu --user $value -o "%.10c %10D" | awk '{print $1 * $2}' | awk '{s+=$1} END {print s}'`

		# if $gpu_in_use is empty, then a user waits in the queue CPU/GPU is -1
		if [ -z "$gpu_in_use" ]
		then
			cpu_per_gpu=`echo PENDING`
		else
		    if [ $gpu_in_use = 0 ]
		    then
			cpu_per_gpu=`echo -1`
		    else
			cpu_per_gpu=`echo $(printf %.1f $(echo $cpu_in_use / $gpu_in_use | bc -l))`
		    fi
		fi

		while IFS= read -r -u2 u && read -r -u3 a && read -r -u4 b && read -r -u5 c; do
			printf '%10s %4d %3s %10s\n' "$u" "$a" "$b" "$c"
		done 2<<<"$value" 3<<<"$cpu_in_use" 4<<<"$gpu_in_use" 5<<<"$cpu_per_gpu"
	done

echo
echo

total_gpu_in_use=`squeue -h -t R -p gpu -o "%.100b %10D" | awk  '{print $1 "\t" $2 }' |sed 's/teslav100://'|sed 's/teslap100://' |sed 's/gpu://' | awk '{print $1 * $2}' | paste -sd+ | bc`
total_gpu=`sinfo -N -p gpu -o %a -O "gres" --noheader | wc -l`
mul_fac=4

total_gpu_in_csc=$(echo "${total_gpu}*${mul_fac}" | bc -l)

echo Total GPUs in CSC: "$total_gpu_in_csc "

echo Total GPUs are in use: "$total_gpu_in_use "

    fi

fi
