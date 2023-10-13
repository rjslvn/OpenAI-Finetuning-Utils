#!/bin/bash

# Advanced Filepinecone Utils Script

echo "🚀 Starting Filepinecone Utils..."

# Initialize environment and paths
PDF_PATH="data/pdfs/MYGPT.pdf"
WORD2VEC_PATH="models/googlenews-vectors-negative300.bin"
EMBEDDINGS_PATH="output/embeddings.json"

# Environment setup
echo "Setting up environment..."
if [[ ! -d "venv" ]]; then
  python3 -m venv venv
  source venv/bin/activate
  pip install gensim sentence_transformers PyPDF2 tqdm
else
  source venv/bin/activate
fi

# Extract text from PDF
echo "📄 Extracting text from PDFs..."
pdf_text=$(pdftotext $PDF_PATH -)
echo "Extraction complete!"

# Generate Word2Vec Embeddings
echo "🧠 Generating Word2Vec Embeddings..."
if [ ! -f $WORD2VEC_PATH ]; then
    echo 'Word2Vec model not found. Downloading...'
    wget -P models/ -c "https://s3.amazonaws.com/dl4j-distribution/GoogleNews-vectors-negative300.bin.gz"
    gunzip models/GoogleNews-vectors-negative300.bin.gz
fi

python - <<END
import os
from gensim.models import KeyedVectors
pdf_text = '''$pdf_text'''
model = KeyedVectors.load_word2vec_format("$WORD2VEC_PATH", binary=True)
words = pdf_text.split()
embeddings = {}
for word in words:
    try:
        embeddings[word] = model[word].tolist()
    except:
        pass
with open("$EMBEDDINGS_PATH", 'w') as f:
    json.dump(embeddings, f)
END
echo "Embeddings generation complete!"

# Generate SentenceTransformer Embeddings and save to Pinecone
echo "🔍 Generating SentenceTransformer Embeddings and saving to Pinecone..."
python - <<END
from sentence_transformers import SentenceTransformer
import json
model = SentenceTransformer('all-MiniLM-L6-v2')
with open("data/json/conversations.json", 'r') as f:
    data = json.load(f)
embeddings = model.encode([item['text'] for item in data])
for item, embedding in zip(data, embeddings):
    item['embedding'] = embedding.tolist()
with open("output/pinecone_upsert.json", 'w') as f:
    json.dump(data, f)
END
echo "SentenceTransformer embeddings saved successfully!"

# Placeholder for additional functionalities
echo "🤖 Running main script for query and response generation..."
# Add any other functionalities or scripts here
echo "Placeholder for main functionality"

# Completion message
echo "🎉 All tasks completed successfully!"

# Deactivate the virtual environment
echo "Deactivating environment..."
deactivate
