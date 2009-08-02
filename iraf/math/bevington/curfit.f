C SUBROUTINE CURFIT.F 
C
C SOURCE
C   BEVINGTON, PAGES 237-239.
C
C PURPOSE
C   MAKE A LEAST-SQUARES FIT TO A NON-LINEAR FUNCTION
C      WITH A LINEARIZATION OF THE FITTING FUNCTION
C
C USAGE 
C   CALL CURFIT (X, Y, SIGMAY, NPTS, NTERMS, MODE, A, DELTAA,
C      SIGMAA, FLAMDA, YFIT, CHISQR ,FUNCTN)
C
C DESCRIPTION OF PARAMETERS
C   X	   - ARRAY OF DATA POINTS FOR INDEPENDENT VARIABLE
C   Y	   - ARRAY OF DATA POINTS FOR DEPENDENT VARIABLE
C   SIGMAY - ARRAY OF STANDARD DEVIATIONS FOR Y DATA POINTS
C   NPTS   - NUMBER OF PAIRS OF DATA POINTS
C   NTERMS - NUMBER OF PARAMETERS
C   MODE   - DETERMINES METHOD OF WEIGHTING LEAST-SQUARES FIT
C	     +1 (INSTRUMENTAL) WEIGHT(I) = 1./SIGMAY(I)**2
C	      0 (NO WEIGHTING) WEIGHT(I) = 1.
C	     -1 (STATISTICAL)  WEIGHT(I) = 1./Y(I)
C   A	   - ARRAY OF PARAMETERS
C   DELTAA - ARRAY OF INCREMENTS FOR PARAMETERS A
C   SIGMAA - ARRAY OF STANDARD DEVIATIONS FOR PARAMETERS A
C   FLAMDA - PROPORTION OF GRADIENT SEARCH INCLUDED
C   YFIT   - ARRAY OF CALCULATED VALUES OF Y
C   CHISQR - REDUCED CHI SQUARE FOR FIT 
C
C SUBROUTINES AND FUNCTION SUBPROGRAMS REQUIRED 
C   FUNCTN (X, I, A)
C      EVALUATES THE FITTING FUNCTION FOR THE ITH TERM
C   FCHISQ (Y, SIGMAY, NPTS, NFREE, MODE, YFIT) 
C      EVALUATES REDUCED CHI SQUARED FOR FIT TO DATA
C   FDERIV (X, I, A, DELTAA, NTERMS, DERIV, FUNCTN)
C      EVALUATES THE DERIVATIVES OF THE FITTING FUNCTION
C      FOR THE ITH TERM WITH RESPECT TO EACH PARAMETER
C   MATINV (ARRAY, NTERMS, DET) 
C      INVERTS A SYMMETRIC TWO-DIMENSIONAL MATRIX OF DEGREE NTERMS
C      AND CALCULATES ITS DETERMINANT
C
C COMMENTS
C   DIMENSION STATEMENT VALID FOR NTERMS UP TO 10
C   SET FLAMDA = 0.001 AT BEGINNING OF SEARCH
C
      SUBROUTINE CURFIT (X,Y,SIGMAY,NPTS,NTERMS,MODE,A,DELTAA,
     *SIGMAA,FLAMDA,YFIT,CHISQR,FUNCTN)
      REAL FUNCTN
      EXTERNAL FUNCTN
      DOUBLE PRECISION ARRAY
      DIMENSION X(1),Y(1),SIGMAY(1),A(1),DELTAA(1),SIGMAA(1), 
     *YFIT(1)
      DIMENSION WEIGHT(100),ALPHA(10,10),BETA(10),DERIV(10),
     *ARRAY(10,10),B(10)
C
11     NFREE=NPTS-NTERMS
       IF (NFREE) 13,13,20
13     CHISQR=0.
       GOTO 110
C
C EVALUATE WEIGHTS
C
20     DO 30 I=1,NPTS
21     IF (MODE) 22,27,29
22     IF (Y(I)) 25,27,23
23     WEIGHT(I)=1./Y(I)
       GOTO 30 
25     WEIGHT(I)=1./(-Y(I))
       GOTO 30 
27     WEIGHT(I)=1.
       GOTO 30 
29     WEIGHT(I)=1./SIGMAY(I)**2
30     CONTINUE
C
C EVALUATE ALPHA AND BETA MATRICES
C
31     DO 34 J=1,NTERMS
       BETA(J)=0.
       DO 34 K=1,J
34     ALPHA(J,K)=0.
41     DO 50 I=1,NPTS
       CALL FDERIV (X,I,A,DELTAA,NTERMS,DERIV,FUNCTN)
       DO 46 J=1,NTERMS
       BETA(J)=BETA(J)+WEIGHT(I)*(Y(I)-FUNCTN(X,I,A))*DERIV(J) 
       DO 46 K=1,J
46     ALPHA(J,K)=ALPHA(J,K)+WEIGHT(I)*DERIV(J)*DERIV(K)
50     CONTINUE
51     DO 53 J=1,NTERMS
       DO 53 K=1,J
53     ALPHA(K,J)=ALPHA(J,K)
C
C EVALUATE CHI SQUARE AT STARTING POINT 
C
61     DO 62 I=1,NPTS
62     YFIT(I)=FUNCTN (X,I,A)
63     CHISQ1=FCHISQ (Y,SIGMAY,NPTS,NFREE,MODE,YFIT)
C
C INVERT MODIFIED CURVATURE MATRIX TO FIND NEW PARAMETERS
C
71     DO 74 J=1,NTERMS
       DO 73 K=1,NTERMS
73     ARRAY(J,K)=ALPHA(J,K)/SQRT(ALPHA(J,J)*ALPHA(K,K))
74     ARRAY(J,J)=1.+FLAMDA
80     CALL MATINV (ARRAY,NTERMS,DET)
81     DO 84 J=1,NTERMS
       B(J)=A(J)
       DO 84 K=1,NTERMS
84     B(J)=B(J)+BETA(K)*ARRAY(J,K)/SQRT(ALPHA(J,J)*ALPHA(K,K))
C
C IF CHI SQUARE INCREASED, INCREASE FLAMDA AND TRY AGAIN
C
91     DO 92 I=1,NPTS
92     YFIT(I)=FUNCTN (X,I,B)
93     CHISQR=FCHISQ (Y,SIGMAY,NPTS,NFREE,MODE,YFIT)
       IF (CHISQ1-CHISQR) 95,101,101
95     FLAMDA=10.*FLAMDA
       GOTO 71 
C
C EVALUATE PARAMETERS AND UNCERTAINTIES 
C
101    DO 103 J=1,NTERMS
       A(J)=B(J)
103    SIGMAA(J)=SQRT(ARRAY(J,J)/ALPHA(J,J))
       FLAMDA=FLAMDA/10.
110    RETURN
       END
