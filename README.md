# CNN_Preparation: preparation of an sEMG signal to train a CNN 

This repository contains the description of "CNN_preparation," a code that, from a myoelectric signal acquired with a specific protocol, prepares the samples of each movement to be classified to train a CNN. Each part of the main program, called CNN_preparation, is described below.

##  Load the myoelectric signal 
The signal must be recorded based on an acquisition protocol, where it is known how many acquisition channels there are, how many movements were made, how many repetitions of each movement were made, how long each repetition lasted, and also, each repetition must be interspersed by a rest time. The variable that contains the signal must be named "EMG" and be arranged like this: Rows are the number of channels, and Columns are the acquired data.


```matlab
load Example_signal 
```
## Parameter selection 

This is the most critical section because here, the parameters under which the signal acquisition protocol was carried out are indicated, the number of channels acquired, and the sampling frequency.

```matlab
Subject_number = 1;                 %Subject number 
channels = 12;                      %Number of channels
Movements = 9;                      %Number of moves
Seconds_per_move = 5;               %Seconds per move
Repetitions = 6;                    %Number of repetitions per movement
Seconds_rest = 3;                   %Seconds of rest between repetitions
sample_rate = 2000;                 %Sample rate
```

In the following line, one of the four groups of characteristics in time to be extracted from each of the samples that will be generated is selected. In the code comment, it is specified which characteristics each of the groups includes.

```matlab
Feature_group = 2;                  %Feature group
                                    %1- Integrated EMG(IEMG), Variance(VAR), Willison Amplitude(WAMP), Waveform Length(WL), Slope Sign Change(SSC) and Zero Crossing(ZC) 
                                    %2- Mean Absolute Value(MAV), SSC, WL, VAR, WAMP, ZC and four coefficients of the autoregression model (AR) 
                                    %3- Number of peaks multiplied by the signal power (MPP) and the zero crossings multiplied by the signal power (MZP)
                                    %4- 5 features of the power spectrum in the time domain
```

Next, the type of image that will be formed with the samples for the training of the CNN network is selected, of which there are four options: 
1. Feature Image .- where the height of the image is the acquisition channels and the width are the features selected in the previous step. 
2. MixChannel Image .- where the height of the image is the channels rearranged so that each channel is adjacent to all the others at some point, and the width is the selected features. 
3. MixFeature Image .- where the height of the image is the acquisition channels and the width are the features rearranged so that each one is adjacent to all the others at some point. 
4. MixImage .- where the height of the image is the rearranged channels and the width is the rearranged features.

```matlab
image_type = 1;                     %Image type: 
                                    %1-Feature Image
                                    %2-MixChannel Image
                                    %3-MixFeature Image
                                    %4-MixImage
```
The "threshold" variable is adjusted empirically according to the acquired signal. It is crucial for some features, such as Zero Crossing (ZC), because if the threshold is too low, zero crossings of the noise will also be considered, and if it is very high, it will omit the zero crossings of the signal itself.

```matlab
threshold=0.000001;                 %Threshold for some features
```
The following four variables are necessary to carry out a digital filtering stage, which consists of a band-pass filter from 20 to 500 Hz (range of interest for a myoelectric signal) and a band-reject filter from 50 Hz (to eliminate possible power supply noise), both ranges can be changed as required.

```matlab
Low_frequency=20;                   %High pass cutoff frequency
High_frequency=500;                 %Low pass cutoff frequency
Low_band = 49;                      %Band Reject Filter Low Cutoff Frequency
High_band = 51;                     %Band Reject Filter High Cutoff Frequency
```
Finally, the time of each sample (Time_window_length) and the overlap time (Time_overlap) of the following sample are selected.

```matlab
Time_window_length = 200;           %Window size in milliseconds
Time_overlap = 100;                 %Overlap size in milliseconds
```

This means that for each sample, N amount of data will be taken, determined by the time of each window and the sampling time and that the samples will be taken each specific time determined by the overlap time and the sampling time.

