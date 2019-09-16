# Sensor_Fusion_Radar-Target-Generation-and-Detection
FMCW Radar 77GHz - Range-Velocity and displacement simualtion - 2D FFT process to generate Range Doppler Maps - CFAR Processing to display the target

**FMCW Waveform Design**
- Using the given system requirements, design a FMCW waveform. Find its Bandwidth (B), chirp time (Tchirp) and slope of the chirp.

**Simulation loop**
- A beat signal should be generated such that once range FFT implemented, it gives the correct range i.e the initial position of target assigned with an error margin of +/- 10 meters.

**Range FFT (1st FFT)**
- A correct implementation should generate a peak at the correct range, i.e the 
initial position of target assigned with an error margin of +/- 10 meters.

**2D CFAR**
- The 2D CFAR processing should be able to suppress the noise and separate
the target signal. The output should match the image shared in walkthrough.
