package youtube

import "regexp"

var iso8601DurationRE = regexp.MustCompile(`P(?:(\d+)D)?T?(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?`)

func ParseISO8601Duration(duration string) (int, bool) {
	matches := iso8601DurationRE.FindStringSubmatch(duration)
	if matches == nil {
		return 0, false
	}

	days := parseInt(matches[1])
	hours := parseInt(matches[2])
	minutes := parseInt(matches[3])
	seconds := parseInt(matches[4])

	total := days*24*3600 + hours*3600 + minutes*60 + seconds
	return total, true
}

func parseInt(value string) int {
	if value == "" {
		return 0
	}

	n := 0
	for _, r := range value {
		if r < '0' || r > '9' {
			return 0
		}
		n = n*10 + int(r-'0')
	}

	return n
}
