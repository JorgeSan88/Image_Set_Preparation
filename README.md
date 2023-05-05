# CNN_Preparation: preparation of an sEMG signal to train a CNN 

This repository contains the description of "CNN_preparation," a code that, from a myoelectric signal acquired with a specific protocol, prepares the samples of each movement to be classified to train a CNN. Each part of the main program, called CNN_preparation, is described below.

##  Load the myoelectric signal 
The signal must be recorded based on an acquisition protocol, where it is known how many acquisition channels there are, how many movements were made, how many repetitions of each movement were made, how long each repetition lasted, and also, each repetition must be interspersed by a rest time. The variable that contains the signal must be named "EMG" and be arranged like this: Rows are the number of channels, and Columns are the acquired data.


```matlab
load Example_signal 
```
## Parameter selection 

