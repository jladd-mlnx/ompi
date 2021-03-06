# -*- shell-script -*-
#
# Copyright (c) 2004-2005 The Trustees of Indiana University and Indiana
#                         University Research and Technology
#                         Corporation.  All rights reserved.
# Copyright (c) 2004-2005 The University of Tennessee and The University
#                         of Tennessee Research Foundation.  All rights
#                         reserved.
# Copyright (c) 2004-2005 High Performance Computing Center Stuttgart,
#                         University of Stuttgart.  All rights reserved.
# Copyright (c) 2004-2005 The Regents of the University of California.
#                         All rights reserved.
# Copyright (c) 2009-2011 Cisco Systems, Inc.  All rights reserved.
# Copyright (c) 2011-2013 Los Alamos National Security, LLC. All rights
#                         reserved.
# Copyright (c) 2014      Intel, Inc. All rights reserved.
# $COPYRIGHT$
#
# Additional copyrights may follow
#
# $HEADER$
#

#
# special check for cray pmi, uses macro(s) from pkg.m4 
#
# OPAL_CHECK_CRAY_PMI(prefix, [action-if-found], [action-if-not-found])
# --------------------------------------------------------
AC_DEFUN([OPAL_CHECK_CRAY_PMI],[

    PKG_CHECK_MODULES([CRAY_PMI], [cray-pmi],
                      [$1_LDFLAGS="$CRAY_PMI_LIBS"
                       $1_CPPFLAGS="$CRAY_PMI_CFLAGS"
                       $1_LIBS="$1_LDFLAGS"
                        $2],
                       [AC_MSG_RESULT([no])
                        $3])
])


