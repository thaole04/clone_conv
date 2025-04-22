#!/usr/bin/env python3
import numpy as np
from conv2d import conv2d

def read_matrix(H, W, name="input"):
    """
    Read a H×W matrix from user input.
    name: descriptor for prompt (e.g. "input channel 0" or "kernel oc0 ic1").
    """
    mat = np.zeros((H, W), dtype=float)
    print(f"\nEnter values for {name} (each row {W} space-separated numbers):")
    for i in range(H):
        while True:
            row_str = input(f" Row {i}: ")
            parts = row_str.strip().split()
            if len(parts) != W:
                print(f"  ➤ You must enter exactly {W} values.")
                continue
            try:
                mat[i] = [float(x) for x in parts]
                break
            except ValueError:
                print("  ➤ Invalid number, please re-enter.")
    return mat


def main():
    print("=== Conv2D Parameter Interface ===")
    C_in  = int(input("Number of input channels (C_in): "))
    H     = int(input("Input height (H): "))
    W     = int(input("Input width  (W): "))
    P_h   = int(input("Padding height (pad_h): "))
    P_w   = int(input("Padding width  (pad_w): "))
    S_h   = int(input("Stride height (stride_h): "))
    S_w   = int(input("Stride width  (stride_w): "))
    K_h   = int(input("Kernel height (K_h): "))
    K_w   = int(input("Kernel width  (K_w): "))
    C_out = int(input("Number of output channels (C_out): "))

    # Read the input tensor interactively
    input_tensor = np.zeros((C_in, H, W), dtype=float)
    for c in range(C_in):
        input_tensor[c] = read_matrix(H, W, name=f"input channel {c}")

    # Read kernels interactively
    kernels = np.zeros((C_out, C_in, K_h, K_w), dtype=float)
    for oc in range(C_out):
        for ic in range(C_in):
            kernels[oc, ic] = read_matrix(K_h, K_w, name=f"kernel oc{oc} ic{ic}")

    # Read bias interactively
    bias = np.zeros((C_out,), dtype=float)
    print(f"\nEnter bias for each of {C_out} output channels (space-separated):")
    while True:
        parts = input(" Bias: ").strip().split()
        if len(parts) != C_out:
            print(f"  ➤ You must enter exactly {C_out} values.")
            continue
        try:
            bias[:] = [float(x) for x in parts]
            break
        except ValueError:
            print("  ➤ Invalid number, please re-enter.")

    # Read MACC coefficient
    macc_coef = float(input("\nEnter MACC coefficient (scalar): "))

    # Display summary
    print("\nConfiguration Summary:")
    print(f" Input tensor shape: {input_tensor.shape}")
    print(f" Kernel shape: {kernels.shape}")
    print(f" Bias shape: {bias.shape}")
    print(f" Stride: ({S_h}, {S_w}), Padding: ({P_h}, {P_w})")
    print(f" MACC coefficient: {macc_coef}\n")

    # Perform raw convolution (no bias)
    raw_output = conv2d(input_tensor, kernels, bias=None,
                        stride=(S_h, S_w), padding=(P_h, P_w))

    # Apply MACC scaling and then add bias
    # raw_output shape: (C_out, H_out, W_out)
    scaled = raw_output * macc_coef
    # add bias per channel
    final_output = np.zeros_like(scaled)
    for oc in range(C_out):
        final_output[oc] = scaled[oc] + bias[oc]

    print("Convolution output after scaling and bias (shape: {}):".format(final_output.shape))
    print(final_output)

if __name__ == '__main__':
    main()

