from fastapi import FastAPI, Request, BackgroundTasks
from fastapi.responses import JSONResponse
from fastapi.exceptions import HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from agent import run_agent
from dotenv import load_dotenv
import uvicorn
import os
from shared_store import url_time, BASE64_STORE
import time

load_dotenv()

EMAIL = os.getenv("EMAIL") 
SECRET = os.getenv("SECRET")

class SolveRequest(BaseModel):
    email: str
    secret: str
    url: str

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # or specific domains
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
START_TIME = time.time()

@app.get("/")
def root():
    """Root endpoint with API information."""
    return {
        "message": "LLM Analysis Quiz Solver API",
        "endpoints": {
            "GET /": "This endpoint (API information)",
            "GET /healthz": "Health check endpoint",
            "POST /solve": "Solve quiz endpoint (requires email, secret, and url in JSON body)",
            "GET /docs": "Interactive API documentation (Swagger UI)",
            "GET /redoc": "Alternative API documentation (ReDoc)"
        },
        "status": "running"
    }

@app.get("/healthz")
def healthz():
    """Simple liveness check."""
    return {
        "status": "ok",
        "uptime_seconds": int(time.time() - START_TIME)
    }

@app.post("/solve")
async def solve(request: SolveRequest, background_tasks: BackgroundTasks):
    if request.secret != SECRET:
        raise HTTPException(status_code=403, detail="Invalid secret")
    
    url_time.clear() 
    BASE64_STORE.clear()  
    print("Verified starting the task...")
    os.environ["url"] = request.url
    os.environ["offset"] = "0"
    url_time[request.url] = time.time()
    background_tasks.add_task(run_agent, request.url)

    return JSONResponse(status_code=200, content={"status": "ok"})


if __name__ == "__main__":
    port = int(os.getenv("PORT", "7860"))
    uvicorn.run(app, host="0.0.0.0", port=port)