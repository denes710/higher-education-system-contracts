import pytest

from brownie import accounts, reverts
from brownie import CourseCatalog, University, CourseHelper

@pytest.fixture(scope="function")
def fixture():
    accounts[0].deploy(CourseHelper)
    university = accounts[0].deploy(University)
    university.createTeacher(accounts[1])
    university.createTeacher(accounts[2])
    course_catalog = accounts[0].deploy(CourseCatalog, "CourseCatalog", "coc", university.address)
    return (university, course_catalog)

def test_create_course(fixture):
    _, course_catalog = fixture
    course_catalog.mint(5, {'from': accounts[1]})
    course_catalog.setTokenURI(1, "uri", {'from': accounts[1]})
    assert course_catalog.balanceOf(accounts[1]) == 1
    assert course_catalog.ownerOf(1) == accounts[1]
    assert course_catalog.tokenURI(1) == "uri"
    assert course_catalog.creditValues(1) == 5
    course_catalog.mint(8, {'from': accounts[2]})
    course_catalog.setTokenURI(2, "uri", {'from': accounts[2]})
    assert course_catalog.balanceOf(accounts[2]) == 1
    assert course_catalog.ownerOf(2) == accounts[2]
    assert course_catalog.tokenURI(2) == "uri"
    assert course_catalog.creditValues(2) == 8

def test_only_off_season(fixture):
    university, course_catalog = fixture
    university.createNewSemester({'from': accounts[0]})
    with reverts("Course catalog is not in the off season!"):
        course_catalog.burn(0, {'from': accounts[1]})
    with reverts("Course catalog is not in the off season!"):
        course_catalog.mint(0, {'from': accounts[1]})

def test_only_modifiable(fixture):
    university, course_catalog = fixture
    course_catalog.mint(5, {'from': accounts[1]})
    university.createNewSemester({'from': accounts[0]})

    university.setNextState({'from': accounts[0]})
    with reverts("Course catalog cannot be modified in the current state!"):
        course_catalog.setTokenURI(1, "uri", {'from': accounts[1]})

    university.setNextState({'from': accounts[0]})
    with reverts("Course catalog cannot be modified in the current state!"):
        course_catalog.setTokenURI(1, "uri", {'from': accounts[1]})

    university.setNextState({'from': accounts[0]})
    with reverts("Course catalog cannot be modified in the current state!"):
        course_catalog.setTokenURI(1, "uri", {'from': accounts[1]})

    university.setNextState({'from': accounts[0]})
    course_catalog.setTokenURI(1, "uri", {'from': accounts[1]})

def test_only_teacher_create_course(fixture):
    _, course_catalog = fixture
    with reverts("Only teacher can mint a course!"):
        course_catalog.mint(5, {'from': accounts[3]})

def test_only_owner_burn_course(fixture):
    _, course_catalog = fixture
    course_catalog.mint(5, {'from': accounts[1]})
    with reverts("Sender is not the owner!"):
        course_catalog.burn(1, {'from': accounts[2]})