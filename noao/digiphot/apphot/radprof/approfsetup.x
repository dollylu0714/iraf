include "../lib/display.h"
include "../lib/center.h"
include "../lib/fitsky.h"

define	HELPFILE	"apphot$radprof/iradprof.key"

# AP_PROFSETUP -- Procedure to set up radprof interactively using a radial
# profile plot.

procedure ap_profsetup (ap, im, wx, wy, gd, out, stid)

pointer	ap			# pointer to apphot structure
pointer	im			# pointer to the IRAF image
real	wx, wy			# cursor coordinates
pointer	gd			# pointer to graphics stream
int	out			# output file descriptor
int	stid			# output file sequence number

int	cier, sier, pier, rier, wcs, key
pointer	sp, str, cmd
real	xc, yc, xcenter, ycenter, rmin, rmax, imin, imax, rval
real	u1, u2, v1, v2, x1, x2, y1, y2

int	apfitcenter(), clgcur(), apfitsky(), ap_frprof(), apstati()
int	ap_showplot()
real	apstatr(), ap_cfwhmpsf(), ap_ccapert(), ap_cannulus(), ap_cdannulus()
real	ap_crprof(), ap_crpstep(), ap_cdatamin()
real	ap_cdatamax(), ap_crgrow(), ap_crclip(), ap_crclean(), ap_csigma()

begin
	if (gd == NULL)
	    return
	call greactivate (gd, 0)

	# Save old viewport and window
	call ggview (gd, u1, u2, v1, v2)
	call ggwind (gd, x1, x2, y1, y2)

	# Plot the radial profile.
	if (ap_showplot (ap, im, wx, wy, gd, xcenter, ycenter, rmin, rmax,
	    imin, imax) == ERR) {
	    call gdeactivate (gd, 0)
	    return
	}

	call smark (sp)
	call salloc (str, SZ_LINE, TY_CHAR)
	call salloc (cmd, SZ_LINE, TY_CHAR)
        call printf (
        "Waiting for setup menu command (?=help, v=default setup, q=quit):\n")
	while (clgcur ("gcommands", xc, yc, wcs, key, Memc[cmd],
	    SZ_LINE) != EOF) {

	switch (key) {

	    case 'q':
	        break
	    case '?':
		call gpagefile (gd, HELPFILE, "")
	    case 'f':
	        rval = ap_cfwhmpsf (ap, gd, out, stid, rmin, rmax, imin, imax)
	    case 's':
	        rval = ap_csigma (ap, gd, out, stid, rmin, rmax, imin, imax)
	    case 'l':
	        rval = ap_cdatamin (ap, gd, out, stid, rmin, rmax, imin, imax)
	    case 'u':
	        rval = ap_cdatamax (ap, gd, out, stid, rmin, rmax, imin, imax)
	    case 'c':
	        rval = ap_ccapert (ap, gd, out, stid, rmin, rmax, imin, imax)
	    case 'n':
	        rval = ap_crclean (ap, gd, out, stid, rmin, rmax, imin, imax)
	    case 'p':
	        rval = ap_crclip (ap, gd, out, stid, rmin, rmax, imin, imax)
	    case 'a':
	        rval = ap_cannulus (ap, gd, out, stid, rmin, rmax, imin, imax)
	    case 'd':
	        rval = ap_cdannulus (ap, gd, out, stid, apstatr (ap, ANNULUS),
		    rmin, rmax, imin, imax)
	    case 'g':
	        rval = ap_crgrow (ap, gd, out, stid, rmin, rmax, imin, imax)
	    case 'r':
		call ap_caper (ap, gd, out, stid, Memc[str], rmin, rmax,
		    imin, imax)
	    case 'w':
		rval = ap_crprof (ap, gd, out, stid, rmin, rmax, imin, imax)
	    case 'x':
		rval = ap_crpstep (ap, gd, out, stid, rmin, rmax, imin, imax)
	    case 'v':
	        rval = ap_cfwhmpsf (ap, gd, out, stid, rmin, rmax, imin, imax)
	        rval = ap_ccapert (ap, gd, out, stid, rmin, rmax, imin, imax)
	        rval = ap_cannulus (ap, gd, out, stid, rmin, rmax, imin, imax)
	        rval = ap_cdannulus (ap, gd, out, stid, apstatr (ap, ANNULUS),
		    rmin, rmax, imin, imax)
	        rval = ap_csigma (ap, gd, out, stid, rmin, rmax, imin, imax)
		call ap_caper (ap, gd, out, stid, Memc[str], rmin, rmax,
		    imin, imax)
		rval = ap_crprof (ap, gd, out, stid, rmin, rmax, imin, imax)
		rval = ap_crpstep (ap, gd, out, stid, rmin, rmax, imin, imax)
	    default:
		call printf ("Unknown or ambiguous keystroke command\007\n")
	    }
            call printf (
         "Waiting for setup menu command (?=help, v=default setup, q=quit):\n")
	}
	call printf (
	    "Interactive setup is complete. Type w to save parameters.\n")

	# Restore old view port and window
	call gsview (gd, u1, u2, v1, v2)
	call gswind (gd, x1, x2, y1, y2)

	call gdeactivate (gd, 0)
	call sfree (sp)

	# Compute the answer.
	cier = apfitcenter (ap, im, xcenter, ycenter)
	sier = apfitsky (ap, im, apstatr (ap, XCENTER), apstatr (ap, YCENTER),
	    NULL, gd)
	rier = ap_frprof (ap, im, apstatr (ap, XCENTER), apstatr (ap, YCENTER),
	    pier)
	call ap_rpplot (ap, 0, gd, apstati (ap, RADPLOTS))
	call ap_qprprof (ap, cier, sier, pier, rier)
end
