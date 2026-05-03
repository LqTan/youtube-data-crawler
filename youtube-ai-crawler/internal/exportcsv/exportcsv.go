package exportcsv

import (
	"encoding/csv"
	"fmt"
	"math"
	"strconv"
	"strings"

	"youtube-ai-crawler/internal/youtube"
)

type Metadata struct {
	Category string
	Topic    string
	Skill    string
}

func WriteHeader(writer *csv.Writer) error {
	return writer.Write([]string{
		"external_video_id",
		"video_title",
		"video_description",
		"video_url",
		"thumbnail_url",
		"channel_id",
		"channel_title",
		"channel_url",
		"published_at",
		"duration_seconds",
		"duration_minutes",
		"view_count",
		"like_count",
		"comment_count",
		"category",
		"topic",
		"skill",
		"level",
		"quality_score",
		"search_query",
	})
}

func WriteVideoRow(writer *csv.Writer, video youtube.Video, meta Metadata, searchQuery string) error {
	durationSeconds, _ := youtube.ParseISO8601Duration(video.ContentDetails.Duration)
	durationMinutes := int(math.Ceil(float64(durationSeconds) / 60.0))

	viewCount := parseInt64(video.Statistics.ViewCount)
	likeCount := parseInt64(video.Statistics.LikeCount)
	commentCount := parseInt64(video.Statistics.CommentCount)

	videoURL := "https://www.youtube.com/watch?v=" + video.ID
	channelURL := "https://www.youtube.com/channel/" + video.Snippet.ChannelID
	level := classifyLevel(video.Snippet.Title, video.Snippet.Description)
	qualityScore := calculateQualityScore(viewCount, likeCount, commentCount)

	return writer.Write([]string{
		video.ID,
		normalizeText(video.Snippet.Title),
		normalizeText(video.Snippet.Description),
		videoURL,
		getBestThumbnail(video),
		video.Snippet.ChannelID,
		normalizeText(video.Snippet.ChannelTitle),
		channelURL,
		video.Snippet.PublishedAt,
		strconv.Itoa(durationSeconds),
		strconv.Itoa(durationMinutes),
		strconv.FormatInt(viewCount, 10),
		strconv.FormatInt(likeCount, 10),
		strconv.FormatInt(commentCount, 10),
		meta.Category,
		meta.Topic,
		meta.Skill,
		level,
		fmt.Sprintf("%.2f", qualityScore),
		searchQuery,
	})
}

func getBestThumbnail(video youtube.Video) string {
	priorities := []string{"maxres", "standard", "high", "medium", "default"}
	for _, key := range priorities {
		thumbnail, ok := video.Snippet.Thumbnails[key]
		if ok && thumbnail.URL != "" {
			return thumbnail.URL
		}
	}
	return ""
}

func classifyLevel(title string, description string) string {
	text := strings.ToLower(title + " " + description)

	if strings.Contains(text, "beginner") ||
		strings.Contains(text, "basics") ||
		strings.Contains(text, "introduction") ||
		strings.Contains(text, "from scratch") {
		return "Beginner"
	}

	if strings.Contains(text, "advanced") ||
		strings.Contains(text, "production") ||
		strings.Contains(text, "fine-tuning") ||
		strings.Contains(text, "optimization") {
		return "Advanced"
	}

	return "Intermediate"
}

func calculateQualityScore(viewCount int64, likeCount int64, commentCount int64) float64 {
	score := 5.0

	if viewCount >= 1_000_000 {
		score += 2
	} else if viewCount >= 100_000 {
		score += 1.5
	} else if viewCount >= 10_000 {
		score += 1
	}

	if likeCount >= 10_000 {
		score += 1
	} else if likeCount >= 1_000 {
		score += 0.5
	}

	if commentCount >= 500 {
		score += 0.5
	}

	if score > 10 {
		score = 10
	}

	return math.Round(score*100) / 100
}

func normalizeText(value string) string {
	value = strings.ReplaceAll(value, "\r", " ")
	value = strings.ReplaceAll(value, "\n", " ")
	value = strings.Join(strings.Fields(value), " ")
	return strings.TrimSpace(value)
}

func parseInt64(value string) int64 {
	value = strings.TrimSpace(value)
	if value == "" {
		return 0
	}

	n, err := strconv.ParseInt(value, 10, 64)
	if err != nil {
		return 0
	}

	return n
}
