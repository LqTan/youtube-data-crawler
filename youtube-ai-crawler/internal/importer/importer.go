package importer

import (
	"context"
	"errors"
	"math"
	"strconv"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"youtube-ai-crawler/internal/importcsv"
)

type Importer struct{}

func New() *Importer {
	return &Importer{}
}

type VideoRow struct {
	VideoID         int64
	DurationSeconds *int
}

func (i *Importer) ImportOne(ctx context.Context, pool *pgxpool.Pool, row importcsv.Video) error {
	tx, err := pool.Begin(ctx)
	if err != nil {
		return err
	}

	defer func() {
		_ = tx.Rollback(ctx)
	}()

	platformID, err := i.upsertPlatform(ctx, tx)
	if err != nil {
		return err
	}

	resourceTypeID, err := i.upsertResourceType(ctx, tx)
	if err != nil {
		return err
	}

	languageID, err := i.upsertLanguage(ctx, tx)
	if err != nil {
		return err
	}

	levelID, err := i.upsertLevel(ctx, tx, row.Level)
	if err != nil {
		return err
	}

	categoryID, err := i.upsertCategory(ctx, tx, row.Category)
	if err != nil {
		return err
	}

	topicID, err := i.upsertTopic(ctx, tx, categoryID, row.Topic)
	if err != nil {
		return err
	}

	skillID, err := i.upsertSkill(ctx, tx, row.Skill)
	if err != nil {
		return err
	}

	channelID, err := i.upsertChannel(ctx, tx, platformID, row)
	if err != nil {
		return err
	}

	videoRow, err := i.upsertVideo(ctx, tx, channelID, row)
	if err != nil {
		return err
	}

	resourceID, err := i.upsertLearningResource(ctx, tx, resourceTypeID, languageID, levelID, videoRow, row)
	if err != nil {
		return err
	}

	if err := i.linkResourceSource(ctx, tx, resourceID, videoRow.VideoID); err != nil {
		return err
	}

	if err := i.linkResourceTopic(ctx, tx, resourceID, topicID); err != nil {
		return err
	}

	if err := i.linkResourceSkill(ctx, tx, resourceID, skillID); err != nil {
		return err
	}

	if err := i.insertVideoStatistics(ctx, tx, videoRow.VideoID, row); err != nil {
		return err
	}

	return tx.Commit(ctx)
}

func (i *Importer) upsertPlatform(ctx context.Context, tx pgx.Tx) (int64, error) {
	var id int64

	err := tx.QueryRow(ctx, `
		INSERT INTO ai_learning.platforms (platform_name, platform_url)
		VALUES ($1, $2)
		ON CONFLICT (platform_name)
		DO UPDATE SET platform_url = EXCLUDED.platform_url
		RETURNING platform_id
	`, "YouTube", "https://www.youtube.com").Scan(&id)

	return id, err
}

func (i *Importer) upsertResourceType(ctx context.Context, tx pgx.Tx) (int64, error) {
	var id int64

	err := tx.QueryRow(ctx, `
		INSERT INTO ai_learning.resource_types (resource_type_name)
		VALUES ($1)
		ON CONFLICT (resource_type_name)
		DO UPDATE SET resource_type_name = EXCLUDED.resource_type_name
		RETURNING resource_type_id
	`, "VIDEO").Scan(&id)

	return id, err
}

func (i *Importer) upsertLanguage(ctx context.Context, tx pgx.Tx) (int64, error) {
	var id int64

	err := tx.QueryRow(ctx, `
		INSERT INTO ai_learning.languages (language_code, language_name)
		VALUES ($1, $2)
		ON CONFLICT (language_code)
		DO UPDATE SET language_name = EXCLUDED.language_name
		RETURNING language_id
	`, "en", "English").Scan(&id)

	return id, err
}

func (i *Importer) upsertLevel(ctx context.Context, tx pgx.Tx, levelName string) (int64, error) {
	if levelName == "" {
		levelName = "Intermediate"
	}

	levelOrder := 2
	switch levelName {
	case "Beginner":
		levelOrder = 1
	case "Intermediate":
		levelOrder = 2
	case "Advanced":
		levelOrder = 3
	}

	var id int64

	err := tx.QueryRow(ctx, `
		INSERT INTO ai_learning.levels (level_name, level_order)
		VALUES ($1, $2)
		ON CONFLICT (level_name)
		DO UPDATE SET level_order = EXCLUDED.level_order
		RETURNING level_id
	`, levelName, levelOrder).Scan(&id)

	return id, err
}

