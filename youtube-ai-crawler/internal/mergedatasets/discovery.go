package mergedatasets

import (
	"fmt"
	"io/fs"
	"path/filepath"
	"sort"
	"strings"
)

type DiscoverOptions struct {
	RootDir         string
	IgnoreBaseNames map[string]bool
	AllowedExts     map[string]bool
}

func DefaultDiscoverOptions(rootDir string) DiscoverOptions {
	return DiscoverOptions{
		RootDir: rootDir,
		IgnoreBaseNames: map[string]bool{
			"merged_youtube_ai_videos.csv": true,
			"manual_review.csv":            true,
		},
		AllowedExts: map[string]bool{
			".csv": true,
		},
	}
}

func DiscoverExternalFiles(opts DiscoverOptions) ([]string, error) {
	if opts.RootDir == "" {
		return nil, fmt.Errorf("external root dir is empty")
	}

	files := make([]string, 0)
	seen := make(map[string]bool)

	err := filepath.WalkDir(opts.RootDir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		if d.IsDir() {
			name := strings.ToLower(d.Name())
			if name == ".git" || name == ".idea" || name == ".vscode" {
				return filepath.SkipDir
			}
			return nil
		}

		baseName := strings.ToLower(filepath.Base(path))
		if opts.IgnoreBaseNames != nil && opts.IgnoreBaseNames[baseName] {
			return nil
		}

		ext := strings.ToLower(filepath.Ext(baseName))
		if opts.AllowedExts != nil && !opts.AllowedExts[ext] {
			return nil
		}

		clean := filepath.Clean(path)
		if !seen[clean] {
			seen[clean] = true
			files = append(files, clean)
		}

		return nil
	})
	if err != nil {
		return nil, err
	}

	sort.Strings(files)
	return files, nil
}
