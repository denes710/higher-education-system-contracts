import pytest

from brownie import accounts, reverts
from brownie import Student

@pytest.fixture
def student():
    return accounts[0].deploy(Student, "Student", "stu")

def test_create_student(student):
    student.mint(accounts[1], {'from': accounts[0]})
    assert student.balanceOf(accounts[1]) == 1
    student.setTokenURI(1, "uri", {'from': accounts[1]})
    assert student.tokenURI(1) == "uri"
    student.addMark(5, 10, 1, {'from': accounts[0]})
    student_info = student.students(1)
    assert student_info[0] == 10
    assert student_info[1] == 5
    student.addMark(4, 11, 1, {'from': accounts[0]})
    student_info = student.students(1)
    assert student_info[0] == 21
    assert student_info[1] == 9

def test_mint(student):
    student.mint(accounts[1], {'from': accounts[0]})
    with reverts("The address already owns a token!"):
        student.mint(accounts[1], {'from': accounts[0]})
    with reverts("Ownable: caller is not the owner"):
        student.mint(accounts[1], {'from': accounts[1]})

def test_add_mark(student):
    with reverts("Ownable: caller is not the owner"):
        student.addMark(5, 10, 1, {'from': accounts[1]})
    with reverts("There is no student with this id!"):
        student.addMark(5, 10, 1, {'from': accounts[0]})