import torch
from transformers import  AutoTokenizer, AutoModelForCausalLM, LlamaTokenizer, LlamaForCausalLM, pipeline

print("Setting up first model")
model_path = 'yhyhy3/open_llama_7b_v2_med_dolphin_qlora_merged'

tokenizer = LlamaTokenizer.from_pretrained(model_path)
model = LlamaForCausalLM.from_pretrained(
    model_path,
#    torch_dtype=torch.float16,
    device_map='auto',
)

prompt = '''### Instruction: Answer the following question.

### Input: Why is Fiasp injection 100 units/mL medically necessary for type 1 diabetes mellitus?

### Response:'''
input_ids = tokenizer(prompt, return_tensors="pt").input_ids

print("Running test generation on 1st model.")
generation_output = model.generate(
    input_ids=input_ids, max_new_tokens=100
)

print(tokenizer.decode(generation_output[0]))

model = None

print("Loading biogpt.")
biogpt_tokenizer = AutoTokenizer.from_pretrained("microsoft/BioGPT-Large-PubMEDQA")

biogpt_model = AutoModelForCausalLM.from_pretrained(
    "microsoft/BioGPT-Large-PubMEDQA",
)
