from pydantic import BaseModel, Field
from fastapi import FastAPI, HTTPException, Request
from ray import serve

from typing import Optional

