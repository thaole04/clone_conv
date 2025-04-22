import numpy as np

def conv2d(
    input_tensor: np.ndarray,
    kernels: np.ndarray,
    bias: np.ndarray = None,
    stride: tuple = (1, 1),
    padding: tuple = (0, 0)
) -> np.ndarray:
    """
    Perform a 2D convolution over a multi-channel input.

    Parameters:
    - input_tensor: shape (C_in, H_in, W_in)
    - kernels:       shape (C_out, C_in, K_h, K_w)
    - bias:          shape (C_out,), optional
    - stride:        (stride_h, stride_w)
    - padding:       (pad_h, pad_w)

    Returns:
    - output: shape (C_out, H_out, W_out)
    """
    C_in, H_in, W_in = input_tensor.shape
    C_out, _, K_h, K_w = kernels.shape
    s_h, s_w = stride
    p_h, p_w = padding

    # Pad input
    padded = np.pad(
        input_tensor,
        ((0, 0), (p_h, p_h), (p_w, p_w)),
        mode='constant', constant_values=0
    )

    # Compute output dimensions
    H_out = (H_in + 2*p_h - K_h) // s_h + 1
    W_out = (W_in + 2*p_w - K_w) // s_w + 1

    output = np.zeros((C_out, H_out, W_out), dtype=input_tensor.dtype)

    # Convolution
    for co in range(C_out):
        for ho in range(H_out):
            for wo in range(W_out):
                h_start = ho * s_h
                w_start = wo * s_w
                region = padded[:, h_start:h_start+K_h, w_start:w_start+K_w]
                output[co, ho, wo] = np.sum(region * kernels[co])
        if bias is not None:
            output[co] += bias[co]
    return output


if __name__ == '__main__':
    # Example usage
    # Input: 2 channels, 5x5
    C_in, H, W = 2, 5, 5
    C_out = 3
    input_tensor = np.arange(C_in*H*W).reshape(C_in, H, W)

    # Kernels: 3 output channels, 2 input channels, 3x3 kernel
    kernels = np.ones((C_out, C_in, 3, 3), dtype=input_tensor.dtype)
    bias = np.array([0, 1, 2])

    # Convolution with stride=1, padding=1
    out = conv2d(input_tensor, kernels, bias=bias, stride=(1,1), padding=(1,1))
    print("Output shape:", out.shape)
    print(out)

