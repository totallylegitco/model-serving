from fastapi import FastAPI
from ray import serve
from transformers import LlamaTokenizer, LlamaForCausalLM, pipeline


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


@serve.deployment(num_replicas=2, route_prefix="/openllamamed")
class OpenLLAMAMed():
    def __init__(self, max_new_tokens=200):
        model_path = 'yhyhy3/open_llama_7b_v2_med_dolphin_qlora_merged'

        self.tokenizer = LlamaTokenizer.from_pretrained(model_path)
        self.model = LlamaForCausalLM.from_pretrained(
            model_path, torch_dtype=torch.float16, device_map='auto',
        )        

    @app.get("infer")
    def infer(self, question: str) -> str:
        prompt = f'''### Instruction: Answer the following question.

### Input: {question}

### Response:'''
        return self.pipeline(prompt)
    
biogpt = BioGPT.bind()
models = OpenLLAMAMed.bind(biogpt)
