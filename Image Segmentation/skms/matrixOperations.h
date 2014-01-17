#ifndef _MATRIX_OPERATIONS_H_
#define _MATRIX_OPERATIONS_H_

#include <math.h>
#include <algorithm>
#include <stdio.h>

using namespace std;
extern "C" int dgesvd_(char*, char*, int*, int*, double*, int*, double*,
					   double*, int*, double*, int*, double*, int*, int*);

extern "C" int dgetrf_(int *m, int *n, double *a, int *lda, int *ipiv, int *info);

template<class Tp>
int matrixMultiply(Tp *a, Tp *b, Tp *c, int m, int n, int k)
{
	int i, j, l;
	for( i=0; i<m; i++ )
	{
		for( j=0; j<k; j++ )
		{
			c[j*m+i] = 0;
			for( l=0; l<n; l++ )
				//c[i*k+j] += a[i*n+l]*b[l*k+j];
				c[j*m+i] += a[l*m+i]*b[j*n+l];
		}
	}
	return 0;
}

template<class Tp>
int matrixTranspose(Tp *A, Tp *B, int m, int n)
{
	Tp** temp;
	temp = (Tp**)mxMalloc(m*sizeof(Tp*));
	for(int i = 0; i < m; i++)
		temp[i] = (Tp*)mxMalloc(n*sizeof(Tp));
	
	for(int i = 0; i < n; i++)
		for(int j = 0; j < m; j++)
			temp[j][i] = A[i*m + j];
	
	for(int j = 0; j < m; j++)
		for(int i = 0; i < n; i++)
			B[j*n + i] = temp[j][i];

	for(int i = 0; i < m; i++)
		mxFree(temp[i]);
	mxFree(temp);
	return 0;
}

 inline double round(double val)
{   
  return floor(val + 0.5);
}

template <class Tp>
void innerProduct(const Tp* A, const int a_dim[], const Tp* B, const int b_dim[], Tp* result)
{
// pass a_dim as a 1x2 array of dimensions of A {rows, cols}  & b_dim as an array of dimensions of B {rows,cols}
#ifdef DEBUG_
	mxAssert(a_dim[0] == b_dim[0], "Dimensionality mismatch in function innerProduct");
#endif

	Tp* AtB = result;
	int indexAtb = 0, d = a_dim[0];
	for(int n = 0;n<b_dim[1]; ++n)
	{
		int indexB = n*d;
		for(int m = 0; m<a_dim[1]; ++m)
		{
			int indexA = m*d;
			double sum = 0.0;
			for(int dim_i = 0;dim_i<d; ++dim_i)
			{
				sum += A[indexA + dim_i]*B[indexB + dim_i];
			}
			AtB[indexAtb++] = sum;
		}
	}
}

template<class Tp>
double dotProduct(Tp *pt1, Tp *pt2)
{	
	double val = pt1[0]*pt2[0] + pt1[1]*pt2[1] + pt1[2]*pt2[2];
	return val;
}

static int matrixInverse(double *A, double *B, int m, int n)
{
	int Lwork = 5000*max(m,n);
	int Info;
	double *U, *UT, *V, *VT, *S, *S_, *Sinv, *Work, *ATemp;
	double *tempMul;
	
	U = new double[m*m];
	UT = new double[m*m];
	S_ = new double[min(m,n)];
	S = new double[m*n];
	Sinv = new double[m*n];
	VT = new double[n*n];
	V = new double[n*n];

	Work = new double[Lwork];
	tempMul = new double[m*n];
	ATemp = new double[m*n];
	
	memcpy(ATemp,A,m*n*sizeof(double));
	
	dgesvd_("A", "A", &m, &n, ATemp, &m, S_, U, &m, VT, &n, Work, &Lwork, &Info);

	matrixTranspose(U,UT,m,m);
	matrixTranspose(VT,V,n,n);
	for(int i = 0; i < m*n; i++)
	{
		S[i] = 0.0;
		Sinv[i] = 0.0;
	}
	for(int i = 0; i < min(m,n); i++)
	{
		if(S_[i] > 1.0e-15 || S_[i] < -1.0e-15)
		{
			S[(m+1)*i] = S_[i];
			Sinv[(n+1)*i] = 1.0/S_[i];
		}
	}

	matrixMultiply(V,Sinv,tempMul,n,n,m);
	matrixMultiply(tempMul,UT,B,n,m,m);
	delete []U; delete []UT; delete []V; delete []VT; delete []S_; delete []S; delete []Sinv; delete []Work;
	delete []tempMul; delete []ATemp;
	return 0;
}

//matrix determinant using lu factorization
static double matrixDeterminant(double *A, int m)
{
	int* ipiv = new int[m*sizeof(int)];
	int info;
	double* ATemp = new double[m*m*sizeof(double)];
	memcpy(ATemp,A,m*m*sizeof(double));
	
	dgetrf_(&m, &m, ATemp, &m, ipiv, &info);
	
	// mexPrintf("ipiv = ");
	// for(int i = 0; i < m; i++)
		// mexPrintf("%d ", ipiv[i]);
	// mexPrintf("\n");
	
	double det = 1.0;
	
	for(int i = 0; i < m; i++)
	{
		det *= ATemp[(m+1)*i];
		if(ipiv[i] != i+1)
			det *= -1.0;
	}
	
	delete []ipiv;
	delete []ATemp;
	return det;
}

#endif