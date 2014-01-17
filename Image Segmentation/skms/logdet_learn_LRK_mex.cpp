///////////////////////////////////////////////////////////////////////////
// logdet_learn_LRK_mex.cpp
// Kernel learning using Log-Det divergence
// This is a supporting function for the Semi-supervised Kernel Mean Shift 
// Clustering Algorithm. Please refer to the following publication for the 
// details of implementation
// Anand, S., Mittal, S., Tuzel, O., Meer, P., "Semi-Supervised Kernel Mean
// Shift Clustering", to appear in IEEE TPAMI, 35.
///////////////////////////////////////////////////////////////////////////

#include <mex.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <cstdlib>
#include <cstdio>
#include <cstring>
#include <fstream>
#include <cassert>
#include <vector>
#include "matrixOperations.h"
#include <math.h>

double cholUpdateMult(double alpha, double* x, double*B,const int r)
{
	double t_chol_update = 0.0;

	double* alpha_vec = (double*)mxCalloc(r+1,sizeof(double));
	if(alpha_vec == NULL)
		assert(0 && "Unable to allocate memory in cholUpdateMult()");
	
	double* h_vec = (double*) mxCalloc(r,sizeof(double));
	if(h_vec == NULL)
		assert(0 && "Unable to allocate memory in cholUpdateMult()");
	
	clock_t t1 = clock();
	alpha_vec[0] = alpha;
	double s,t;
	for(int i = 0; i < r; i++)
	{
		t = 1+alpha_vec[i]*x[i]*x[i];
		h_vec[i] = sqrt(t);
		alpha_vec[i+1] = alpha_vec[i]/t;
		t = B[i*r+i];
		s = 0;
		B[i*r+i] *= h_vec[i];
		for(int j = i-1; j>=0; j--)
		{
			s += t*x[j+1];
			t = B[j*r+i];
			B[j*r+i] += alpha_vec[j+1]*x[j]*s;
			B[j*r+i] *= h_vec[j];
		}
	}


	clock_t t2 = clock();
	t_chol_update += ((double)(t2-t1)/((double)(CLOCKS_PER_SEC)));

	mxFree(alpha_vec);
	mxFree(h_vec);
	return(t_chol_update);
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray* prhs[])
{
	clock_t t1 = clock();

	double*	C = mxGetPr(prhs[0]);								// Constraint matrix
	int	   c = (int)(mxGetM(prhs[0]));							// number of constraints
	double* X = mxGetPr(prhs[1]);								// data points
	int  npts = (int)(mxGetM(prhs[1]));							// number of data points
	int		d = (int)(mxGetN(prhs[1]));							// number of data points
	double* G0 = mxGetPr(prhs[2]);								// input kernel factor matrix
	int	 r = (int)(mxGetN(prhs[2]));							// dimensionality of factor matrix
	double tol = (double)(*mxGetPr(prhs[3]));					// tolerance
	double gamma = (double)(*mxGetPr(prhs[4]));					// gamma
	int max_iters = (int)(*mxGetPr(prhs[5]));					// maximum number of iterations
	int rank = (int)(*mxGetPr(prhs[6]));						// rank of input kernel matrix



	// allocating memory

	// initialize the low rank matrix as I_{rxr}
	double* B = (double*)mxCalloc(r*r,sizeof(double));
	int B_dim[2] = {r,r};

	for(int i = 0;i<r; i++)
		B[i*r+i] = 1;

	double* bhat   = (double*)mxCalloc(c,sizeof(double));
	double* lambda = (double*)mxCalloc(c,sizeof(double));
	double* lambdaold = (double*)mxCalloc(c,sizeof(double));
	double* v = (double*)mxCalloc(r,sizeof(double));
	double* w = (double*)mxCalloc(r,sizeof(double));
	int v_dim[2] = {r,1};

	memcpy(bhat,C+3*c,sizeof(double)*c);
		

	int delta,iter;
	int cnt = 0;
	double beta,conv;
	iter = 0;

	clock_t t3_temp, t4_temp;
	double t_chol = 0.0;
	double t_chol_update = 0.0;
	while(1)
	{
		int i1 = C[cnt]-1;
		int i2 = C[cnt+c]-1;
		memset(v,0.0,sizeof(double)*r);
		for(int i = 0; i < r; i++)
			v[i] = G0[i*npts + i1] - G0[i*npts + i2];
		innerProduct(B,B_dim,v,v_dim,w);
		
		delta = C[cnt+2*c];
		double p,alpha;
		innerProduct(w,v_dim,w,v_dim,&p);
		alpha = min(lambda[cnt],delta*gamma/(gamma + 1)*(1/p - 1/bhat[cnt]));
		lambdaold[cnt] = lambda[cnt];

		beta = delta*alpha/(1-delta*alpha*p);
		bhat[cnt] = gamma*bhat[cnt]/(gamma + delta*alpha*bhat[cnt]);
		lambda[cnt] = lambda[cnt] - alpha;

		
		t3_temp = clock();
		t_chol_update += cholUpdateMult(beta,w,B,r);
		t4_temp = clock();
		t_chol += ((double)(t4_temp-t3_temp)/((double)(CLOCKS_PER_SEC)));

		//for(int row_i = 0; row_i < r; row_i++)
		//{
		//	mexPrintf("\n");
		//	for(int col_i = 0;col_i < r;col_i++)
		//	{
		//		mexPrintf("%.2f ",B[col_i*r+row_i]);
		//	}
		//}
		if(cnt == c-1)
		{
			double norm_sum, norm_lambda, norm_lambdaold, norm_lambdadiff;
			matrixMultiply(lambda,lambda,&norm_lambda,1,c,1);
			matrixMultiply(lambdaold,lambdaold,&norm_lambdaold,1,c,1);
			norm_lambda = sqrt(norm_lambda);
			norm_lambdaold = sqrt(norm_lambdaold);
			double normsum = norm_lambda + norm_lambdaold;
			if(normsum == 0)
				break;
			else
			{
				norm_lambdadiff = 0.0;
				for(int j = 0; j < c; j++)
					norm_lambdadiff += fabs(lambdaold[j] - lambda[j]);
				conv = norm_lambdadiff/normsum;
				if(conv < tol || iter >= max_iters)
					break;
			}
		}
		cnt = cnt % (c-1) + 1;
		iter++;
		if(iter % max(25000,c) == 0)
		{
			mexPrintf("itml iter: %d of %d, conv = %0.12f\n", iter, max_iters, conv);
			mexEvalString("drawnow;");
		}

	}

	mexPrintf("itml converged to tol: %f, iter: %d\n", conv, iter);
	clock_t t2 = clock();
	mexPrintf("total time taken in C++ =  %.4lf\n", ((double)(t2-t1)/((double)(CLOCKS_PER_SEC))));
//	mexPrintf("total time taken in chol update =  %.4lf, %.4lf\n", t_chol,t_chol_update);

	mxArray* G = mxCreateDoubleMatrix(npts,r,mxREAL);
	matrixMultiply(G0,B,mxGetPr(G),npts,r,r);

	mxArray* mxbhat = mxCreateDoubleMatrix((mwSize)c,1,mxREAL);
	memcpy(mxGetPr(mxbhat),bhat,c*sizeof(double));

	plhs[0] = G;
	plhs[1] = mxbhat;

	mxFree(B);
	mxFree(bhat);
	mxFree(lambda);
	mxFree(lambdaold);
	mxFree(v);
}