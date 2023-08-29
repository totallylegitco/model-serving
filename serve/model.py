from fastapi import FastAPI
from ray import serve
from transformers import  AutoTokenizer, AutoModelForCausalLM, LlamaTokenizer, LlamaForCausalLM, pipeline


app = FastAPI()


@serve.deployment(num_replicas=2, route_prefix="/biogpt")
class BioGPT():
    def __init__(self, max_new_tokens=200):
        self.tokenizer = AutoTokenizer.from_pretrained("microsoft/BioGPT-Large-PubMEDQA")

        self.model = AutoModelForCausalLM.from_pretrained(
            "microsoft/BioGPT-Large-PubMEDQA",
        )


    @app.get("infer")
    def infer(self, prompt: str) -> str:
        input_ids = self.tokenizer(prompt, return_tensors="pt").input_ids

        generation_output = self.model.generate(
            input_ids=input_ids, max_new_tokens=100
        )

        return generation_output


@serve.deployment(num_replicas=2, route_prefix="/openllamamed")
class OpenLLAMAMed():
    def __init__(self, max_new_tokens=200):
        model_path = 'yhyhy3/open_llama_7b_v2_med_dolphin_qlora_merged'

        self.tokenizer = LlamaTokenizer.from_pretrained(model_path)
        self.model = LlamaForCausalLM.from_pretrained(
            model_path, torch_dtype=torch.float16, device_map='auto',
        )        

    @app.get("infer")
    def infer(self, prompt: str) -> str:
        input_ids = self.tokenizer(prompt, return_tensors="pt").input_ids

        generation_output = self.model.generate(
            input_ids=input_ids, max_new_tokens=100
        )

        return generation_output
    
biogpt = BioGPT.bind()
models = OpenLLAMAMed.bind(biogpt)