func (i *Importer) upsertCategory(ctx context.Context, tx pgx.Tx, categoryName string) (int64, error) {
	var id int64

	err := tx.QueryRow(ctx, `
		INSERT INTO ai_learning.categories (category_name)
		VALUES ($1)
		ON CONFLICT (category_name)
		DO UPDATE SET category_name = EXCLUDED.category_name
		RETURNING category_id
	`, categoryName).Scan(&id)

	return id, err
}

func (i *Importer) upsertTopic(ctx context.Context, tx pgx.Tx, categoryID int64, topicName string) (int64, error) {
	var id int64

	err := tx.QueryRow(ctx, `
		INSERT INTO ai_learning.topics (category_id, topic_name)
		VALUES ($1, $2)
		ON CONFLICT (category_id, topic_name)
		DO UPDATE SET topic_name = EXCLUDED.topic_name
		RETURNING topic_id
	`, categoryID, topicName).Scan(&id)

	return id, err
}

func (i *Importer) upsertSkill(ctx context.Context, tx pgx.Tx, skillName string) (int64, error) {
	var id int64

	err := tx.QueryRow(ctx, `
		INSERT INTO ai_learning.skills (skill_name)
		VALUES ($1)
		ON CONFLICT (skill_name)
		DO UPDATE SET skill_name = EXCLUDED.skill_name
		RETURNING skill_id
	`, skillName).Scan(&id)

	return id, err
}

func (i *Importer) upsertChannel(ctx context.Context, tx pgx.Tx, platformID int64, row importcsv.Video) (int64, error) {
	var id int64

	err := tx.QueryRow(ctx, `
		INSERT INTO ai_learning.channels (
			platform_id,
			external_channel_id,
			channel_name,
			channel_url
		)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (platform_id, external_channel_id)
		DO UPDATE SET
			channel_name = EXCLUDED.channel_name,
			channel_url = EXCLUDED.channel_url
		RETURNING channel_id
	`,
		platformID,
		row.ChannelID,
		row.ChannelTitle,
		nullIfEmpty(row.ChannelURL),
	).Scan(&id)

	return id, err
}

func (i *Importer) upsertVideo(ctx context.Context, tx pgx.Tx, channelID int64, row importcsv.Video) (VideoRow, error) {
	var result VideoRow

	durationSeconds := parseNullableInt(row.DurationSeconds)
	publishedAt := parseNullableTime(row.PublishedAt)

	err := tx.QueryRow(ctx, `
		INSERT INTO ai_learning.videos (
			channel_id,
			external_video_id,
			video_title,
			video_description,
			video_url,
			thumbnail_url,
			duration_seconds,
			published_at
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		ON CONFLICT (channel_id, external_video_id)
		DO UPDATE SET
			video_title = EXCLUDED.video_title,
			video_description = EXCLUDED.video_description,
			video_url = EXCLUDED.video_url,
			thumbnail_url = EXCLUDED.thumbnail_url,
			duration_seconds = EXCLUDED.duration_seconds,
			published_at = EXCLUDED.published_at
		RETURNING video_id, duration_seconds
	`,
		channelID,
		row.ExternalVideoID,
		row.VideoTitle,
		nullIfEmpty(row.VideoDescription),
		row.VideoURL,
		nullIfEmpty(row.ThumbnailURL),
		durationSeconds,
		publishedAt,
	).Scan(&result.VideoID, &result.DurationSeconds)

	return result, err
}

