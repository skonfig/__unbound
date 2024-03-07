#!/usr/bin/awk -f
#
# 2023,2024 Dennis Camera (dennis.camera at riiengineering.ch)
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
#
# WARNING: This code assumes a "sane" unbound config file, i.e. it adheres to
#          the common layout of options (only one option per line)
#          This code also does not work with "named" sections.

# This script reads a "diff" specification on stdin.
# It is of the form:
#
#  + TOP_LEVEL:option: value  (ensure the given value is one of the options)
#  = TOP_LEVEL:option: value  (ensure only one of "option" is present with "value")
#  - TOP_LEVEL:option: value? (remove either option with given value or if value is empty all options)
#

function usage() {
	print "Usage: awk -f update_unbound_conf.awk /etc/unbound/unbound.conf <diff"
}

function comment_pos(line) {
	# returns the position in line at which the comment's text starts
	# (0 if the line is not a comment)
	return match(line, /[ \t]*\#+[ \t]*/) ? (RSTART + RLENGTH) : 0
}

# NOTE: s starts with option name and colon, returns position of colon
function option_len(s) { return match(s, /^[a-z0-9-]+:/) ? (RLENGTH - 1) : 0 }

function comment_only_line(line) {
	# HACK: Accessing RSTART of other function
	return comment_pos(line) ? RSTART == 1 : 0
}
function empty_line(line) { return line ~ /^[ \t]*$/ }
function option_hint_line(line,    x) {
	x = comment_pos(line)
	return x && option_len(substr(line, x))
}
function get_option(line) {
	sub(/^[ \t]*/, "", line)
	return substr(line, 1, option_len(line))
}

function top_level_keyword(line) {
	# NOTE: Hard-coded list of valid top-level keywords as per unbound.conf(5)
	if (match(line, /^[ \t]*(auth-zone|cachedb|dnscrypt|dnstap|dynlib|forward-zone|ipset|python|remote-control|rpz|server|stub-zone|view):/)) {
		return substr(line, RSTART, RLENGTH - 1)
	} else {
		return ""
	}
}

function in_list(list, val,    i, parts) {
	split(list, parts, SUBSEP)
	for (i = 1; (i in parts); ++i) {
		if (val == parts[i]) {
			return 1
		}
	}
	return 0
}

function list_join(arr, sep,    s) {
	s = arr[1]
	for (i = 2; (i in arr); ++i) {
		s = s sep arr[i]
	}
	return s
}

function list_with(list, val) {
	return (list ? (list SUBSEP val) : val)
}

function list_without(list, val,    i, parts) {
	split(list, parts, SUBSEP)
	for (i = 1; (i in parts); ++i) {
		if (parts[i] == val) {
			delete parts[i]
		}
	}
	return list_join(parts, SUBSEP)
}

function proc_diff_line(line, conf_set, conf_unset,    op, kwd, opt) {
	# Extract operation
	op = substr(line, 1, 1)
	sub(/^[+=-][ \t]+/, "", line)

	# Extract top-level keyword
	if (!top_level_keyword(line)) return 1
	kwd = substr(line, RSTART, RLENGTH - 1)
	line = substr(line, RSTART + RLENGTH)

	# We only support "singleton" sections
	if (kwd ~ /^(key|pattern|zone)$/) {
		return 1
	}

	# Extract option
	if (!option_len(line)) return 2
	opt = get_option(line)
	line = substr(line, length(opt) + 2)

	# Strip whitespace before value
	sub(/^[ \t]*/, "", line)

	# Process
	if ("=" == op) {
		if (conf_unset[kwd, opt]) {
			# remove some and all? wat?!
			return 3
		}

		conf_unset[kwd, opt] = ""
		conf_set[kwd, opt] = line
	} else if ("+" == op) {
		conf_set[kwd, opt] = list_with(conf_set[kwd, opt], line)
	} else if ("-" == op) {
		if (((kwd, opt) in conf_unset) && !conf_unset[kwd, opt]) {
			# remove all and some? wat?!
			return 3
		}

		conf_unset[kwd, opt] = list_with(conf_unset[kwd, opt], line)
	} else {
		return 4
	}
}

function print_rest_for(top_level,    i, k, p, values) {
	for (k in conf_set) {
		split(k, p, SUBSEP)
		if (p[1] == top_level) {
			split(conf_set[k], values, SUBSEP)
			for (i = 1; i in values; ++i) {
				printf "\t%s: %s\n", p[2], values[i]
			}

			delete conf_set[k]
		}
	}
}

BEGIN {
	FS = "\n"  # disable field splitting

	if (ARGC != 2) {
		# incorrect number of arguments
		usage()
		exit (e=1)
	}

	# Loop over file twice!
	ARGV[2] = ARGV[1]
	++ARGC

	# Read the "diff" into the `conf_{set,unset}` arrays
	split("", conf_set)
	split("", conf_unset)
	while (0 < ("cat" | getline)) {
		if (empty_line($0) || comment_only_line($0)) {
			# ignore empty and comment lines
			continue
		}
		if (proc_diff_line($0, conf_set, conf_unset)) {
			exit (e=1)
		}
	}
	close("cat")
}


NR == FNR {
	# First pass (collect "positions")

	if (/^[ \t]*#*[ \t]*include[-a-z]*:/) {
		# ignore
	} else if (option_hint_line($0)) {
		hinted_option = get_option(substr($0, comment_pos($0)))

		if (top_level_keyword(hinted_option ":")) {
			TOP_LEVEL = "#" hinted_option
		} else {
			last_occ["#" TOP_LEVEL, hinted_option] = FNR
		}
		last_occ[TOP_LEVEL] = FNR
	} else if (top_level_keyword($0)) {
		TOP_LEVEL = top_level_keyword($0)
		last_occ[TOP_LEVEL] = FNR
	} else {
		option = get_option($0)

		if (option) {
			last_occ[TOP_LEVEL, option] = FNR
			last_occ[TOP_LEVEL] = FNR
		}
	}

	next
}

# before second pass prepare hashes containing location information to be used
# in the second pass.
NR > FNR && FNR == 1 {
	# First we drop the locations of commented-out options if a non-commented
	# option is available.
	# Otherwise, we convert it as if it were the last occurrence of a
	# non-commented option.
	# Why? If a non-commented option is available, we will
	# append new config options there to have them all at one place.

	# "double commented options" are commented options in a commented top-level,
	# they are thus only used if nothing else is available.
	for (k in last_occ) {
		if (k ~ /^##/) {
			if (!(substr(k, 2) in last_occ)) {
				last_occ[substr(k, 2)] = last_occ[k]
			}
			delete last_occ[k]
			k = substr(k, 2)
		}
		if (k ~ /^#[^#]/) {
			if (!(substr(k, 2) in last_occ)) {
				last_occ[substr(k, 2)] = last_occ[k]
			}
			delete last_occ[k]
		}
	}

	# Reverse the option => line mapping. The line_map allows for easier lookups
	# in the second pass.
	# We only keep options, not top-level keywords, because we can only have
	# one entry per line and there are conflicts with last lines of "sections".
	for (k in last_occ) {
		if (!index(k, SUBSEP)) continue
		line_map[last_occ[k]] = k
	}
}

# Second pass
{
	if (/^[ \t]*include[-a-z]*:/ || empty_line($0) || comment_only_line($0)) {
		print
	} else if (top_level_keyword($0)) {
		TOP_LEVEL = top_level_keyword($0)
		print
	} else if (get_option($0)) {
		# This is an option line
		option = get_option($0)

		comment_start = comment_pos($0) ? RSTART : 0  # HACK
		if (comment_start) {
			comment = substr($0, comment_start)
			$0 = substr($0, 1, comment_start - 1)
		} else {
			comment = ""
		}

		value_start = index($0, option) + length(option) + 1
		value_start += match(substr($0, value_start), /[^ \t]/) - 1
		raw_value = substr($0, value_start)

		if ((TOP_LEVEL, option) in conf_unset) {
			if (conf_unset[TOP_LEVEL, option]) {
				# only unset some, so check
				if (!in_list(conf_unset[TOP_LEVEL, option], raw_value)) {
					printf "%s%s\n", $0, comment
				}
			} else {
				# only set some, so check
				if (in_list(conf_set[TOP_LEVEL, option], raw_value)) {
					printf "%s%s\n", $0, comment

					conf_set[TOP_LEVEL, option] = list_without( \
						conf_set[TOP_LEVEL, option], raw_value)
				}
			}
		} else {
			# "append-only
			printf "%s%s\n", $0, comment
		}
	}
}

line_map[FNR] {
	# we have the last occurrence of a (hinted) option here...
	split(line_map[FNR], parts, SUBSEP)
	top_level = parts[1]
	option = parts[2]

	split(conf_set[top_level, option], parts, SUBSEP)
	for (i = 1; (i in parts); ++i) {
		printf "\t%s: %s\n", option, parts[i]
	}

	delete conf_set[top_level, option]
}

last_occ[TOP_LEVEL] == FNR {
	for (k in conf_set) {
		if (index(k, TOP_LEVEL SUBSEP) == 1) {
			# Only inset newline if there is a rest
			printf "\n"
			break
		}
	}
	print_rest_for(TOP_LEVEL)
}

END {
	if (e) exit

	# Print the rest for which no "section" could be found in the input file
	for (k in conf_set) {
		split(k, parts, SUBSEP)
		if (!(parts[1] in missing_sections)) {
			missing_sections[parts[1]] = ""
		}
	}

	for (top_level in missing_sections) {
		printf "\n%s:\n", top_level
		print_rest_for(top_level)
	}
}
