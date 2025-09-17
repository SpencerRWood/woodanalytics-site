from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
import pathlib

app = FastAPI(debug=True)

CSS_PATH = pathlib.Path("app/static/css/output.css")

def css_build_id():
    try:
        return str(int(CSS_PATH.stat().st_mtime))
    except FileNotFoundError:
        return "dev"

# Mount the static directory for CSS/JS files
app.mount("/static", StaticFiles(directory="app/static"), name="static")

# Set up Jinja2 templates
templates = Jinja2Templates(directory="app/templates")
templates.env.globals["build_id"] = css_build_id()

@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    return templates.TemplateResponse("home.html", {"request": request, "title": "Hello World"})

@app.get("/about", response_class=HTMLResponse)
async def about(request: Request):
    return templates.TemplateResponse("about.html", {"request": request})

@app.get("/services", response_class=HTMLResponse)
async def about(request: Request):
    return templates.TemplateResponse("services.html", {"request": request})

@app.get("/contact", response_class=HTMLResponse)
async def about(request: Request):
    return templates.TemplateResponse("contact.html", {"request": request})

app.mount("/static", StaticFiles(directory="app/static"), name="static")
