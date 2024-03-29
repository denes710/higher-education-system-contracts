import pytest

from brownie import accounts, reverts
from brownie import University, CourseCatalog, Person, Semester, Student, Degree
from brownie.network.contract import Contract
from brownie.convert import to_address

def test_create_teacher():
    university = accounts[0].deploy(University)
    university.createTeacher(accounts[1], {'from': accounts[0]})
    with reverts("The address already owns a token!"):
        university.createTeacher(accounts[1], {'from': accounts[0]})
    with reverts("Ownable: caller is not the owner"):
        university.createTeacher(accounts[2], {'from': accounts[2]})
    teacher = Contract.from_abi("Person", university.teacher(), Person.abi)
    assert teacher.balanceOf(accounts[1]) == 1
    university.createNewSemester({'from': accounts[0]})
    with reverts("This is not the off season state!"):
        university.createTeacher(accounts[2], {'from': accounts[0]})

def test_create_student():
    university = accounts[0].deploy(University)
    university.createStudent(accounts[1], {'from': accounts[0]})
    with reverts("The address already owns a token!"):
        university.createStudent(accounts[1], {'from': accounts[0]})
    with reverts("Ownable: caller is not the owner"):
        university.createStudent(accounts[2], {'from': accounts[2]})
    teacher = Contract.from_abi("Student", university.student(), Student.abi)
    assert teacher.balanceOf(accounts[1]) == 1
    university.createNewSemester({'from': accounts[0]})
    with reverts("This is not the off season state!"):
        university.createStudent(accounts[2], {'from': accounts[0]})

def test_create_new_semester():
    university = accounts[0].deploy(University)
    assert university.semesterId() == 0
    assert university.currentState() == 0
    university.createNewSemester({'from': accounts[0]})
    assert university.semesterId() == 1
    assert university.currentState() == 1
    semester = Contract.from_abi("Semester", university.semesters(university.semesterId()), Semester.abi)
    assert semester.currentState() == 1
    assert semester.semesterId() == 1

def test_set_next_state():
    university = accounts[0].deploy(University)
    university.createNewSemester({'from': accounts[0]})
    semester = Contract.from_abi("Semester", university.semesters(university.semesterId()), Semester.abi)
    for state in range(2, 5):
        university.setNextState({'from': accounts[0]})
        assert semester.currentState() == state
        assert university.currentState() == state
    university.setNextState({'from': accounts[0]})
    assert university.currentState() == 0
    assert semester.currentState() == 0
    with reverts("This semester has been already end!"):
        university.setNextState({'from': accounts[0]})
    university.createNewSemester({'from': accounts[0]})
    assert university.currentState() == 1
    university.setNextState({'from': accounts[0]})
    assert university.currentState() == 2

def test_add_my_course_next_semester():
    university = accounts[0].deploy(University)
    university.createTeacher(accounts[1])
    course_catalog = Contract.from_abi("CourseCatalog", university.courseCatalog(), CourseCatalog.abi)
    course_catalog.mint(5, {'from': accounts[1]})
    with reverts("You must be teacher!"):
        university.addMyCourseNextSemester(1, 2, {'from': accounts[2]})
    with reverts("This is not the planning state!"):
        university.addMyCourseNextSemester(1, 2, {'from': accounts[1]})
    university.createNewSemester({'from': accounts[0]})
    university.addMyCourseNextSemester(1, 2, {'from': accounts[1]})
    semester = Contract.from_abi("Semester", university.semesters(university.semesterId()), Semester.abi)
    university.setNextState({'from': accounts[0]})
    with reverts("This is not the planning state!"):
        university.addMyCourseNextSemester(1, 2, {'from': accounts[1]})

def test_apply_for_course():
    university = accounts[0].deploy(University)
    university.createTeacher(accounts[1])
    university.createStudent(accounts[2])
    university.createStudent(accounts[3])
    course_catalog = Contract.from_abi("CourseCatalog", university.courseCatalog(), CourseCatalog.abi)
    course_catalog.mint(5, {'from': accounts[1]})
    university.createNewSemester({'from': accounts[0]})
    university.addMyCourseNextSemester(1, 2, {'from': accounts[1]})
    with reverts("You must be a student!"):
        university.applyForCourse(1, 2, {'from': accounts[0]})
    with reverts("This is not the applying state!"):
        university.applyForCourse(1, 1, {'from': accounts[2]})
    university.setNextState({'from': accounts[0]})
    with reverts("You are not the owner this id!"):
        university.applyForCourse(1, 1, {'from': accounts[3]})
    university.applyForCourse(1, 1, {'from': accounts[2]})
    university.setNextState({'from': accounts[0]})
    semester = Contract.from_abi("Semester", university.semesters(university.semesterId()), Semester.abi)
    semester.claim(1, 1, {'from': accounts[2]})
    assert semester.balanceOf(accounts[2]) == 1

def test_mint_degree():
    university = accounts[0].deploy(University)
    university.createTeacher(accounts[1])
    university.createStudent(accounts[2])
    university.createStudent(accounts[3])
    course_catalog = Contract.from_abi("CourseCatalog", university.courseCatalog(), CourseCatalog.abi)
    course_catalog.mint(180, {'from': accounts[1]})
    with reverts("You do not have enough credits!"):
        university.mintDegree(1, {'from': accounts[2]})
    university.createNewSemester({'from': accounts[0]})
    university.addMyCourseNextSemester(1, 3, {'from': accounts[1]})
    university.setNextState({'from': accounts[0]})
    university.applyForCourse(1, 1, {'from': accounts[2]})
    university.setNextState({'from': accounts[0]})
    semester = Contract.from_abi("Semester", university.semesters(university.semesterId()), Semester.abi)
    semester.claim(1, 1, {'from': accounts[2]})
    university.setNextState({'from': accounts[0]})
    university.markStudent(1, 5, {'from': accounts[1]})
    university.setNextState({'from': accounts[0]})
    with reverts("Sender does not own the token!"):
        university.mintDegree(1, {'from': accounts[3]})
    university.mintDegree(1, {'from': accounts[2]})
    university.setHashDegree(1, 12345, {'from': accounts[0]})
    degree = Contract.from_abi("Degree", university.degree(), Degree.abi)
    assert degree.ownerOf(1) == accounts[2]
    assert degree.balanceOf(accounts[2]) == 1
    assert degree.hashValues(1) == 12345
