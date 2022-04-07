import pytest

from brownie import accounts, reverts
from brownie import Person

@pytest.fixture
def person():
    return accounts[0].deploy(Person, "Person", "pes")

def test_create_person(person):
    person.mint(accounts[1], {'from': accounts[0]})
    assert person.balanceOf(accounts[1]) == 1
    assert person.ownerOf(1) == accounts[1]
    person.setTokenURI(1, "uri", {'from': accounts[1]})
    assert person.tokenURI(1) == "uri"

def test_addr_owns_only_one(person):
    person.mint(accounts[1], {'from': accounts[0]})
    with reverts("The address already owns a token!"):
        person.mint(accounts[1], {'from': accounts[0]})

def test_only_owner_mint(person):
    with reverts("Ownable: caller is not the owner"):
        person.mint(accounts[1], {'from': accounts[1]})

def test_only_owner_burn(person):
    with reverts("Ownable: caller is not the owner"):
        person.burn(0, {'from': accounts[1]})