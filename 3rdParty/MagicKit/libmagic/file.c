/*
 * Copyright (c) Ian F. Darwin 1986-1995.
 * Software written by Ian F. Darwin and others;
 * maintained 1995-present by Christos Zoulas and others.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice immediately at the beginning of the file, without modification,
 *    this list of conditions, and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */
/*
 * file - find type of a file or files - main program.
 */

#include "file.h"

#ifndef	lint
FILE_RCSID("@(#)$File: file.c,v 1.145 2011/12/08 12:12:46 rrt Exp $")
#endif	/* lint */

#include "magic.h"

#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#ifdef RESTORE_TIME
# if (__COHERENT__ >= 0x420)
#  include <sys/utime.h>
# else
#  ifdef USE_UTIMES
#   include <sys/time.h>
#  else
#   include <utime.h>
#  endif
# endif
#endif
#ifdef HAVE_UNISTD_H
#include <unistd.h>	/* for read() */
#endif
#ifdef HAVE_LOCALE_H
#include <locale.h>
#endif
#ifdef HAVE_WCHAR_H
#include <wchar.h>
#endif

#if defined(HAVE_GETOPT_H) && defined(HAVE_STRUCT_OPTION)
#include <getopt.h>
#ifndef HAVE_GETOPT_LONG
int getopt_long(int argc, char * const *argv, const char *optstring, const struct option *longopts, int *longindex);
#endif
#else
#include "mygetopt.h"
#endif

#ifdef S_IFLNK
#define FILE_FLAGS "-bchikLlNnprsvz0"
#else
#define FILE_FLAGS "-bciklNnprsvz0"
#endif

# define USAGE  \
    "Usage: %s [" FILE_FLAGS \
	"] [--apple] [--mime-encoding] [--mime-type]\n" \
    "            [-e testname] [-F separator] [-f namefile] [-m magicfiles] " \
    "file ...\n" \
    "       %s -C [-m magicfiles]\n" \
    "       %s [--help]\n"

private int 		/* Global command-line options 		*/
	bflag = 0,	/* brief output format	 		*/
	nopad = 0,	/* Don't pad output			*/
	nobuffer = 0,   /* Do not buffer stdout 		*/
	nulsep = 0;	/* Append '\0' to the separator		*/

private const char *separator = ":";	/* Default field separator	*/
/*private const struct option long_options[] = {
#define OPT(shortname, longname, opt, doc)      \
    {longname, opt, NULL, shortname},
#define OPT_LONGONLY(longname, opt, doc)        \
    {longname, opt, NULL, 0},
#include "file_opts.h"
#undef OPT
#undef OPT_LONGONLY
    {0, 0, NULL, 0}
};*/
#define OPTSTRING	"bcCde:f:F:hiklLm:nNprsvz0"

/*private const struct {
	const char *name;
	int value;
} nv[] = {
	{ "apptype",	MAGIC_NO_CHECK_APPTYPE },
	{ "ascii",	MAGIC_NO_CHECK_ASCII },
	{ "cdf",	MAGIC_NO_CHECK_CDF },
	{ "compress",	MAGIC_NO_CHECK_COMPRESS },
	{ "elf",	MAGIC_NO_CHECK_ELF },
	{ "encoding",	MAGIC_NO_CHECK_ENCODING },
	{ "soft",	MAGIC_NO_CHECK_SOFT },
	{ "tar",	MAGIC_NO_CHECK_TAR },
	{ "text",	MAGIC_NO_CHECK_TEXT },
	{ "tokens",	MAGIC_NO_CHECK_TOKENS }, 
};*/

private char *progname;		/* used throughout 		*/

private void usage(void);
private void help(void);

//int main(int, char *[]);

private int unwrap(struct magic_set *, const char *);
private int process(struct magic_set *ms, const char *, int);
private struct magic_set *load(const char *, int);


