# RaktDrishti Cloud Deployment & CI/CD Guide

> **Production Topology**:
> - **Frontend & Flutter Web Screener**: Deployed on **Vercel** (Global Edge CDN)
> - **Backend REST API**: Deployed on **Render** (FastAPI Web Service)
> - **Primary Database**: Managed **PostgreSQL 15** on Render
> - **Automated CI/CD**: **GitHub Actions** (`.github/workflows/ci-cd.yml`)

---

## 1. What Has Been Automatically Configured in the Codebase

1. **`render.yaml` (Render Blueprint)**:
   - Defines the `raktdrishti-backend` Python service and `raktdrishti-postgres` database.
   - Automatically builds `backend/requirements.txt`, binds `DATABASE_URL`, and starts `uvicorn backend.app.main:app`.
   - Normalizes database scheme (`postgres://` -> `postgresql://`) for SQLAlchemy 2.0.
2. **`vercel.json` (Vercel Routing & Proxy)**:
   - Serves the Web Dashboard at `/` and Mobile Screener at `/screener`.
   - Proxies all `/api/v1/*` requests directly to your Render backend to eliminate CORS and mixed-content issues.
3. **Adaptive Client API Base**:
   - `dashboard/js/app.js` and `dashboard/screener.html` automatically detect whether they are running on localhost (`http://localhost:8000/api/v1`) or in production (`/api/v1` via Vercel proxy).
4. **GitHub Actions Workflow (`.github/workflows/ci-cd.yml`)**:
   - Automatically runs on every push or PR:
     1. Installs dependencies and runs all 9 Pytest backend integration tests.
     2. Runs the ML model evaluation benchmark.
     3. Triggers automated Render and Vercel deployments on `main`/`master`.

---

## 2. Step-by-Step: Remaining Things You Should Do

### Step A: Push Code to GitHub
Ensure your latest code is committed and pushed to your GitHub repository:
```bash
git add .
git commit -m "feat: complete deployment setup for Render and Vercel with CI/CD"
git push origin main
```

---

### Step B: Deploy Backend on Render (5 minutes)

1. Go to [Render Dashboard](https://dashboard.render.com/) and sign in with your GitHub account.
2. Click **New +** in the top right and select **Blueprint**.
3. Connect your repository: `Kailashsharma282/raktdrishti-anemia-screener`.
4. Render will automatically detect `render.yaml` and create:
   - **`raktdrishti-backend`** (Web Service)
   - **`raktdrishti-postgres`** (Managed PostgreSQL Database)
5. Click **Apply**.
6. Once deployed (typically 2–3 minutes), Render will give you your backend URL, for example:  
   `https://raktdrishti-backend.onrender.com`
7. Test the health endpoint in your browser:  
   `https://raktdrishti-backend.onrender.com/api/v1/health`  
   *(You should see `{"status": "healthy", ...}`)*

---

### Step C: Deploy Frontend on Vercel (2 minutes)

1. Go to [Vercel Dashboard](https://vercel.com/new) and sign in with GitHub.
2. Click **Add New...** -> **Project**.
3. Import your GitHub repository (`Kailashsharma282/raktdrishti-anemia-screener`).
4. In the configuration:
   - **Framework Preset**: `Other`
   - **Root Directory**: `./` (leave default, `vercel.json` will route to `dashboard/`)
5. Click **Deploy**.
6. Vercel will build and deploy your application in under 30 seconds.
7. If your Render backend URL is different from `https://raktdrishti-backend.onrender.com`, update the proxy destination in `vercel.json`:
   ```json
   {
     "source": "/api/v1/:match*",
     "destination": "https://<YOUR-ACTUAL-RENDER-NAME>.onrender.com/api/v1/:match*"
   }
   ```
   Commit and push, and Vercel will automatically redeploy!

---

### Step D: Optional GitHub Actions CI/CD Secrets

To enable fully automated deployments from GitHub Actions instead of relying solely on Git webhooks:

1. In your GitHub repository, go to **Settings** -> **Secrets and variables** -> **Actions**.
2. Add the following repository secrets:
   - `RENDER_DEPLOY_HOOK`:
     - *How to get it*: In your Render Web Service dashboard -> Settings -> Deploy Hook -> Copy URL.
   - `VERCEL_TOKEN`:
     - *How to get it*: In Vercel Account Settings -> Tokens -> Create Token.
   - `VERCEL_ORG_ID` & `VERCEL_PROJECT_ID`:
     - *How to get it*: Generated in `.vercel/project.json` when running `vercel link` or from Vercel Project Settings.

---

## 3. Verification Checklist After Deployment

- [ ] **Backend Health Check**: `https://<YOUR-RENDER-APP>.onrender.com/api/v1/health` returns status `healthy`.
- [ ] **Interactive Swagger Docs**: `https://<YOUR-RENDER-APP>.onrender.com/docs` opens the OpenAPI documentation.
- [ ] **Vercel Web Dashboard**: `https://<YOUR-VERCEL-APP>.vercel.app/` loads the Epidemiological Command Center and fetches KPIs from Render.
- [ ] **Vercel Flutter Web Screener**: `https://<YOUR-VERCEL-APP>.vercel.app/screener` launches the interactive mobile screener in browser.
- [ ] **End-to-End Simulation**: Run a live screening test from the web screener and verify that the screening appears in the dashboard tables!
