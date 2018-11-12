#!/bin/bash

echo Simulation Log Summary

res_PATH=./temp_res

cat $res_PATH/simulation.log | grep "User Count:"
cat $res_PATH/simulation.log | grep "Tot. Server Count:"

PM_TYPES=$(grep -o ': Count=' $res_PATH/simulation.log | wc -l)
echo PM Types: $PM_TYPES
cat $res_PATH/simulation.log | grep "PM Type "

echo Total failures: $(grep -o 'Failure' $res_PATH/simulation.log | wc -l)

for i in `seq 1 $PM_TYPES`;
do
	echo Failures in PM type $i: $(grep -o "of PM type $i" $res_PATH/simulation.log | wc -l)
done

echo Catastrophic events: $(grep 'Catastrophic' $res_PATH/simulation.log)

echo Total VM assignments: $(grep -o 'Assignment:' $res_PATH/simulation.log | wc -l)
echo Total VM deactivations: $(grep -o 'deactivation' $res_PATH/simulation.log | wc -l)
echo Total VM reactivations: $(grep -o 'Reactivation' $res_PATH/simulation.log | wc -l)
echo Total migrations: $(grep -o 'migrated' $res_PATH/simulation.log | wc -l)
echo -Failure related: $(grep -o 'Due to f' $res_PATH/simulation.log | wc -l)
echo -Benign migrations: $(grep -o 'DTf' $res_PATH/simulation.log | wc -l)
echo Deliberate pauses: $(grep -o 'Deliberate' $res_PATH/simulation.log | wc -l)
echo User-period not meet the SLA: $(grep -o 'credit' $res_PATH/simulation.log | wc -l)
