def create_main_test(source_path, import_path, output_path):
    with (
        open(import_path) as impfile,
        open(output_path, "w") as outfile,
        open(source_path) as infile,
    ):
        outfile.write(impfile.read())
        outfile.write("\n")
        for line in infile:
            if line == "%lang starknet\n":
                break
        outfile.write(infile.read())


def str_to_felt(text):
    b_text = bytes(text, "ascii")
    return int.from_bytes(b_text, "big")


def felt_to_str(felt):
    b_felt = felt.to_bytes(31, "big")
    return b_felt.decode()


def to_uint(a):
    """Takes in value, returns uint256-ish tuple."""
    return (a & ((1 << 128) - 1), a >> 128)


def from_uint(uint):
    """Takes in uint256-ish tuple, returns value."""
    return uint[0] + (uint[1] << 128)


# async def assert_revert(fun, reverted_with=None):
#     try:
#         await fun
#         assert False
#     except StarkException as err:
#         _, error = err.args
#         if reverted_with is not None:
#             assert reverted_with in error['message']
#
#
# async def assert_revert_entry_point(fun, invalid_selector):
#     selector_hex = hex(get_selector_from_name(invalid_selector))
#     entry_point_msg = f"Entry point {selector_hex} not found in contract"
#
#     await assert_revert(fun, entry_point_msg)
#
#
# def assert_event_emitted(tx_exec_info, from_address, name, data, order=0):
#     """Assert one single event is fired with correct data."""
#     assert_events_emitted(tx_exec_info, [(order, from_address, name, data)])
#
#
# def assert_events_emitted(tx_exec_info, events):
#     """Assert events are fired with correct data."""
#     for event in events:
#         order, from_address, name, data = event
#         event_obj = OrderedEvent(
#             order=order,
#             keys=[get_selector_from_name(name)],
#             data=data,
#         )
#
#         base = tx_exec_info.call_info.internal_calls[0]
#         if event_obj in base.events and from_address == base.contract_address:
#             return
#
#         try:
#             base2 = base.internal_calls[0]
#             if event_obj in base2.events and from_address == base2.contract_address:
#                 return
#         except IndexError:
#             pass
#
#         raise BaseException("Event not fired or not fired correctly")
