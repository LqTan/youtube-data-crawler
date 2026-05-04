package mergedatasets

import (
	"encoding/csv"
	"fmt"
	"math"
	"net/url"
	"os"
	"path/filepath"
	"strconv"
	"strings"
)

func Run(config Config) error {
	baseRecords, err := readCSV(config.BaseCSV, "youtube_api")
	if err != nil {
		return err
	}

	externalFiles, err := DiscoverExternalFiles(DefaultDiscoverOptions(config.ExternalDir))
	if err != nil {
		return err
	}

	if len(externalFiles) == 0 {
		fmt.Println("No external CSV files found in:", config.ExternalDir)
		return nil
	}

	videoIndex := make(map[string]int)
	for i, record := range baseRecords {
		record = normalizeRecord(record)
		baseRecords[i] = record
		if record.ExternalVideoID != "" {
			videoIndex[record.ExternalVideoID] = i
		}
	}

	totalExternalRecords := 0
	totalExactMerged := 0
	totalFuzzyMerged := 0
	totalNewAdded := 0
	totalManualReview := 0
	manualReview := make([]VideoRecord, 0)

	for _, externalFile := range externalFiles {
		sourceDataset := inferSourceDataset(config.ExternalDir, externalFile)

		fmt.Println("Merging file:", externalFile)
		fmt.Println("Source dataset:", sourceDataset)

		externalRecords, err := readCSV(externalFile, sourceDataset)
		if err != nil {
			fmt.Println("Read external CSV failed:", externalFile, err)
			continue
		}

		exactMerged := 0
		fuzzyMerged := 0
		newAdded := 0
		manualReviewCount := 0

		for _, external := range externalRecords {
			external = normalizeRecord(external)
			if external.SourceDataset == "" {
				external.SourceDataset = sourceDataset
			}

			if external.ExternalVideoID != "" {
				if index, exists := videoIndex[external.ExternalVideoID]; exists {
					mergeMissingFields(&baseRecords[index], external, "exact_match", 1.0)
					exactMerged++
					continue
				}

				if !isImportable(external) {
					external.MergeStatus = "need_youtube_api_enrichment"
					external.MatchScore = ""
					manualReview = append(manualReview, external)
					manualReviewCount++
					continue
				}

				external.MergeStatus = "new_external_record"
				external.MatchedVideoID = external.ExternalVideoID
				baseRecords = append(baseRecords, external)
				videoIndex[external.ExternalVideoID] = len(baseRecords) - 1
				newAdded++
				continue
			}

			bestIndex, bestScore := findBestFuzzyMatch(external, baseRecords)
			if bestIndex >= 0 && bestScore >= config.Threshold {
				mergeMissingFields(&baseRecords[bestIndex], external, "fuzzy_match", bestScore)
				fuzzyMerged++
				continue
			}

			external.MergeStatus = "manual_review"
			external.MatchScore = fmt.Sprintf("%.4f", bestScore)
			if bestIndex >= 0 {
				external.MatchedVideoID = baseRecords[bestIndex].ExternalVideoID
			}

			manualReview = append(manualReview, external)
			manualReviewCount++
		}

		totalExternalRecords += len(externalRecords)
		totalExactMerged += exactMerged
		totalFuzzyMerged += fuzzyMerged
		totalNewAdded += newAdded
		totalManualReview += manualReviewCount

		fmt.Println("File done:", externalFile)
		fmt.Println("  External records:", len(externalRecords))
		fmt.Println("  Exact merged:", exactMerged)
		fmt.Println("  Fuzzy merged:", fuzzyMerged)
		fmt.Println("  New added:", newAdded)
		fmt.Println("  Manual review:", manualReviewCount)
		fmt.Println()
	}

	if err := writeCSV(config.OutputCSV, baseRecords); err != nil {
		return err
	}

	if err := writeCSV(config.ManualReviewCSV, manualReview); err != nil {
		return err
	}

	fmt.Println("Done.")
	fmt.Println("Base + merged records:", len(baseRecords))
	fmt.Println("External files:", len(externalFiles))
	fmt.Println("External records:", totalExternalRecords)
	fmt.Println("Exact merged:", totalExactMerged)
	fmt.Println("Fuzzy merged:", totalFuzzyMerged)
	fmt.Println("New added:", totalNewAdded)
	fmt.Println("Manual review:", totalManualReview)
	fmt.Println("Merged output:", config.OutputCSV)
	fmt.Println("Manual review file:", config.ManualReviewCSV)

	return nil
}

