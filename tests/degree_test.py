import pytest

from brownie import accounts, reverts
from brownie import Degree

@pytest.fixture
def degree():
    return accounts[0].deploy(Degree, "Degree", "deg")

def test_create_degree(degree):
    degree.mint(accounts[1], 250, 180, {'from': accounts[0]})
    assert degree.balanceOf(accounts[1]) == 1
    assert degree.ownerOf(1) == accounts[1]
    degree.setTokenURI(1, "uri", {'from': accounts[1]})
    assert degree.tokenURI(1) == "uri"
    credit_value = degree.creditValues(1)
    assert credit_value == 14333