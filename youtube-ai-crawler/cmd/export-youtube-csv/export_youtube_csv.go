package main

import (
	"context"
	"encoding/csv"
	"fmt"
	"os"
	"path/filepath"
	"youtube-ai-crawler/internal/env"
	"youtube-ai-crawler/internal/exportcsv"
	"youtube-ai-crawler/internal/topics"
	"youtube-ai-crawler/internal/youtube"
)

func main() {
	err := env.LoadFile(".env")
	if err != nil {
		panic(err)
	}

	apiKey := os.Getenv("YOUTUBE_API_KEY")
	if apiKey == "" {
		panic("missing YOUTUBE_API_KEY in .env")
	}

	targetVideoCount := env.GetInt("TARGET_VIDEO_COUNT", 300)
	searchPagesPerQuery := env.GetInt("SEARCH_PAGES_PER_QUERY", 1)
	outputCSV := env.Get("OUTPUT_CSV", "data/youtube_ai_videos.csv")

	err = os.MkdirAll(filepath.Dir(outputCSV), 0755)
	if err != nil {
		panic(err)
	}

	file, err := os.Create(outputCSV)
	if err != nil {
		panic(err)
	}
	defer file.Close()

	writer := csv.NewWriter(file)
	defer writer.Flush()

	err = exportcsv.WriteHeader(writer)
	if err != nil {
		panic(err)
	}

	ctx := context.Background()
	yt := youtube.NewClient(apiKey)
	seenVideoIDs := map[string]bool{}
	exportedCount := 0

	for _, plan := range topics.DefaultPlans {
		meta := exportcsv.Metadata{
			Category: plan.Category,
			Topic:    plan.Topic,
			Skill:    plan.Skill,
		}

		for _, query := range plan.Queries {
			if exportedCount >= targetVideoCount {
				break
			}

			fmt.Println("Searching:", query)

			videoIDs, err := yt.SearchVideoIDs(ctx, query, searchPagesPerQuery)
			if err != nil {
				fmt.Println("Search failed:", err)
				continue
			}

			newVideoIDs := make([]string, 0)

			for _, videoID := range videoIDs {
				if seenVideoIDs[videoID] {
					continue
				}

				seenVideoIDs[videoID] = true
				newVideoIDs = append(newVideoIDs, videoID)
			}

			videos, err := yt.GetVideoDetails(ctx, newVideoIDs)
			if err != nil {
				fmt.Println("Get video details failed:", err)
				continue
			}

			for _, video := range videos {
				if exportedCount >= targetVideoCount {
					break
				}

				durationSeconds, ok := youtube.ParseISO8601Duration(video.ContentDetails.Duration)
				if !ok {
					continue
				}

				if durationSeconds < 5*60 || durationSeconds > 180*60 {
					continue
				}

				err := exportcsv.WriteVideoRow(writer, video, meta, query)
				if err != nil {
					fmt.Println("Write CSV row failed:", err)
					continue
				}

				exportedCount++
				fmt.Printf("[%d] Exported: %s\n", exportedCount, video.Snippet.Title)
			}

			writer.Flush()

			if err := writer.Error(); err != nil {
				panic(err)
			}
		}
	}

	fmt.Println("Done. Exported CSV:", outputCSV)
	fmt.Println("Total videos:", exportedCount)
}
