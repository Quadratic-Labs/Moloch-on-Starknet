def to_cairo_felt(short_string):
    utfted = short_string.encode("utf-8")
    hexed = utfted.hex()
    return int(hexed, 16)
