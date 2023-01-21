import pytest

from brownie import accounts, reverts
from brownie import Semester, University, CourseHelper, CourseCatalog
from brownie.network.contract import Contract

@pytest.fixture(scope="function")
def fixture():
    accounts[0].deploy(CourseHelper)
    university = accounts[0].deploy(University)
    university.createTeacher(accounts[1])
    university.createTeacher(accounts[2])
    university.createStudent(accounts[3])
    university.createStudent(accounts[4])
    university.createStudent(accounts[5])
    course_catalog = Contract.from_abi("CourseCatalog", university.courseCatalog(), CourseCatalog.abi)
    course_catalog.mint(5, {'from': accounts[1]})
    course_catalog.mint(4, {'from': accounts[2]})
    course_catalog.mint(3, {'from': accounts[1]})
    semester = accounts[0].deploy(Semester, "Semester", "ses", university.address, 1)
    return (university, semester)

def test_semester_default_functionality(fixture):
    _, semester = fixture
    # adds a course
    semester.addNewCourse(1, 10, {'from': accounts[0]})
    assert semester.balanceOf(accounts[1]) == 0
    # claims a place
    semester.setNextState({'from': accounts[0]})
    semester.applyForCourse(1, 1, 3, {'from': accounts[0]})
    semester.applyForCourse(1, 2, 4, {'from': accounts[0]})
    semester.setNextState({'from': accounts[0]})
    semester.claim(1, 1, {'from': accounts[3]})
    semester.claim(1, 2, {'from': accounts[4]})
    assert semester.balanceOf(accounts[3]) == 1
    # transfers a course
    semester.approve(accounts[0], 1, {'from': accounts[3]})
    semester.transferFrom(accounts[3], accounts[0], 1, {'from': accounts[0]})
    assert semester.balanceOf(accounts[0]) == 1
    assert semester.balanceOf(accounts[3]) == 0
    assert semester.balanceOf(accounts[4]) == 1
    # marks a student
    semester.setNextState({'from': accounts[0]})
    semester.markStudent(1, 5, {'from': accounts[0]})
    assert semester.marks(1) == 5

def test_mark_student(fixture):
    _, semester = fixture
    with reverts("Ownable: caller is not the owner"):
        semester.markStudent(1, 5, {'from': accounts[1]})
    with reverts("This is not the active state!"):
        semester.markStudent(1, 5, {'from': accounts[0]})
    semester.addNewCourse(1, 10, {'from': accounts[0]})
    semester.setNextState({'from': accounts[0]})
    semester.applyForCourse(1, 1, 3, {'from': accounts[0]})
    semester.setNextState({'from': accounts[0]})
    semester.claim(1, 1, {'from': accounts[3]})
    semester.setNextState({'from': accounts[0]})
    with reverts("ERC721: owner query for nonexistent token"):
        semester.markStudent(2, 5, {'from': accounts[0]})
    semester.markStudent(1, 5, {'from': accounts[0]})
    assert semester.marks(1) == 5

def test_next_state(fixture):
    _, semester = fixture
    for state in range(1,5):
        assert semester.currentState() == state
        semester.setNextState({'from': accounts[0]})
    assert semester.currentState() == 0
    with reverts("This semester has been already end!"):
        semester.setNextState({'from': accounts[0]})
    assert semester.currentState() == 0

def test_add_new_course(fixture):
    _, semester = fixture
    semester.addNewCourse(1, 10, {'from': accounts[0]})
    with reverts("This course is already added!"):
        semester.addNewCourse(1, 10, {'from': accounts[0]})
    with reverts("Ownable: caller is not the owner"):
        semester.addNewCourse(2, 10, {'from': accounts[2]})
    semester.setNextState({'from': accounts[0]})
    with reverts("This is not the planning state!"):
        semester.addNewCourse(2, 10, {'from': accounts[0]})

def test_apply_for_course(fixture):
    _, semester = fixture
    semester.addNewCourse(1, 2, {'from': accounts[0]})
    with reverts("This is not the applying state!"):
        semester.applyForCourse(1, 1, 3, {'from': accounts[0]})
    semester.setNextState({'from': accounts[0]})
    with reverts("There is no course with given id!"):
        semester.applyForCourse(2, 1, 3, {'from': accounts[0]})
    semester.applyForCourse(1, 1, 3, {'from': accounts[0]})

def test_limit_of_course(fixture):
    _, semester = fixture
    semester.addNewCourse(1, 2, {'from': accounts[0]})
    semester.setNextState({'from': accounts[0]})
    semester.applyForCourse(1, 1, 3, {'from': accounts[0]})
    semester.applyForCourse(1, 2, 4, {'from': accounts[0]})
    with reverts("Student has already applied for this course!"):
        semester.applyForCourse(1, 2, 3, {'from': accounts[0]})
    with reverts("The first index is too high to apply for this course!"):
        semester.applyForCourse(1, 3, 2, {'from': accounts[0]})
    semester.setNextState({'from': accounts[0]})
    semester.claim(1, 1, {'from': accounts[3]})
    semester.claim(1, 2, {'from': accounts[4]})
    assert semester.balanceOf(accounts[3]) == 1
    assert semester.balanceOf(accounts[4]) == 1

