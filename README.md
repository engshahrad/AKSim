# AKSim Stochastic Cloud Simulator

AKSim is a high-level stochastic cloud simulator written in MATLAB by me, Mohammad Shahrad. We used it in our SoCC '16 paper: http://parallel.princeton.edu/papers/ak-socc2016.pdf . This code was written in the 8/15-8/16 time period and I am open sourcing it so that others can also use it.

Please feel free to use it or base your simulator on it. Don't forget to cite us after using it! :blush:
```
@inproceedings{Shahrad:2016:AKF:2987550.2987556,
 author = {Shahrad, Mohammad and Wentzlaff, David},
 title = {Availability Knob: Flexible User-Defined Availability in the Cloud},
 booktitle = {Proceedings of the Seventh ACM Symposium on Cloud Computing},
 series = {SoCC '16},
 year = {2016},
 isbn = {978-1-4503-4525-5},
 location = {Santa Clara, CA, USA},
 pages = {42--56},
 numpages = {15},
 url = {http://doi.acm.org/10.1145/2987550.2987556},
 doi = {10.1145/2987550.2987556},
 acmid = {2987556},
 publisher = {ACM},
 address = {New York, NY, USA},
 keywords = {SLA, cloud availability, cloud economics, failure-aware scheduling, flexible availability},
}
```

## How to use it?

1. Set the simulation parameters which can be find in `RDT_Parameters.m`. A deeper change of settings requires you to modify the initial configurations in `RDT.m`.
2. Run the simulation. There is no need to use MATLAB GUI, and you can directly run it using the following command:
```
matlab -nodisplay -nosplash -nodesktop -r RDT
```
Simulation results will be stored in the `temp_res` directory. 
3. Analyze the results: use different plotting scripts to analyze the simulation in different aspects.


## Tested Environment

Environment/Tool | Tested Version 
---------------- | --------------
MATLAB | R2015b
OS | Springdale Linux release 6.9 (Pisa)