func inferSourceDataset(baseDir string, csvPath string) string {
	relativePath, err := filepath.Rel(baseDir, csvPath)
	if err != nil {
		fileName := filepath.Base(csvPath)
		fileName = strings.TrimSuffix(fileName, filepath.Ext(fileName))
		return normalizeDatasetName(fileName)
	}

	relativePath = filepath.ToSlash(relativePath)
	withoutExt := strings.TrimSuffix(relativePath, filepath.Ext(relativePath))
	parts := strings.Split(withoutExt, "/")

	normalized := make([]string, 0, len(parts))
	for _, part := range parts {
		part = normalizeDatasetName(part)
		if part != "" {
			normalized = append(normalized, part)
		}
	}

	if len(normalized) == 0 {
		return "external"
	}

	return strings.Join(normalized, "_")
}

func normalizeDatasetName(value string) string {
	value = strings.TrimSpace(value)
	value = strings.ToLower(value)
	value = strings.ReplaceAll(value, "-", "_")
	value = strings.ReplaceAll(value, " ", "_")
	return value
}

func readCSV(path string, sourceDefault string) ([]VideoRecord, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	reader := csv.NewReader(file)
	reader.FieldsPerRecord = -1
	reader.LazyQuotes = true
	reader.TrimLeadingSpace = true

	header, err := reader.Read()
	if err != nil {
		return nil, err
	}

	index := make(map[string]int)
	for i, name := range header {
		index[normalizeHeader(name)] = i
	}

	records, err := reader.ReadAll()
	if err != nil {
		return nil, err
	}

	result := make([]VideoRecord, 0)
	for _, row := range records {
		record := VideoRecord{
			ExternalVideoID: getByAliases(row, index,
				"external_video_id", "video_id", "youtube_video_id", "yt_video_id", "id", "Video ID",
			),
			VideoTitle: getByAliases(row, index,
				"video_title", "title", "name", "Title",
			),
			VideoDescription: getByAliases(row, index,
				"video_description", "description", "desc", "Description",
			),
			VideoURL: getByAliases(row, index,
				"video_url", "url", "youtube_url", "link", "webpage_url", "Video URL",
			),
			ThumbnailURL: getByAliases(row, index,
				"thumbnail_url", "thumbnail", "thumbnail_link",
			),
			ChannelID: getByAliases(row, index,
				"channel_id", "youtube_channel_id", "uploader_id", "Channel ID",
			),
			ChannelTitle: getByAliases(row, index,
				"channel_title", "channel_name", "uploader", "author", "Channel", "Channel Title",
			),
			ChannelURL: getByAliases(row, index,
				"channel_url", "youtube_channel_url",
			),
			PublishedAt: getByAliases(row, index,
				"published_at", "upload_date", "published_date", "date", "Time Published",
			),
			DurationSeconds: getByAliases(row, index,
				"duration_seconds", "duration", "length_seconds", "video_duration", "Duration",
			),
			DurationMinutes: getByAliases(row, index,
				"duration_minutes", "minutes",
			),
			ViewCount: getByAliases(row, index,
				"view_count", "views", "viewcount", "View Count",
			),
			LikeCount: getByAliases(row, index,
				"like_count", "likes", "likecount", "Like Count",
			),
			CommentCount: getByAliases(row, index,
				"comment_count", "comments", "commentcount", "Comment Count",
			),
			Category: getByAliases(row, index,
				"category", "category_name", "Category",
			),
			Topic: getByAliases(row, index,
				"topic", "topic_name", "subject",
			),
			Skill: getByAliases(row, index,
				"skill", "skill_name", "keyword", "keywords", "Keywords",
			),
			Level: getByAliases(row, index,
				"level", "difficulty",
			),
			QualityScore: getByAliases(row, index,
				"quality_score", "score",
			),
			SearchQuery: getByAliases(row, index,
				"search_query", "query",
			),
			SourceDataset: getByAliases(row, index,
				"source_dataset", "dataset", "source",
			),
			MergeStatus: getByAliases(row, index,
				"merge_status",
			),
			MatchedVideoID: getByAliases(row, index,
				"matched_video_id",
			),
			MatchScore: getByAliases(row, index,
				"match_score",
			),
			TranscriptText: getByAliases(row, index,
				"transcript_text", "transcript", "text", "Text",
			),
		}

		if record.SourceDataset == "" {
			record.SourceDataset = sourceDefault
		}

		record = normalizeRecord(record)
		if isEmptyRecord(record) {
			continue
		}

		result = append(result, record)
	}

	return result, nil
}

