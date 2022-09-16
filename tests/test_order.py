import pytest



@pytest.mark.asyncio
async def test_caller_not_member(contract):
    caller_address = 404 # not existing member
    with pytest.raises(Exception):
        await contract.submitOrder().invoke(caller_address=caller_address)

@pytest.mark.asyncio
async def test_caller_not_govern(contract):
    caller_address = 1 # existing but not govern member
    with pytest.raises(Exception):
        await contract.submitOrder().invoke(caller_address=caller_address)

@pytest.mark.asyncio
async def test_submitOrder(contract):
    caller_address = 3 # existing and govern member

    number_before_submit = (await contract.get_proposals_length().call(caller_address=caller_address)).result.length

    return_value = await contract.submitOrder().invoke(caller_address=caller_address)
    assert return_value.result.success == 1
    
    number_after_submit = (await contract.get_proposals_length().call(caller_address=caller_address)).result.length

    #Check if the proposal was taken into account 
    assert number_after_submit == number_before_submit + 1