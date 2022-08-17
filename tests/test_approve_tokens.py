import pytest




@pytest.mark.asyncio
async def test_not_member(contract):
    # given the caller is not a member, when invoking submitApproveToken for any token address, should fail
    caller_address = 404 # not a member
    token_address = 123
    with pytest.raises(Exception):
        await contract.submitApproveToken(tokenAddress=token_address).invoke(caller_address=caller_address)


@pytest.mark.asyncio
async def test_not_admin(contract):
    # given the caller is not admin, when invoking submitApproveToken for any token address, should fail
    caller_address = 3 # not admin
    token_address = 123
    with pytest.raises(Exception):
        await contract.submitApproveToken(tokenAddress=token_address).invoke(caller_address=caller_address)

@pytest.mark.asyncio
async def test_already_whitelisted(contract):
    # given token is already whitelisted, when invoking submitApproveToken for that token, should fail
    caller_address = 42 # admin
    token_address = 404 # a non whitelisted token
    with pytest.raises(Exception):
        await contract.submitApproveToken(tokenAddress=token_address).invoke(caller_address=caller_address)

@pytest.mark.xfail
@pytest.mark.asyncio
async def test_not_ERCs(contract):
    # given the token is not an ERC20 or ERC721, when invoking submitApproveToken for that token's address, should fail
    #TODO complete this test
    caller_address = 42 # admin
    token_address = 123
    with pytest.raises(Exception):
        await contract.submitApproveToken(tokenAddress=token_address).invoke(caller_address=caller_address)


@pytest.mark.asyncio
async def test_submit_token(contract):
    # given the above passed, when invoking submitApproveToken, should add proposal and succeed
    caller_address = 42 # admin
    token_address = 123 # a whitelisted token

    number_before_submit = (await contract.get_proposals_length().call(caller_address=caller_address)).result.length
    return_value = await contract.submitApproveToken(tokenAddress=token_address).invoke(caller_address=caller_address)
    assert return_value.result.success == 1

    number_after_submit = (await contract.get_proposals_length().call(caller_address=caller_address)).result.length

    #Check if the proposal was taken into account 
    assert number_after_submit == number_before_submit + 1
    