func writeCSV(path string, records []VideoRecord) error {
	if err := os.MkdirAll(filepath.Dir(path), 0755); err != nil {
		return err
	}

	file, err := os.Create(path)
	if err != nil {
		return err
	}
	defer file.Close()

	writer := csv.NewWriter(file)
	defer writer.Flush()

	if err := writer.Write(canonicalHeaders); err != nil {
		return err
	}

	for _, record := range records {
		if err := writer.Write(recordToRow(record)); err != nil {
			return err
		}
	}

	return writer.Error()
}

func recordToRow(record VideoRecord) []string {
	return []string{
		record.ExternalVideoID,
		record.VideoTitle,
		record.VideoDescription,
		record.VideoURL,
		record.ThumbnailURL,
		record.ChannelID,
		record.ChannelTitle,
		record.ChannelURL,
		record.PublishedAt,
		record.DurationSeconds,
		record.DurationMinutes,
		record.ViewCount,
		record.LikeCount,
		record.CommentCount,
		record.Category,
		record.Topic,
		record.Skill,
		record.Level,
		record.QualityScore,
		record.SearchQuery,
		record.SourceDataset,
		record.MergeStatus,
		record.MatchedVideoID,
		record.MatchScore,
		record.TranscriptText,
	}
}

func normalizeRecord(record VideoRecord) VideoRecord {
	record.ExternalVideoID = strings.TrimSpace(record.ExternalVideoID)
	record.VideoURL = strings.TrimSpace(record.VideoURL)

	if strings.Contains(record.ExternalVideoID, "youtube.com") || strings.Contains(record.ExternalVideoID, "youtu.be") {
		if record.VideoURL == "" {
			record.VideoURL = record.ExternalVideoID
		}
		record.ExternalVideoID = extractYouTubeVideoID(record.ExternalVideoID)
	}

	if record.ExternalVideoID == "" && record.VideoURL != "" {
		record.ExternalVideoID = extractYouTubeVideoID(record.VideoURL)
	}

	if record.VideoURL == "" && record.ExternalVideoID != "" {
		record.VideoURL = "https://www.youtube.com/watch?v=" + record.ExternalVideoID
	}

	if record.ChannelURL == "" && record.ChannelID != "" {
		record.ChannelURL = "https://www.youtube.com/channel/" + record.ChannelID
	}

	record.VideoTitle = normalizeText(record.VideoTitle)
	record.VideoDescription = normalizeText(record.VideoDescription)
	record.ChannelTitle = normalizeText(record.ChannelTitle)
	record.Category = normalizeText(record.Category)
	record.Topic = normalizeText(record.Topic)
	record.Skill = normalizeText(record.Skill)
	record.Level = normalizeText(record.Level)
	record.SearchQuery = normalizeText(record.SearchQuery)
	record.TranscriptText = normalizeText(record.TranscriptText)

	durationSeconds := normalizeDurationSeconds(record.DurationSeconds, record.DurationMinutes)
	if durationSeconds > 0 {
		record.DurationSeconds = strconv.Itoa(durationSeconds)
		record.DurationMinutes = strconv.Itoa(int(math.Ceil(float64(durationSeconds) / 60.0)))
	}

	if record.Level == "" {
		record.Level = classifyLevel(record.VideoTitle, record.VideoDescription)
	}

	return record
}

