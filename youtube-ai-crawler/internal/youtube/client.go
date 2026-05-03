package youtube

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"
)

const baseURL = "https://www.googleapis.com/youtube/v3"

type Client struct {
	apiKey     string
	httpClient *http.Client
}

func NewClient(apiKey string) *Client {
	return &Client{
		apiKey: apiKey,
		httpClient: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

type SearchResponse struct {
	NextPageToken string `json:"nextPageToken"`
	Items         []struct {
		ID struct {
			VideoID string `json:"videoId"`
		} `json:"id"`
	} `json:"items"`
}

type VideosResponse struct {
	Items []Video `json:"items"`
}

type Video struct {
	ID      string `json:"id"`
	Snippet struct {
		Title        string `json:"title"`
		Description  string `json:"description"`
		ChannelID    string `json:"channelId"`
		ChannelTitle string `json:"channelTitle"`
		PublishedAt  string `json:"publishedAt"`
		Thumbnails   map[string]struct {
			URL string `json:"url"`
		} `json:"thumbnails"`
	} `json:"snippet"`
	ContentDetails struct {
		Duration string `json:"duration"`
	} `json:"contentDetails"`
	Statistics struct {
		ViewCount    string `json:"viewCount"`
		LikeCount    string `json:"likeCount"`
		CommentCount string `json:"commentCount"`
	} `json:"statistics"`
}

func (c *Client) SearchVideoIDs(ctx context.Context, query string, maxPages int) ([]string, error) {
	videoIDs := make([]string, 0)
	pageToken := ""

	for page := 0; page < maxPages; page++ {
		params := url.Values{}
		params.Set("key", c.apiKey)
		params.Set("part", "snippet")
		params.Set("q", query)
		params.Set("type", "video")
		params.Set("maxResults", "50")
		params.Set("order", "relevance")
		params.Set("videoDuration", "medium")
		params.Set("safeSearch", "strict")
		params.Set("relevanceLanguage", "en")

		if pageToken != "" {
			params.Set("pageToken", pageToken)
		}

		var response SearchResponse
		if err := c.get(ctx, "search", params, &response); err != nil {
			return nil, err
		}

		for _, item := range response.Items {
			if item.ID.VideoID != "" {
				videoIDs = append(videoIDs, item.ID.VideoID)
			}
		}

		if response.NextPageToken == "" {
			break
		}

		pageToken = response.NextPageToken
	}

	return videoIDs, nil
}

func (c *Client) GetVideoDetails(ctx context.Context, videoIDs []string) ([]Video, error) {
	results := make([]Video, 0)

	for i := 0; i < len(videoIDs); i += 50 {
		end := i + 50
		if end > len(videoIDs) {
			end = len(videoIDs)
		}

		batch := videoIDs[i:end]
		if len(batch) == 0 {
			continue
		}

		params := url.Values{}
		params.Set("key", c.apiKey)
		params.Set("part", "snippet,contentDetails,statistics")
		params.Set("id", strings.Join(batch, ","))

		var response VideosResponse
		if err := c.get(ctx, "videos", params, &response); err != nil {
			return nil, err
		}

		results = append(results, response.Items...)
	}

	return results, nil
}

func (c *Client) get(ctx context.Context, path string, params url.Values, out any) error {
	endpoint := baseURL + "/" + path + "?" + params.Encode()

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint, nil)
	if err != nil {
		return err
	}

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("youtube api error: status=%d, body=%s", resp.StatusCode, string(body))
	}

	return json.NewDecoder(resp.Body).Decode(out)
}
