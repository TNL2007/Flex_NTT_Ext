import json
import os

Q = 3329
ZETA = 17
N = 256

def bitrev7(x):
    r = 0
    for i in range(7):
        r |= ((x >> i) & 1) << (6 - i)
    return r

def modpow(b, e, m):
    return pow(b, e, m)

def modinv(x, q=Q):
    return pow(x, q - 2, q)

def build_zetas():
    return [modpow(ZETA, bitrev7(k), Q) for k in range(128)]

def build_gammas():
    return [modpow(ZETA, 2 * bitrev7(i) + 1, Q) for i in range(128)]

ZETAS = build_zetas()
GAMMAS = build_gammas()

def ntt(f):
    f = f[:]
    k = 1
    length = 128
    while length >= 2:
        start = 0
        while start < N:
            zeta = ZETAS[k]
            k += 1
            for j in range(start, start + length):
                t = (zeta * f[j + length]) % Q
                f[j + length] = (f[j] - t) % Q
                f[j] = (f[j] + t) % Q
            start += 2 * length
        length //= 2
    return f

def intt(f):
    f = f[:]
    k = 127
    length = 2
    while length <= 128:
        start = 0
        while start < N:
            zeta = ZETAS[k]
            k -= 1
            for j in range(start, start + length):
                t = f[j]
                f[j] = (t + f[j + length]) % Q
                f[j + length] = (zeta * ((f[j + length] - t) % Q)) % Q
            start += 2 * length
        length *= 2
    f_inv = modinv(128, Q)
    return [(x * f_inv) % Q for x in f]

def base_case_multiply(a0, a1, b0, b1, gamma):
    c0 = (a0 * b0 + gamma * a1 * b1) % Q
    c1 = (a0 * b1 + a1 * b0) % Q
    return c0, c1

def pointwise_base_multiply(A, B):
    C = [0] * N
    for i in range(128):
        c0, c1 = base_case_multiply(A[2 * i], A[2 * i + 1], B[2 * i], B[2 * i + 1], GAMMAS[i])
        C[2 * i] = c0
        C[2 * i + 1] = c1
    return C

def poly_mult_ntt(a, b):
    A = ntt(a)
    B = ntt(b)
    C = pointwise_base_multiply(A, B)
    return intt(C), A, B, C

def negacyclic_conv_schoolbook(a, b, q=Q):
    n = len(a)
    c = [0] * n
    for i in range(n):
        for j in range(n):
            k = i + j
            val = (a[i] * b[j]) % q
            if k >= n:
                k -= n
                val = (-val) % q
            c[k] = (c[k] + val) % q
    return c

def random_poly(n, q, seed):
    x = seed
    out = []
    for i in range(n):
        x = (1103515245 * x + 12345) % (2 ** 31)
        out.append(x % q)
    return out

if __name__ == "__main__":
    a = random_poly(N, Q, 11)
    b = random_poly(N, Q, 22)

    roundtrip_a = intt(ntt(a))
    assert roundtrip_a == a, "NTT/INTT roundtrip failed"

    c, A, B, C = poly_mult_ntt(a, b)
    ref = negacyclic_conv_schoolbook(a, b)
    assert c == ref, "poly-mult does not match schoolbook negacyclic convolution"

    assert ZETAS[0:8] == [1, 1729, 2580, 3289, 2642, 630, 1897, 848], "ZETAS table does not match FIPS 203 published constants"

    dump = {
        "Q": Q,
        "ZETA": ZETA,
        "N": N,
        "ZETAS": ZETAS,
        "GAMMAS": GAMMAS,
        "input_a": a,
        "input_b": b,
        "NTT_A": A,
        "NTT_B": B,
        "pointwise_base_mult_result": C,
        "output_c": c,
        "schoolbook_ref": ref,
        "match_schoolbook": c == ref
    }
    dump_path = os.path.join(os.path.dirname(__file__), "..", "expected", "mlkem_golden_model_dump.json")
    with open(dump_path, "w") as f:
        json.dump(dump, f, indent=2)

    print("all checks passed")
    print("Q =", Q, "ZETA =", ZETA, "N =", N)
    print("ZETAS[0:8] =", ZETAS[0:8])
    print("GAMMAS[0:4] =", GAMMAS[0:4])
    print("output_c[0:8] =", c[0:8])