func mergeMissingFields(target *VideoRecord, source VideoRecord, status string, score float64) {
	fillIfEmpty(&target.VideoTitle, source.VideoTitle)
	fillIfEmpty(&target.VideoDescription, source.VideoDescription)
	fillIfEmpty(&target.VideoURL, source.VideoURL)
	fillIfEmpty(&target.ThumbnailURL, source.ThumbnailURL)
	fillIfEmpty(&target.ChannelID, source.ChannelID)
	fillIfEmpty(&target.ChannelTitle, source.ChannelTitle)
	fillIfEmpty(&target.ChannelURL, source.ChannelURL)
	fillIfEmpty(&target.PublishedAt, source.PublishedAt)
	fillIfEmpty(&target.DurationSeconds, source.DurationSeconds)
	fillIfEmpty(&target.DurationMinutes, source.DurationMinutes)
	fillIfEmpty(&target.ViewCount, source.ViewCount)
	fillIfEmpty(&target.LikeCount, source.LikeCount)
	fillIfEmpty(&target.CommentCount, source.CommentCount)
	fillIfEmpty(&target.Category, source.Category)
	fillIfEmpty(&target.Topic, source.Topic)
	fillIfEmpty(&target.Skill, source.Skill)
	fillIfEmpty(&target.Level, source.Level)
	fillIfEmpty(&target.QualityScore, source.QualityScore)
	fillIfEmpty(&target.SearchQuery, source.SearchQuery)
	fillIfEmpty(&target.TranscriptText, source.TranscriptText)

	target.SourceDataset = joinUnique(target.SourceDataset, source.SourceDataset)
	target.MergeStatus = status

	if source.ExternalVideoID != "" {
		target.MatchedVideoID = source.ExternalVideoID
	} else if target.ExternalVideoID != "" {
		target.MatchedVideoID = target.ExternalVideoID
	}

	target.MatchScore = fmt.Sprintf("%.4f", score)
}

func fillIfEmpty(target *string, source string) {
	if strings.TrimSpace(*target) == "" && strings.TrimSpace(source) != "" {
		*target = source
	}
}

func findBestFuzzyMatch(external VideoRecord, baseRecords []VideoRecord) (int, float64) {
	bestIndex := -1
	bestScore := 0.0

	for i, base := range baseRecords {
		score := calculateMatchScore(external, base)
		if score > bestScore {
			bestScore = score
			bestIndex = i
		}
	}

	return bestIndex, bestScore
}

func calculateMatchScore(a VideoRecord, b VideoRecord) float64 {
	titleSimilarity := textSimilarity(a.VideoTitle, b.VideoTitle)
	channelSimilarity := textSimilarity(a.ChannelTitle, b.ChannelTitle)
	durationSimilarityValue := durationSimilarity(a.DurationSeconds, b.DurationSeconds)

	return 0.5*titleSimilarity + 0.3*channelSimilarity + 0.2*durationSimilarityValue
}

func textSimilarity(a string, b string) float64 {
	a = normalizeForCompare(a)
	b = normalizeForCompare(b)

	if a == "" || b == "" {
		return 0
	}

	levenshteinScore := levenshteinSimilarity(a, b)
	jaccardScore := tokenJaccardSimilarity(a, b)

	return (levenshteinScore + jaccardScore) / 2.0
}

