from fastapi import FastAPI
from ray import serve
from transformers import pipeline


app = FastAPI()


@serve.deployment(num_replicas=2, route_prefix="/biogpt")
class BioGPT():
    def __init__(self, max_new_tokens=200):
        self.pipeline = pipeline(
            model="microsoft/BioGPT-Large-PubMedQA",
            max_new_tokens=max_new_tokens,
            device_map="auto",
        )

    @app.get("infer")
    def infer(self, prompt: str) -> str:
        return self.pipeline(prompt)


biogpt = BioGPT.bind()
models = biogpt