private struct magic_set *
/*ARGSUSED*/
load(const char *magicfile, int flags)
{
	struct magic_set *magic = magic_open(flags);
	if (magic == NULL) {
		(void)fprintf(stderr, "%s: %s\n", progname, strerror(errno));
		return NULL;
	}
	if (magic_load(magic, magicfile) == -1) {
		(void)fprintf(stderr, "%s: %s\n",
		    progname, magic_error(magic));
		magic_close(magic);
		return NULL;
	}
	return magic;
}

/*
 * unwrap -- read a file of filenames, do each one.
 */
private int
unwrap(struct magic_set *ms, const char *fn)
{
	FILE *f;
	ssize_t len;
	char *line = NULL;
	size_t llen = 0;
	int wid = 0, cwid;
	int e = 0;

	if (strcmp("-", fn) == 0) {
		f = stdin;
		wid = 1;
	} else {
		if ((f = fopen(fn, "r")) == NULL) {
			(void)fprintf(stderr, "%s: Cannot open `%s' (%s).\n",
			    progname, fn, strerror(errno));
			return 1;
		}

		while ((len = getline(&line, &llen, f)) > 0) {
			if (line[len - 1] == '\n')
				line[len - 1] = '\0';
			cwid = (int)file_mbswidth(line);
			if (cwid > wid)
				wid = cwid;
		}

		rewind(f);
	}

	while ((len = getline(&line, &llen, f)) > 0) {
		if (line[len - 1] == '\n')
			line[len - 1] = '\0';
		e |= process(ms, line, wid);
		if(nobuffer)
			(void)fflush(stdout);
	}

	free(line);
	(void)fclose(f);
	return e;
}

/*
 * Called for each input file on the command line (or in a list of files)
 */
private int
process(struct magic_set *ms, const char *inname, int wid)
{
	const char *type;
	int std_in = strcmp(inname, "-") == 0;

	if (wid > 0 && !bflag) {
		(void)printf("%s", std_in ? "/dev/stdin" : inname);
		if (nulsep)
			(void)putc('\0', stdout);
		(void)printf("%s", separator);
		(void)printf("%*s ",
		    (int) (nopad ? 0 : (wid - file_mbswidth(inname))), "");
	}

	type = magic_file(ms, std_in ? NULL : inname);
	if (type == NULL) {
		(void)printf("ERROR: %s\n", magic_error(ms));
		return 1;
	} else {
		(void)printf("%s\n", type);
		return 0;
	}
}

size_t
file_mbswidth(const char *s)
{
#if defined(HAVE_WCHAR_H) && defined(HAVE_MBRTOWC) && defined(HAVE_WCWIDTH)
	size_t bytesconsumed, old_n, n, width = 0;
	mbstate_t state;
	wchar_t nextchar;
	(void)memset(&state, 0, sizeof(mbstate_t));
	old_n = n = strlen(s);

	while (n > 0) {
		bytesconsumed = mbrtowc(&nextchar, s, n, &state);
		if (bytesconsumed == (size_t)(-1) ||
		    bytesconsumed == (size_t)(-2)) {
			/* Something went wrong, return something reasonable */
			return old_n;
		}
		if (s[0] == '\n') {
			/*
			 * do what strlen() would do, so that caller
			 * is always right
			 */
			width++;
		} else
			width += wcwidth(nextchar);

		s += bytesconsumed, n -= bytesconsumed;
	}
	return width;
#else
	return strlen(s);
#endif
}

private void
usage(void)
{
	(void)fprintf(stderr, USAGE, progname, progname, progname);
	exit(1);
}

private void
help(void)
{
	(void)fputs(
"Usage: file [OPTION...] [FILE...]\n"
"Determine type of FILEs.\n"
"\n", stdout);
#define OPT(shortname, longname, opt, doc)      \
	fprintf(stdout, "  -%c, --" longname doc, shortname);
#define OPT_LONGONLY(longname, opt, doc)        \
	fprintf(stdout, "      --" longname doc);
#include "file_opts.h"
#undef OPT
#undef OPT_LONGONLY
	fprintf(stdout, "\nReport bugs to http://bugs.gw.com/\n");
	exit(0);
}
