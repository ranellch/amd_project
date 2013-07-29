function [Iorg Imasked]  = mask_leaks(I1, I2)
% [Iorg Imasked] = mask_leak(I1, I2) Masks areas of leakage in grayscale FA image
% I1 using function leak_detection and places equivalent mask on FA image I2.

BWleak = leak_detection(I1)