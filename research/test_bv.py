import bv


def test_create_qasm_files():
    min = 2
    max = 10
    bit_range = range(min, max)
    [bv.bitstring_to_file("1" * N, "circuits") for N in bit_range]


def test_verify_zx():
    min = 2
    max = 31
    bit_range = range(min, max)
    for N in bit_range:
        assert bv.verify_circuits_qmdd("1" * N) is True
        assert bv.verify_circuits_qmdd("0" * N) is True


def test_verify_qmdd():
    min = 2
    max = 31
    bit_range = range(min, max)
    for N in bit_range:
        assert bv.verify_circuits_zx("1" * N) is True
        assert bv.verify_circuits_zx("0" * N) is True
