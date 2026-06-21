# OT-FinalProject-Robust-ISAC-Waveform-Design
Optimization Theory final project - Robust Angle-Uncertainty-Aware Joint ISAC Waveform Design and Simulation

## Overview

This project implements a MATLAB simulation for robust joint Integrated Sensing and Communication (ISAC) waveform design.

The system considers multi-user communication and multi-target sensing under target angle uncertainty. The main goal is to design a waveform that satisfies constructive interference (CI) constraints while reducing sensing beampattern MSE under angle errors.

## Features

- Joint ISAC waveform design
- Multi-user and multi-target MIMO scenario
- Constructive interference (CI) communication constraints
- Ellipsoidal target angle uncertainty model
- Robust sensing beampattern matching
- Semidefinite relaxation (SDR) optimization with CVX
- Comparison between nominal and robust waveform designs

## Requirements

- MATLAB
- CVX for MATLAB

Run CVX setup before executing the project:

```matlab
cvx_setup
```

## Usage

Run the main script in MATLAB:

```matlab
main
```

## Experiments

- `sim1`: Robust design vs. nominal design
- `sim2`: Worst-case MSE under different uncertainty radii
- `sim3`: Beampattern visualization under worst-case angle error

## Summary

The robust ISAC design slightly sacrifices nominal performance but improves sensing robustness under target angle uncertainty.
