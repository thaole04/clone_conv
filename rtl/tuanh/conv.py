#!/usr/bin/env python3
import numpy as np
from conv2d import conv2d

def read_matrix(H, W, name="input"):
    """
    Read a H×W matrix from user input.
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


def clamp_and_round(arr):
    """
    Clamp values to [0,255], perform round-half-up,
    and return as numpy uint8 array.
    """
    # Round half up: add 0.5 then floor
    rounded = np.floor(arr + 0.5)
    # Clamp to [0,255]
    clamped = np.clip(rounded, 0, 255).astype(np.uint8)
    return clamped


def build_interleaved_hex(result):
    """
    Build comma-separated interleaved hex words string from result array.
    result: shape (C_out, H, W) uint8
    """
    C_out, H, W = result.shape
    words = []
    for i in range(H):
        for j in range(W):
            val = 0
            for oc in reversed(range(C_out)):
                val = (val << 8) | int(result[oc, i, j])
            words.append(f"{val:04x}")
    return ",".join(words), words


def layer_process(input_tensor):
    C_in, H, W = input_tensor.shape
    print(f"\n--- New layer: input shape = ({C_in}, {H}, {W}) ---")
    C_out = int(input("Number of output channels (C_out): "))
    K_h   = int(input("Kernel height (K_h): "))
    K_w   = int(input("Kernel width  (K_w): "))
    P_h   = int(input("Padding height (pad_h): "))
    P_w   = int(input("Padding width  (pad_w): "))
    S_h   = int(input("Stride height (stride_h): "))
    S_w   = int(input("Stride width  (stride_w): "))

    kernels = np.zeros((C_out, C_in, K_h, K_w), dtype=float)
    for oc in range(C_out):
        for ic in range(C_in):
            kernels[oc, ic] = read_matrix(K_h, K_w, name=f"kernel oc{oc} ic{ic}")

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

    macc_coef = float(input("Enter MACC coefficient (scalar): "))

    raw_output = conv2d(input_tensor, kernels, bias=None,
                        stride=(S_h, S_w), padding=(P_h, P_w))
    scaled = raw_output * macc_coef
    final = np.zeros_like(scaled)
    for oc in range(C_out):
        final[oc] = scaled[oc] + bias[oc]

    result = clamp_and_round(final)
    return result


def compare_arrays(computed, expected_str):
    """
    Compare computed list of hex words to expected comma-separated string.
    """
    exp_list = expected_str.split(',')
    if exp_list == computed:
        print("\n✅ Arrays match exactly.")
    else:
        print("\n❌ Arrays differ:")
        length = max(len(computed), len(exp_list))
        for idx in range(length):
            c = computed[idx] if idx < len(computed) else '<no data>'
            e = exp_list[idx] if idx < len(exp_list) else '<no entry>'
            if c != e:
                print(f" Index {idx}: computed={c}, expected={e}")
        if len(computed) != len(exp_list):
            print(f"Length mismatch: computed={len(computed)}, expected={len(exp_list)}")


def main():
    print("=== Sequential Conv2D Interface ===")
    C_in  = int(input("Number of input channels (C_in): "))
    H     = int(input("Input height (H): "))
    W     = int(input("Input width  (W): "))

    input_tensor = np.zeros((C_in, H, W), dtype=float)
    for c in range(C_in):
        input_tensor[c] = read_matrix(H, W, name=f"input channel {c}")

    while True:
        result = layer_process(input_tensor)
        output_str, words = build_interleaved_hex(result)
        print("\nInterleaved output array:")
        print(output_str)

        exp = input("\nEnter expected array (comma-separated, no spaces): ")
        compare_arrays(words, exp)

        cont = input("\nProcess next layer with this output as input? (y/n): ")
        if cont.lower().startswith('y'):
            input_tensor = result.astype(float)
        else:
            print("Done processing layers.")
            break

if __name__ == '__main__':
    main()