func durationSimilarity(a string, b string) float64 {
	d1 := parseInt(a)
	d2 := parseInt(b)

	if d1 <= 0 || d2 <= 0 {
		return 0
	}

	diff := math.Abs(float64(d1 - d2))
	maxDuration := math.Max(float64(d1), float64(d2))

	if maxDuration == 0 {
		return 0
	}

	score := 1.0 - math.Min(diff/maxDuration, 1.0)
	if score < 0 {
		return 0
	}

	return score
}

func levenshteinSimilarity(a string, b string) float64 {
	distance := levenshteinDistance(a, b)
	maxLen := math.Max(float64(len(a)), float64(len(b)))
	if maxLen == 0 {
		return 1
	}
	return 1.0 - float64(distance)/maxLen
}

func levenshteinDistance(a string, b string) int {
	ar := []rune(a)
	br := []rune(b)

	rows := len(ar) + 1
	cols := len(br) + 1

	dp := make([][]int, rows)
	for i := range dp {
		dp[i] = make([]int, cols)
	}

	for i := 0; i < rows; i++ {
		dp[i][0] = i
	}

	for j := 0; j < cols; j++ {
		dp[0][j] = j
	}

	for i := 1; i < rows; i++ {
		for j := 1; j < cols; j++ {
			cost := 0
			if ar[i-1] != br[j-1] {
				cost = 1
			}

			dp[i][j] = minInt(
				dp[i-1][j]+1,
				minInt(
					dp[i][j-1]+1,
					dp[i-1][j-1]+cost,
				),
			)
		}
	}

	return dp[len(ar)][len(br)]
}

func tokenJaccardSimilarity(a string, b string) float64 {
	aTokens := strings.Fields(a)
	bTokens := strings.Fields(b)
	if len(aTokens) == 0 || len(bTokens) == 0 {
		return 0
	}

	aSet := make(map[string]bool)
	bSet := make(map[string]bool)

	for _, token := range aTokens {
		aSet[token] = true
	}
	for _, token := range bTokens {
		bSet[token] = true
	}

	intersection := 0
	union := make(map[string]bool)

	for token := range aSet {
		union[token] = true
		if bSet[token] {
			intersection++
		}
	}
	for token := range bSet {
		union[token] = true
	}

	if len(union) == 0 {
		return 0
	}

	return float64(intersection) / float64(len(union))
}

func extractYouTubeVideoID(rawURL string) string {
	rawURL = strings.TrimSpace(rawURL)
	if rawURL == "" {
		return ""
	}

	if len(rawURL) == 11 && youtubeIDRe.MatchString(rawURL) {
		return rawURL
	}

	parsed, err := url.Parse(rawURL)
	if err == nil {
		host := strings.ToLower(parsed.Host)

		if strings.Contains(host, "youtu.be") {
			parts := strings.Split(strings.Trim(parsed.Path, "/"), "/")
			if len(parts) > 0 && len(parts[0]) == 11 {
				return parts[0]
			}
		}

		if strings.Contains(host, "youtube.com") {
			videoID := parsed.Query().Get("v")
			if len(videoID) == 11 {
				return videoID
			}

			parts := strings.Split(strings.Trim(parsed.Path, "/"), "/")
			if len(parts) >= 2 && (parts[0] == "embed" || parts[0] == "shorts") && len(parts[1]) == 11 {
				return parts[1]
			}
		}
	}

	matches := youtubeURLIDRe.FindStringSubmatch(rawURL)
	if len(matches) >= 2 {
		return matches[1]
	}

	return ""
}

func normalizeDurationSeconds(secondsRaw string, minutesRaw string) int {
	seconds := parseDurationToSeconds(secondsRaw)
	if seconds > 0 {
		return seconds
	}

	minutesRaw = strings.TrimSpace(minutesRaw)
	if minutesRaw == "" {
		return 0
	}

	minutes, err := strconv.ParseFloat(minutesRaw, 64)
	if err != nil {
		return 0
	}

	return int(math.Round(minutes * 60))
}

