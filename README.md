# CachyOS Setup with R9700 Inference

This directory contains bootstrap scripts for setting up CachyOS with ASRock Creator Radeon AI PRO R9700 inference capabilities and a comprehensive user environment.

## Files

1. **r9700_inference_setup.sh** - Configures the R9700 GPU for AI/ML inference
2. **user_environment_setup.sh** - Sets up development environment and tools
3. **bootstrap.sh** - Combined script that runs both setups

## Usage

After installing CachyOS, run the scripts in order:

```bash
# Make scripts executable
chmod +x *.sh

# Run inference setup
./r9700_inference_setup.sh

# Run user environment setup
./user_environment_setup.sh

# Or run the combined script
./bootstrap.sh
```

## Hardware Configuration

- **Primary GPU for display**: Intel Arc Pro B50 (33P6PEB0BB)
- **Inference GPU**: ASRock Creator Radeon AI PRO R9700
- **CPU**: AMD Ryzen 5 7600X
- **Motherboard**: Asus ProArt X870E-CREATOR WIFI
- **Memory**: Corsair Vengeance 32GB DDR5-6000 CL36

## Notes

- The R9700 script configures ROCm for optimal inference performance
- The user environment script sets up development tools, Docker, and shell configuration
- Both scripts are designed to run on a fresh CachyOS installation

## Troubleshooting

If ROCm doesn't detect the R9700:
1. Check that the GPU is properly connected
2. Verify ROCm installation: `rocm-smi`
3. Check udev rules: `ls -la /etc/udev/rules.d/70-amdgpu.rules`