#!/bin/bash

# Initialize virtual environment and install dependencies
echo "Setting up environment..."
if [[ ! -d "venv" ]]; then
  python3 -m venv venv
  source venv/bin/activate
  pip install transformers beautifulsoup4 tqdm
else
  source venv/bin/activate
fi

# Prompt to continue
read -n 1 -s -r -p "Press any key to continue to data extraction..."

# Extract data from conversations.html
echo -e "\n\nExtracting data from conversations.html..."
python ./scripts/extract_from_html.py --input ./data/raw/conversations.html --output ./data/raw/chat_history.txt

# Display progress using tqdm
python -c "from tqdm import tqdm; import time; [time.sleep(0.01) for _ in tqdm(range(100), desc='Extracting')]"

# Prompt to continue
read -n 1 -s -r -p "Press any key to continue to data tokenization..."

# Tokenize extracted data
echo -e "\n\nTokenizing data..."
python ./scripts/tokenize_data.py --input ./data/raw/chat_history.txt --output ./data/tokenized/chat_data.jsonl

# Display progress using tqdm
python -c "from tqdm import tqdm; import time; [time.sleep(0.01) for _ in tqdm(range(100), desc='Tokenizing')]"

# Placeholder for further steps like fine-tuning or evaluation

echo -e "\n\nProcess complete! Remember to deactivate the virtual environment when done."