func parseDurationToSeconds(value string) int {
	value = strings.TrimSpace(value)
	if value == "" {
		return 0
	}

	if strings.HasPrefix(value, "P") {
		return parseISO8601Duration(value)
	}

	if strings.Contains(value, ":") {
		return parseColonDuration(value)
	}

	n, err := strconv.ParseFloat(value, 64)
	if err != nil {
		return 0
	}

	return int(math.Round(n))
}

func parseISO8601Duration(duration string) int {
	matches := isoDurationRe.FindStringSubmatch(duration)
	if matches == nil {
		return 0
	}

	days := parseInt(matches[1])
	hours := parseInt(matches[2])
	minutes := parseInt(matches[3])
	seconds := parseInt(matches[4])

	return days*24*3600 + hours*3600 + minutes*60 + seconds
}

func parseColonDuration(value string) int {
	parts := strings.Split(value, ":")
	if len(parts) == 2 {
		minutes := parseInt(parts[0])
		seconds := parseInt(parts[1])
		return minutes*60 + seconds
	}

	if len(parts) == 3 {
		hours := parseInt(parts[0])
		minutes := parseInt(parts[1])
		seconds := parseInt(parts[2])
		return hours*3600 + minutes*60 + seconds
	}

	return 0
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

func isImportable(record VideoRecord) bool {
	return record.ExternalVideoID != "" &&
		record.VideoTitle != "" &&
		record.VideoURL != "" &&
		record.ChannelID != "" &&
		record.ChannelTitle != ""
}

func isEmptyRecord(record VideoRecord) bool {
	return record.ExternalVideoID == "" &&
		record.VideoTitle == "" &&
		record.VideoURL == "" &&
		record.TranscriptText == ""
}

func normalizeText(value string) string {
	value = strings.ReplaceAll(value, "\r", " ")
	value = strings.ReplaceAll(value, "\n", " ")
	value = strings.Join(strings.Fields(value), " ")
	return strings.TrimSpace(value)
}

func normalizeForCompare(value string) string {
	value = strings.ToLower(value)
	value = nonAlphaNumRe.ReplaceAllString(value, " ")
	value = strings.Join(strings.Fields(value), " ")
	return value
}

func normalizeHeader(value string) string {
	value = strings.TrimPrefix(value, "\ufeff")
	value = strings.TrimSpace(value)
	value = strings.ToLower(value)
	value = strings.ReplaceAll(value, " ", "_")
	value = strings.ReplaceAll(value, "-", "_")
	value = strings.ReplaceAll(value, ".", "_")
	return value
}

func getByAliases(row []string, index map[string]int, aliases ...string) string {
	for _, alias := range aliases {
		i, exists := index[normalizeHeader(alias)]
		if !exists || i >= len(row) {
			continue
		}

		value := strings.TrimSpace(row[i])
		if value != "" {
			return value
		}
	}

	return ""
}

func joinUnique(a string, b string) string {
	values := make(map[string]bool)
	result := make([]string, 0)

	for _, item := range strings.Split(a, "|") {
		item = strings.TrimSpace(item)
		if item != "" && !values[item] {
			values[item] = true
			result = append(result, item)
		}
	}

	for _, item := range strings.Split(b, "|") {
		item = strings.TrimSpace(item)
		if item != "" && !values[item] {
			values[item] = true
			result = append(result, item)
		}
	}

	return strings.Join(result, "|")
}

func parseInt(value string) int {
	value = strings.TrimSpace(value)
	if value == "" {
		return 0
	}

	n, err := strconv.Atoi(value)
	if err != nil {
		return 0
	}

	return n
}

func minInt(a int, b int) int {
	if a < b {
		return a
	}
	return b
}
