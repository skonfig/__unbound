#!/usr/bin/awk -f
#
# 2024 Dennis Camera (dennis.camera at riiengineering.ch)
#
# This file is part of the skonfig set __unbound.
#
# This set is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This set is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this set. If not, see <http://www.gnu.org/licenses/>.
#
# This script reads a "diff" specification on stdin.
# The diff specification is the same used by update_unbound_conf.awk and
# it is of the form:
#
#  + TOP_LEVEL:option: value  (ensure the given value is one of the options)
#  = TOP_LEVEL:option: value  (ensure only one of "option" is present with "value")
#  - TOP_LEVEL:option: value? (remove either option with given value or if value is empty all options)
#

function usage() {
	print "Usage: awk -f filter_diff.awk explorer/options <diff"
}

function options_dump(    k, i, s) {
	for (k in OPTIONS) {
		if (index(k, SUBSEP)) continue

		for (i = 1; i <= OPTIONS[k]; ++i) {
			s = ""

			if (OPTIONS[k, i, "deleted"]) {
				s = (s ? s ", " : s) "deleted by \"" DIFF_LINES[OPTIONS[k, i, "deleted"]] "\""
			}
			if (OPTIONS[k, i, "added"]) {
				s = (s ? s ", " : s) "added by \"" DIFF_LINES[OPTIONS[k, i, "added"]] "\""
			}

			printf "> %s: %s %s" ORS, k, OPTIONS[k, i], (s ? "["s"]" : "")
		}
	}
	print ""
}

function option_is_deleted(k, i) {
	return (OPTIONS[k, i, "deleted"] && !OPTIONS[k, i, "added"])
}
function option_has(k, v,    i) {
	for (i = 1; i <= OPTIONS[k]; ++i) {
		if (v == OPTIONS[k, i] && !option_is_deleted(k, i)) {
			return 1
		}
	}
	return 0
}
function option_add(k, v,    i) {
	for (i = 1; i <= OPTIONS[k]; ++i) {
		if (v == OPTIONS[k, i]) {
			if (option_is_deleted(k, i)) {
				# revert
				OPTIONS[k, i, "added"] = DIFF_CUR
				return
			}
		}
	}

	# new
	++OPTIONS[k]
	OPTIONS[k, OPTIONS[k]] = v
	OPTIONS[k, OPTIONS[k], "added"] = DIFF_CUR
}
function option_remove(k, v,    i) {
	for (i = 1; i <= OPTIONS[k]; ++i) {
		if ((v == "" || v == OPTIONS[k, i]) \
				&& !option_is_deleted(k, i)) {
			OPTIONS[k, i, "deleted"] = DIFF_CUR
		}
	}
}


BEGIN {
	FS = "\n"  # disable field splitting

	CSEP_RE = ":( +|$)"

	if (ARGC != 2) {
		# incorrect number of arguments
		usage()
		exit (e=1)
	}
}

/^[ \t]*(\#|$)/ { next }

{
	match($0, CSEP_RE)
	k = substr($0, 1, RSTART - 1)
	v = substr($0, RSTART + RLENGTH)
	sub(/^ */, "", v)

	++OPTIONS[k]
	OPTIONS[k, OPTIONS[k]] = v
}

END {
	if (e) exit e

	# read diff lines from stdin, and print only those which modify the given options
	while (0 < ("cat" | getline)) {
		++DIFF_CUR

		if (/^[ \t]*(\#|$)/) {
			# ignore empty and comment lines
			continue
		}
		if (!/^[+=-][ \t]/) {
			# error
			continue
		}

		DIFF_LINES[DIFF_CUR] = $0

		op = substr($0, 1, 1)
		sub(/^.[ \t]+/, "")

		if (!match($0, CSEP_RE)) {
			# invalid line
			continue
		}
		k = substr($0, 1, RSTART - 1)
		v = substr($0, RSTART + RLENGTH)
		sub(/^ */, "", v)

		if ("-" == op) {
			option_remove(k, v)
		} else if ("=" == op) {
			if (!option_has(k, v)) {
				option_remove(k)
				option_add(k, v)
			}
		} else if ("+" == op) {
			option_add(k, v)
		}
	}
	close("cat")

	# DEBUG
	if (DEBUG) options_dump()

	for (k in OPTIONS) {
		if (index(k, SUBSEP)) continue

		for (i = 1; i <= OPTIONS[k]; ++i) {
			if (OPTIONS[k, i, "deleted"] && OPTIONS[k, i, "added"]) {
				# not modified
				continue
			}

			if (OPTIONS[k, i, "deleted"]) {
				++diff_use[OPTIONS[k, i, "deleted"]]

				for (j = 1; j <= OPTIONS[k]; ++j) {
					if (OPTIONS[k, j, "deleted"] == OPTIONS[k, i, "deleted"] \
							&& OPTIONS[k, j, "added"]) {
						++diff_use[OPTIONS[k, j, "added"]]
					}
				}
			} else if (OPTIONS[k, i, "added"]) {
				++diff_use[OPTIONS[k, i, "added"]]
			}
		}
	}

	for (i = 1; i <= DIFF_CUR; ++i) {
		if (diff_use[i]) {
			print DIFF_LINES[i]
		}
	}
}
