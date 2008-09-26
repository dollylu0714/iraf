# Header file for the surface fitting package

# set up the curve descriptor structure

define	LEN_GSSTRUCT	30

define	GS_TYPE		Memi[P2I($1)]	# Type of curve to be fitted
define	GS_XORDER	Memi[P2I($1+1)]	# Order of the fit in x
define	GS_YORDER	Memi[P2I($1+2)]	# Order of the fit in y
define	GS_XTERMS	Memi[P2I($1+3)]	# Cross terms for polynomials
define	GS_NXCOEFF	Memi[P2I($1+4)]	# Number of x coefficients
define	GS_NYCOEFF	Memi[P2I($1+5)]	# Number of y coefficients
define	GS_NCOEFF	Memi[P2I($1+6)]	# Total number of coefficients
define	GS_XMAX		Memr[P2R($1+7)]	# Maximum x value
define	GS_XMIN		Memr[P2R($1+8)]	# Minimum x value
define	GS_YMAX		Memr[P2R($1+9)]	# Maximum y value
define	GS_YMIN		Memr[P2R($1+10)]	# Minimum y value		
define	GS_XRANGE	Memr[P2R($1+11)]	# 2. / (xmax - xmin), polynomials
define	GS_XMAXMIN	Memr[P2R($1+12)]	# - (xmax + xmin) / 2., polynomials
define	GS_YRANGE	Memr[P2R($1+13)]	# 2. / (ymax - ymin), polynomials
define	GS_YMAXMIN	Memr[P2R($1+14)]	# - (ymax + ymin) / 2., polynomials
define	GS_NPTS		Memz[P2Z($1+15)]	# Number of data points

define	GS_MATRIX	Memp[$1+16]	# Pointer to original matrix
define	GS_CHOFAC	Memp[$1+17]	# Pointer to Cholesky factorization
define	GS_VECTOR	Memp[$1+18]	# Pointer to  vector
define	GS_COEFF	Memp[$1+19]	# Pointer to coefficient vector
define	GS_XBASIS	Memp[$1+20]	# Pointer to basis functions (all x)
define	GS_YBASIS	Memp[$1+21]	# Pointer to basis functions (all y)
define	GS_WZ		Memp[$1+22]	# Pointer to w * z (gsrefit)

# matrix and vector element definitions

define	XBASIS		Memr[$1]	# Non zero basis for all x
define	YBASIS		Memr[$1]	# Non zero basis for all y
define	XBS		Memr[$1]	# Non zero basis for single x
define	YBS		Memr[$1]	# Non zero basis for single y
define	MATRIX		Memr[$1]	# Element of MATRIX
define	CHOFAC		Memr[$1]	# Element of CHOFAC
define	VECTOR		Memr[$1]	# Element of VECTOR
define	COEFF		Memr[$1]	# Element of COEFF

# structure definitions for restore

define	GS_SAVETYPE	$1[1]
define	GS_SAVEXORDER	$1[2]
define	GS_SAVEYORDER	$1[3]
define	GS_SAVEXTERMS	$1[4]
define	GS_SAVEXMIN	$1[5]
define	GS_SAVEXMAX	$1[6]
define	GS_SAVEYMIN	$1[7]
define	GS_SAVEYMAX	$1[8]

# data type

define	DELTA		EPSILON

# miscellaneous
