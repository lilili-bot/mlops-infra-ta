from fastapi import FastAPI
from pydantic import BaseModel
from typing import Optional
from instrumentation import instrumentation
# from instrumentation import measure_latency, global_exception_handler, count_requests
import os

app = FastAPI()
# init_tracing()
# init_metrics()
service_specific_attributes = {
    "service.instance.id": "leamore"
}

instrumentation(app, additional_atrributes= service_specific_attributes)



# Register middleware

# app.middleware('http')(measure_latency)
# app.middleware('http')(count_requests)
# app.add_exception_handler(Exception, global_exception_handler)


# Define Pydantic model for Item
class Item(BaseModel):
    name: str
    description: Optional[str] = None
    price: float
    tax: Optional[float] = None

# Define routes
@app.get("/")
def read_root():
    return {"message": "Hello, World"}

@app.get("/items/{item_id}")
def read_item(item_id: int, q: Optional[str] = None):
    return {"item_id": item_id, "q": q}

@app.post("/items/")
def create_item(item: Item):
    return {"name": item.name, "price": item.price}


# Mock function to simulate database operations
# async def query_database():
#     import random
#     import asyncio
#     duration = random.uniform(0.01, 0.2)  # Simulate query duration
#     await asyncio.sleep(duration)
#     return duration


# @app.get("/db")
# async def db_operation():
#     duration = await query_database()
#     return {"db_query_duration": duration}