from pydantic import BaseModel, Field
from fastapi import FastAPI, HTTPException, Request
from ray import serve
from transformers import pipeline


from typing import Optional

app = FastAPI()

@serve.deployment(num_replicas=2, route_prefix="/biogpt")
class BioGPT():
    def __init__(self, max_new_tokens=200):
        self.pipeline = pipeline(
            model="microsoft/BioGPT-Large-PubMedQA",
            max_new_tokens=max_new_tokens)

    @app.get("infer")
    def infer(self, prompt: str) -> str:
        return self.pipeline(prompt)


biogpt = BioGPT.bind()
models = biogpt