def test_claim(fixture):
    _, semester = fixture
    semester.addNewCourse(1, 2, {'from': accounts[0]})
    semester.setNextState({'from': accounts[0]})
    semester.applyForCourse(1, 1, 3, {'from': accounts[0]})
    with reverts("This is not the trading state!"):
        semester.claim(1, 1, {'from': accounts[3]})
    semester.setNextState({'from': accounts[0]})
    with reverts("You must be a student!"):
        semester.claim(1, 1, {'from': accounts[0]})
    with reverts("You are not the owner of this student token!"):
        semester.claim(1, 1, {'from': accounts[4]})
    with reverts("There is no course with this id!"):
        semester.claim(2, 1, {'from': accounts[3]})
    with reverts("You have no place in this course!"):
        semester.claim(1, 2, {'from': accounts[4]})
    semester.claim(1, 1, {'from': accounts[3]})
    with reverts("You have already claimed this course!"):
        semester.claim(1, 1, {'from': accounts[3]})
    assert semester.balanceOf(accounts[3]) == 1

def test_changing_in_tree(fixture):
    _, semester = fixture
    semester.addNewCourse(1, 2, {'from': accounts[0]})
    semester.setNextState({'from': accounts[0]})
    semester.applyForCourse(1, 1, 3, {'from': accounts[0]})
    semester.applyForCourse(1, 2, 4, {'from': accounts[0]})
    with reverts("The first index is too high to apply for this course!"):
        semester.applyForCourse(1, 3, 3, {'from': accounts[0]})
    semester.applyForCourse(1, 3, 5, {'from': accounts[0]})
    semester.applyForCourse(1, 1, 6, {'from': accounts[0]})
    semester.setNextState({'from': accounts[0]})
    semester.claim(1, 1, {'from': accounts[3]})
    semester.claim(1, 3, {'from': accounts[5]})
    with reverts("You have no place in this course!"):
        semester.claim(1, 2, {'from': accounts[4]})
    assert semester.balanceOf(accounts[3]) == 1
    assert semester.balanceOf(accounts[4]) == 0
    assert semester.balanceOf(accounts[5]) == 1

def test_more_courses(fixture):
    _, semester = fixture
    semester.addNewCourse(1, 1, {'from': accounts[0]})
    semester.addNewCourse(3, 1, {'from': accounts[0]})
    assert semester.balanceOf(accounts[1]) == 0
    semester.setNextState({'from': accounts[0]})
    semester.applyForCourse(1, 1, 3, {'from': accounts[0]})
    semester.applyForCourse(3, 1, 3, {'from': accounts[0]})
    semester.setNextState({'from': accounts[0]})
    semester.claim(1, 1, {'from': accounts[3]})
    semester.claim(3, 1, {'from': accounts[3]})
    assert semester.balanceOf(accounts[3]) == 2
    semester.setNextState({'from': accounts[0]})
    semester.markStudent(1, 5, {'from': accounts[0]})
    semester.markStudent(2, 3, {'from': accounts[0]})
    assert semester.marks(1) == 5
    assert semester.marks(2) == 3

def test_transfers(fixture):
    def trading_state_check():
        with reverts("This is not the trading state!"):
            semester.transferFrom(accounts[3], accounts[0], 1, {'from': accounts[0]})
        with reverts("This is not the trading state!"):
            semester.safeTransferFrom(accounts[3], accounts[0], 1, {'from': accounts[0]})
    _, semester = fixture
    semester.addNewCourse(1, 10, {'from': accounts[0]})
    trading_state_check()
    semester.setNextState({'from': accounts[0]})
    semester.applyForCourse(1, 1, 4, {'from': accounts[0]})
    trading_state_check()
    semester.setNextState({'from': accounts[0]})
    semester.claim(1, 1, {'from': accounts[3]})
    with reverts("Ownable: caller is not the owner"):
        semester.transferFrom(accounts[3], accounts[0], 1, {'from': accounts[3]})
    with reverts("Ownable: caller is not the owner"):
        semester.safeTransferFrom(accounts[3], accounts[0], 1, {'from': accounts[3]})
    semester.approve(accounts[0], 1, {'from': accounts[3]})
    semester.transferFrom(accounts[3], accounts[0], 1, {'from': accounts[0]})
    assert semester.balanceOf(accounts[0]) == 1
    assert semester.balanceOf(accounts[3]) == 0
    semester.setNextState({'from': accounts[0]})
    trading_state_check()