func (i *Importer) upsertLearningResource(
	ctx context.Context,
	tx pgx.Tx,
	resourceTypeID int64,
	languageID int64,
	levelID int64,
	videoRow VideoRow,
	row importcsv.Video,
) (int64, error) {
	var existingResourceID int64

	err := tx.QueryRow(ctx, `
		SELECT resource_id
		FROM ai_learning.resource_sources
		WHERE video_id = $1
		LIMIT 1
	`, videoRow.VideoID).Scan(&existingResourceID)

	estimatedMinutes := parseEstimatedMinutes(row.DurationMinutes, videoRow.DurationSeconds)
	qualityScore := parseNullableFloat(row.QualityScore)

	if err == nil {
		_, updateErr := tx.Exec(ctx, `
			UPDATE ai_learning.learning_resources
			SET
				resource_type_id = $1,
				level_id = $2,
				language_id = $3,
				resource_title = $4,
				resource_description = $5,
				estimated_minutes = $6,
				quality_score = $7,
				status = 'APPROVED',
				updated_at = CURRENT_TIMESTAMP
			WHERE resource_id = $8
		`,
			resourceTypeID,
			levelID,
			languageID,
			row.VideoTitle,
			nullIfEmpty(row.VideoDescription),
			estimatedMinutes,
			qualityScore,
			existingResourceID,
		)

		return existingResourceID, updateErr
	}

	if !errors.Is(err, pgx.ErrNoRows) {
		return 0, err
	}

	var id int64

	err = tx.QueryRow(ctx, `
		INSERT INTO ai_learning.learning_resources (
			resource_type_id,
			level_id,
			language_id,
			resource_title,
			resource_description,
			estimated_minutes,
			quality_score,
			status
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, 'APPROVED')
		RETURNING resource_id
	`,
		resourceTypeID,
		levelID,
		languageID,
		row.VideoTitle,
		nullIfEmpty(row.VideoDescription),
		estimatedMinutes,
		qualityScore,
	).Scan(&id)

	return id, err
}

func (i *Importer) linkResourceSource(ctx context.Context, tx pgx.Tx, resourceID int64, videoID int64) error {
	_, err := tx.Exec(ctx, `
		INSERT INTO ai_learning.resource_sources (
			resource_id,
			video_id,
			source_note
		)
		VALUES ($1, $2, $3)
		ON CONFLICT (resource_id, video_id)
		DO NOTHING
	`, resourceID, videoID, "Imported from youtube_ai_videos.csv")

	return err
}

func (i *Importer) linkResourceTopic(ctx context.Context, tx pgx.Tx, resourceID int64, topicID int64) error {
	_, err := tx.Exec(ctx, `
		INSERT INTO ai_learning.resource_topics (
			resource_id,
			topic_id
		)
		VALUES ($1, $2)
		ON CONFLICT (resource_id, topic_id)
		DO NOTHING
	`, resourceID, topicID)

	return err
}

func (i *Importer) linkResourceSkill(ctx context.Context, tx pgx.Tx, resourceID int64, skillID int64) error {
	_, err := tx.Exec(ctx, `
		INSERT INTO ai_learning.resource_skills (
			resource_id,
			skill_id
		)
		VALUES ($1, $2)
		ON CONFLICT (resource_id, skill_id)
		DO NOTHING
	`, resourceID, skillID)

	return err
}

func (i *Importer) insertVideoStatistics(ctx context.Context, tx pgx.Tx, videoID int64, row importcsv.Video) error {
	_, err := tx.Exec(ctx, `
		INSERT INTO ai_learning.video_statistics (
			video_id,
			view_count,
			like_count,
			comment_count
		)
		VALUES ($1, $2, $3, $4)
	`,
		videoID,
		parseInt64(row.ViewCount),
		parseInt64(row.LikeCount),
		parseInt64(row.CommentCount),
	)

	return err
}

func parseNullableInt(value string) *int {
	value = strings.TrimSpace(value)
	if value == "" {
		return nil
	}

	n, err := strconv.Atoi(value)
	if err != nil {
		return nil
	}

	return &n
}

func parseNullableFloat(value string) *float64 {
	value = strings.TrimSpace(value)
	if value == "" {
		return nil
	}

	n, err := strconv.ParseFloat(value, 64)
	if err != nil {
		return nil
	}

	return &n
}

func parseNullableTime(value string) *time.Time {
	value = strings.TrimSpace(value)
	if value == "" {
		return nil
	}

	t, err := time.Parse(time.RFC3339, value)
	if err != nil {
		return nil
	}

	return &t
}

func parseEstimatedMinutes(durationMinutes string, durationSeconds *int) *int {
	if n := parseNullableInt(durationMinutes); n != nil {
		return n
	}

	if durationSeconds == nil {
		return nil
	}

	minutes := int(math.Ceil(float64(*durationSeconds) / 60.0))
	return &minutes
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

func nullIfEmpty(value string) any {
	value = strings.TrimSpace(value)
	if value == "" {
		return nil
	}
	return value
}
