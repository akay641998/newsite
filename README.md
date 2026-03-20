# AcmeCorp — Nginx Company Website

A simple, polished company single-page website served by **Nginx**.  
Designed to be tested on an **OpenShift** cluster and easy to run locally via **Docker**.

---

## Project Structure

```
nginx-company-site/
├── index.html                  # Single-page website
├── style.css                   # All styles
├── main.js                     # Navbar, animations, form logic
├── nginx.conf                  # Nginx server config (non-root, port 8080)
├── Dockerfile                  # Multi-stage Docker image (OpenShift-compatible)
├── docker-compose.yml          # Local development with docker-compose
├── .gitignore
├── .github/
│   └── workflows/
│       └── build-and-push.yml  # GitHub Actions CI — builds Docker image on push
└── openshift/
    ├── deployment.yaml         # Kubernetes/OpenShift Deployment (2 replicas)
    ├── service.yaml            # ClusterIP Service
    └── route.yaml              # OpenShift Route with TLS edge termination
```

---

## Run Locally

### Option 1 — Docker (recommended)

**Requirements:** [Docker Desktop](https://docs.docker.com/get-docker/) installed and running.

```bash
# 1. Clone the repository
git clone https://github.com/<your-username>/<your-repo>.git
cd nginx-company-site

# 2. Build and start the container
docker compose up --build

# 3. Open in your browser
open http://localhost:8080
# or visit http://localhost:8080 manually
```

To stop the container:
```bash
docker compose down
```

---

### Option 2 — Docker (without compose)

```bash
# Build the image
docker build -t acmecorp-website .

# Run the container
docker run -p 8080:8080 --name acmecorp-website acmecorp-website

# Open http://localhost:8080
```

---

### Option 3 — No Docker (plain browser)

If you just want to preview the site without Docker:

```bash
# Clone the repo
git clone https://github.com/<your-username>/<your-repo>.git
cd nginx-company-site

# Open the HTML file directly in your browser
open index.html         # macOS
start index.html        # Windows
xdg-open index.html     # Linux
```

> Note: The contact form works in all options. It simulates a submission client-side (no backend needed).

---

## Deploy to OpenShift

### Prerequisites

- `oc` CLI installed and logged in to your OpenShift cluster
- A container image pushed to a registry (e.g. Quay.io, Docker Hub, or the internal OpenShift registry)

### Steps

**1. Build and push your image**

```bash
# Example: push to Quay.io
docker build -t quay.io/<your-username>/acmecorp-website:latest .
docker push quay.io/<your-username>/acmecorp-website:latest
```

**2. Update the image reference**

Edit `openshift/deployment.yaml` and replace the placeholder image:
```yaml
image: quay.io/<your-username>/acmecorp-website:latest
```

**3. Create a new OpenShift project (optional)**

```bash
oc new-project acmecorp-website
```

**4. Apply the manifests**

```bash
oc apply -f openshift/deployment.yaml
oc apply -f openshift/service.yaml
oc apply -f openshift/route.yaml
```

**5. Get the public URL**

```bash
oc get route acmecorp-website
```

The output will show the HOST/PORT — open it in your browser.

---

## GitHub Actions CI

The workflow in `.github/workflows/build-and-push.yml` automatically builds the Docker image on every push to `main`.

To enable automatic pushes to a registry:
1. Open `.github/workflows/build-and-push.yml`
2. Uncomment the relevant push section (Docker Hub or Quay.io)
3. Add the required secrets in **GitHub → Settings → Secrets and variables → Actions**:
   - `DOCKERHUB_USERNAME` + `DOCKERHUB_TOKEN` (for Docker Hub)
   - `QUAY_USERNAME` + `QUAY_TOKEN` (for Quay.io)

---

## Push to GitHub

```bash
# 1. Initialise git (if not already done)
git init
git add .
git commit -m "Initial commit: AcmeCorp nginx website"

# 2. Create a new repo on GitHub (github.com → New repository)
#    Then link it:
git remote add origin https://github.com/<your-username>/<your-repo>.git
git branch -M main
git push -u origin main
```

---

## Health Check

The Nginx config exposes a `/health` endpoint that returns `200 OK`.  
This is used by the OpenShift liveness and readiness probes automatically.

```bash
curl http://localhost:8080/health
# OK
```

---

## Customisation

| What to change | Where |
|---|---|
| Company name, colours, text | `index.html` + `style.css` (CSS variables at the top) |
| Nginx port (default 8080) | `nginx.conf` → `listen 8080` and `Dockerfile` → `EXPOSE 8080` |
| Number of replicas | `openshift/deployment.yaml` → `spec.replicas` |
| Resource limits | `openshift/deployment.yaml` → `resources` |
