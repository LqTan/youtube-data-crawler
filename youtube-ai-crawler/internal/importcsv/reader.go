package importcsv

import (
	"encoding/csv"
	"fmt"
	"io"
	"os"
	"strings"
)

type Video struct {
	ExternalVideoID  string
	VideoTitle       string
	VideoDescription string
	VideoURL         string
	ThumbnailURL     string
	ChannelID        string
	ChannelTitle     string
	ChannelURL       string
	PublishedAt      string
	DurationSeconds  string
	DurationMinutes  string
	ViewCount        string
	LikeCount        string
	CommentCount     string
	Category         string
	Topic            string
	Skill            string
	Level            string
	QualityScore     string
	SearchQuery      string
}

func ReadFile(path string) ([]Video, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	reader := csv.NewReader(file)

	header, err := reader.Read()
	if err != nil {
		return nil, err
	}

	index := map[string]int{}
	for i, name := range header {
		index[name] = i
	}

	requiredColumns := []string{
		"external_video_id",
		"video_title",
		"video_url",
		"channel_id",
		"channel_title",
		"category",
		"topic",
		"skill",
		"level",
	}

	for _, column := range requiredColumns {
		if _, ok := index[column]; !ok {
			return nil, fmt.Errorf("missing required csv column: %s", column)
		}
	}

	result := make([]Video, 0)

	for {
		record, err := reader.Read()
		if err != nil {
			if err == io.EOF {
				break
			}
			return nil, err
		}

		row := Video{
			ExternalVideoID:  getValue(record, index, "external_video_id"),
			VideoTitle:       getValue(record, index, "video_title"),
			VideoDescription: getValue(record, index, "video_description"),
			VideoURL:         getValue(record, index, "video_url"),
			ThumbnailURL:     getValue(record, index, "thumbnail_url"),
			ChannelID:        getValue(record, index, "channel_id"),
			ChannelTitle:     getValue(record, index, "channel_title"),
			ChannelURL:       getValue(record, index, "channel_url"),
			PublishedAt:      getValue(record, index, "published_at"),
			DurationSeconds:  getValue(record, index, "duration_seconds"),
			DurationMinutes:  getValue(record, index, "duration_minutes"),
			ViewCount:        getValue(record, index, "view_count"),
			LikeCount:        getValue(record, index, "like_count"),
			CommentCount:     getValue(record, index, "comment_count"),
			Category:         getValue(record, index, "category"),
			Topic:            getValue(record, index, "topic"),
			Skill:            getValue(record, index, "skill"),
			Level:            getValue(record, index, "level"),
			QualityScore:     getValue(record, index, "quality_score"),
			SearchQuery:      getValue(record, index, "search_query"),
		}

		if row.ExternalVideoID == "" || row.VideoTitle == "" {
			continue
		}

		result = append(result, row)
	}

	return result, nil
}

func getValue(record []string, index map[string]int, column string) string {
	i, ok := index[column]
	if !ok || i >= len(record) {
		return ""
	}

	return strings.TrimSpace(record[i])
}
