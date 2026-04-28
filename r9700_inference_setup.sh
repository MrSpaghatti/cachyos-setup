#!/bin/bash
set -e

# Specific R9700 Inference Setup Script

# Validate GPU
validate_gpu() {
    echo "Validating ASRock Creator Radeon AI PRO R9700..."
    
    # Check if ROCm detects the GPU
    if ! rocm-smi | grep -q "R9700"; then
        echo "Error: R9700 GPU not detected by ROCm"
        exit 1
    fi
}

# Install AI/ML Frameworks
install_frameworks() {
    echo "Installing AI/ML frameworks optimized for R9700..."
    
    # ROCm and AI dependencies
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm \
        rocm-hip-sdk \
        rocm-ml-sdk \
        python-pytorch-rocm \
        python-tensorflow-rocm \
        python-onnx \
        python-onnxruntime

    # Create Python virtual environment for inference
    python -m venv ~/r9700_inference_env
    source ~/r9700_inference_env/bin/activate
    
    # Install additional inference libraries
    pip install --upgrade pip
    pip install \
        transformers \
        accelerate \
        datasets \
        evaluate \
        torch-directml
}

# Optimize ROCm for R9700
configure_rocm() {
    echo "Configuring ROCm for optimal R9700 performance..."
    
    # Udev rules for GPU access
    echo 'KERNEL=="kfd", SUBSYSTEM=="drm", DRIVERS=="amdgpu", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/70-amdgpu.rules
    
    # ROCm performance tuning
    echo "export ROCM_PATH=/opt/rocm" >> ~/.bashrc
    echo "export HIP_PLATFORM=amd" >> ~/.bashrc
    echo "export HSA_OVERRIDE_GFX_VERSION=10.3.0" >> ~/.bashrc
}

# Verify inference capabilities
verify_inference() {
    echo "Verifying R9700 inference capabilities..."
    
    source ~/r9700_inference_env/bin/activate
    
    python -c "
import torch
import torch.nn as nn

# Simple inference test
class TestModel(nn.Module):
    def __init__(self):
        super().__init__()
        self.linear = nn.Linear(10, 1)
    
    def forward(self, x):
        return self.linear(x)

model = TestModel()
x = torch.randn(1, 10)
output = model(x)
print('Inference test passed successfully!')
print(f'GPU Available: {torch.cuda.is_available()}')
print(f'GPU Device: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else "No GPU detected"}')
"
}

# Main execution
main() {
    validate_gpu
    install_frameworks
    configure_rocm
    verify_inference
}

main