.PHONY: setup run delete

setup:
	python3 -m venv env
	. env/bin/activate && pip install -r requirements.txt

run:
	. env/bin/activate && python ingest_data.py

delete:
	rm -rf env