package main

import (
	"youtube-ai-crawler/internal/env"
	"youtube-ai-crawler/internal/mergedatasets"
)

func main() {
	_ = env.LoadFile(".env")

	config := mergedatasets.Config{
		BaseCSV:         env.Get("BASE_CSV", "data/youtube_ai_videos.csv"),
		ExternalDir:     env.Get("EXTERNAL_DIR", "data/external"),
		OutputCSV:       env.Get("MERGED_OUTPUT_CSV", "data/external/merged_youtube_ai_videos.csv"),
		ManualReviewCSV: env.Get("MANUAL_REVIEW_CSV", "data/external/manual_review.csv"),
		Threshold:       env.GetFloat("DUP_THRESHOLD", 0.85),
	}

	if err := mergedatasets.Run(config); err != nil {
		panic(err)
	}
}
