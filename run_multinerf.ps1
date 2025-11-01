# ============================================
# MultiNeRF Auto Run Script (PowerShell)
# Author: ChatGPT
# ============================================

# === [1] Path Setup ===
$repo_path = "C:\Users\94230\Documents\GitHub\multinerf"
$data_dir = "D:\BoxFotos"
$env_name = "multinerf"

Write-Host "=== [MultiNeRF Auto Run Script Started] ===" -ForegroundColor Cyan
cd $repo_path

# === [2] Activate Conda Environment ===
Write-Host ">> Activating conda environment '$env_name' ..."
conda activate $env_name

# === [3] Check COLMAP installation ===
Write-Host ">> Checking COLMAP installation ..."
if (-not (Get-Command "colmap" -ErrorAction SilentlyContinue)) {
    Write-Host "!! COLMAP not found. Please install COLMAP and add it to your PATH." -ForegroundColor Red
    Write-Host "Download: https://colmap.github.io/install.html"
    exit
} else {
    Write-Host "COLMAP detected successfully." -ForegroundColor Green
}

# === [4] Run COLMAP pose estimation ===
Write-Host ">> Running COLMAP to estimate camera poses (this may take several minutes)..."
bash scripts/local_colmap_and_resize.sh $data_dir

# === [5] Start MultiNeRF training ===
Write-Host ">> Starting MultiNeRF training ..."
python -m train `
  --gin_configs=configs/360.gin `
  --gin_bindings="Config.data_dir = '$data_dir'" `
  --gin_bindings="Config.checkpoint_dir = '$data_dir\checkpoints'" `
  --logtostderr

# === [6] Render final video ===
Write-Host ">> Rendering result video ..."
python -m render `
  --gin_configs=configs/360.gin `
  --gin_bindings="Config.data_dir = '$data_dir'" `
  --gin_bindings="Config.checkpoint_dir = '$data_dir\checkpoints'" `
  --gin_bind_
