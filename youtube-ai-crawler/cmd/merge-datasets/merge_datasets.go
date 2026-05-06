package main

import (
	"flag"
	"youtube-ai-crawler/internal/env"
	"youtube-ai-crawler/internal/mergedatasets"
)

func main() {
	_ = env.LoadFile(".env")

	baseCSV := flag.String("base-csv", env.Get("BASE_CSV", "data/youtube_ai_videos.csv"), "Path to base CSV file")
	externalDir := flag.String("external-dir", env.Get("EXTERNAL_DIR", "data/external"), "Directory containing external CSV datasets (recursive)")
	outputCSV := flag.String("output-csv", env.Get("MERGED_OUTPUT_CSV", "data/external/merged_youtube_ai_videos.csv"), "Path to write merged CSV output")
	manualReviewCSV := flag.String("manual-review-csv", env.Get("MANUAL_REVIEW_CSV", "data/external/manual_review.csv"), "Path to write manual review CSV output")
	dupThreshold := flag.Float64("dup-threshold", env.GetFloat("DUP_THRESHOLD", 0.85), "Fuzzy duplicate match threshold (0..1)")

	enableYouTubeEnrichment := flag.Bool("enable-youtube-enrichment", false, "Enrich missing YouTube fields via YouTube Data API videos.list")
	youtubeAPIKey := flag.String("youtube-api-key", env.Get("YOUTUBE_API_KEY", ""), "YouTube Data API key (falls back to YOUTUBE_API_KEY env)")
	youtubeEnrichMaxIDs := flag.Int("youtube-enrich-max-ids", env.GetInt("YOUTUBE_ENRICH_MAX_IDS", 2000), "Max unique YouTube video IDs to enrich per run (0 = unlimited)")

	flag.Parse()

	config := mergedatasets.Config{
		BaseCSV:                *baseCSV,
		ExternalDir:            *externalDir,
		OutputCSV:              *outputCSV,
		ManualReviewCSV:        *manualReviewCSV,
		Threshold:              *dupThreshold,
		EnableYouTubeEnrichment: *enableYouTubeEnrichment,
		YouTubeAPIKey:           *youtubeAPIKey,
		YouTubeEnrichMaxIDs:     *youtubeEnrichMaxIDs,
	}

	if err := mergedatasets.Run(config); err != nil {
		panic(err)
	}
}
