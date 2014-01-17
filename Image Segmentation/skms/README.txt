===============================================================================
Semi-supervised Kernel Mean Shift Clustering
Authors: Saket Anand, Sushil Mittal, Oncel Tuzel and Peter Meer
===============================================================================
Affiliations: 
Saket Anand - Robust Image Understanding Laboratory, Rutgers University, NJ
Sushil Mittal - Scibler Technologies, Bangalore, India
Oncel Tuzel - Mitsubishi Electric Research Laboratory, MA
Peter Meer - Robust Image Understanding Laboratory, Rutgers University, NJ
===============================================================================

Implementation of Semi-Supervised Kernel Mean Shift Clustering (SKMS) algorithm presented in:
[1] S. Anand, S. Mittal, O. Tuzel and P. Meer "Semi-supervised Kernel Mean Shift Clustering",
IEEE Trans. Pattern Anal. Machine Intell. (to appear) 

We propose a semi-supervised framework for kernel mean shift clustering (SKMS) that uses only pairwise constraints to guide the clustering procedure. The data points are first mapped to a high-dimensional kernel space where the constraints are imposed by a linear transformation of the mapped points. This is achieved by modifying the initial kernel matrix by minimizing a log det divergence-based objective function.

Examples for the following applications are provided:
1. Ten concentric circles
2. Five olympic circles 

In the paper [1], we tested SKMS on four real examples. 

The mex functions (64 bit Windows) for the core functions are provided. To compile the core C/C++ files and generate the platform-specific dlls, use the following command on the Matlab command prompt: 

>> mex logdet_learn_LRK_mex.cpp


To develop the code for a new application, the script 'run_SKMS.m' can be followed as an example. Some of the key steps are described below. Most of the variable names are consistent with the ones used in [1] above.

Key Variables:
-----------------------------------------
Name							Purpose
-----------------------------------------
Input variables:
X								Data matrix (n x d)
C								Pairwise constraint matrix (n_c x 2)

Variables computed:
K0								Initial kernel matrix (n x n)
K_skms							Learned kernel matrix (n x n)
k 								Bandwidth parameter for kernel mean shift clustering

Key Functions:
-----------------------------------------
Name								Purpose
-----------------------------------------
init_config.m 						Setup configuration; Initialize the parameters
estimate_sigma.m 					Estimate the sigma value using the pairwise constraints
generate_gaussian_kernel.m			Compute the initial kernel matrix
learn_kernel.m						Learn the kernel matrix by minimizing the log det divergence
estimate_bw_from_constraints.m  	Estimate the bandwidth parameter 'k' for kernel mean shift clustering
kernel_mean_shift_clustering.m  	Perform kernel mean shift clustering
compute_clustering_performance.m	Compute performance metric using the ground truth labels


For more information about the usage of various functions, refer to individual .m/.cpp/.h files.

Please report any inconsistencies/bugs/suggestions to:

Saket Anand						|	Sushil Mittal						
anands[at]eden.rutgers.edu 		|	sushil.mittal.caip[at]gmail.com

Robust Image Understanding Laboratory
http://coewww.rutgers.edu/riul

NOTE: The code was only tested on Windows. Please let us know if you have trouble running the programs on other platforms. 