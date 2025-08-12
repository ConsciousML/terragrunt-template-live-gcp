Install the [gcloud CLI](https://cloud.google.com/sdk/docs/install).

Test the installation:
```bash
gcloud --version
```

Authenticate to `gcloud`:
```bash
# Click on the link and log in with your Google account.
gcloud auth login
```

Repeat the process:
```bash
gcloud auth application-default login
```

List projects on GCP:
```bash
gcloud projects list
```

Set your default project:
```bash
gcloud config set project YOUR_PROJECT_ID
```

Edit files `project.hcl` and `region.hcl` with your `GCP_PROJEC_ID` and `GCP_REGION_NAME` in:
```bash
├── live
│   ├── dev
│   │   ├── project.hcl
│   │   └── region.hcl
│   ├── staging
│   │   ├── project.hcl
│   │   └── region.hcl
│   ├── prod
│   │   ├── project.hcl
│   │   └── region.hcl
```