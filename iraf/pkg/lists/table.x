# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<ctype.h>

# Read a list of strings from the standard input or a list of files and
# assemble them into a nicely formatted table.  If reading from multiple
# input files, make a separate table for each.  There is no fixed limit
# to the size of the table which can be formatted.  The table is not
# sorted; this should be done as a separate operation if desired.

define	INIT_STRBUF		512
define	STRBUF_INCREMENT	1024
define	INIT_MAXSTR		64
define	MAXSTR_INCREMENT	128


procedure t_table()

int	first_col, last_col, ncols, maxstrlen
int	fd, nextch, maxch, sz_strbuf
size_t	nstrings, max_strings
pointer	sp, strbuf, fname, stroff, list, ip
size_t	sz_val
int	strlen(), fscan(), nscan()
int	clgfil(), open(), envgeti(), clplen(), clgeti()
pointer	clpopni()

begin
	# Allocate buffers.  The string buffer "strbuf", and associated list
	# of offsets "stroff" will be reallocated later if they fill up.
	call smark (sp)
	sz_val = SZ_FNAME
	call salloc (fname, sz_val, TY_CHAR)

	sz_val = INIT_STRBUF
	call malloc (strbuf, sz_val, TY_CHAR)
	sz_val = INIT_MAXSTR
	call malloc (stroff, sz_val, TY_POINTER)


	# Get various table formatting parameters from CL.
	ncols = clgeti ("ncols")
	first_col = clgeti ("first_col")
	last_col = clgeti ("last_col")

	# Attempt to read the terminal x-dimension from the environment,
	# if the user did not specify a valid "last_col".  No good reason
	# to abort if cannot find environment variable.
	if (last_col == 0)
	    iferr (last_col = envgeti ("ttyncols"))
		last_col = 80

	# Set maximum string length to size of an output line if max length
	# not given.
	maxstrlen = clgeti ("maxstrlen")
	if (maxstrlen == 0)
	    maxch = last_col - first_col + 1
	else
	    maxch = min (maxstrlen, last_col - first_col + 1)

	max_strings = INIT_MAXSTR
	sz_strbuf = INIT_STRBUF


	# Read the contents of each file into a big string buffer.  Print a
	# separate table for each file.

	list = clpopni ("input_files")

	while (clgfil (list, Memc[fname], SZ_FNAME) != EOF) {
	    fd = open (Memc[fname], READ_ONLY, TEXT_FILE)
	    nextch = 1
	    nstrings = 0

	    # If printing several tables, label each with the name of the file.
	    if (clplen (list) > 1) {
		call printf ("\n==> %s <==\n")
		    call pargstr (Memc[fname])
	    }
		
	    while (fscan (fd) != EOF) {
		call gargstr (Memc[strbuf+nextch-1], maxch)
		# Ignore blank lines and faulty scans.
		if (nscan() == 0)
		    next
		for (ip=strbuf+nextch-1;  IS_WHITE (Memc[ip]);  ip=ip+1)
		    ;
		if (Memc[ip] == '\n' || Memc[ip] == EOS)
		    next

		# Save one indexed string index for strtbl.
		Memp[stroff+nstrings] = nextch
		nextch = nextch + strlen (Memc[strbuf+nextch-1]) + 1

		# Check buffers, make bigger if necessary.
		if (nextch + maxch >= sz_strbuf) {
		    sz_strbuf = sz_strbuf + STRBUF_INCREMENT
		    sz_val = sz_strbuf
		    call realloc (strbuf, sz_val, TY_CHAR)
		}
		# Add space for more string offsets if too many strings.
		nstrings = nstrings + 1
		if (nstrings > max_strings) {
		    max_strings = max_strings + MAXSTR_INCREMENT
		    call realloc (stroff, max_strings, TY_POINTER)
		}
	    }

	    # Print the table on the standard output.
	    call strtbl (STDOUT, Memc[strbuf], Memp[stroff], nstrings,
	    first_col, last_col, maxch, ncols)
	}

	call clpcls (list)
	call mfree (strbuf, TY_CHAR)
	call mfree (stroff, TY_POINTER)
	call sfree (sp)
end
