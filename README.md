# Sensor_Fusion_Radar-Target-Generation-and-Detection


**FMCW Waveform Design**
- Configure the FMCW waveform based on the system requirements.
- Using the given system requirements, design a FMCW waveform. Find its Bandwidth (B), chirp time (Tchirp) and slope of the chirp.

**Simulation loop**
-Define the range and velocity of target and simulate its displacement.
-For the same simulation loop process the transmit and receive signal to determine the beat signal
- A beat signal should be generated such that once range FFT implemented, it gives the correct range i.e the initial position of target assigned with an error margin of +/- 10 meters.

**Range FFT (1st FFT)**
-Perform Range FFT on the received signal to determine the Range
- A correct implementation should generate a peak at the correct range, i.e the 
initial position of target assigned with an error margin of +/- 10 meters.

**2D CFAR**
-Towards the end, perform the CFAR processing on the output of 2nd FFT to display the target.
- The 2D CFAR processing should be able to suppress the noise and separate
the target signal. The output should match the image shared in walkthrough.
