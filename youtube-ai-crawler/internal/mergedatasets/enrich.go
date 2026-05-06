package mergedatasets

import (
	"context"
	"fmt"
	"strings"
	"youtube-ai-crawler/internal/youtube"
)

type YouTubeEnrichmentStats struct {
	Candidates      int
	SkippedExisting int
	Requested       int
	Found           int
}

func EnrichMissingYouTubeFields(ctx context.Context, yt *youtube.Client, records []VideoRecord, maxIDs int, existingVideoIndex map[string]int) ([]VideoRecord, YouTubeEnrichmentStats, error) {
	stats := YouTubeEnrichmentStats{}
	if yt == nil || len(records) == 0 {
		return records, stats, nil
	}

	uniqueIDs := make([]string, 0)
	seen := make(map[string]bool)

	for _, record := range records {
		record = normalizeRecord(record)
		if record.ExternalVideoID == "" || isImportable(record) {
			continue
		}

		stats.Candidates++
		if existingVideoIndex != nil {
			if _, exists := existingVideoIndex[record.ExternalVideoID]; exists {
				stats.SkippedExisting++
				continue
			}
		}
		if !seen[record.ExternalVideoID] {
			seen[record.ExternalVideoID] = true
			uniqueIDs = append(uniqueIDs, record.ExternalVideoID)
		}
	}

	if len(uniqueIDs) == 0 {
		return records, stats, nil
	}

	if maxIDs > 0 && len(uniqueIDs) > maxIDs {
		uniqueIDs = uniqueIDs[:maxIDs]
	}

	stats.Requested = len(uniqueIDs)

	videoByID := make(map[string]youtube.Video, len(uniqueIDs))

	for i := 0; i < len(uniqueIDs); i += 50 {
		end := i + 50
		if end > len(uniqueIDs) {
			end = len(uniqueIDs)
		}

		batch := uniqueIDs[i:end]
		videos, err := yt.GetVideoDetails(ctx, batch)
		if err != nil {
			return records, stats, err
		}

		for _, video := range videos {
			if video.ID == "" {
				continue
			}
			if _, exists := videoByID[video.ID]; !exists {
				videoByID[video.ID] = video
			}
		}
	}

	stats.Found = len(videoByID)

	out := make([]VideoRecord, len(records))
	for i, record := range records {
		record = normalizeRecord(record)

		if record.ExternalVideoID == "" || isImportable(record) {
			out[i] = record
			continue
		}

		video, ok := videoByID[record.ExternalVideoID]
		if !ok {
			out[i] = record
			continue
		}

		enriched := record

		fillIfEmpty(&enriched.VideoTitle, video.Snippet.Title)
		fillIfEmpty(&enriched.VideoDescription, video.Snippet.Description)
		fillIfEmpty(&enriched.ChannelID, video.Snippet.ChannelID)
		fillIfEmpty(&enriched.ChannelTitle, video.Snippet.ChannelTitle)
		fillIfEmpty(&enriched.PublishedAt, video.Snippet.PublishedAt)

		if strings.TrimSpace(enriched.VideoURL) == "" && enriched.ExternalVideoID != "" {
			enriched.VideoURL = "https://www.youtube.com/watch?v=" + enriched.ExternalVideoID
		}
		if strings.TrimSpace(enriched.ChannelURL) == "" && strings.TrimSpace(enriched.ChannelID) != "" {
			enriched.ChannelURL = "https://www.youtube.com/channel/" + enriched.ChannelID
		}

		fillIfEmpty(&enriched.ThumbnailURL, pickBestThumbnailURL(video))

		out[i] = normalizeRecord(enriched)
	}

	return out, stats, nil
}

func pickBestThumbnailURL(video youtube.Video) string {
	if len(video.Snippet.Thumbnails) == 0 {
		return ""
	}

	preferred := []string{"maxres", "standard", "high", "medium", "default"}
	for _, key := range preferred {
		if thumb, ok := video.Snippet.Thumbnails[key]; ok {
			if strings.TrimSpace(thumb.URL) != "" {
				return thumb.URL
			}
		}
	}

	for _, thumb := range video.Snippet.Thumbnails {
		if strings.TrimSpace(thumb.URL) != "" {
			return thumb.URL
		}
	}

	return ""
}

func FormatYouTubeEnrichmentStats(stats YouTubeEnrichmentStats) string {
	return fmt.Sprintf(
		"candidates=%d, skipped_existing=%d, requested=%d, found=%d",
		stats.Candidates,
		stats.SkippedExisting,
		stats.Requested,
		stats.Found,
	)
}
