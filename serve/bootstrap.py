from transformers import pipeline

biogpt_pipeline = pipeline(model="microsoft/BioGPT-Large-PubMedQA", max_new_tokens=250)
