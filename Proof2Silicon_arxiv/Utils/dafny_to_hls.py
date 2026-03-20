import subprocess
import shutil
import os
import sys

def dafny_to_hls(input_dfy: str, out_dir: str):
    """
    1. Verify & compile the Dafny program to C++ (via Dafny's C++ backend).
    2. Spill the generated C++ source to disk.
    3. Copy into out_dir and insert simple HLS pragmas.
    """
    base = os.path.splitext(os.path.basename(input_dfy))[0]
    # Step 1: verify + compile to C++
    # Requires Dafny’s C++ backend (limited support) :contentReference[oaicite:0]{index=0}
    subprocess.run([
        "dafny",
        input_dfy,
        "/verify:1",
        "/compile:1",
        "/compileTarget:cpp",
        "/spillTargetCode:1"
    ], check=True)

    # The Dafny C++ backend by default writes <base>.exe and side‐files; with spillTargetCode=1
    # it also emits <base>.cpp alongside. :contentReference[oaicite:1]{index=1}
    generated_cpp = f"{base}.cpp"
    if not os.path.exists(generated_cpp):
        raise FileNotFoundError(f"Expected {generated_cpp} after Dafny run")

    os.makedirs(out_dir, exist_ok=True)
    hls_cpp = os.path.join(out_dir, f"{base}_hls.cpp")

    with open(generated_cpp, "r") as fin, open(hls_cpp, "w") as fout:
        # Insert HLS headers
        fout.write("// Auto‐generated HLS C++ from Dafny\n")
        fout.write("#include <ap_int.h>\n")
        fout.write("#include <hls_stream.h>\n\n")
        # Mark the top‐level function for HLS
        fout.write("#pragma HLS TOP\n\n")

        for line in fin:
            # Very basic loop pipelining pragma insertion
            stripped = line.lstrip()
            indent = line[:len(line) - len(stripped)]
            if stripped.startswith("for (") or stripped.startswith("while ("):
                fout.write(f"{indent}#pragma HLS PIPELINE II=1\n")
            fout.write(line)

    print(f"[+] HLS‐ready C++ written to {hls_cpp}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 dafny_to_hls.py <input.dfy> <output_dir>")
        sys.exit(1)
    dafny_to_hls(sys.argv[1], sys.argv[2])