# OPAL_CHECK_PMI(prefix, [action-if-found], [action-if-not-found])
# --------------------------------------------------------
AC_DEFUN([OPAL_CHECK_PMI],[
    AC_ARG_WITH([pmi],
                [AC_HELP_STRING([--with-pmi(=DIR)],
                                [Build PMI support, optionally adding DIR to the search path (default: no)])],
	                        [], with_pmi=no)

    opal_enable_pmi=0
    opal_pmi_rpath=
    opal_have_pmi2=0
    opal_have_pmi1=0
    opal_check_pmi_incdir=
    opal_check_pmi_libdir=
    opal_default_loc=0
    opal_pmi_added_cppflag=no
    opal_pmi_added_ldflag=no

    # save flags
    opal_check_pmi_$1_save_CPPFLAGS="$CPPFLAGS"
    opal_check_pmi_$1_save_LDFLAGS="$LDFLAGS"
    opal_check_pmi_$1_save_LIBS="$LIBS"

    # set defaults
    opal_check_pmi_$1_LDFLAGS=
    opal_check_pmi_$1_CPPFLAGS=
    opal_check_pmi_$1_LIBS=

    AC_MSG_CHECKING([if user requested PMI support])
    AS_IF([test "$with_pmi" = "no"],
          [AC_MSG_RESULT([no])
           $3],
          [AC_MSG_RESULT([yes])
           AC_MSG_CHECKING([if PMI installed])
           # cannot use OPAL_CHECK_PACKAGE as its backend header
           # support appends "include" to the path, which won't
           # work with slurm :-(
           AS_IF([test ! -z "$with_pmi" -a "$with_pmi" != "yes"],
                 [opal_check_pmi_incdir=$with_pmi
                  opal_check_pmi_libdir=$with_pmi
                  opal_default_loc="no"],
                 [opal_check_pmi_incdir="/usr/include"
                  opal_check_pmi_libdir="/usr"
                  opal_default_loc="yes"])
           # check for pmi-1 lib */
           AS_IF([test -f "$opal_check_pmi_libdir/lib64/libpmi.so"],
                 [opal_have_pmi1=1
                  AS_IF([test "$opal_default_loc" == "no"],
                        [opal_check_pmi_$1_LDFLAGS="-L$opal_check_pmi_libdir/lib64"
                         opal_pmi_rpath="$opal_check_pmi_libdir/lib64"
                         opal_pmi_added_ldflag=yes])
                  opal_check_pmi_$1_LIBS="-lpmi"],
                 [AS_IF([test -f "$opal_check_pmi_libdir/lib/libpmi.so"],
                        [opal_have_pmi1=1
                         AS_IF([test "$opal_default_loc" == "no"],
                               [opal_check_pmi_$1_LDFLAGS="-L$opal_check_pmi_libdir/lib"
                                opal_pmi_rpath="$opal_check_pmi_libdir/lib"
                                opal_pmi_added_ldflag=yes])
                         opal_check_pmi_$1_LIBS="-lpmi"])])
           # check for pmi.h
           AS_IF([test -f "$opal_check_pmi_incdir/include/pmi.h"],
               [AS_IF([test "$opal_default_loc" == "no"],
                      [opal_check_pmi_$1_CPPFLAGS="-I$opal_check_pmi_incdir/include"
                       opal_pmi_added_cppflag=yes])],
               # this could be SLURM, which puts things in a different location
               [AS_IF([test -f "$opal_check_pmi_incdir/include/slurm/pmi.h"],
                       # even if this was the default loc, we still need to add it in
                       # because of the slurm path addition
                      [opal_check_pmi_$1_CPPFLAGS="-I$opal_check_pmi_incdir/include/slurm"
                       opal_pmi_added_cppflag=yes])])

           # check for pmi2 lib */
           AS_IF([test -f "$opal_check_pmi_libdir/lib64/libpmi2.so"],
                 [opal_have_pmi2=1
                  AS_IF([test "$opal_pmi_added_ldflag" != "yes" && "$opal_default_loc" == "no"],
                        [opal_check_pmi_$1_LDFLAGS="$-L$opal_check_pmi_libdir/lib64"
                         opal_pmi_rpath="$opal_check_pmi_libdir/lib64"])
                  opal_check_pmi_$1_LIBS="$opal_check_pmi_$1_LIBS -lpmi2"],
                 [AS_IF([test -f "$opal_check_pmi_libdir/lib/libpmi2.so"],
                        [opal_have_pmi2=1
                         AS_IF([test "$opal_pmi_added_ldflag" != "yes" && "$opal_default_loc" == "no"],
                               [opal_check_pmi_$1_LDFLAGS="$-L$opal_check_pmi_libdir/lib"
                                opal_pmi_rpath="$opal_check_pmi_libdir/lib"])
                         opal_check_pmi_$1_LIBS="$opal_check_pmi_$1_LIBS -lpmi2"])])
           # check for pmi2.h
           AS_IF([test -f "$opal_check_pmi_incdir/include/pmi2.h"],
               [AS_IF([test "$opal_pmi_added_cppflag" != "yes" && "$opal_default_loc" == "no"],
                      [opal_check_pmi_$1_CPPFLAGS="-I$opal_check_pmi_incdir/include"])],
               # this could be SLURM, which puts things in a different location
               [AS_IF([test -f "$opal_check_pmi_incdir/include/slurm/pmi2.h"],
                       # even if this was the default loc, we still need to add it in
                       # because of the slurm path addition
                      [opal_check_pmi_$1_CPPFLAGS="-I$opal_check_pmi_incdir/include/slurm"])])

           # since support was explicitly requested, then we should error out
           # if we didn't find the required support
           AS_IF([test $opal_have_pmi1 != 1 && $opal_have_pmi2 != 1],
                 [AC_MSG_RESULT([not found])
                  AC_MSG_WARN([PMI support requested (via --with-pmi) but neither libpmi])
                  AC_MSG_WARN([nor libpmi2 were found under locations:])
                  AC_MSG_WARN([    $opal_check_pmi_libdir/lib])
                  AC_MSG_WARN([    $opal_check_pmi_libdir/lib64])
                  AC_MSG_WARN([Specified path: $with_pmi])
                  AC_MSG_ERROR([Aborting])
                  $3],
                 [AC_MSG_RESULT([yes])
                  opal_enable_pmi=1
                  $1_LDFLAGS="$opal_check_pmi_$1_LDFLAGS"
                  $1_CPPFLAGS="$opal_check_pmi_$1_CPPFLAGS"
                  $1_LIBS="$opal_check_pmi_$1_LIBS  -Wl,-rpath=$opal_pmi_rpath"
                  AC_MSG_CHECKING([final added libraries])
                  AC_MSG_RESULT([$opal_check_pmi_$1_LIBS])
                  $2])
           ])

    # restore flags
    CPPFLAGS="$opal_check_pmi_$1_save_CPPFLAGS"
    LDFLAGS="$opal_check_pmi_$1_save_LDFLAGS"
    LIBS="$opal_check_pmi_$1_save_LIBS"
])
