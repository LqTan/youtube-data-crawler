package mergedatasets

import "regexp"

type Config struct {
	BaseCSV         string
	ExternalDir     string
	OutputCSV       string
	ManualReviewCSV string
	Threshold       float64
	EnableYouTubeEnrichment bool
	YouTubeAPIKey           string
	YouTubeEnrichMaxIDs     int
}

type VideoRecord struct {
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
	SourceDataset    string
	MergeStatus      string
	MatchedVideoID   string
	MatchScore       string
	TranscriptText   string
}

var canonicalHeaders = []string{
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
	"source_dataset",
	"merge_status",
	"matched_video_id",
	"match_score",
	"transcript_text",
}

var nonAlphaNumRe = regexp.MustCompile(`[^a-z0-9]+`)
var isoDurationRe = regexp.MustCompile(`P(?:(\d+)D)?T?(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?`)
var youtubeIDRe = regexp.MustCompile(`^[a-zA-Z0-9_-]{11}$`)
var youtubeURLIDRe = regexp.MustCompile(`(?:v=|youtu\.be/|embed/|shorts/)([a-zA-Z0-9_-]{11})`)
