from brownie import CourseHelper, University, accounts

def main():
    account = accounts.load('deployment_account')
    CourseHelper.deploy({'from': account})
    University.deploy({'from': account})