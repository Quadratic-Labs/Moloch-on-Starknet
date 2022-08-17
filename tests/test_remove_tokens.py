import pytest




@pytest.mark.asyncio
async def test_not_member(contract):
    # given the caller is not a member, when invoking submitRemoveToken for any token address, should fail
    caller_address = 404 # not a member
    token_address = 123
    with pytest.raises(Exception):
        await contract.submitRemoveToken(tokenAddress=token_address).invoke(caller_address=caller_address)


@pytest.mark.asyncio
async def test_not_admin(contract):
    # given the caller is not admin, when invoking submitRemoveToken for any token address, should fail
    caller_address = 3 # not admin
    token_address = 123
    with pytest.raises(Exception):
        await contract.submitRemoveToken(tokenAddress=token_address).invoke(caller_address=caller_address)

@pytest.mark.asyncio
async def test_not_whitelisted(contract):
    # given token is not whitelisted, when invoking submitRemoveToken for that token, should fail
    caller_address = 42 # admin
    token_address = 404 # a non whitelisted token
    with pytest.raises(Exception):
        await contract.submitRemoveToken(tokenAddress=token_address).invoke(caller_address=caller_address)


@pytest.mark.asyncio
async def test_submit_token(contract):
    # given the above passed, when invoking submitRemoveToken, should add proposal and succeed
    caller_address = 42 # admin
    token_address = 123 # a whitelisted token

    number_before_submit = (await contract.get_proposals_length().call(caller_address=caller_address)).result.length
    return_value = await contract.submitRemoveToken(tokenAddress=token_address).invoke(caller_address=caller_address)
    assert return_value.result.success == 1

    number_after_submit = (await contract.get_proposals_length().call(caller_address=caller_address)).result.length

    #Check if the proposal was taken into account 
    assert number_after_submit == number_before_submit + 1
    


