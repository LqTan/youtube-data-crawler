package topics

type Plan struct {
	Category string
	Topic    string
	Skill    string
	Queries  []string
}

var DefaultPlans = []Plan{
	{
		Category: "AI Foundations",
		Topic:    "AI Basics",
		Skill:    "Artificial Intelligence",
		Queries: []string{
			"artificial intelligence tutorial for beginners",
			"AI explained for beginners",
			"AI roadmap for beginners",
		},
	},
	{
		Category: "Machine Learning",
		Topic:    "Machine Learning Basics",
		Skill:    "Machine Learning",
		Queries: []string{
			"machine learning tutorial for beginners",
			"machine learning full course",
			"supervised learning tutorial",
		},
	},
	{
		Category: "Deep Learning",
		Topic:    "Neural Networks",
		Skill:    "Deep Learning",
		Queries: []string{
			"neural networks tutorial",
			"deep learning tutorial",
			"deep learning full course",
		},
	},
	{
		Category: "NLP & LLM",
		Topic:    "Large Language Models",
		Skill:    "LLM",
		Queries: []string{
			"large language models tutorial",
			"LLM tutorial for beginners",
			"how large language models work",
		},
	},
	{
		Category: "NLP & LLM",
		Topic:    "Prompt Engineering",
		Skill:    "Prompt Engineering",
		Queries: []string{
			"prompt engineering tutorial",
			"prompt engineering for beginners",
			"ChatGPT prompt engineering course",
		},
	},
	{
		Category: "RAG & Vector Search",
		Topic:    "Retrieval Augmented Generation",
		Skill:    "RAG",
		Queries: []string{
			"RAG tutorial",
			"retrieval augmented generation tutorial",
			"build RAG application",
		},
	},
	{
		Category: "RAG & Vector Search",
		Topic:    "Embeddings",
		Skill:    "Embeddings",
		Queries: []string{
			"embeddings tutorial",
			"vector embeddings explained",
			"semantic search tutorial",
		},
	},
	{
		Category: "RAG & Vector Search",
		Topic:    "Vector Databases",
		Skill:    "Vector Database",
		Queries: []string{
			"vector database tutorial",
			"Pinecone tutorial",
			"ChromaDB tutorial",
		},
	},
	{
		Category: "Computer Vision",
		Topic:    "Computer Vision Basics",
		Skill:    "Computer Vision",
		Queries: []string{
			"computer vision tutorial",
			"image classification tutorial",
			"object detection tutorial",
		},
	},
	{
		Category: "MLOps",
		Topic:    "Model Deployment",
		Skill:    "MLOps",
		Queries: []string{
			"MLOps tutorial",
			"machine learning model deployment",
			"deploy machine learning model FastAPI",
		},
	},
}
